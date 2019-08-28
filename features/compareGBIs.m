%% compareGBIs
% comparison of GBIs from NOAA, ERA5 and CMIP6 historical simulations
%
% susann.aschenneller@uni-bonn.de, 08/2019
%
% Contents:
%   0.settings
%   1. Load data
%   2. Todo: Correct future data by 
%   3. Filtering
%   4. Running standard deviation
%   5. Plots
%       5.1 General definitions
%       5.2 Historical simulation
%       5.3 Historical simulation AND future scenarios 
%       5.4 Running standard deviation
%           5.4.1 Historical simulation
%           5.4.2 Future scenarios
%           5.4.3 Historical simulation AND future scenarios

%% 0.settings
clearvars; close all; clc;
f = filesep;
addpath(genpath(cd), genpath(['..' f 'functions']), genpath(['..' f 'data' f 'GBI']),...
    genpath(['..' f 'data' f 'GBI_zonal']));

% Plot or not
plot_historical = true;          % plot historical data
plot_future = true;              % plot historical data from future scenarios SSP245 and SSP585
plot_stdev = true;               % running standard deviation
plot_historicalAndFuture = true; % creates a 'messy-plot'

%% 1. Load data
% NOAA downloaded GBI
temp = load('GBI1.data');
gbi_NOAA = struct('time',datetime(temp(:,1),temp(:,2),temp(:,3),'Format','dd.MM.yyyy'));
gbi_NOAA = setfield(gbi_NOAA,'GBI',temp(:,4));
clear temp;

% ERA5 geopotential
gbi_ERA5 = load('GBI_ERA5.mat');
gbi_ERA5 = gbi_ERA5.GBI;

% CMIP6 historical
path = '..\data\GBI\CMIP6_zg_historical\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_CMIP6_hist{i} = temp.GBI;
    gbi_CMIP6_hist{i}.name = strrep(folderContents(i).name,'_',' ');
    gbi_CMIP6_hist{i}.name = erase(gbi_CMIP6_hist{i}.name,'GBI zg Amon ');
    gbi_CMIP6_hist{i}.name = erase(gbi_CMIP6_hist{i}.name,' historical r1i1p1f1 gn.mat');
end

% CMIP6 SSP245
path = '..\data\GBI\CMIP6_zg_ssp245\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_CMIP6_scen245{i} = temp.GBI;
    gbi_CMIP6_scen245{i}.name = strrep(folderContents(i).name,'_',' ');
    gbi_CMIP6_scen245{i}.name = erase(gbi_CMIP6_scen245{i}.name,'GBI zg Amon ');
end

% CMIP6 SSP585
path = '..\data\GBI\CMIP6_zg_ssp585\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_CMIP6_scen585{i} = temp.GBI;
    gbi_CMIP6_scen585{i}.name = strrep(folderContents(i).name,'_',' ');
    gbi_CMIP6_scen585{i}.name = erase(gbi_CMIP6_scen585{i}.name,'GBI zg Amon ');
end

%% 2. Todo: Correct future data by 
    % - seasonal mean (e.g. 12-months-filter)
    % - warming effect --> subtract mean over all longitudes
%% 2.1 Computation of zonal mean
% (temporal mean of the data over all longitudes in the specified latitudes)  

% CMIP6 SSP245
path = '..\data\GBI\CMIP6_zg_ssp245\';
folderContents = dir(strcat(path, '*.mat'));
for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_zonal_CMIP6_scen245{i} = temp.GBI;
    gbi_zonal_CMIP6_scen245{i}.name = strrep(folderContents(i).name,'_',' ');
    gbi_zonal_CMIP6_scen245{i}.name = erase(gbi_zonal_CMIP6_scen245{i}.name,'GBI zg Amon ');
end

for k = 1 : length(gbi_zonal_CMIP6_scen245)
   gbi_zonal_mean_CMIP6_scen245(k) = mean(gbi_zonal_CMIP6_scen245{k}.GBI);
end

