function [ NAO ] = compute_NAO( data )
addpath(genpath('../toolboxes'));

varName = getVariableName(data);

% cut out boxes
% iceland_box = select_subset(data, 50, 90, -45, 15);
% azores_box = select_subset(data, 20, 50, -60, 0);
iceland_box = select_subset(data, 55, 90, -80, 10);
azores_box = select_subset(data, 30, 50, -80, 10);

% Average pressure over box
iceland_psi = mean(mean(iceland_box.(varName), 1), 2);
azores_psi = mean(mean(azores_box.(varName), 1), 2);

% Compute NAO
NAO = nao(azores_psi, iceland_psi, data.time);
NAO = reshape(NAO, [length(NAO), 1]);

end

