clc, clear, close all;
%load('../binary_data/mat_files/psl_Amon_MIROC6_amip_r1i1p1f1_gn_197901-201412.nc.mat');
load('../binary_data/mat_files/ta_Amon_EC-Earth3_historical_r1i1p1f1_gr_201201-201212.nc.mat');
data.psl = data.ta(:,:,2,:); % ok, it's really just a test :D
data = select_subset(data, 0, 90, -100, -5);
datasize = size(data.psl);
observ_matrix = reshape(data.psl, datasize(1)*datasize(2), datasize(end));
[U, S, V] = svd(observ_matrix');
%principal_components = V;
%time_series = U*S;
eigenvalues = diag(S).^2./(size(S,1)-1);

[x,y] = meshgrid(data.lat, data.lon);
for i = 1:10
    figure(i);
    z = reshape(V(:,i), datasize(1), datasize(2));
    surf(x,y,z);
end
figure;
semilogy(eigenvalues);