% CMIP6 SSP585
path = '..\data\GBI\CMIP6_zg_ssp585\';
folderContents = dir(strcat(path, '*.mat'));
for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_zonal_CMIP6_scen585{i} = temp.GBI;
    gbi_zonal_CMIP6_scen585{i}.name = strrep(folderContents(i).name,'_',' ');
    gbi_zonal_CMIP6_scen585{i}.name = erase(gbi_zonal_CMIP6_scen585{i}.name,'GBI zg Amon ');
end

for k = 1 : length(gbi_zonal_CMIP6_scen585)
   gbi_zonal_mean_CMIP6_scen585(k) = mean(gbi_zonal_CMIP6_scen585{k}.GBI);
end

%% 3. Filtering
a = 1;
% window size for daily data
ws_filt = 36;
b = (1/ws_filt)*ones(1,ws_filt);

% compute filtered time series
gbi_NOAA_filt = filter(b,a,gbi_NOAA.GBI);

%% 4. Running standard deviation
% window size
ws_std_daily = 60 * 30; % [days]
ws_std_mon = 60; % [months]

gbi_NOAA_stdev = movstd(gbi_NOAA.GBI,ws_std_daily);
gbi_ERA5_stdev = movstd(gbi_ERA5.GBI,ws_std_mon);

% moving standard deviations
for k = 1 : length(gbi_CMIP6_hist)
    gbi_CMIP6_hist_stdev{k} = movstd(gbi_CMIP6_hist{k}.GBI,ws_std_mon);
end

for k = 1 : length(gbi_CMIP6_scen245)
    gbi_CMIP6_scen245_stdev{k} = movstd(gbi_CMIP6_scen245{k}.GBI,ws_std_mon);
end

for k = 1 : length(gbi_CMIP6_scen585)
    gbi_CMIP6_scen585_stdev{k} = movstd(gbi_CMIP6_scen585{k}.GBI,ws_std_mon);
end

%% 5. Plots
%% 5.1 General definitions
% Colors!
colors = struct('orange',[0.9290, 0.6940, 0.1250]);
colors.darkgreen = [0, 0.5, 0];
colors.lila = [138,43,226] ./ 255;
colors.greenyellow = [173,255,47] ./ 255;
colors.DarkGoldenrod1 = [255,185,15] ./ 255;
colors.MediumPurple4 = [93,71,139] ./ 255;
colors.IndianRed = [255,106,106] ./ 255;
colors.turquoise4 = [0,134,139] ./ 255;
colors.blue = [0 0 1];
colors.red = [1 0 0];

% this is for manual line specifications in a for-loop
line_spec{1,1} = colors.blue;
line_spec{2,1} = colors.blue;
line_spec{3,1} = colors.red;
line_spec{4,1} = colors.red;
line_spec{5,1} = colors.orange;
line_spec{6,1} = colors.orange;
line_spec{7,1} = colors.greenyellow;
line_spec{8,1} = colors.greenyellow;
line_spec{9,1} = colors.darkgreen;
line_spec{10,1} = colors.darkgreen;

line_spec{1,2} = '-';
line_spec{2,2} = '-.';
line_spec{3,2} = '-';
line_spec{4,2} = '-.';
line_spec{5,2} = '-';
line_spec{6,2} = '-.';
line_spec{7,2} = '-';
line_spec{8,2} = '-.';
line_spec{9,2} = '-';
line_spec{10,2} = '-.';

% Line Width
lw1 = 1.2;

