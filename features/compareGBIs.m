%% compareGBIs
% comparison of GBIs from NOAA, ERA5 and CMIP6 historical simulations
%
% susann.aschenneller@uni-bonn.de, 08/2019
%
% Contents:
%   0.settings
%   1. Load data
%       1.1 Equalize timespans
%   2. Corrections / Reductions
%       2.1 Monthly means of daily NOAA data
%       2.2 Computation of annual means
%       2.3 Subtraction of annual mean from 'raw' GBI
%       2.4 Reduction for annual cycle (12-months-filter)
%   3. Running standard deviation
%   4. Plots
%       4.1 General definitions
%       4.2 Historical simulation
%       4.3 Future scenarios
%       4.4 Historical simulation AND future scenarios 
%       4.5 Running standard deviation
%           4.5.1 Historical simulation
%           4.5.2 Future scenarios
%           4.5.3 Historical simulation AND future scenarios

%% 0.settings
clearvars; close all; clc;
f = filesep;
addpath(genpath(cd), genpath(['..' f 'functions']), genpath(['..' f 'data' f 'GBI']),...
    genpath(['..' f 'data' f 'GBI_zonal']));

% *** INPUT ***
% -------------------------------------------------------------------------

% Plot or not
plot_historical = false;          % plot historical data
plot_future = true;              % plot historical data from future scenarios SSP245 and SSP585
plot_stdev = false;               % running standard deviation
plot_historicalAndFuture = false; % creates a 'messy-plot'

% select timespan
day_start_hist = datetime(1978,01,01); % one year from the start day on gets cut off 
                                       % because of the 12-month-filter in section 2.2
day_end_hist = datetime(2014,12,31);
day_start_fut = datetime(2015,01,01); % one year from the start day on gets cut off 
                                      % because of the 12-month-filter in section 2.2
day_end_fut = datetime(2099,12,31);

% -------------------------------------------------------------------------

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
    gbi_CMIP6_hist{i}.name = erase(gbi_CMIP6_hist{i}.name,' historical r1i1p1f2 gn.mat');    
    gbi_CMIP6_hist{i}.name = erase(gbi_CMIP6_hist{i}.name,' historical r1i1p1f1 gr.mat');
    gbi_CMIP6_hist{i}.name = erase(gbi_CMIP6_hist{i}.name,' historical r1i1p1f2 gr.mat');
end

% CMIP6 SSP245
path = '..\data\GBI\CMIP6_zg_ssp245\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_CMIP6_scen245{i} = temp.GBI;
    gbi_CMIP6_scen245{i}.name = strrep(folderContents(i).name,'_',' ');
    gbi_CMIP6_scen245{i}.name = erase(gbi_CMIP6_scen245{i}.name,'GBI zg Amon ');
    gbi_CMIP6_scen245{i}.name = erase(gbi_CMIP6_scen245{i}.name,'r1i1p1f1 gn');
    gbi_CMIP6_scen245{i}.name = erase(gbi_CMIP6_scen245{i}.name,'r1i1p1f2 gn');
    gbi_CMIP6_scen245{i}.name = erase(gbi_CMIP6_scen245{i}.name,'r1i1p1f1 gr');
    gbi_CMIP6_scen245{i}.name = erase(gbi_CMIP6_scen245{i}.name,'r1i1p1f2 gr');
    gbi_CMIP6_scen245{i}.name = erase(gbi_CMIP6_scen245{i}.name,'.nc.mat');       
end

% CMIP6 SSP585
path = '..\data\GBI\CMIP6_zg_ssp585\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_CMIP6_scen585{i} = temp.GBI;
    gbi_CMIP6_scen585{i}.name = strrep(folderContents(i).name,'_',' ');
    gbi_CMIP6_scen585{i}.name = erase(gbi_CMIP6_scen585{i}.name,'GBI zg Amon ');
    gbi_CMIP6_scen585{i}.name = erase(gbi_CMIP6_scen585{i}.name,'r1i1p1f1 gn');
    gbi_CMIP6_scen585{i}.name = erase(gbi_CMIP6_scen585{i}.name,'r1i1p1f2 gn');
    gbi_CMIP6_scen585{i}.name = erase(gbi_CMIP6_scen585{i}.name,'r1i1p1f1 gr');
    gbi_CMIP6_scen585{i}.name = erase(gbi_CMIP6_scen585{i}.name,'r1i1p1f2 gr');
    gbi_CMIP6_scen585{i}.name = erase(gbi_CMIP6_scen585{i}.name,'.nc.mat'); 
