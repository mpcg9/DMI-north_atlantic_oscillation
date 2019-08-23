function [LonName, LatName] = getLonLatName(data)

data_fields = fieldnames(data);

for i = 1:length(data_fields)
    if strcmp(data_fields{i},'lon') ||...
       strcmp(data_fields{i},'longitude')
        LonName = data_fields{i};
    elseif strcmp(data_fields{i}, 'lat') ||...
           strcmp(data_fields{i}, 'latitude')
        LatName = data_fields{i};
    end
end

end

