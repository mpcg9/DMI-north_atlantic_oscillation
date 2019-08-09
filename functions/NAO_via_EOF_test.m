clc, clear, close all;
addpath(genpath('../toolboxes'));

load('../binary_data/mat_files/psl_Amon_MIROC6_amip_r1i1p1f1_gn_197901-201412.nc.mat');
%load('../binary_data/mat_files/ta_Amon_EC-Earth3_historical_r1i1p1f1_gr_201201-201212.nc.mat');
%data.psl = data.ta(:,:,2,:); % ok, it's really just a test :D

data = select_subset(data, 0, 90, -100, 20);
datasize = size(data.psl);
observ_matrix = reshape(data.psl, datasize(1)*datasize(2), datasize(end));
[U, S, V] = svd(observ_matrix');
%principal_components = V;
%time_series = U*S;
eigenvalues = diag(S).^2./(size(S,1)-1);

%[x,y] = meshgrid(data.lat, data.lon);
temp_struct = struct;
temp_struct.lon = data.lon;
temp_struct.lat = data.lat;
[temp_struct, lon_idx] = convert_longitudes(temp_struct, -180);
for i = 1:5
    subplot(2,3,i);
    z = reshape(V(:,i), datasize(1), datasize(2));
    temp_struct.z = z(lon_idx, :);
    m_proj('lambert', 'long', [-100 20], 'lat', [0 90]);
    m_image(temp_struct.lon, temp_struct.lat, temp_struct.z');
    m_coast('linewidth', 1, 'color', 'black');
    m_grid;
    title(strcat('The ', num2str(i), '-th EOF component'));
    colorbar;
    %surf(x,y,z);
end
subplot(2,3,i+1);
semilogy(eigenvalues);
title('Eigenvalues');


