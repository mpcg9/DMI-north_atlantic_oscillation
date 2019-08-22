% This script was written by Florian Sauerland, 08/2019
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
folderContents = dir(strcat(path, '*.mat'));

[s_file, s_path] = uiputfile({'.ps', 'Postscript Level 3 File (*.ps)'}, 'Save plots as...', strcat(path, 'plots.ps'));

%% Settings
Bounds_lat = [20, 85]; % Boundaries for latitude [in degrees]
Bounds_lon = [-90, 40]; % Boundaries for longitude [in degrees]
use_time_bounds = true;
Bounds_time = datetime({'1979-1-1', '2015-12-31'}, 'InputFormat', 'uuuu-M-d'); % Boundaries for time
use_month_bounds = false;
Months = [1 1 0 0 0 0  0 0 0 0 0 1]; % Months to be evaluated [J F M A M J  J A S O N D] - Warning: only works if data starts on a January and stops on a December! Will also be applied if use_time_bounds is false.
noEOFs = 3; % Number of EOFs to calculate.
% cols = 2; % Number of plot columns per page.
averageData = true; % Set to true if you wish to calculate the averages for all grid points over time and substract it from the data
normalizeByStandardDeviation = false; % Set to true if you additionally wish to normalize the data by its standard deviation
normalizeByGridSize = true; % Set to true if you wish that every EOF Value is being multiplicated by the square root of the number of grid cells. This normalizes the mean Variance of all EOFs to 1.
plotEigenvalues = false; % Set to true if you wish to compute and plot the eigenvalues for the EOF components calculated
useLandscapeModeForEigenvalues = false;
plotTimeseries = true; % If set to true, a second plot with timeseries will appear
useLandscapeModeForTimeseries = false; % If true, the paper will be flipped
projectionType = 'lambert'; % Select projection to use for plots
variableName = 'auto'; % Select variable
flipMaxSouth = true; % If set to true, this script wil automatically flip signs in a way that the maximum is always in the south
displayMaxMin = true; % If set to true, this script will add max/min markers in the plots.
climval = 3.5; % Set the max/min Value for colorbar (scalar positive)
cm = cbrewer('div', 'RdBu', 31); % Set Colormap
modifypapersize = true;
papersize = [21 21]; % Size of the Paper, in centimeters [21 29.7 for A4]

%% EOF Calculation
noPlot = 0;
tic;

