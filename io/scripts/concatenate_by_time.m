function [ data_combined ] = concatenate_by_time( data1, data2 )
%CONCATENATE_BY_TIME Summary of this function goes here
%   Detailed explanation goes here

data_fields = fieldnames(data1);
l = length(data_fields);
data_combined = struct;
for fieldnum = 1:l
    fieldname = data_fields{fieldnum};
    fieldval = getfield(data1, fieldname);
    if      strcmp(fieldname,'plev') ||...
            strcmp(fieldname,'units') ||...
            strcmp(fieldname,'lat') ||...
            strcmp(fieldname,'lat_bnds') ||...
            strcmp(fieldname,'lon') ||...
            strcmp(fieldname,'lon_bnds')
                data_combined = setfield(data_combined, fieldname, fieldval);
    elseif  strcmp(fieldname, 'time')
                fieldval2 = getfield(data2, fieldname);
                data_combined = setfield(data_combined, fieldname, [fieldval; fieldval2]);
    elseif  strcmp(fieldname, 'time_bnds')
                fieldval2 = getfield(data2, fieldname);
                data_combined = setfield(data_combined, fieldname, [fieldval, fieldval2]);
    else
                fieldval2 = getfield(data2, fieldname);
                if length(size(fieldval)) == 4
                    data_combined = setfield(data_combined, fieldname, cat(4, fieldval, fieldval2));
                else
                    data_combined = setfield(data_combined, fieldname, cat(3, fieldval, fieldval2));
                end
    end
end

end