end

% --- zonal "GBI" ---
% ... this is no real GBI, than rather an areal mean of data between the
% GBI-latitudes and all longitudes around the world
% CMIP6 SSP245

path = '..\data\GBI_zonal\CMIP6_zg_ssp245\';
folderContents = dir(strcat(path, '*.mat'));
for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_zonal_CMIP6_scen245{i} = temp.GBI;
end

% CMIP6 SSP585
path = '..\data\GBI_zonal\CMIP6_zg_ssp585\';
folderContents = dir(strcat(path, '*.mat'));
for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_zonal_CMIP6_scen585{i} = temp.GBI;    
end

%% 1.1 Equalize timespans
force_no_boundary_usage = false;

gbi_NOAA = select_timespan( gbi_NOAA, day_start_hist, day_end_hist, force_no_boundary_usage );
gbi_ERA5 = select_timespan( gbi_ERA5, day_start_hist, day_end_hist, force_no_boundary_usage );

for k = 1 : length(gbi_CMIP6_hist)
    gbi_CMIP6_hist{k} = select_timespan( gbi_CMIP6_hist{k}, day_start_hist, day_end_hist, force_no_boundary_usage );
end

for k = 1 : length(gbi_CMIP6_scen245)
    gbi_CMIP6_scen245{k} = select_timespan( gbi_CMIP6_scen245{k}, day_start_fut, day_end_fut, force_no_boundary_usage );
end

for k = 1 : length(gbi_CMIP6_scen585)
    gbi_CMIP6_scen585{k} = select_timespan( gbi_CMIP6_scen585{k}, day_start_fut, day_end_fut, force_no_boundary_usage );
end

for k = 1 : length(gbi_zonal_CMIP6_scen245)
    gbi_zonal_CMIP6_scen245{k} = select_timespan( gbi_zonal_CMIP6_scen245{k}, day_start_fut, day_end_fut, force_no_boundary_usage );
end

for k = 1 : length(gbi_zonal_CMIP6_scen585)
    gbi_zonal_CMIP6_scen585{k} = select_timespan( gbi_zonal_CMIP6_scen585{k}, day_start_fut, day_end_fut, force_no_boundary_usage );
end

%% 2. Corrections / Reductions

%% 2.1 Monthly means of daily NOAA data
gbi_NOAA_mon = monthlyMeanFilter(gbi_NOAA);
   
%% 2.2 Computation of annual means
% 1 mean for each 12-month-period and for each model
% especially for correction of changes only because of warming in the future scenarios

gbi_mean_NOAA = meanFilter(gbi_NOAA_mon,12);
gbi_mean_ERA5 = meanFilter(gbi_ERA5,12);

for k = 1 : length(gbi_CMIP6_hist)
    gbi_mean_CMIP6_hist{k} = meanFilter(gbi_CMIP6_hist{k},12);
end

% SSP245 and SSP585: annual means over all longitudes
for k = 1 : length(gbi_zonal_CMIP6_scen245)
   gbi_zonal_mean_CMIP6_scen245{k} = meanFilter(gbi_zonal_CMIP6_scen245{k},12);
end

for k = 1 : length(gbi_zonal_CMIP6_scen585)
   gbi_zonal_mean_CMIP6_scen585{k} = meanFilter(gbi_zonal_CMIP6_scen585{k},12);
end

%% 2.3 Subtraction of annual mean from 'raw' GBI
gbi_NOAA_mon_temp{1} = gbi_NOAA_mon; gbi_mean_NOAA_temp{1} = gbi_mean_NOAA; % cheat the function...
gbi_ERA5_temp{1} = gbi_ERA5; gbi_mean_ERA5_temp{1} = gbi_mean_ERA5; % cheat the function...
gbi_NOAA_red = subtract_annual_zonal_mean(gbi_NOAA_mon_temp,gbi_mean_NOAA_temp);
gbi_ERA5_red = subtract_annual_zonal_mean(gbi_ERA5_temp,gbi_mean_ERA5_temp);

gbi_CMIP6_hist_red = subtract_annual_zonal_mean(gbi_CMIP6_hist,gbi_mean_CMIP6_hist);

gbi_CMIP6_scen245_red = subtract_annual_zonal_mean(gbi_CMIP6_scen245,gbi_zonal_mean_CMIP6_scen245);
gbi_CMIP6_scen585_red = subtract_annual_zonal_mean(gbi_CMIP6_scen585,gbi_zonal_mean_CMIP6_scen585);

