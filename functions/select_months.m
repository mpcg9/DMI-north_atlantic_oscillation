function [ data_subset ] = select_months( data, months )
%SELECT_MONTHS Use this function to select months from monthly data
%   use like this: subset = select_months(data, [1 1 0 0 0 0  0 0 0 0 0 1])
%   (for selecting data from january, february, and december).
%   currently only works when the first month is a january and the last
%   month is a december.

time_length = length(data.time);
assert(mod(time_length, 12) == 0);
num_years = time_length/12;
time_idx = repmat(months, 1, num_years);

% copy data
data_fields = fieldnames(data);
l = length(data_fields);
data_subset = struct;
for fieldnum = 1:l
    fieldname = data_fields{fieldnum};
    fieldval = getfield(data, fieldname);
    if      strcmp(fieldname,'plev') ||...
            strcmp(fieldname,'units') ||...
            strcmp(fieldname,'lat') ||...
            strcmp(fieldname,'lat_bnds') ||...
            strcmp(fieldname,'lon') ||...
            strcmp(fieldname,'lon_bnds')
                data_subset = setfield(data_subset, fieldname, fieldval);
    elseif  strcmp(fieldname, 'time')
                data_subset = setfield(data_subset, fieldname, fieldval(time_idx));
    elseif  strcmp(fieldname, 'time_bnds')
                data_subset = setfield(data_subset, fieldname, fieldval(:,time_idx));
    else
                if length(size(fieldval)) == 4
                    data_subset = setfield(data_subset, fieldname, fieldval(:, :, :, time_idx));
                else
                    data_subset = setfield(data_subset, fieldname, fieldval(:, :, time_idx));
                end
    end
end

end

