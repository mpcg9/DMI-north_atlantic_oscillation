%% Preparation
clc, clear, close all;
[file, path] = uigetfile('*.nc', 'Please select file to read');
addpath('./scripts');
addpath('./functions');

%% Options
useLatLonBounds = true;
Latitudes = [20 85]; % Boundaries for latitude [in degrees]
Longitudes = [-90 40]; % Boundaries for longitude [in degrees]
Plev = 0; % Set to zero if you wish to keep all height dimensions in data. If you only wish to keep one height, set this number to the corresponding plev value.

%% Ingestion
if useLatLonBounds
    data = readNetCDF2_new(strcat(path,file), 'Latitudes', Latitudes, 'Longitudes', Longitudes, 'Plev', Plev);
else
    data = readNetCDF2_new(strcat(path,file), 'Plev', Plev);
end

uisave('data', file);