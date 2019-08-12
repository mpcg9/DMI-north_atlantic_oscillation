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

% Find out the indices of the subset
if isfield(data, 'lon_bnds') && isfield(data, 'lat_bnds')
    if lon_max > lon_min
        lon_idx = lon_min < data.lon_bnds(2,:) & lon_max > data.lon_bnds(1,:);
    elseif lon_max < lon_min
        lon_idx = lon_min < data.lon_bnds(2,:) | lon_max > data.lon_bnds(1,:);
    else
        lon_idx = true(size(data.lon));
    end
    lat_idx = lat_min <= data.lat_bnds(2,:) & lat_max >= data.lat_bnds(1,:);
else % CNRM data is weird
    if lon_max > lon_min
        lon_idx = lon_min < data.lon & lon_max > data.lon;
    elseif lon_max < lon_min
        lon_idx = lon_min < data.lon | lon_max > data.lon;
    else
        lon_idx = true(size(data.lon));
    end
    lat_idx = lat_min <= data.lat & lat_max >= data.lat;
end

% copy data
data_fields = fieldnames(data);
l = length(data_fields);
data_subset = struct;
for fieldnum = 1:l
    fieldname = data_fields{fieldnum};
    fieldval = getfield(data, fieldname);
    if      strcmp(fieldname,'time') ||...
            strcmp(fieldname,'time_bnds') ||...
            strcmp(fieldname,'time_bounds') ||...
            strcmp(fieldname,'plev') ||...
            strcmp(fieldname,'units') ||...
                data_subset = setfield(data_subset, fieldname, fieldval);
    elseif  strcmp(fieldname,'lat')
                data_subset = setfield(data_subset, fieldname, fieldval(lat_idx));
    elseif  strcmp(fieldname,'lat_bnds') ||...
            strcmp(fieldname,'lat_bounds')
                data_subset = setfield(data_subset, fieldname, fieldval(:,lat_idx));
    elseif  strcmp(fieldname,'lon')
                data_subset = setfield(data_subset, fieldname, fieldval(lon_idx));
    elseif  strcmp(fieldname,'lon_bnds') ||...
            strcmp(fieldname,'lon_bounds')
                data_subset = setfield(data_subset, fieldname, fieldval(:,lon_idx));
    else
                data_subset = setfield(data_subset, fieldname, fieldval(lon_idx, lat_idx, :, :));
    end
end
end