clear gbi_NOAA_mon_temp gbi_mean_NOAA_temp gbi_ERA5_temp gbi_mean_ERA5_temp

%% 2.4 Reduction for annual cycle (12-months-filter)
a = 1;
% window size for monthly data
ws = 12; % [months]
b = (1/ws)*ones(1,ws);

gbi_NOAA_filt = filter(b,a,gbi_NOAA_red{1});
gbi_ERA5_filt = filter(b,a,gbi_ERA5_red{1});

% cut off the first 12 months (= filter error)
gbi_NOAA_filt(1:12) = NaN;
gbi_ERA5_filt(1:12) = NaN;

for k = 1 : length(gbi_CMIP6_hist)
    gbi_CMIP6_hist_filt{k} = filter(b,a,(gbi_CMIP6_hist_red{k}));
    % cut off the first 12 months (= filter error)
    gbi_CMIP6_hist_filt{k}(1:12) = NaN;
end

for k = 1 : length(gbi_CMIP6_scen245)
    gbi_CMIP6_scen245_filt{k} = filter(b,a,(gbi_CMIP6_scen245_red{k}));
    % cut off the first 12 months (= filter error)
    gbi_CMIP6_scen245_filt{k}(1:12) = NaN;
end

for k = 1 : length(gbi_CMIP6_scen585)
    gbi_CMIP6_scen585_filt{k} = filter(b,a,(gbi_CMIP6_scen585_red{k}));
    % cut off the first 12 months (= filter error)
    gbi_CMIP6_scen585_filt{k}(1:12) = NaN;
end

%% 3. Running standard deviation
% window size
ws_std = 60; % [months]

gbi_NOAA_stdev = movstd(gbi_NOAA_filt,ws_std);
gbi_ERA5_stdev = movstd(gbi_ERA5_filt,ws_std);

% moving standard deviations
for k = 1 : length(gbi_CMIP6_hist)
    gbi_CMIP6_hist_stdev{k} = movstd(gbi_CMIP6_hist_filt{k},ws_std);
end

for k = 1 : length(gbi_CMIP6_scen245)
    gbi_CMIP6_scen245_stdev{k} = movstd(gbi_CMIP6_scen245_filt{k},ws_std);
end

for k = 1 : length(gbi_CMIP6_scen585)
    gbi_CMIP6_scen585_stdev{k} = movstd(gbi_CMIP6_scen585_filt{k},ws_std);
end

%% 4. Plots
%% 4.1 General definitions
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
colors.grey = [102,102,102] ./ 255;

% this is for manual line specifications in a for-loop
line_spec{1,1} = colors.blue;
line_spec{2,1} = colors.turquoise4;
line_spec{3,1} = colors.red;
line_spec{4,1} = colors.grey;
line_spec{5,1} = colors.orange;
line_spec{6,1} = colors.IndianRed;
line_spec{7,1} = colors.greenyellow;
line_spec{8,1} = colors.DarkGoldenrod1;
line_spec{9,1} = colors.darkgreen;
line_spec{10,1} = colors.lila;

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

%% 4.2 Historical simulation
%% 4.2.1 - 5 models per plot
if plot_historical == true
    % axis settings
    x_min = day_start_hist + years(1); x_max = day_end_hist;
    y_min = -80; y_max = 50;  
    
    % --- Part 1 ---
    h = figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
    
    % plot first 5 historical models individually
    for k = 1 : 5
        plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist_filt{k},'LineWidth',lw1,...
            'DisplayName', gbi_CMIP6_hist{k}.name);
    end
    % references
%     plot(gbi_NOAA_mon.time,gbi_NOAA_filt,'Color',colors.grey,'LineWidth',lw1,...
%         'DisplayName','NOAA');
    plot(gbi_ERA5.time,gbi_ERA5_filt,'k','LineWidth',lw1,...
        'DisplayName','ERA5');
    
    xlim([x_min x_max]); ylim([y_min y_max]);
    legend('show','Location','southoutside');
    title('GBI CMIP6 historical Part 1');
    hold off;
    orient(h,'landscape');
    print(h,'-append','-dpsc','historical - 5 models per plot.ps');
    
    % --- Part 2 ---
    h = figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
        
    % plot second 5 historical models individually
    for k = 6 : length(gbi_CMIP6_hist_filt)
        plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist_filt{k},'LineWidth',lw1,...
            'DisplayName',gbi_CMIP6_hist{k}.name);
    end
    % references