%% 5.2 Historical simulation
% (more detailed - 2 parts with 5 models per plot)
if plot_historical == true
    % axis settings
    x_min = datetime(1979,1,1); x_max = datetime(2019,7,1);
    y_min = 4800; y_max = 5800;  
    
    % --- Part 1 ---
    figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
    % references
    plot(gbi_NOAA.time,gbi_NOAA_filt,'k','DisplayName',...
        ['NOAA (daily) download, filtered with windows size ' num2str(ws_filt)]);
    plot(gbi_ERA5.time,gbi_ERA5.GBI,'DisplayName','ERA5 (monthly)');
    
    % plot first 5 historical models individually
    for k = 1 : 5
        plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist{k}.GBI,...
            'DisplayName',['CMIP6 historical ' gbi_CMIP6_hist{k}.name]);
    end
    
    xlim([x_min x_max]); ylim([y_min y_max]); legend show
    title('GBI as a weighted mean of the geopotential height at 500hPa pressure level part 1');
    ylabel('GBI [m]'); hold off;
    
    % --- Part 2 ---
    figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
    % references
    plot(gbi_NOAA.time,gbi_NOAA_filt,'k','DisplayName',...
        ['NOAA (daily) download, filtered with windows size ' num2str(ws_filt)]);
    plot(gbi_ERA5.time,gbi_ERA5.GBI,'DisplayName','ERA5 (monthly)');
    
    % plot second 5 historical models individually
    for k = 6 : length(gbi_CMIP6_hist)
        plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist{k}.GBI,...
            'DisplayName',['CMIP6 historical ' gbi_CMIP6_hist{k}.name]);
    end
    xlim([x_min x_max]); ylim([y_min y_max]); legend show
    title('GBI as a weighted mean of the geopotential height at 500hPa pressure level part 2');
    ylabel('GBI [m]'); hold off;    
end
%% 5.3 Historical simulation AND future scenarios 
% xxxxxx improve colors in the following part
if plot_historicalAndFuture == true % historical & future
    x_min = datetime(1979,1,1); x_max = datetime(2100,1,1);
    y_min = 4600; y_max = 6600;
    
    figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;    
    % references
    plot(gbi_NOAA.time,gbi_NOAA_filt,'k','DisplayName',...
        ['NOAA (daily) download, filtered with windows size ' num2str(ws_filt)]);
    plot(gbi_ERA5.time,gbi_ERA5.GBI,'DisplayName','ERA5 (monthly)');
    
    % all historical models
    for k = 1 : length(gbi_CMIP6_hist)
        plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist{k}.GBI,...
            'DisplayName',['CMIP6 historical ' gbi_CMIP6_hist{k}.name]);
    end
    
    % all future models - SSP245
    for k = 1 : length(gbi_CMIP6_scen245)
        plot(gbi_CMIP6_scen245{k}.time,gbi_CMIP6_scen245{k}.GBI,...
            'DisplayName',['CMIP6 SSP245 ' gbi_CMIP6_hist{k}.name]);
    end
    
    % all future models - SSP585
    for k = 1 : length(gbi_CMIP6_scen585)
        plot(gbi_CMIP6_scen585{k}.time,gbi_CMIP6_scen585{k}.GBI,...
            'DisplayName',['CMIP6 SSP585 ' gbi_CMIP6_hist{k}.name]);
    end
     
    xlim([x_min x_max]); ylim([y_min y_max]); legend show
    title('GBI as a weighted mean of the geopotential height at 500hPa pressure level');
    ylabel('GBI [m]'); hold off;   
end


%% 5.4 Running standard deviation
if plot_stdev == true
%%  5.4.1 Historical simulation
    if plot_historical == true
        x_min = datetime(1979,1,1); x_max = datetime(2015,1,1);
        y_min = 120; y_max = 220;
        
        h = figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
        
        % references
        plot(gbi_NOAA.time,gbi_NOAA_stdev,'k-.','LineWidth',lw1,'DisplayName',['NOAA 30*' num2str(ws_std_mon) ' days filter']);
        plot(gbi_ERA5.time,gbi_ERA5_stdev,'k','LineWidth',lw1,'DisplayName','ERA5');
        
        % CMIP6 historical
        for k = 1 : length(gbi_CMIP6_hist_stdev)
            plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist_stdev{k},'Color',line_spec{k,1},'LineStyle',line_spec{k,2},...
                'DisplayName',[gbi_CMIP6_hist{k}.name],'LineWidth',lw1);
        end
        
        xlim([x_min x_max]); ylim([y_min y_max]);
        leg = legend('show');
        set(leg,'Location','southoutside');
        title(['GBI from CMIP6-historical - running standard deviation (' num2str(ws_std_mon) ' months)']);
        ylabel('running standard deviation'); hold off;
        
        orient(h,'landscape');
        print(h,'-dpdf','GBI historical running standard deviation.pdf','-fillpage');
    end
