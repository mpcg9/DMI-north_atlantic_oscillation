function [ data ] = readNetCDF2_new( filename, varargin )
% Reads netCDF Version 3 and 4 files in Matlab
%
% INPUT: filename ... filename including path
%
% OUTPUT: data ... struct with netCDF data
%
% Note: All scale factors, add_offsets etc. will be applied so the
% resulting data should have the units decribed in the "units" cell array
% which is included inside the data struct.
%
% original: Uebbing 06/2016
% this version: Sauerland 08/2019

ncid = netcdf.open(filename, 'NC_NOWRITE'); % oeffnen der Datei

%% Treat name-value pairs
options = struct(...  % setting defaults...
    'Longitudes',false,...
    'Latitudes', false,...
    'Plev', 0 ...
    );

% read the acceptable names
optionNames = fieldnames(options);

% count arguments
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
   error('EXAMPLE needs propertyName/propertyValue pairs')
end

for pair = reshape(varargin,2,[]) % pair is {propName;propValue}
   inpName = pair{1}; 
   if any(strcmp(inpName,optionNames))
      % overwrite options. 
      options.(inpName) = pair{2};
   else
      error('%s is not a recognized parameter name',inpName)
   end
end
   
% get overview over variables
[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

%% Apply Longitude and Latitude Boundaries

% read lat/lon + bounds
restrict_lon = length(options.Longitudes) > 1;
restrict_lat = length(options.Latitudes) > 1;
restrict_plev= options.Plev ~= 0;
if restrict_lon || restrict_lat
    if restrict_lon
        bnds_lon_exist = false;
        
        % wrap longitude around 360 degrees
        options.Longitudes(1) = mod(options.Longitudes(1), 360);
        options.Longitudes(2) = mod(options.Longitudes(2), 360);
    end
    if restrict_lat
        bnds_lat_exist = false;
    end
    for j = 0:nvars-1
        [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,j);
        if restrict_lon && (strcmp(varname, 'lon') || strcmp(varname, 'longitude'))
            lon = double(netcdf.getVar(ncid, j));
        elseif restrict_lon && (strcmp(varname, 'lon_bnds') || strcmp(varname, 'lon_bounds'))
            bnds_lon_exist = true;
            lon_bnds = double(netcdf.getVar(ncid, j));
        elseif restrict_lon && (strcmp(varname, 'lat') || strcmp(varname, 'latitude'))
            lat = double(netcdf.getVar(ncid, j));
        elseif restrict_lon && (strcmp(varname, 'lat_bnds') || strcmp(varname, 'lat_bounds'))
            bnds_lat_exist = true;
            lat_bnds = double(netcdf.getVar(ncid, j));
        end
    end
    
    % find out valid indices
    if restrict_lon
        if bnds_lon_exist
            if options.Longitudes(2) > options.Longitudes(1)
                lon_idx = options.Longitudes(1) < lon_bnds(2,:) & options.Longitudes(2) > lon_bnds(1,:);
            elseif options.Longitudes(1) > options.Longitudes(2)
                lon_idx = options.Longitudes(1) < lon_bnds(2,:) | options.Longitudes(2) > lon_bnds(1,:);
            else
                lon_idx = true(size(lon));
            end
        else
            if options.Longitudes(2) > options.Longitudes(1)
                lon_idx = options.Longitudes(1) <= lon & options.Longitudes(2) >= lon;
            elseif options.Longitudes(1) > options.Longitudes(2)
                lon_idx = options.Longitudes(1) <= lon | options.Longitudes(2) >= lon;
            else
                lon_idx = true(size(lon));
            end
        end
    end
    if restrict_lat
        if bnds_lat_exist
            lat_idx = options.Latitudes(1) < lat_bnds(2,:) & options.Latitudes(2) > lat_bnds(1,:);
        else
            lat_idx = options.Latitudes(1) <= lat & options.Latitudes(2) >= lat;
        end
    end
    
    % convert into start/stride values
    if restrict_lon
        idx = find(lon_idx == 1);
        interruptions = find(diff(idx) ~= 1);
        length_first_stride = interruptions(1);
        stride_in_between_lengths = diff(interruptions);
        length_last_stride = length(idx) - length_first_stride + sum(stride_in_between_lengths);
        start_lon = [idx(1) idx(interruptions+1)];
        stride_lon= [length_first_stride, stride_in_between_lengths, length_last_stride];
    end
    if restrict_lat
        idx = find(lat_idx == 1);
        start_lat = idx(1);
        stride_lat= length(idx);
    end
    starts = cell(length(start_lon), 1);
    strides= cell(length(start_lon), 1);
end

%% Read data
for j=0:nvars-1
    [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,j);
    
    % Check dimensions if there is something to restrict
    cat_necessary = false;
    reduce_plev_dim = false;
    if restrict_lon || restrict_lat
        for s = 1:length(starts)
            starts{s} = ones(1, length(dimids));
            strides{s}= Inf(1, length(dimids));
        end
        for k = 1:length(dimids)
            dim = netcdf.inqDim(ncid, dimids(k));
            if restrict_lat && (strcmp(dim, 'lat') || strcmp(dim, 'latitude'))
                for s = 1:length(starts)
                    starts{s}(k) = start_lat;
                    strides{s}(k)= stride_lat;
                end
            elseif restrict_lon && (strcmp(dim, 'lon') || strcmp(dim, 'longitude'))
                cat_lon_dim = k;
                cat_necessary = length(starts) > 1;
                for s = 1:length(starts)
                    starts{s}(k) = start_lon(s);
                    strides{s}(k)= stride_lon(s);
                end
            elseif restrict_plev && (strcmp(dim, 'plev'))
                reduce_plev_dim = length(dimids) == 4;
                for s = 1:length(starts)
                    starts{s}(k) = options.Plev;
                    strides{s}(k)= 1;
                end
            end
        end
        if cat_necessary
            data.(varname) = cell(length(starts), 1);
            for s = 1:length(starts)
                data.(varname){s} = double(ncread(filename, varname, starts{s}, strides{s}));
            end
            data.(varname) = cat(cat_lon_dim, data.(varname){:});
        else
            data.(varname) = double(ncread(filename, varname, starts{1}, strides{1}));
        end
        if reduce_plev_dim
            dataSize = size(data.(varname));
            data.(varname) = reshape(data.(varname), dataSize(1), dataSize(2), dataSize(4));
        end
    else
        data.(varname) = double(netcdf.getVar(ncid, j)); % einlesen der daten
    end
    
    scaleFac = 1;
    addOff=0;
    fillVal=NaN;
    for k=0:natts-1
        attname = netcdf.inqAttName(ncid,j,k);
        switch attname
            
            case 'scale_factor'
                scaleFac = netcdf.getAtt(ncid,j,'scale_factor');  % Scaling factor
            case 'add_offset'
                addOff = netcdf.getAtt(ncid,j,'add_offset'); % Additionskonstante
            case '_FillValue'
                fillVal = netcdf.getAtt(ncid,j,'_FillValue'); % Fillvalue (NaN)
            case 'units'
                units.(varname) = netcdf.getAtt(ncid,j,'units'); % Einheit
            otherwise
                %nix
                
        end
        
    end
    
    % Transformieren der Daten in richtige Einheit
    if (isnan(fillVal)==0)
        data.(varname)(data.(varname)==fillVal)=NaN;
    end
    data.(varname) = data.(varname)*double(scaleFac) + double(addOff);
    
%     data.(varname)=adat;
    
end

data.units = units;
netcdf.close(ncid);
end

