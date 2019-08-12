function [ data_output ] = sort_by_time( data )
%SORT_BY_TIME Summary of this function goes here
%   Detailed explanation goes here

[data.time, time_idx] = sort(data.time);

% copy data
if nnz(time_idx' ~= 1:length(data.time)) > 0
    data_fields = fieldnames(data);
    l = length(data_fields);
    data_output = struct;
    for fieldnum = 1:l
        fieldname = data_fields{fieldnum};
        fieldval = getfield(data, fieldname);
        if      strcmp(fieldname,'plev') ||...
                strcmp(fieldname,'units') ||...
                strcmp(fieldname,'lat') ||...
                strcmp(fieldname,'lat_bnds') ||...
                strcmp(fieldname,'lon') ||...
                strcmp(fieldname,'lon_bnds')
                    data_output = setfield(data_output, fieldname, fieldval);
        elseif  strcmp(fieldname, 'time')
                    data_output = setfield(data_output, fieldname, fieldval(time_idx));
        elseif  strcmp(fieldname, 'time_bnds')
                    data_output = setfield(data_output, fieldname, fieldval(:,time_idx));
        else
                    if length(size(fieldval)) == 4
                        data_output = setfield(data_output, fieldname, fieldval(:, :, :, time_idx));
                    else
                        data_output = setfield(data_output, fieldname, fieldval(:, :, time_idx));
                    end
        end
    end
else
    disp('data already sorted, skipping...');
    data_output = data;
end
end

