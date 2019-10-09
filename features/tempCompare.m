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
Bounds_time_ref = datetime({'1995-1-1', '2014-12-31'}, 'InputFormat', 'uuuu-M-d'); % Boundaries for time on the reference
Bounds_time = datetime({'2080-1-1', '2100-12-31'}, 'InputFormat', 'uuuu-M-d'); % Boundaries for time on the models
Months = [1 1 0 0 0 0  0 0 0 0 0 1]; % Months to be evaluated [J F M A M J  J A S O N D] - Warning: only works if data starts on a January and stops on a December!
projectionType = 'lambert'; % Select projection to use for plots
papersize = [21 21]; % Size of the Paper, in centimeters [21 29.7 for A4]
climval = 10; % Set the max/min Value for colorbar (scalar positive)
cm = flipud(cbrewer('div', 'RdBu', 20)); % Set Colormap

%% Read reference file
load(strcat(refFilePath,refFile));
data = select_subset(data, Bounds_lat(1), Bounds_lat(2), Bounds_lon(1), Bounds_lon(2));
data = select_timespan(data, Bounds_time_ref(1), Bounds_time_ref(2), true);
data = select_months(data, Months);
data = convert_longitudes(data, -180);
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
    data = convert_longitudes(data, -180);
    varn = getVariableName(data);
    
    % Resample reference data to current data grid
    refDataRegridded = regridData(refData, data);
    
    % Compute temperature differences and compute the mean over the
    % selected timespan
    tempMeansRef = mean(refDataRegridded.(refDataVarn), 3);
    tempMeans = mean(data.(varn), 3);
    data.(varn) = tempMeans - tempMeansRef;
    
    % find out latitude name
    data_fields = fieldnames(data);
    for j = 1:length(data_fields)
        if strcmp(data_fields{j},'lat') ||...
                strcmp(data_fields{j},'latitude')
            latname = data_fields{j};
        end
    end
    
    % Compute area-weighted mean, ignoring NaNs
%     weights = cos(data.(latname) .* (pi/180));
%     weights = weights ./ (sum(weights) - weights(1) - weights(end));
%     dTempMean = nanmean(nanmean(nansum(data.(varn) .* weights', 2)));
    dTempMean = nanmean(nanmean(nanmean(data.(varn))));
    
    % create and plots
    titlecontent = {[folderContents(i).name], ['versus ', refFile], ['Months: ', num2str(Months)], ['Mean Temperature Difference: ', num2str(dTempMean, 2), 'K']};
    fig = plot_map(data, projectionType, Bounds_lon, Bounds_lat, 'colorbarlimits', [-climval climval], 'colormap', cm, 'Visible', 'off', 'title', titlecontent, 'modifyPapersize', papersize);
    noPlot = noPlot + 1;
    if noPlot == 1
        print(strcat(s_path, s_file), '-dpsc', '-fillpage');
    else
        print(strcat(s_path, s_file), '-dpsc', '-fillpage', '-append');
    end
end