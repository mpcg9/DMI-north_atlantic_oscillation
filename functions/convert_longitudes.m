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

data_fields = fieldnames(data);
for i = 1:length(data_fields)
    if strcmp(data_fields{i},'lon') ||...
       strcmp(data_fields{i},'longitude')
        lonname = data_fields{i};
    end
end         

lon_max = lon_min + 360;
data.(lonname) = mod(data.(lonname), 360);

too_large = data.(lonname) >= lon_max;
while nnz(too_large > 0)
    data.(lonname)(too_large) = data.(lonname)(too_large) - 360;
    too_large = data.(lonname) >= lon_max;
end
too_small = data.(lonname) < lon_min;
while nnz(too_small > 0)
    data.(lonname)(too_small) = data.(lonname)(too_small) + 360;
    too_small = data.(lonname) < lon_min;
end

[data.(lonname), lon_idx] = sort(data.(lonname));

data_fields = fieldnames(data);
l = length(data_fields);
data_converted = struct;
for fieldnum = 1:l
    fieldname = data_fields{fieldnum};
    if      strcmp(fieldname,'time') ||...
            strcmp(fieldname,'time_bnds') ||...
            strcmp(fieldname,'time_bounds') ||...
            strcmp(fieldname,'plev') ||...
            strcmp(fieldname,'units') ||...
            strcmp(fieldname,'lat') ||...
            strcmp(fieldname,'latitude') ||...
            strcmp(fieldname,'lat_bnds') ||...
            strcmp(fieldname,'lat_bounds') ||...
            strcmpi(fieldname,'bounds') ||...
            strcmpi(fieldname,'bnds')
            strcmp(fieldname, lonname) % This looks weird, but lon is already sorted above!
                data_converted.(fieldname) = data.(fieldname);
    elseif  strcmp(fieldname,'lon_bnds') ||...
            strcmp(fieldname,'lon_bounds')
                data_converted.(fieldname) = data.(fieldname)(:,lon_idx);
    else
                data_converted.(fieldname) = data.(fieldname)(lon_idx, :, :, :);
    end
end

end

