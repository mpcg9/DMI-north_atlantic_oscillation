clc, clear, close all;
addpath(genpath(cd));
addpath(genpath('../toolboxes'));
[file, path] = uigetfile('*.nc', 'Please select file to read');
data = readNetCDF2(strcat(path,file));
save(strcat(path, '../mat_files', file, '.mat'), 'data');

%% Find information
keyboard;
disp(size(data.ta)); % To find out the dimensions of data.ta. 
% This information can be used together with the dimension data of time,
% latitude, longitude and elevation to find out which dimension of data.ta 
% is which.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Let's see if it's always the same! (Write down your findings here)
% <File>: [Order of dimensions], (dimension of dimensions)
%
% ta_Amon_EC-Earth3_historical_r1i1p1f1_gr_201201-201212.nc: [Lon, Lat, Elev, Time], (512, 256, 19, 12)
% ta_Amon_GISS-E2-1-H_abrupt-4xCO2_r1i1p1f1_gn_195101-200012.nc: [Lon, Lat, Elev, Time], (144, 90, 19, 600)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Some more fun
keyboard;

% Let's do a plot (just for testing)
ta = data.ta(:,:,2,1)'; %January, Height 850hPa
ta = [ta(:, 257:end), ta(:, 1:256)];
lon = data.lon - 180;
lat = data.lat;

% cut out greenland (optional)
if false
    lat_bound_lo = 210;
    lat_bound_hi = 250;
    lon_bound_lo = 145;
    lon_bound_hi = 250;
lat = lat(lat_bound_lo:lat_bound_hi);
lon = lon(lon_bound_lo:lon_bound_hi);
ta = ta(lat_bound_lo:lat_bound_hi, lon_bound_lo:lon_bound_hi);
end

m_proj('orthographic');
m_image(lon, lat, ta); 
m_coast('linewidth', 1, 'color', 'black');
m_grid;
