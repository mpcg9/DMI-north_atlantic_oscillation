function [ data_converted, lon_idx] = convert_longitudes( data, lon_min )
%CONVERT_LONGITUDES Changes the range of longitudes
%   This method wraps longitudes to a certain range. lon_min defines the
%   easternmost coordinate possible before wrapping back to coordinates
%   west (e.g. if lon_min is set to -90, all resulting coordinates will lie
%   in a range of [-90 270)).
%
%   If you want to do multiple conversions using the same grid, you can use
%   lon_idx to do so more efficiently (e.g. you can use
%   this_is_some_data(lon_idx, :, :, :) together with the output longitudes
%   of this function).

lon_max = lon_min + 360;
data.lon = mod(data.lon, 360);

too_large = data.lon >= lon_max;
while nnz(too_large > 0)
    data.lon(too_large) = data.lon(too_large) - 360;
    too_large = data.lon >= lon_max;
end
too_small = data.lon < lon_min;
while nnz(too_small > 0)
    data.lon(too_small) = data.lon(too_small) + 360;
    too_small = data.lon < lon_min;
end

[data.lon, lon_idx] = sort(data.lon);

data_fields = fieldnames(data);
l = length(data_fields);
data_converted = struct;
for fieldnum = 1:l
    fieldname = data_fields{fieldnum};
    fieldval = getfield(data, fieldname);
    if      strcmp(fieldname,'time') ||...
            strcmp(fieldname,'time_bnds') ||...
            strcmp(fieldname,'time_bounds') ||...
            strcmp(fieldname,'plev') ||...
            strcmp(fieldname,'units') ||...
            strcmp(fieldname,'lat') ||...
            strcmp(fieldname,'lat_bnds') ||...
            strcmp(fieldname,'lon') % This looks weird, but lon is already sorted above!
                data_converted = setfield(data_converted, fieldname, fieldval);
    elseif  strcmp(fieldname,'lon_bnds')
                data_converted = setfield(data_converted, fieldname, fieldval(:,lon_idx));
    else
                data_converted = setfield(data_converted, fieldname, fieldval(lon_idx, :, :, :));
    end
end

end

