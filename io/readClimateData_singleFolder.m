%% Preparation
clc, clear, close all;
[file, path] = uigetfile({'*.nc', 'NetCDF2-File (*.nc)'}, 'Please select one file to read. All files will be added automatically');
% ATTENTION! Do not use different Variables!

addpath('./scripts');
addpath('../functions');
addpath('./functions');
folderContents = dir(strcat(path, '*.nc'));

%% Settings
use_boundaries = true;
Bounds_lat = [20 85]; % Boundaries for latitude [in degrees]
Bounds_lon = [-90 40]; % Boundaries for longitude [in degrees]
Plev_query = 0; % Set to zero if you wish to keep all height dimensions in data. If you only wish to keep one height, set this number to the corresponding plev value.
auto_convert_time = true; % Set to true if you wish to automatically convert time specifications to datetimes. We recommend to set this to true because it will also cope for different start dates in different parts of the data.

%% Ingestion
if use_boundaries
    data = readClimateDataFolder(path, 'Longitudes', Bounds_lon, 'Latitudes', Bounds_lat, 'Plev', Plev_query);
else
    data = readClimateDataFolder(path, 'Plev', Plev_query);
end

uisave('data', strcat(path, file, '.mat'));