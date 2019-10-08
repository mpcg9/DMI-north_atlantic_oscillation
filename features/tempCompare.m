% this script was created by Florian Sauerland, 10/2019
% florian.sauerland@uni-bonn.de

%% Preparation
clc, clear, close all;
addpath(genpath('../functions'));
addpath(genpath('../toolboxes'));
addpath('../addons/cbrewer');
addpath('../addons');

% Information: all *.mat-files in the selected folder will have to contain
% a data variable and will be evaluated as well!
[file, path] = uigetfile({'*.mat', 'MATLAB binary file (*.mat)'}, 'Please select one file to read. All files will be added automatically');
[refFile, refFilePath] = uigetfile({'*.mat', 'MATLAB binary file (*.mat)'}, 'Select the reference file', strcat(path, 'reference.mat'));
folderContents = dir(strcat(path, '*.mat'));
[s_file, s_path] = uiputfile({'.ps', 'Postscript Level 3 File (*.ps)'}, 'Save plots as...', strcat(path, 'plots.ps'));

%% Settings
Bounds_lat = [20, 85]; % Boundaries for latitude [in degrees]
Bounds_lon = [-90, 40]; % Boundaries for longitude [in degrees]
Bounds_time = datetime({'1995-1-1', '2014-12-31'}, 'InputFormat', 'uuuu-M-d'); % Boundaries for time
Months = [1 1 0 0 0 0  0 0 0 0 0 1]; % Months to be evaluated [J F M A M J  J A S O N D] - Warning: only works if data starts on a January and stops on a December!
projectionType = 'lambert'; % Select projection to use for plots
papersize = [21 21]; % Size of the Paper, in centimeters [21 29.7 for A4]
climval = 3.5; % Set the max/min Value for colorbar (scalar positive)
cm = cbrewer('div', 'RdBu', 16); % Set Colormap

%% Read reference file
load(strcat(refFilePath,refFile));
data = select_subset(data, Bounds_lat(1), Bounds_lat(2), Bounds_lon(1), Bounds_lon(2));
data = select_timespan(data, Bounds_time(1), Bounds_time(2), true);
data = select_months(data, Months);
refDataVarn = getVariableName(data);
refData = data;

%% Compare with all the other files
noPlot = 0;
for i = 1:size(folderContents, 1)
    close all;
    
    % load current data
    load(strcat(path,folderContents(i).name));
    data = select_subset(data, Bounds_lat(1), Bounds_lat(2), Bounds_lon(1), Bounds_lon(2));
    data = select_timespan(data, Bounds_time(1), Bounds_time(2), true);
    data = select_months(data, Months);
    varn = getVariableName(data);
    
    % Resample reference data to current data grid
    refDataRegridded = regridData(refData, data);
    
    tempMeansRef = mean(refDataRegridded.(refDataVarn), 3);
    tempMeans = mean(data.(varn), 3);
    
    data.(varn) = tempMeans - tempMeansRef;
    
    titlecontent = {[folderContents(i).name], ['versus ', refFile], ['Months: ', num2str(Months)]};
    
    fig = plot_map(data, projectionType, Bounds_lon, Bounds_lat, 'colorbarlimits', [-climval climval], 'colormap', cm, 'Visible', 'off', 'title', titlecontent, 'modifyPapersize', papersize);
    noPlot = noPlot + 1;
    if noPlot == 1
        print(strcat(s_path, s_file), '-dpsc', '-fillpage');
    else
        print(strcat(s_path, s_file), '-dpsc', '-fillpage', '-append');
    end
end