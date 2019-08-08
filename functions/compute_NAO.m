function [ NAO ] = compute_NAO( data )
addpath(genpath('../toolboxes'));

% cut out boxes
iceland_box = select_subset(data, 50, 90, -45, 15);
azores_box = select_subset(data, 20, 50, -60, 0);

% Average pressure over box
iceland_psi = mean(mean(iceland_box.psl, 1), 2);
azores_psi = mean(mean(azores_box.psl, 1), 2);

% Compute NAO
NAO = nao(azores_psi, iceland_psi, data.time);
NAO = reshape(NAO, [length(NAO), 1]);

end