%%  5.4.2 Future scenarios
     if plot_future == true
         x_min = datetime(2019,1,1);x_max = datetime(2100,1,1);
         y_min = 120; y_max = 220;
         
         % --- SSP245 ---
         figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
         
         for k = 1 : length(gbi_CMIP6_scen245_stdev)
             plot(gbi_CMIP6_scen245{k}.time,gbi_CMIP6_scen245_stdev{k},...
                 'DisplayName',[gbi_CMIP6_hist{k}.name]);
         end
         
         xlim([x_min x_max]); ylim([y_min y_max]); legend show
         title(['GBI from CMIP6-SSP245 - running standard deviation (' num2str(ws_std) ' months)']);
         ylabel('running standard deviation'); hold off;
         
         % --- SSP585 ---
         figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
         
         for k = 1 : length(gbi_CMIP6_scen585_stdev)
             plot(gbi_CMIP6_scen585{k}.time,gbi_CMIP6_scen585_stdev{k},...
                 'DisplayName',[gbi_CMIP6_hist{k}.name]);
         end
         
         xlim([x_min x_max]); ylim([y_min y_max]); legend show
         title(['GBI from CMIP6-SSP585 - running standard deviation (' num2str(ws_std) ' months)']);
         ylabel('running standard deviation'); hold off;
         
         % --- SSP245 and SSP585 ---
         figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
         
         for k = 1 : length(gbi_CMIP6_scen245_stdev)
             if k < 2
                 plot(gbi_CMIP6_scen245{k}.time,gbi_CMIP6_scen245_stdev{k},'g',...
                     'DisplayName','SSP245');
             else
                 plot(gbi_CMIP6_scen245{k}.time,gbi_CMIP6_scen245_stdev{k},'g',...
                     'HandleVisibility','off');
             end
         end
         
         for k = 1 : length(gbi_CMIP6_scen585_stdev)
             if k < 2
                 plot(gbi_CMIP6_scen585{k}.time,gbi_CMIP6_scen585_stdev{k},'b',...
                     'DisplayName','SSP585');
             else
                 plot(gbi_CMIP6_scen585{k}.time,gbi_CMIP6_scen585_stdev{k},'b',...
                     'HandleVisibility','off');
             end
         end
         
         xlim([x_min x_max]); ylim([y_min y_max]); legend show
         title(['GBI from CMIP6-SSP245 and SSP585 - running standard deviation (' num2str(ws_std) ' months)']);
         ylabel('running standard deviation'); hold off;
         
     end
    
%%  5.4.3 Historical simulation AND future scenarios
    if plot_historicalAndFuture == true % historical & future   
        x_min = datetime(1979,1,1);x_max = datetime(2100,1,1);
        y_min = 120; y_max = 220;
        
        figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
        
        for k = 1 : length(gbi_CMIP6_hist_stdev)
            if k < 2
                plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist_stdev{k},'Color',colors.orange,...
                    'DisplayName','historical');
            else
                plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist_stdev{k},'Color',colors.orange,...
                    'HandleVisibility','off');
            end
        end
        
        for k = 1 : length(gbi_CMIP6_scen245_stdev)
            if k < 2
                plot(gbi_CMIP6_scen245{k}.time,gbi_CMIP6_scen245_stdev{k},'g',...
                    'DisplayName','SSP245');
            else
                plot(gbi_CMIP6_scen245{k}.time,gbi_CMIP6_scen245_stdev{k},'g',...
                    'HandleVisibility','off');
            end
        end
        
        for k = 1 : length(gbi_CMIP6_scen585_stdev)
            if k < 2
                plot(gbi_CMIP6_scen585{k}.time,gbi_CMIP6_scen585_stdev{k},'b',...
                    'DisplayName','SSP585');
            else
                plot(gbi_CMIP6_scen585{k}.time,gbi_CMIP6_scen585_stdev{k},'b',...
                    'HandleVisibility','off');
            end
        end
        
        xlim([x_min x_max]); ylim([y_min y_max]); legend show
        title(['GBI from CMIP6-SSP245 and SSP585 - running standard deviation (' num2str(ws_std) ' months)']);
        ylabel('running standard deviation'); hold off;
        
    end
end