% plot(gbi_NOAA_mon.time,gbi_NOAA_filt,'Color',colors.grey,'LineWidth',lw1,...
%         'DisplayName','NOAA');
    plot(gbi_ERA5.time,gbi_ERA5_filt,'k','LineWidth',lw1,...
        'DisplayName','ERA5');
    
    xlim([x_min x_max]); ylim([y_min y_max]);
    legend('show','Location','southoutside');
    title('GBI CMIP6 historical Part 2');
    hold off;    
    orient(h,'landscape');
    print(h,'-append','-dpsc','historical - 5 models per plot.ps');
end

%% 4.2.2 - 1 model per plot
if plot_historical == true
    % axis settings
    x_min = day_start_hist + years(1); x_max = day_end_hist;
    y_min = -80; y_max = 50;
    
    for k = 1 : length(gbi_CMIP6_hist_filt)
        h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
        
        % references
%         plot(gbi_NOAA_mon.time,gbi_NOAA_filt,'Color',colors.grey,'LineWidth',lw1,...
%             'DisplayName','NOAA');
        plot(gbi_ERA5.time,gbi_ERA5_filt,'k','LineWidth',lw1,...
            'DisplayName','ERA5');
        % CMIP6 - 1 model per plot
        plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist_filt{k},'LineWidth',lw1,...
            'Color',line_spec{k,1},'DisplayName',gbi_CMIP6_hist{k}.name);
        
        xlim([x_min x_max]); ylim([y_min y_max]);
        legend('show','Location','southoutside');
        title(['GBI CMIP6 historical ' gbi_CMIP6_hist{k}.name]);
        hold off;
        orient(h,'landscape');
        print(h,'-append','-dpsc','historical - 1 model per plot.ps');
    end    
end

%% 4.3 Future scenarios
if plot_future == true
    x_min = day_start_fut + years(1); x_max = day_end_fut;
    y_min = -70; y_max = 70;
    
    % --- SSP245 ---
    figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
    
    for k = 1 : length(gbi_CMIP6_scen245_filt)
        plot(gbi_CMIP6_scen245{k}.time,gbi_CMIP6_scen245_filt{k},...
            'DisplayName',gbi_CMIP6_scen245{k}.name);
    end
    
    xlim([x_min x_max]); ylim([y_min y_max]);
    legend('show','Location','southoutside');
    title('GBI SSP245');
    hold off;
    
    % --- SSP585 ---
    figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
    
    for k = 1 : length(gbi_CMIP6_scen585_filt)
        plot(gbi_CMIP6_scen585{k}.time,gbi_CMIP6_scen585_filt{k},...
            'DisplayName',gbi_CMIP6_scen585{k}.name);
    end
    
    xlim([x_min x_max]); ylim([y_min y_max]);
    legend('show','Location','southoutside');
    title('GBI SSP585');
    hold off;
    
    % --- SSP245 and SSP585 ---
    figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
    
    for k = 1 : length(gbi_CMIP6_scen245_filt)
        if k < 2
            plot(gbi_CMIP6_scen245{k}.time,gbi_CMIP6_scen245_filt{k},'g',...
                'DisplayName','SSP245');
        else
            plot(gbi_CMIP6_scen245{k}.time,gbi_CMIP6_scen245_filt{k},'g',...
                'HandleVisibility','off');
        end
    end
    
    for k = 1 : length(gbi_CMIP6_scen585_filt)
        if k < 2
            plot(gbi_CMIP6_scen585{k}.time,gbi_CMIP6_scen585_filt{k},'b',...
                'DisplayName','SSP585');
        else
            plot(gbi_CMIP6_scen585{k}.time,gbi_CMIP6_scen585_filt{k},'b',...
                'HandleVisibility','off');
        end
    end
    
    xlim([x_min x_max]); ylim([y_min y_max]);
    legend('show','Location','southoutside');
    title('GBI SSP245 and SSP585');
    ylabel('running standard deviation'); hold off;    
end

