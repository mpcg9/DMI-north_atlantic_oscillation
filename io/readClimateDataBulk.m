clc, clear, close all;
[file, path] = uigetfile({'*.nc', 'NetCDF2-File (*.nc)'}, 'Please select one file to read. All files will be added automatically');
% ATTENTION! Do not use different Variables!

addpath('./scripts');
addpath('../functions');
folderContents = dir(strcat(path, '*.nc'));

% Find out dimensions and variable
dataParts = cell(size(folderContents, 1), 1);
dataParts{1} = readNetCDF2(strcat(path,folderContents(1).name));
varn = getVariableName(dataParts{1});
dataDimensions = size(dataParts{i}.(varn));
dataLength = 0;
dataLength = dataLength + dataDimensions(end);
numDimensions = length(dataDimensions);
dataDimensions = dataDimensions(1:end-1);

for i = 2:size(folderContents, 1)
    dataParts{i} = readNetCDF2(strcat(path,folderContents(i).name));
    dataLength = dataLength + size(dataParts{i}.(varn), numDimensions);
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