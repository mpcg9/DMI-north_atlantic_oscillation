% This script was written by Florian Sauerland, 08/2019
% florian.sauerland@uni-bonn.de

%% Preparation
clc, clear, close all;
addpath(genpath('../functions'));
addpath(genpath('../toolboxes'));

% Information: all *.mat-files in the selected folder will have to contain
% a data variable and will be evaluated as well!
[file, path] = uigetfile({'*.mat', 'MATLAB binary file (*.mat)'}, 'Please select one file to read. All files will be added automatically');
folderContents = dir(strcat(path, '*.mat'));

[s_file, s_path] = uiputfile({'.ps', 'Postscript Level 3 File (*.ps)'}, 'Save plots as...', strcat(path, 'plots.ps'));

%% Settings
Bounds_lat = [30, 85]; % Boundaries for latitude [in degrees]
Bounds_lon = [-80, 10]; % Boundaries for longitude [in degrees]
Months = [0 0 0 0 0 1  1 1 0 0 0 0]; % Months to be evaluated [J F M A M J  J A S O N D] - Warning: only works if data starts on a January and stops on a December!
noEOFs = 3; % Number of EOFs to calculate.
averageData = true; % Set to true if you wish to calculate the averages for all grid points over time and substract it from the data
plotEigenvalues = true; % Set to true if you wish to compute and plot the eigenvalues for the EOF components calculated
numPlotColumns = 2; % Set to the number of columns you wish to get in the resulting .ps file.
projectionType = 'lambert'; % Select projection to use for plots
variableName = 'psl'; % Select variable

%% EOF Calculation and Plotting
noPlot = 1;
tic;
for i = 1:size(folderContents, 1)
    load(strcat(path,folderContents(i).name));
    
    % Get subset of data
    data = select_subset(data, Bounds_lat(1), Bounds_lat(2), Bounds_lon(1), Bounds_lon(2));
    data = select_months(data, [1 1 0 0 0 0  0 0 0 0 0 1]); 
    
    % Compute and substract averages
    if averageData
        data.(variableName) = data.(variableName) - mean(data.(variableName), 3);
    end
    
    % Compute Singular Value Decomposition
    datasize = size(data.(variableName));
    data.(variableName) = reshape(data.(variableName), datasize(1)*datasize(2), datasize(3:end)); % Create observation matrix by reshaping
    [~, S, V] = svds(data.(variableName)', noEOFs);
    
    % Change Latitude range to work with m_map
    temp_struct = struct;
    temp_struct.lon = data.lon;
    temp_struct.lat = data.lat;
%     if plotEigenvalues
%         unit = data.units;
%         maxMultiplicator = max(abs(U*S),1)
%     end
    clear data;
    [temp_struct, lon_idx] = convert_longitudes(temp_struct, min(Bounds_lon));
    
    % Compute Eigenvalues
    if plotEigenvalues
        eigenvalues = diag(S).^2./(size(S,1)-1);
    end
    clear U S;
    
    figure('Visible','off', 'Name', folderContents(i).name);
    for j = 1:noEOFs
        % Reshape EOF values
        z = reshape(V(:,j), datasize(1), datasize(2));
        temp_struct.z = z(lon_idx, :); % Remember that we have resorted longitudes!
        
        % create plot
        subplot(ceil((noEOFs + plotEigenvalues)/2), 2, j);
        climval = max([max(V(:,j)), - min(V(:,j))]); % Set colormap to be zero-centered
        caxis([-climval climval]);
        colormap('jet');
        m_proj(projectionType, 'long', Bounds_lon, 'lat', Bounds_lat);
        m_image(temp_struct.lon, temp_struct.lat, temp_struct.z');
        m_coast('linewidth', 1, 'color', 'black');
        m_grid;
        xlabel(...
            {folderContents(i).name, ...
            strcat('EOF-', num2str(j), '; Eigenvalue: ', num2str(eigenvalues(j))) ...
            }, 'Interpreter', 'none');
        colorbar('southoutside'); 
        % You might want to add more things here for plotting
        
    end
    
    if plotEigenvalues
        subplot(ceil((noEOFs + plotEigenvalues)/2), 2, j+1);
        semilogy(eigenvalues);
        title('Eigenvalues');
    end
    
    % save plots to postscript file (can be easily converted to pdf, is the only format with -append option available)
    if noPlot == 1
        print(strcat(s_path, s_file), '-dpsc', '-fillpage');
    else
        print(strcat(s_path, s_file), '-dpsc', '-fillpage', '-append');
    end
    noPlot = noPlot + 1;
end
toc;