%% 4.4 Historical simulation AND future scenarios 
% xxxxxx improve colors in the following part
if plot_historicalAndFuture == true % historical & future
    x_min = day_start_hist + years(1); x_max = day_end_fut;
    y_min = -75; y_max = 75;
    
    figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;    
   
    % references
    plot(gbi_NOAA_mon.time,gbi_NOAA_filt,'Color',colors.grey,'LineWidth',lw1,...
        'DisplayName','NOAA');
    plot(gbi_ERA5.time,gbi_ERA5_filt,'k','LineWidth',lw1,...
        'DisplayName','ERA5');
    
    % all historical models
    for k = 1 : length(gbi_CMIP6_hist)
        plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist_filt{k},...
            'DisplayName',gbi_CMIP6_hist{k}.name);
    end
    
    % all future models - SSP245
    for k = 1 : length(gbi_CMIP6_scen245)
        plot(gbi_CMIP6_scen245{k}.time,gbi_CMIP6_scen245_filt{k},...
            'DisplayName',['CMIP6 SSP245 ' gbi_CMIP6_hist{k}.name]);
    end
    
    % all future models - SSP585
    for k = 1 : length(gbi_CMIP6_scen585)
        plot(gbi_CMIP6_scen585{k}.time,gbi_CMIP6_scen585_filt{k},...
            'DisplayName',['CMIP6 SSP585 ' gbi_CMIP6_hist{k}.name]);
    end
     
    xlim([x_min x_max]); ylim([y_min y_max]);
    legend('show','Location','westoutside');
    title('GBI - CMIP6 historical, SSP245 and SSP585');
    ylabel('GBI [m]'); hold off;   
end


%% 4.5 Running standard deviation
if plot_stdev == true
%%  4.5.1 Historical simulation
    if plot_historical == true
        x_min = day_start_hist + years(1); x_max = day_end_hist;
        y_min = 0; y_max = 35;
        
        h = figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
        
        % references
        plot(gbi_NOAA_mon.time,gbi_NOAA_stdev,'k-.','LineWidth',lw1,'DisplayName',['NOAA 30*' num2str(ws_std) ' days filter']);
        plot(gbi_ERA5.time,gbi_ERA5_stdev,'k','LineWidth',lw1,'DisplayName','ERA5');
        
        % CMIP6 historical
        for k = 1 : length(gbi_CMIP6_hist_stdev)
            plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist_stdev{k},'Color',line_spec{k,1},'LineStyle',line_spec{k,2},...
                'DisplayName',[gbi_CMIP6_hist{k}.name],'LineWidth',lw1);
        end
        
        xlim([x_min x_max]); ylim([y_min y_max]);
        legend('show','Location','southoutside');
        title(['GBI CMIP6 historical - running standard deviation (' num2str(ws_std) ' months)']);
        ylabel('running standard deviation'); hold off;
        
%         orient(h,'landscape');
%         print(h,'-dpdf','GBI historical running standard deviation.pdf','-fillpage');
    end
%%  5.5.2 Future scenarios
     if plot_future == true
         x_min = day_start_fut + years(1); x_max = day_end_fut;
         y_min = 0; y_max = 35;
         
         % --- SSP245 ---
         figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
         
         for k = 1 : length(gbi_CMIP6_scen245_stdev)
             plot(gbi_CMIP6_scen245{k}.time,gbi_CMIP6_scen245_stdev{k},...
                 'DisplayName',[gbi_CMIP6_scen245{k}.name]);
         end
         
         xlim([x_min x_max]); ylim([y_min y_max]);
         legend('show','Location','southoutside');
         title(['GBI CMIP6 SSP245 - running standard deviation (' num2str(ws_std) ' months)']);
         ylabel('running standard deviation'); hold off;
         
         % --- SSP585 ---
         figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
         
         for k = 1 : length(gbi_CMIP6_scen585_stdev)
             plot(gbi_CMIP6_scen585{k}.time,gbi_CMIP6_scen585_stdev{k},...
                 'DisplayName',[gbi_CMIP6_scen585{k}.name]);
         end
         
         xlim([x_min x_max]); ylim([y_min y_max]);
         legend('show','Location','southoutside');
         title(['GBI CMIP6 SSP585 - running standard deviation (' num2str(ws_std) ' months)']);
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
         
         xlim([x_min x_max]); ylim([y_min y_max]);
         legend('show','Location','southoutside');
         title(['GBI CMIP6 SSP245 and SSP585 - running standard deviation (' num2str(ws_std) ' months)']);
         ylabel('running standard deviation'); hold off;
         
     end
    
%%  5.5.3 Historical simulation AND future scenarios
    if plot_historicalAndFuture == true % historical & future   
         x_min = day_start_hist + years(1); x_max = day_end_fut;
         y_min = 0; y_max = 35;
        
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
        
        xlim([x_min x_max]); ylim([y_min y_max]);
        legend('show','Location','southoutside');
        title(['GBI from CMIP6 - historical, SP245 and SSP585 - running standard deviation (' num2str(ws_std) ' months)']);
        ylabel('running standard deviation'); hold off;
        
    end
end

