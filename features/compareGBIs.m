%% compareGBIs
% comparison of GBIs from NOAA, ERA5 and CMIP6 historical simulations
%
% susann.aschenneller@uni-bonn.de, 08/2019

%% settings
clearvars; close all; clc;
f = filesep;
addpath(genpath(cd), genpath(['..' f 'functions']), genpath(['..' f 'data' f 'GBI']));

plot_historical = true;          % plot historical data
plot_future = true;              % plot historical data from future scenarios SSP245 and SSP585
plot_stdev = true;               % running standard deviation
plot_historicalAndFuture = true; % creates a 'messy-plot'

%% load data
% NOAA downloaded GBI
temp = load('GBI1.data');
gbi_NOAA = struct('time',datetime(temp(:,1),temp(:,2),temp(:,3),'Format','dd.MM.yyyy'));
gbi_NOAA = setfield(gbi_NOAA,'GBI',temp(:,4));
clear temp;

% ERA5 geopotential
gbi_ERA5 = load('C:\Users\Lenovo\Documents\Master\DMI-north_atlantic_oscillation\data\GBI\ERA5\GBI_ERA5.mat');
gbi_ERA5 = gbi_ERA5.GBI;

% CMIP6 historical
path = '..\data\GBI\CMIP6_zg_historical\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_CMIP6_hist{i} = temp.GBI;
    gbi_CMIP6_hist{i}.name = strrep(folderContents(i).name,'_',' ');
end

% CMIP6 SSP245
path = '..\data\GBI\CMIP6_zg_ssp245\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_CMIP6_scen245{i} = temp.GBI;
    gbi_CMIP6_scen245{i}.name = strrep(folderContents(i).name,'_',' ');
end

% CMIP6 SSP585
path = '..\data\GBI\CMIP6_zg_ssp585\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_CMIP6_scen585{i} = temp.GBI;
    gbi_CMIP6_scen585{i}.name = strrep(folderContents(i).name,'_',' ');
end

%% Todo: Correct future data by 
    % - seasonal mean (e.g. 12-months-filter)
    % - warming effect --> subtract mean over all longitudes

%% Filtering
a = 1;
% window size for daily data
ws_filt = 36;
b = (1/ws_filt)*ones(1,ws_filt);

% compute filtered time series
gbi_NOAA_filt = filter(b,a,gbi_NOAA.GBI);

%% Colors!
colors = struct('orange',[0.9290, 0.6940, 0.1250]);
colors.darkgreen = [0, 0.5, 0];
colors.lila = [138,43,226] ./ 255;
colors.greenyellow = [173,255,47] ./ 255;
colors.DarkGoldenrod1 = [255,185,15] ./ 255;
colors.MediumPurple4 = [93,71,139] ./ 255;
colors.IndianRed = [255,106,106] ./ 255;
colors.turquoise4 = [0,134,139] ./ 255;

%% plots: averaged geopotential height
%  only historical (more detailed - 2 parts with 5 models per plot)
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

%% running standard deviation
% window size
ws_std = 60; % [months]

% moving standard deviations
for k = 1 : length(gbi_CMIP6_hist)
    gbi_CMIP6_hist_stdev{k} = movstd(gbi_CMIP6_hist{k}.GBI,ws_std);
end

for k = 1 : length(gbi_CMIP6_scen245)
    gbi_CMIP6_scen245_stdev{k} = movstd(gbi_CMIP6_scen245{k}.GBI,ws_std);
end

for k = 1 : length(gbi_CMIP6_scen585)
    gbi_CMIP6_scen585_stdev{k} = movstd(gbi_CMIP6_scen585{k}.GBI,ws_std);
end

%% plots: running standard deviation
if plot_stdev == true
    %  only historical
    if plot_historical == true
        x_min = datetime(1979,1,1);x_max = datetime(2015,1,1);
        y_min = 120; y_max = 220;
        
        figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
        
        for k = 1 : length(gbi_CMIP6_hist_stdev)
            plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist_stdev{k},...
                'DisplayName',[gbi_CMIP6_hist{k}.name]);
        end
        
        xlim([x_min x_max]); ylim([y_min y_max]); legend show
        title(['GBI from CMIP6-historical - running standard deviation (' num2str(ws_std) ' months)']);
        ylabel('running standard deviation'); hold off;
        
    end
     %  only future
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
    
    % historical and future
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

