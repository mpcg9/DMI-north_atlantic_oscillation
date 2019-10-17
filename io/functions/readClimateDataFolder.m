function [data] = readClimateDataFolder(path, varargin)
%% Options
options = struct(...  % setting defaults...
        'Longitudes', false,...
        'Latitudes', false,...
        'Plev', 0,...
        'convertTime', true...
    );

% read the acceptable names
optionNames = fieldnames(options);

% count arguments
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
   error('EXAMPLE needs propertyName/propertyValue pairs')
end

for pair = reshape(varargin,2,[]) % pair is {propName;propValue}
   inpName = pair{1}; 
   if any(strcmp(inpName,optionNames))
      % overwrite options. 
      options.(inpName) = pair{2};
   else
      error('%s is not a recognized parameter name',inpName)
   end
end

addpath('../scripts');
addpath('../../functions');

%% Ingestion
if path(end) ~= '/'
    path = [path, '/'];
end

folderContents = dir(strcat(path, '*.nc'));

% Find out dimensions and variable
dataParts = cell(size(folderContents, 1), 1);
[dataParts{1}, timeConversionOptions] = readNetCDF2_new(strcat(path,folderContents(1).name), 'Latitudes', options.Latitudes, 'Longitudes', options.Longitudes, 'Plev', options.Plev, 'convertTime', options.convertTime);
timeConversionOptions.checkIrregularities = false;
varn = getVariableName(dataParts{1});
dataDimensions = size(dataParts{1}.(varn));
disp(strcat({'Read file 1/'}, num2str(size(folderContents, 1))));
dataLength = 0;
dataLength = dataLength + dataDimensions(end);
numDimensions = length(dataDimensions);
dataDimensions = dataDimensions(1:end-1);

for i = 2:size(folderContents, 1)
    dataParts{i} = readNetCDF2_new(strcat(path,folderContents(i).name), 'Latitudes', options.Latitudes, 'Longitudes', options.Longitudes, 'Plev', options.Plev, 'convertTime', options.convertTime, 'timeConversionOptions', timeConversionOptions);
    dataLength = dataLength + size(dataParts{i}.(varn), numDimensions);
    disp(strcat('Read file', {' '},num2str(i),'/', num2str(size(folderContents, 1))));
end

% Preallocation
data = dataParts{1};
data.(varn) = zeros([dataDimensions dataLength]);
if ~options.convertTime
    if isfield(data, 'time')
        data.time = zeros(dataLength, 1);
    end
    if isfield(data, 'time_bnds')
        data.time_bnds = zeros(2, dataLength);
    end
    if isfield(data, 'time_bounds')
        data.time_bounds = zeros(2, dataLength);
    end
else
    if isfield(data, 'time')
        data.time = NaT(dataLength, 1);
    end
    if isfield(data, 'time_bnds')
        data.time_bnds = NaT(2, dataLength);
    end
    if isfield(data, 'time_bounds')
        data.time_bounds = NaT(2, dataLength);
    end
end

% Concatenation
currentPosition = 1;
for i = 1:length(dataParts)
    currentLength = length(dataParts{i}.time);
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
end

