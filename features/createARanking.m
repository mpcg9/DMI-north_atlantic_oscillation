clc, clear, close all;
EOF = 1;
load('../binary_data/EOF/ERA-5.mat');
max_ref = maxPositionsTable(:,:,EOF);
min_ref = minPositionsTable(:,:,EOF);
load('../binary_data/EOF/models.mat');

addpath(genpath('../toolboxes'));
max_distances = zeros(size(maxPositionsTable, 1), 1);
min_distances = zeros(size(minPositionsTable, 1), 1);
for i = 1:size(maxPositionsTable, 1)
    max_distances(i) = m_lldist([max_ref(1); maxPositionsTable(i,1)], [max_ref(2); maxPositionsTable(i,2)]);
end
for i = 1:size(minPositionsTable, 1)
    min_distances(i) = m_lldist([min_ref(1); minPositionsTable(i,1)], [min_ref(2); minPositionsTable(i,2)]);
end
folderContents = struct2table(folderContents);

result = table(max_distances, min_distances, max_distances+min_distances, folderContents.name, 'VariableNames', {'maxDist', 'minDist', 'distSum', 'model'});
result = sortrows(result, 'distSum');