function [dataRegridded] = regridData(dataFrom, dataTo, interpMethod)

if nargin < 3
    interpMethod = 'cubic';
end

% find lat/lon variable names in 'from' data
data_fields_from = fieldnames(dataFrom);
for i = 1:length(data_fields_from)
    if strcmp(data_fields_from{i},'lon') ||...
            strcmp(data_fields_from{i},'longitude')
        lonnameFrom = data_fields_from{i};
    elseif strcmp(data_fields_from{i},'lat') ||...
            strcmp(data_fields_from{i},'latitude')
        latnameFrom = data_fields_from{i};
    end
end

% find data variable name
varn = getVariableName(dataFrom);

% find lat/lon variable names in 'to' data
data_fields_to = fieldnames(dataTo);
for i = 1:length(data_fields_to)
    if strcmp(data_fields_to{i},'lon') ||...
            strcmp(data_fields_to{i},'longitude')
        lonnameTo = data_fields_to{i};
    elseif strcmp(data_fields_to{i},'lat') ||...
            strcmp(data_fields_to{i},'latitude')
        latnameTo = data_fields_to{i};
    end
end

% [gridFromLon, gridFromLat] = meshgrid(dataFrom.(lonnameFrom), dataFrom.(latnameFrom));
% [gridToLon,   gridToLat  ] = meshgrid(dataTo.(lonnameTo),     dataFrom.(latnameTo));
if length(size(dataFrom.(varn))) == 4
    regriddedVar = zeros(length(dataTo.(lonnameTo)), length(dataTo.(latnameTo)), size(dataFrom.(varn), 3), size(dataFrom.(varn), 4));
else
    regriddedVar = zeros(length(dataTo.(lonnameTo)), length(dataTo.(latnameTo)), size(dataFrom.(varn), 3));
end
for i = 1:size(regriddedVar, 3)
    for j = 1:size(regriddedVar, 4)
        regriddedVar(:,:,i,j) = interp2(dataFrom.(lonnameFrom), dataFrom.(latnameFrom), dataFrom.(varn)(:,:,i,j), dataTo.(lonnameTo), dataTo.(latnameTo), interpMethod);
    end
end

% copy data to regridded struct
data_fields = fieldnames(dataFrom);
l = length(data_fields);
dataRegridded = struct;
for fieldnum = 1:l
    fieldname = data_fields{fieldnum};
    if strcmp(fieldname, lonnameFrom)
        dataRegridded.(lonnameFrom) = dataTo.(lonnameTo);
    elseif strcmp(fieldname, latnameFrom)
        dataRegridded.(latnameFrom) = dataTo.(latnameTo);
    elseif strcmp(fieldname, varn)
        dataRegridded.(varn) = regriddedVar;
    else
        dataRegridded.(fieldname) = dataFrom.(fieldname);
    end
end