function [ data_subset ] = select_subset( data, lat_min, lat_max, lon_min, lon_max)
%SELECT_SUBSET Select a certain portion of the variables
%   This function returns a subset of climate data which is defined by
%   lat_max; lat_min; lon_min; lon_max (in degrees north or east).
%
%   lon_min and lon_max may be left out if not required.
%   lat_min and lat_max have to be in a range [-90, 90]

if nargin == 3
    lon_min = 0;
    lon_max = 360;
end

% wrap longitude around 360 degrees
lon_min = mod(lon_min, 360);
lon_max = mod(lon_max, 360);

% Find out which variables exist
data_fields = fieldnames(data);
bnds_lon_exist = false;
bnds_lat_exist = false;
for i = 1:length(data_fields)
    if strcmp(data_fields{i},'lon') ||...
            strcmp(data_fields{i},'longitude')
        lonname = data_fields{i};
    elseif strcmp(data_fields{i},'lat') ||...
            strcmp(data_fields{i},'latitude')
        latname = data_fields{i};
    elseif strcmp(data_fields{i}, 'lon_bnds') ||...
            strcmp(data_fields{i}, 'lon_bounds')
        bnds_lon_exist = true;
        lonbndsname = data_fields{i};
    elseif strcmp(data_fields{i}, 'lat_bnds') ||...
            strcmp(data_fields{i}, 'lat_bounds')
        bnds_lat_exist = true;
        latbndsname = data_fields{i};
    end
end

% Find out the indices of the subset
% longitude
if bnds_lon_exist
    if lon_max > lon_min
        lon_idx = lon_min < data.(lonbndsname)(2,:) & lon_max > data.(lonbndsname)(1,:);
    elseif lon_max < lon_min
        lon_idx = lon_min < data.(lonbndsname)(2,:) | lon_max > data.(lonbndsname)(1,:);
    else
        lon_idx = true(size(data.(lonname)));
    end
else
    if lon_max > lon_min
        lon_idx = lon_min < data.(lonname) & lon_max > data.(lonname);
    elseif lon_max < lon_min
        lon_idx = lon_min < data.(lonname) | lon_max > data.(lonname);
    else
        lon_idx = true(size(data.(lonname)));
    end
end
% latitude
if bnds_lat_exist   
    lat_idx = lat_min <= data.(latbndsname)(2,:) & lat_max >= data.(latbndsname)(1,:);
else
    lat_idx = lat_min <= data.(latname) & lat_max >= data.(latname);
end

% copy data
data_fields = fieldnames(data);
l = length(data_fields);
data_subset = struct;
for fieldnum = 1:l
    fieldname = data_fields{fieldnum};
    if      strcmpi(fieldname,'time') ||...
            strcmpi(fieldname,'time_bnds') ||...
            strcmpi(fieldname,'time_bounds') ||...
            strcmpi(fieldname,'plev') ||...
            strcmpi(fieldname,'units') ||...
            strcmpi(fieldname,'bnds') || ...
            strcmpi(fieldname,'bounds')
                data_subset.(fieldname) = data.(fieldname);
    elseif  strcmp(fieldname, latname)
                data_subset.(fieldname) = data.(fieldname)(lat_idx);
    elseif  bnds_lat_exist && strcmp(fieldname, latbndsname)
                data_subset.(fieldname) = data.(fieldname)(:,lat_idx);
    elseif  strcmp(fieldname, lonname)
                data_subset.(fieldname) = data.(fieldname)(lon_idx);
    elseif  bnds_lon_exist && strcmp(fieldname, lonbndsname)
                data_subset.(fieldname) = data.(fieldname)(:,lon_idx);
    else
                data_subset.(fieldname) = data.(fieldname)(lon_idx, lat_idx, :, :);
    end
end
end

