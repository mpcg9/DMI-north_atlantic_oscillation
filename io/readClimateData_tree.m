% This script will prompt the user to select a folder. All .nc-Files in
% subfolders will be found and stitched together to .mat-Files according to
% the options, which will be named as the folder and placed one
% folder above.

%% Preparation
clc, clear, close all;

% Options
useLonLatBounds = true;
Longitudes = [-90 40]; % Boundaries for longitude [in degrees]
Latitudes = [20 85]; % Boundaries for latitude [in degrees]
Plev = 0; % Set to zero if you don't want to use a Plev restriction, or to the desired height (in Pa, e.g. 70000 for 700hPa)

% Select master folder
path = uigetdir('','Please select the top folder');

%% Go through folders
if useLonLatBounds
    readClimateDataRecursive(path, 'Longitudes', Longitudes, 'Latitudes', Latitudes, 'Plev', Plev);
else
    readClimateDataRecursive(path, 'Plev', plev);
end