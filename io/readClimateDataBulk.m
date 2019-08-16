%% Preparation
clc, clear, close all;
[file, path] = uigetfile({'*.nc', 'NetCDF2-File (*.nc)'}, 'Please select one file to read. All files will be added automatically');
% ATTENTION! Do not use different Variables!

addpath('./scripts');
addpath('../functions');
folderContents = dir(strcat(path, '*.nc'));

%% Settings
use_boundaries = true;
Bounds_lat = [60 80]; % Boundaries for latitude [in degrees]
Bounds_lon = [-80 -20]; % Boundaries for longitude [in degrees]
reduce_height_dimension = 0; % Set to zero if you wish to keep all dimensions in data or if there is only a 2D-grid. If you only wish to keep one height, set this number to the height index you want to read

%% Ingestion

% reset to defaults if no boundaries wanted.
if ~use_boundaries
    Bounds_lat = false;
    Bounds_lon = false;
end

% Find out dimensions and variable
dataParts = cell(size(folderContents, 1), 1);
dataParts{1} = readNetCDF2_new(strcat(path,folderContents(1).name), 'Latitudes', Bounds_lat, 'Longitudes', Bounds_lon, 'Plev', reduce_height_dimension);
varn = getVariableName(dataParts{1});
dataDimensions = size(dataParts{1}.(varn));
disp(strcat({'Read file 1/'}, num2str(size(folderContents, 1))));
dataLength = 0;
dataLength = dataLength + dataDimensions(end);
numDimensions = length(dataDimensions);
dataDimensions = dataDimensions(1:end-1);

for i = 2:size(folderContents, 1)
    dataParts{i} = readNetCDF2_new(strcat(path,folderContents(i).name), 'Latitudes', Bounds_lat, 'Longitudes', Bounds_lon, 'Plev', reduce_height_dimension);
    dataLength = dataLength + size(dataParts{i}.(varn), numDimensions);
    disp(strcat('Read file', {' '},num2str(i),'/', num2str(size(folderContents, 1))));
end

% Preallocation
data = dataParts{1};
data.(varn) = zeros([dataDimensions dataLength]);
if isfield(data, 'time')
    data.time = zeros(dataLength, 1);
end
if isfield(data, 'time_bnds')
    data.time_bnds = zeros(2, dataLength);
end
if isfield(data, 'time_bounds')
    data.time_bounds = zeros(2, dataLength);
end

% Concatenation
currentPosition = 1;
for i = 1:length(dataParts)
    currentLength = size(dataParts{i}.time, 1);
    if numDimensions == 4
        data.(varn)(:, :, :, currentPosition:(currentPosition+currentLength-1)) = dataParts{i}.(varn);
    else
        data.(varn)(:, :, currentPosition:(currentPosition+currentLength-1)) = dataParts{i}.(varn);
    end
    if isfield(data, 'time')
        data.time(currentPosition:(currentPosition+currentLength-1)) = dataParts{i}.time;
    end
    if isfield(data, 'time_bnds')
        data.time_bnds(:,currentPosition:(currentPosition+currentLength-1)) = dataParts{i}.time_bnds;
    end
    if isfield(data, 'time_bounds')
        data.time_bounds(:,currentPosition:(currentPosition+currentLength-1)) = dataParts{i}.time_bounds;
    end
    currentPosition = currentPosition + currentLength;
end

% check if we need to sort and sort if necessary
if ~issorted(data.time)
    data = sort_by_time(data);
end

% data = readNetCDF2(strcat(path,folderContents(1).name));
% if size(folderContents, 1) > 1
%     for i = 2:size(folderContents, 1)
%         data = concatenate_by_time(data, readNetCDF2(strcat(path,folderContents(i).name)));
%     end
%     data = sort_by_time(data);
% end

% Save
uisave('data', strcat(path, file, '.mat'));