% subplotsizes = [ceil((noEOFs*(1+plotTimeseries) + plotEigenvalues)/cols), cols];
for i = 1:size(folderContents, 1)
    close all;
    load(strcat(path,folderContents(i).name));
    
    % Get subset of data
    data = select_subset(data, Bounds_lat(1), Bounds_lat(2), Bounds_lon(1), Bounds_lon(2));
    if use_time_bounds
        data = select_timespan(data, Bounds_time(1), Bounds_time(2), true);
    end
    if use_month_bounds
        data = select_months(data, Months); 
    end
    
    % find out variable if set to auto
    if strcmpi(variableName, 'auto') || useAutoVariableFind
        useAutoVariableFind = true;
        variableName = getVariableName(data);
    end
    [LonName, LatName] = getLonLatName(data);
    
    % Normalization if desired
    if averageData
        data.(variableName) = data.(variableName) - mean(data.(variableName), 3);
    end
    if normalizeByStandardDeviation
        data.(variableName) = data.(variableName) ./ std(data.(variableName), 0, 3);
        variance_sum = size(data.(variableName), 1) * size(data.(variableName), 2);
    else
        variance_sum = sum(sum(var(data.(variableName),0,3)));
    end
    
    % Compute Singular Value Decomposition
    datasize = size(data.(variableName));
    data.(variableName) = reshape(data.(variableName), datasize(1)*datasize(2), datasize(3)); % Create observation matrix by reshaping
    [U, S, V] = svds(data.(variableName)', noEOFs);
    
    % Change Latitude range to work with m_map
    temp_struct = struct;
    temp_struct.(LonName) = data.(LonName);
    temp_struct.(LatName) = data.(LatName);
    if plotTimeseries
        timeticks = data.time;
        units = data.units;
    end
    clear data;
    [temp_struct, lon_idx] = convert_longitudes(temp_struct, min(Bounds_lon));
    
    % Compute Eigenvalues
    if plotEigenvalues
        eigenvalues = diag(S).^2./(datasize(3)-1);
    end
    
    % Normalize by grid size
    if normalizeByGridSize
        gridsize = sqrt(datasize(1)*datasize(2));
    else
        gridsize = 1;
    end 
    
    % Compute Percentage of Variance explained
    time_series = U*S;
    variances = var(time_series);
    variance_percentages = variances ./ variance_sum;
    clear U S;
    
    %% prepare plotting
    %     fig = figure('Visible','off', 'Name', folderContents(i).name);
    %     if modifypapersize
    %         fig.PaperUnits = 'Centimeters';
    %         fig.PaperSize = papersize;
    %     end
    %     noSubplot = 1;
    for j = 1:noEOFs
        % Reshape EOF values
        z = reshape(V(:,j), datasize(1), datasize(2));
        
        % Find maximum positions
        if flipMaxSouth || displayMaxMin
            [~,idx] = max(V(:,j));
            [maxPos(1), maxPos(2)] = ind2sub(datasize(1:2), idx);
            [~,idx] = min(V(:,j));
            [minPos(1), minPos(2)] = ind2sub(datasize(1:2), idx);
        end
        
        % Resort longitude positions
        if displayMaxMin
            maxPos(1) = find(lon_idx == maxPos(1));
            minPos(1) = find(lon_idx == minPos(1));
        end
        
        % Flip colors so that the maximum is always in the south for better
        % comparison
        if flipMaxSouth && temp_struct.(LatName)(maxPos(2)) > temp_struct.(LatName)(minPos(2))
            temp_struct.z = -gridsize*z(lon_idx, :); % Remember that we have resorted longitudes!
            temp = maxPos;
            maxPos = minPos;
            minPos = temp;
        else
            temp_struct.z = +gridsize*z(lon_idx, :); % Remember that we have resorted longitudes!
        end
        
        %% create map plot
        if plotEigenvalues
            titlecontent = {[folderContents(i).name], ['EOF-', num2str(j) ,'; Months: ', num2str(Months)], ['Variance: ', num2str(variance_percentages(j)*100, 3), '%; Eigenvalue: ', num2str(eigenvalues(j), 4)]};
        else
            titlecontent = {[folderContents(i).name], ['EOF-', num2str(j) ,'; Months: ', num2str(Months)], ['Variance: ', num2str(variance_percentages(j)*100, 3), '%']};
        end
        if modifypapersize && displayMaxMin
            fig = plot_map(temp_struct, projectionType, Bounds_lon, Bounds_lat, 'colorbarlimits', [-climval climval], 'colormap', cm, 'Visible', 'off', 'title', titlecontent, 'markMinPosition', minPos, 'markMaxPosition', maxPos, 'modifyPapersize', papersize);
        elseif displayMaxMin
            fig = plot_map(temp_struct, projectionType, Bounds_lon, Bounds_lat, 'colorbarlimits', [-climval climval], 'colormap', cm, 'Visible', 'off', 'title', titlecontent, 'markMinPosition', minPos, 'markMaxPosition', maxPos);
        elseif modifypapersize
            fig = plot_map(temp_struct, projectionType, Bounds_lon, Bounds_lat, 'colorbarlimits', [-climval climval], 'colormap', cm, 'Visible', 'off', 'title', titlecontent, 'modifyPapersize', papersize);
        else
            fig = plot_map(temp_struct, projectionType, Bounds_lon, Bounds_lat, 'colorbarlimits', [-climval climval], 'colormap', cm, 'Visible', 'off', 'title', titlecontent);
        end
        noPlot = noPlot + 1;
        if noPlot == 1
            print(strcat(s_path, s_file), '-dpsc', '-fillpage');
        else
            print(strcat(s_path, s_file), '-dpsc', '-fillpage', '-append');
        end
            
%         % create plot
%         subplot(subplotsizes(1), subplotsizes(2), noSubplot);
%         noSubplot = noSubplot + 1; 
%         hold on;
%         %climval = max([max(V(:,j)), - min(V(:,j))]); % Set colormap to be zero-centered
%         %climval = 0.1;
%         caxis([-climval climval]);
%         colormap(cm);
%         m_proj(projectionType, 'long', Bounds_lon, 'lat', Bounds_lat);
%         m_image(temp_struct.lon, temp_struct.lat, temp_struct.z');
%         m_coast('linewidth', 1, 'color', 'black');
%         m_grid;
%         if displayMaxMin
%             m_plot(temp_struct.lon(minPos(1)), temp_struct.lat(minPos(2)), '*r');
%             m_plot(temp_struct.lon(maxPos(1)), temp_struct.lat(maxPos(2)), '*b');
%         end
%         xLabelString3 = ['EOF-', num2str(j), ' Variance: ', num2str(variance_percentages(j)*100, 3), '%'];
%         if plotEigenvalues
%             xlabel({xLabelString3, ['Eigenvalue: ', num2str(eigenvalues(j), 4)]}, 'Interpreter', 'none');
%         else
%             xlabel({xLabelString3}, 'Interpreter', 'none');
%         end
%         colorbar('southoutside'); 
%         % You might want to add more things here for plotting
%         
%         hold off;

        %% create timeseries plot
        if plotTimeseries
%             subplot(subplotsizes(1), subplotsizes(2), noSubplot);
%             noSubplot = noSubplot + 1;
            fig = figure('Visible','off', 'Name', folderContents(i).name);
            if modifypapersize
                fig.PaperUnits = 'Centimeters';
                fig.PaperSize = papersize;
            end
            noPlot = noPlot + 1;
            hold on;
            bar(timeticks, time_series(:,j)./gridsize);
            title(['EOF-' num2str(j), '; ', folderContents(i).name], 'Interpreter', 'none');
            xlabel([ 'Time' ]);
            ylabel([ 'Amount']);
            hold off;
            if useLandscapeModeForTimeseries
                fig.PaperPositionMode = 'manual';
                orient(fig, 'landscape');
            end
            print(strcat(s_path, s_file), '-dpsc', '-fillpage', '-append');
        end
    end
    
    %% create eigenvalue plot
    if plotEigenvalues
%         subplot(subplotsizes(1), subplotsizes(2), noSubplot);
%         noSubplot = noSubplot + 1;
        fig = figure('Visible','off', 'Name', folderContents(i).name);
        if modifypapersize
            fig.PaperUnits = 'Centimeters';
            fig.PaperSize = papersize;
        end
        noPlot = noPlot + 1;
        semilogy(eigenvalues);
        title('Eigenvalues');
        print(strcat(s_path, s_file), '-dpsc', '-fillpage', '-append');
    end
    
    % save plots to postscript file (can be easily converted to pdf, is the only format with -append option available)
%     if noPlot == 1
%         print(strcat(s_path, s_file), '-dpsc', '-fillpage');
%     else
%         print(strcat(s_path, s_file), '-dpsc', '-fillpage', '-append');
%     end
%     noPlot = noPlot + 1;
end
toc;