function [ GBI ] = compute_GBI( data )

varn = getVariableName(data);
data = select_subset(data, 60, 80, -80, -20);
if varn ~= 'zg'
    warning('Make sure to use variable zg for GBI calculation');
end

% Find Fieldnames
data_fields = fieldnames(data);
for i = 1:length(data_fields)
    if strcmp(data_fields{i},'lat') ||...
       strcmp(data_fields{i},'latitude')
        latname = data_fields{i};
    elseif strcmp(data_fields{i}, 'lon') ||...
           strcmp(data_fields{i}, 'longitude')
        lonname = data_fields{i};
    end
end

weights = cos(data.(latname) .* (pi/180));
weights = weights ./ norm(weights);
% data.(varn) = data.(varn) - mean(data.(varn), 3);
GBI = reshape(mean(mean(data.(varn) .* weights')), size(data.(varn), 3), 1);

end

