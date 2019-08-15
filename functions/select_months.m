function [ data_subset ] = select_months( data, months )
%SELECT_MONTHS Use this function to select months from monthly data
%   use like this: subset = select_months(data, [1 1 0 0 0 0  0 0 0 0 0 1])
%   (for selecting data from january, february, and december).
%   currently only works when the first month is a january and the last
%   month is a december.

time_length = length(data.time);
assert(mod(time_length, 12) == 0);
assert(length(months) == 12);
num_years = time_length/12;
time_idx = repmat(logical(months), 1, num_years);

% copy data
data_fields = fieldnames(data);
l = length(data_fields);
data_subset = struct;
for fieldnum = 1:l
    fieldname = data_fields{fieldnum};
    if      strcmp(fieldname,'plev') ||...
            strcmp(fieldname,'units') ||...
            strcmp(fieldname,'lat') ||...
            strcmp(fieldname,'latitude') ||...
            strcmp(fieldname,'lat_bnds') ||...
            strcmp(fieldname,'lat_bounds') ||...
            strcmp(fieldname,'lon') ||...
            strcmp(fieldname,'longitude') ||...
            strcmp(fieldname,'lon_bnds') ||...
            strcmp(fieldname,'lon_bounds')
                data_subset.(fieldname) = data.(fieldname);
    elseif  strcmp(fieldname, 'time')
                data_subset.(fieldname) = data.(fieldname)(time_idx);
    elseif  strcmp(fieldname, 'time_bnds') ||...
            strcmp(fieldname, 'time_bounds')
                data_subset.(fieldname) = data.(fieldname)(:,time_idx);
    else
                if length(size(data.(fieldname))) == 4
                    data_subset.(fieldname) = data.(fieldname)(:, :, :, time_idx);
                else
                    data_subset.(fieldname) = data.(fieldname)(:, :, time_idx);
                end
    end
end

end

