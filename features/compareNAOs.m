%% compareNAOs
% comparison of NAOs from NOAA/CRU, ERA5, CMIP6 historical simulations and
% CMIP6 future projections (scenarios 245 and 585)
%
% susann.aschenneller@uni-bonn.de, 08/2019
%
% Contents:
%   0. settings
%   1. NAO data preparation
%       1.1 already calculated naos downloaded from NOAA/CRU
%       1.2 computed as pressure differences with data from ERA5
%       1.3 computed as pressure differences with data from CMIP6 - historical
%       1.4 computed as pressure differences with data from CMIP6 - scenario ssp245
%       1.5 computed as pressure differences with data from CMIP6 - scenario ssp585
%       1.6 Equalize timespans
%   2. Mean Computation
%   3. Filtering
%   4. Plots
%       4.1 General definitions
%       4.2 CMIP6 historical simulations compared to NOAA/CRU/ERA5
%       4.3 CMIP6 historical simulations AND future projections compared to NOAA/CRU/ERA5
%   5. Evaluation of negative/positive NAOs
%       5.1 The 'usual' plots
%       5.2 Counting several sequent positive/negative values
%       5.3 Graphical representation of several sequent neg/pos values
%       5.4 Statistics

%% 0. settings
clearvars; close all; clc;
f = filesep;
addpath(genpath(cd), genpath(['..' f 'functions']), genpath(['..' f 'data' f 'nao']));

% *** INPUT ***
% -------------------------------------------------------------------------
% prepare_nao-Input
season = 'winter';      % The season to be selected out of the data. You have the choice
                        % between winter (DJF), spring(MAM), summer(JJA), autumn(SON).
extractNegPos = true;   % If negative/positive NAOs get extracted
extrNPFromSeas = false; % True if the negative/positive NAO should be subtracted from
                        % the already monthly-extracted data. false if you want to
                        % extract of the whole year.
truncate = 1979;        % Use data only after this date
plotmean = true;        % Plot the mean over all models in the all-together-plot
                        % (historical and future projections)

% Plot or not
plot_historical = true;                % see 4.2, Plot historical data
plot_historicalAndFuture = true;       % see 4.3, Creates a 'messy-plot'
plot_negposBars = false;                % see 5.1, the classical bar plot of the dates of negative/positive NAOs
plotNegPosNAOVisualization = false;     % see 5.3, NAO persistence 
plot_negposStatistics = false;          % see 5.4, bar plots with the number of occurrences of negative/positive NAOs

% select timespan
day_start_hist = datetime(1979,01,01);
day_end_hist = datetime(2014,12,01);
day_start_fut = datetime(2080,01,01);
day_end_fut = datetime(2100,10,01);

% -------------------------------------------------------------------------

%% 1. NAO data preparation
% general
switch season
    case 'winter'
        extractMonths = [12 1 2]; title_seas = 'winter months (DJF)';
    case 'spring'
        extractMonths = [3 4 5]; title_seas = 'spring months (MAM)';
    case 'summer'
        extractMonths = [6 7 8]; title_seas = 'summer months (JJA)';
    case 'autumn'
        extractMonths = [9 10 11]; title_seas = 'autumn months (SON)';
end

%% 1.1 already calculated naos downloaded from NOAA/CRU
% for details of the different files have a look at 'nao_overview.ods'
% settings
folderName = 'NOAA_CRU_already calculated';
reshape_1 = true;
replace_1 = -99.99;

% NOAA monthly
[~,~,nao_NOAA_wint,nao_NOAA_neg,nao_NOAA_pos] = prepareNAOs([folderName f 'nao_1.data'],...
    reshape_1,replace_1,truncate,extractMonths,extractNegPos,extrNPFromSeas);
% CRU monthly
[~,~,nao_CRU_wint,nao_CRU_neg,nao_CRU_pos] = prepareNAOs([folderName f 'nao_2.data'],...
    reshape_1,replace_1,truncate,extractMonths,extractNegPos,extrNPFromSeas);

%% 1.2 computed as pressure differences with data from ERA5
% settings
folderName = 'ERA5';
reshape_2 = false;
replace_2 = [];

[~,~,nao_ERA5_wint,nao_ERA5_neg,nao_ERA5_pos] = prepareNAOs([folderName f 'diffNAO_ERA5.mat'],...
    reshape_2,replace_2,truncate, extractMonths,extractNegPos,extrNPFromSeas);

%% 1.3 computed as pressure differences with data from CMIP6 - historical
% settings
reshape_3 = false;
replace_3 = [];

path = '..\data\nao\CMIP6_psl historical\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    [~,~,nao_CMIP6_hist{i},nao_CMIP6_hist_neg{i},nao_CMIP6_hist_pos{i}] = prepareNAOs(strcat(path,folderContents(i).name),...
        reshape_3,replace_3,truncate, extractMonths,extractNegPos,extrNPFromSeas);
    nao_CMIP6_hist{i}.name = strrep(folderContents(i).name,'_',' ');
    nao_CMIP6_hist{i}.name = erase(nao_CMIP6_hist{i}.name,'diffNAO psl Amon ');
    nao_CMIP6_hist{i}.name = erase(nao_CMIP6_hist{i}.name,' historical r1i1p1f1 gn.mat');
    nao_CMIP6_hist{i}.name = erase(nao_CMIP6_hist{i}.name,' historical r1i1p1f1 gn.nc.mat');
    nao_CMIP6_hist{i}.name = erase(nao_CMIP6_hist{i}.name,' historical r1i1p1f2 gn.nc.mat');
    nao_CMIP6_hist{i}.name = erase(nao_CMIP6_hist{i}.name,' historical r1i1p1f1 gr.nc.mat');
    nao_CMIP6_hist{i}.name = erase(nao_CMIP6_hist{i}.name,' historical r1i1p1f2 gr.nc.mat');
end

%% 1.4 computed as pressure differences with data from CMIP6 - scenario ssp245
% settings
reshape_4 = false;
replace_4 = [];

path = '..\data\nao\CMIP6_psl_scenarios_ssp245\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    [~,~,nao_CMIP6_scen245{i},nao_CMIP6_scen245_neg{i},nao_CMIP6_scen245_pos{i}] ...
        = prepareNAOs(strcat(path,folderContents(i).name),...
        reshape_4,replace_4,truncate, extractMonths,extractNegPos,extrNPFromSeas);
    nao_CMIP6_scen245{i}.name = strrep(folderContents(i).name,'_',' ');
    nao_CMIP6_scen245{i}.name = erase(nao_CMIP6_scen245{i}.name,'diffNAO psl Amon ');
    nao_CMIP6_scen245{i}.name = erase(nao_CMIP6_scen245{i}.name,' ssp245 r1i1p1f1nc.mat');
    nao_CMIP6_scen245{i}.name = erase(nao_CMIP6_scen245{i}.name,' ssp245 r1i1p1f1.mat');
    nao_CMIP6_scen245{i}.name = erase(nao_CMIP6_scen245{i}.name,' ssp245 r1i1p1f2.mat');
end

%% 1.5 computed as pressure differences with data from CMIP6 - scenario ssp585
% settings
reshape_5 = false;
replace_5 = [];

path = '..\data\nao\CMIP6_psl_scenarios_ssp585\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    [~,~,nao_CMIP6_scen585{i},nao_CMIP6_scen585_neg{i},nao_CMIP6_scen585_pos{i}]...
        = prepareNAOs(strcat(path,folderContents(i).name),...
        reshape_5,replace_5,truncate, extractMonths,extractNegPos,extrNPFromSeas);
    nao_CMIP6_scen585{i}.name = strrep(folderContents(i).name,'_',' ');
    nao_CMIP6_scen585{i}.name = erase(nao_CMIP6_scen585{i}.name,'diffNAO psl Amon ');
    nao_CMIP6_scen585{i}.name = erase(nao_CMIP6_scen585{i}.name,' ssp585 r1i1p1f1nc.mat');
    nao_CMIP6_scen585{i}.name = erase(nao_CMIP6_scen585{i}.name,' ssp585 r1i1p1f1.mat');
    nao_CMIP6_scen585{i}.name = erase(nao_CMIP6_scen585{i}.name,' ssp585 r1i1p1f2.mat');
    nao_CMIP6_scen585{i}.name = erase(nao_CMIP6_scen585{i}.name,' ssp585 r1i1p1f1-230012.mat');
end

clear truncate extractMonths extractNegPos reshape_1 reshape_2 reshape_3...
    reshape_4 reshape_5 replace_1  replace_2 replace_3 replace_4 replace_5...
    folderName folderContents f path

%% 1.6 Equalize timespans
force_no_boundary_usage = false;

nao_NOAA_wint = select_timespan( nao_NOAA_wint, day_start_hist, day_end_hist, force_no_boundary_usage );
nao_NOAA_neg = select_timespan( nao_NOAA_neg, day_start_hist, day_end_hist, force_no_boundary_usage );
nao_NOAA_pos = select_timespan( nao_NOAA_pos, day_start_hist, day_end_hist, force_no_boundary_usage );
nao_CRU_wint = select_timespan( nao_CRU_wint, day_start_hist, day_end_hist, force_no_boundary_usage );
nao_CRU_neg = select_timespan( nao_CRU_neg, day_start_hist, day_end_hist, force_no_boundary_usage );
nao_CRU_pos = select_timespan( nao_CRU_pos, day_start_hist, day_end_hist, force_no_boundary_usage );
nao_ERA5_wint = select_timespan( nao_ERA5_wint, day_start_hist, day_end_hist, force_no_boundary_usage );
nao_ERA5_neg = select_timespan( nao_ERA5_neg, day_start_hist, day_end_hist, force_no_boundary_usage );
nao_ERA5_po = select_timespan( nao_ERA5_pos, day_start_hist, day_end_hist, force_no_boundary_usage );

for k = 1 : length(nao_CMIP6_hist)
    nao_CMIP6_hist{k} = select_timespan( nao_CMIP6_hist{k}, day_start_hist, day_end_hist, force_no_boundary_usage );
    nao_CMIP6_hist_neg{k} = select_timespan( nao_CMIP6_hist_neg{k}, day_start_hist, day_end_hist, force_no_boundary_usage );
    nao_CMIP6_hist_pos{k} = select_timespan( nao_CMIP6_hist_pos{k}, day_start_hist, day_end_hist, force_no_boundary_usage );
end

for k = 1 : length(nao_CMIP6_scen245)
    nao_CMIP6_scen245{k} = select_timespan( nao_CMIP6_scen245{k}, day_start_fut, day_end_fut, force_no_boundary_usage );
    nao_CMIP6_scen245_neg{k} = select_timespan( nao_CMIP6_scen245_neg{k}, day_start_fut, day_end_fut, force_no_boundary_usage );
    nao_CMIP6_scen245_pos{k} = select_timespan( nao_CMIP6_scen245_pos{k}, day_start_fut, day_end_fut, force_no_boundary_usage );
end

for k = 1 : length(nao_CMIP6_scen585)
    nao_CMIP6_scen585{k} = select_timespan( nao_CMIP6_scen585{k}, day_start_fut, day_end_fut, force_no_boundary_usage );
    nao_CMIP6_scen585_neg{k} = select_timespan( nao_CMIP6_scen585_neg{k}, day_start_fut, day_end_fut, force_no_boundary_usage );
    nao_CMIP6_scen585_pos{k} = select_timespan( nao_CMIP6_scen585_pos{k}, day_start_fut, day_end_fut, force_no_boundary_usage );
end

%% 2. Mean Computation
% for CMIP6_historical, CMIP6_scen245 and CMIP6_scen585 individual
% mean over all models for each sceanrio respectively

[nao_CMIP6_hist_mean,time_interp_hist] = compute_mean_NAOs(nao_CMIP6_hist);
[nao_CMIP6_scen245_mean,time_interp_scen245] = compute_mean_NAOs(nao_CMIP6_scen245);
[nao_CMIP6_scen585_mean,time_interp_scen585] = compute_mean_NAOs(nao_CMIP6_scen585);

%% 3. Filtering
a = 1;
% window size for monthly data
ws = 3; % average of 3 values
b = (1/ws)*ones(1,ws);

% compute filtered time series
nao_1_filt = filter(b,a,nao_NOAA_wint.nao);
nao_2_filt = filter(b,a,nao_CRU_wint.nao);
nao_era5_filt = filter(b,a,nao_ERA5_wint.nao);

for k = 1 : length(nao_CMIP6_hist)
    nao_CMIP6_hist_filt{k} = filter(b,a, nao_CMIP6_hist{k}.nao);
end

for k = 1 : length(nao_CMIP6_scen245)
    nao_CMIP6_scen245_filt{k} = filter(b,a, nao_CMIP6_scen245{k}.nao);
end

for k = 1 : length(nao_CMIP6_scen585)
    nao_CMIP6_scen585_filt{k} = filter(b,a, nao_CMIP6_scen585{k}.nao);
end

nao_CMIP6_hist_mean_filt = filter(b,a, nao_CMIP6_hist_mean);
nao_CMIP6_scen245_mean_filt = filter(b,a, nao_CMIP6_scen245_mean);
nao_CMIP6_scen585_mean_filt = filter(b,a, nao_CMIP6_scen585_mean);

%% 4. Plots
%% 4.1 General definitions
% axis definitions
ax_1 = nao_NOAA_wint.time;
ax_2 = nao_CRU_wint.time;
ax_era5 = nao_ERA5_wint.time;

for k = 1 : length(nao_CMIP6_hist)
    ax_CMIP6_hist{k} = nao_CMIP6_hist{k}.time;
end

for k = 1 : length(nao_CMIP6_scen245)
    ax_CMIP6_scen245{k} = nao_CMIP6_scen245{k}.time;
end

for k = 1 : length(nao_CMIP6_scen585)
    ax_CMIP6_scen585{k} = nao_CMIP6_scen585{k}.time;
end
% LineWidth
lw = 2;

% Colors!
colors = struct('orange',[0.9290, 0.6940, 0.1250]);
colors.darkgreen = [0, 0.5, 0];
colors.lila = [138,43,226] ./ 255;
colors.greenyellow = [173,255,47] ./ 255;
colors.DarkGoldenrod1 = [255,185,15] ./ 255;
colors.MediumPurple4 = [93,71,139] ./ 255;
colors.IndianRed = [255,106,106] ./ 255;
colors.turquoise4 = [0,134,139] ./ 255;
colors.darkBlue = [0,0,139] ./ 255;
colors.red = [1 0 0];

%% 4.2 CMIP6 historical simulations compared to NOAA/CRU/ERA5
% axis settings
if plot_historical == true
    x_min1 = datenum(min(ax_1)); x_max1 = datenum(max(ax_1));
    y_min1 = -6; y_max1 = 5;
    
    % --- part 1 ---
    figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
    axis([x_min1 x_max1 y_min1 y_max1]);
    
    plot(ax_1,nao_1_filt,'LineWidth',lw,'DisplayName','NOAA');
    plot(ax_2,nao_2_filt,'LineWidth',lw,'DisplayName','CRU');
    plot(ax_era5,nao_era5_filt,'LineWidth',lw,'DisplayName','ERA5');
    
    for k = 1 : 5
        plot(ax_CMIP6_hist{k},nao_CMIP6_hist_filt{k},'-.','LineWidth',1.2,...
            'DisplayName',[nao_CMIP6_hist{k}.name ' pressure differences']);
    end
    
    hold off;
    title(['NAO CMIP6 historical part 1 monthly data ' title_seas ' filtered (moving average, windows size: ' num2str(ws) ')']);
    legend show
    
    % --- part 2 ---
    
    figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
    axis([x_min1 x_max1 y_min1 y_max1]);
    
    plot(ax_1,nao_1_filt,'LineWidth',lw,'DisplayName','NOAA');
    plot(ax_2,nao_2_filt,'LineWidth',lw,'DisplayName','CRU');
    plot(ax_era5,nao_era5_filt,'LineWidth',lw,'DisplayName','ERA5');
    
    for k = 6 : length(nao_CMIP6_hist)
        plot(ax_CMIP6_hist{k},nao_CMIP6_hist_filt{k},'-.','LineWidth',1.2,...
            'DisplayName',['from ' nao_CMIP6_hist{k}.name ' pressure differences']);
    end
    
    hold off;
    title(['NAO data comparison, CMIP6 historical part 2, monthly data, ' title_seas ', filtered (moving average, windows size: ' num2str(ws) ')']);
    legend show
end

%% 4.3 CMIP6 historical simulations AND future projections compared to NOAA/CRU/ERA5
if plot_historicalAndFuture == true
    % axis settings
    x_min2 = min(ax_1); x_max2 = datetime(2100,1,1);
    y_min2 = -6; y_max2 = 5;
    
    figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
    
    for k = 1 : length(nao_CMIP6_hist_filt)
        if k > 1
            plot(ax_CMIP6_hist{k},nao_CMIP6_hist_filt{k},'-.','Color',colors.IndianRed,...
                'LineWidth',1.2,'HandleVisibility','off'); % without legend
        else
            plot(ax_CMIP6_hist{k},nao_CMIP6_hist_filt{k},'-.','Color',colors.IndianRed,...
                'LineWidth',1.2,'DisplayName','CMIP6 historical pressure differences'); % with legend
        end
    end
    
    for k = 1 : length(nao_CMIP6_scen245_filt)
        if k > 1
            plot(ax_CMIP6_scen245{k},nao_CMIP6_scen245_filt{k},'r-.',...
                'LineWidth',1.2,'HandleVisibility','off'); % without legend
            plot(ax_CMIP6_scen585{k},nao_CMIP6_scen585_filt{k},'-.','Color',colors.orange,...
                'LineWidth',1.2,'HandleVisibility','off'); % without legend
        else
            plot(ax_CMIP6_scen245{k},nao_CMIP6_scen245_filt{k},'r-.','LineWidth',1.2,...
                'DisplayName','CMIP6 scenario245 pressure differences'); % with legend
            plot(ax_CMIP6_scen585{k},nao_CMIP6_scen585_filt{k},'-.','Color',colors.orange,...
                'LineWidth',1.2,'DisplayName','CMIP6 scenario585 pressure differences'); % with legend
        end
    end
    
    if plotmean == true
        % add the mean values over all models
        plot(time_interp_hist,nao_CMIP6_hist_mean_filt,'Color',colors.MediumPurple4,'LineWidth',lw,'DisplayName','CMIP6 historical mean');
        plot(time_interp_scen245,nao_CMIP6_scen245_mean_filt,'LineWidth',lw,'DisplayName','CMIP6 scenario245 mean');
        plot(time_interp_scen585,nao_CMIP6_scen585_mean_filt,'Color',colors.lila,'LineWidth',lw,'DisplayName','CMIP6 scenario585 mean');
        
        % this is for the title
        withorwithoutmean =  'with mean values over all models, ';
    else
        withorwithoutmean = [];
    end
    
    % add the references
    plot(ax_1,nao_1_filt,'Color','b','LineWidth',lw,'DisplayName','downloaded from CRU');
    plot(ax_2,nao_2_filt,'Color',colors.turquoise4,'LineWidth',lw,'DisplayName','downloaded from NOAA');
    plot(ax_era5,nao_era5_filt,'Color','g','LineWidth',lw,'DisplayName','ERA5 pressure differences');
    
    % add a reference line at y = 0
    zero_line_x = [x_min2;x_max2];
    zero_line_y = [0;0];
    plot(zero_line_x,zero_line_y,'k','LineWidth',1,'HandleVisibility','off');
    
    xlim([x_min2 x_max2]);
    ylim([y_min2 y_max2]);
    legend show
    hold off;
    title(['NAO data comparison, CMIP6 historical simulations and future projections'...
        withorwithoutmean 'monthly data, ' title_seas ', filtered (moving average, windows size: ' num2str(ws) ')']);
    
end
%% 5. Evaluation of negative/positive NAOs
%% 5.1 The 'usual' plots
if plot_negposBars == true
    % settings
    size = 1;
    
    h1 = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
    grid on; hold on;
    plotPosNegNAOs(nao_NOAA_neg.time,size,'neg');
    plotPosNegNAOs(nao_NOAA_pos.time,size,'pos');
    hold off; title('negative/positive NAOs, NOAA');
    orient(h1,'landscape');
    print(h1,'-append','-dpsc','negposNAOs.ps','-fillpage');
    
    h2 = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
    grid on; hold on;
    plotPosNegNAOs(nao_CRU_neg.time,size,'neg');
    plotPosNegNAOs(nao_CRU_pos.time,size,'pos');
    hold off; title('negative/positive NAOs, CRU');
    orient(h2,'landscape');
    print(h2,'-append','-dpsc','negposNAOs.ps','-fillpage');
    
    for k = 1 : length(nao_CMIP6_hist_neg)
        h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
        grid on; hold on;
        plotPosNegNAOs(nao_CMIP6_hist_neg{k}.time,size,'neg');
        plotPosNegNAOs(nao_CMIP6_hist_pos{k}.time,size,'pos');
        hold off; title(['negative/positive NAOs, CMIP6 historical ' nao_CMIP6_hist{k}.name]);
        orient(h,'landscape');
        print(h,'-append','-dpsc','negposNAOs.ps','-fillpage');
    end
    
    for k = 1 : length(nao_CMIP6_scen245_neg)
        h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
        grid on; hold on;
        plotPosNegNAOs(nao_CMIP6_scen245_neg{k}.time,size,'neg');
        plotPosNegNAOs(nao_CMIP6_scen245_pos{k}.time,size,'pos');
        hold off; title(['negative/positive NAOs, CMIP6 SSP585 ' nao_CMIP6_scen245{k}.name]);
        orient(h,'landscape');
        print(h,'-append','-dpsc','negposNAOs.ps','-fillpage');
    end
    
    for k = 1 : length(nao_CMIP6_scen585_neg)
        h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
        grid on; hold on;
        plotPosNegNAOs(nao_CMIP6_scen585_neg{k}.time,size,'neg');
        plotPosNegNAOs(nao_CMIP6_scen585_pos{k}.time,size,'pos');
        hold off; title(['negative/positive NAOs, CMIP6 SSP245 ' nao_CMIP6_scen585{k}.name]);
        orient(h,'landscape');
        print(h,'-append','-dpsc','negposNAOs.ps','-fillpage');
    end
end

%% 5.2 Counting several sequent positive/negative values
% how long has the NAO been negative/positive without interruption?
sev_neg_NOAA = countPosNegNAOs(nao_NOAA_neg.time);
sev_pos_NOAA = countPosNegNAOs(nao_NOAA_pos.time);
sev_neg_CRU = countPosNegNAOs(nao_CRU_neg.time);
sev_pos_CRU = countPosNegNAOs(nao_CRU_pos.time);
sev_neg_ERA5 = countPosNegNAOs(nao_ERA5_neg.time);
sev_pos_ERA5 = countPosNegNAOs(nao_ERA5_pos.time);

% combine NOAA, CRU and ERA5
sev_neg_ref_dat = {sev_neg_NOAA,sev_neg_CRU,sev_neg_ERA5};
sev_pos_ref_dat = {sev_pos_NOAA,sev_pos_CRU,sev_pos_ERA5};

for k = 1 : length(nao_CMIP6_hist_neg)
    sev_neg_CMIP6_hist{k} = countPosNegNAOs(nao_CMIP6_hist_neg{k}.time);
    sev_pos_CMIP6_hist{k} = countPosNegNAOs(nao_CMIP6_hist_pos{k}.time);
end

for k = 1 : length(nao_CMIP6_scen245_neg)
    sev_neg_CMIP6_scen245{k} = countPosNegNAOs(nao_CMIP6_scen245_neg{k}.time);
    sev_pos_CMIP6_scen245{k} = countPosNegNAOs(nao_CMIP6_scen245_pos{k}.time);
end

for k = 1 : length(nao_CMIP6_scen245_neg)
    sev_neg_CMIP6_scen585_start{k} = countPosNegNAOs(nao_CMIP6_scen585_neg{k}.time);
    sev_pos_CMIP6_scen585_start{k} = countPosNegNAOs(nao_CMIP6_scen585_pos{k}.time);
end

%% 5.3 Graphical representation of several sequent neg/pos values
if plotNegPosNAOVisualization == true
    % settings
    size = 0.1;
    
    startdate = datetime(1979,1,1);
    enddate = datetime(2015,1,1);
    for x_min = startdate : calendarDuration(10,1,1) : enddate
        h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
        plotSevPosNegNAOs(sev_neg_NOAA,size,'neg',x_min);
        plotSevPosNegNAOs(sev_pos_NOAA,size,'pos',x_min);
        hold off; title('Persistence of negative/positive NAO in NOAA');
        orient(h,'landscape');
        print(h,'-append','-dpsc','negposNAOVisualization.ps','-fillpage');
    end
    
    startdate = datetime(1979,1,1);
    enddate = datetime(2015,1,1);
    for x_min = startdate : calendarDuration(10,1,1) : enddate
        h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
        plotSevPosNegNAOs(sev_neg_CRU,size,'neg',x_min);
        plotSevPosNegNAOs(sev_pos_CRU,size,'pos',x_min);
        hold off; title('Persistence of negative/positive NAO in CRU');
        orient(h,'landscape');
        print(h,'-append','-dpsc','negposNAOVisualization.ps','-fillpage');
    end
    
    startdate = datetime(1979,1,1);
    enddate = datetime(2015,1,1);
    for x_min = startdate : calendarDuration(10,1,1) : enddate
        h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
        plotSevPosNegNAOs(sev_neg_ERA5,size,'neg',x_min);
        plotSevPosNegNAOs(sev_pos_ERA5,size,'pos',x_min);
        hold off; title('Persistence of negative/positive NAO in ERA5');
        orient(h,'landscape');
        print(h,'-append','-dpsc','negposNAOVisualization.ps','-fillpage');
    end
    
    startdate = datetime(1979,1,1);
    enddate = datetime(2015,1,1);
    for x_min = startdate : calendarDuration(10,1,1) : enddate
        for k = 1 : length(sev_neg_CMIP6_hist)
            h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
            plotSevPosNegNAOs(sev_neg_CMIP6_hist{k},size,'neg',x_min);
            plotSevPosNegNAOs(sev_pos_CMIP6_hist{k},size,'pos',x_min);
            hold off; title(['Persistence of negative/positive NAO in CMIP6 historical ' nao_CMIP6_hist{k}.name]);
            orient(h,'landscape');
            print(h,'-append','-dpsc','negposNAOVisualization.ps','-fillpage');
        end
    end
    
    startdate = datetime(2013,1,1);
    enddate = datetime(2100,1,1);
    for x_min = startdate : calendarDuration(10,1,1) : enddate
        for k = 1 : length(sev_neg_CMIP6_scen245)
            h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
            plotSevPosNegNAOs(sev_neg_CMIP6_scen245{k},size,'neg',x_min);
            plotSevPosNegNAOs(sev_pos_CMIP6_scen245{k},size,'pos',x_min);
            hold off; title(['Persistence of negative/positive NAO in CMIP6 SSP245 ' nao_CMIP6_scen245{k}.name]);
            orient(h,'landscape');
            print(h,'-append','-dpsc','negposNAOVisualization.ps','-fillpage');
        end
    end
    
    startdate = datetime(2013,1,1);
    enddate = datetime(2100,1,1);
    for x_min = startdate : calendarDuration(10,1,1) : enddate
        for k = 1 : length(sev_neg_CMIP6_scen585)
            h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
            plotSevPosNegNAOs(sev_neg_CMIP6_scen585{k},size,'neg',x_min);
            plotSevPosNegNAOs(sev_pos_CMIP6_scen585{k},size,'pos',x_min);
            hold off; title(['Persistence of negative/positive NAO in CMIP6 SSP585 ' nao_CMIP6_scen585{k}.name]);
            orient(h,'landscape');
            print(h,'-append','-dpsc','negposNAOVisualization.ps','-fillpage');
        end
    end
    
end

%% 5.4 Statistics
if plot_negposStatistics == true
    % settings
    max_months = 25;
    x_min4 = 1; x_max4 = 10;
    
    % negative, historical
    h1 = plotPosNegBars(max_months,sev_neg_CMIP6_hist,sev_neg_ref_dat);
    legend([cellstr(nao_CMIP6_hist{1}.name),cellstr(nao_CMIP6_hist{2}.name),cellstr(nao_CMIP6_hist{3}.name),...
        cellstr(nao_CMIP6_hist{4}.name),cellstr(nao_CMIP6_hist{5}.name),cellstr(nao_CMIP6_hist{6}.name),...
        cellstr(nao_CMIP6_hist{7}.name),cellstr(nao_CMIP6_hist{8}.name),cellstr(nao_CMIP6_hist{9}.name),...
        cellstr(nao_CMIP6_hist{10}.name),'NOAA','CRU','ERA5']);
    title(['number of negative NAO values - CMIP6 historical (' datestr(day_start_hist) ' - ' datestr(day_end_hist) ')']);
    xlim([x_min4 x_max4]); % ylim([y_min4 y_max4]);
    orient(h1,'landscape');
    print(h1,'-append','-dpsc','negposNAOStatistics.ps','-fillpage');
    
    % negative, SSP245
    h2 = plotPosNegBars(max_months,sev_neg_CMIP6_scen245);
    legend([cellstr(nao_CMIP6_scen245{1}.name),cellstr(nao_CMIP6_scen245{2}.name),cellstr(nao_CMIP6_scen245{3}.name),...
        cellstr(nao_CMIP6_scen245{4}.name),cellstr(nao_CMIP6_scen245{5}.name),cellstr(nao_CMIP6_scen245{6}.name),...
        cellstr(nao_CMIP6_scen245{7}.name),cellstr(nao_CMIP6_scen245{8}.name)]);
    title(['number of negative NAO values - CMIP6 SSP245 (' datestr(day_start_fut) ' - ' datestr(day_end_fut) ')']);
    xlim([x_min4 x_max4]);
    orient(h2,'landscape');
    print(h2,'-append','-dpsc','negposNAOStatistics.ps','-fillpage');
    
    % negative, SSP585
    h3 = plotPosNegBars(max_months,sev_neg_CMIP6_scen585_start);
    legend([cellstr(nao_CMIP6_scen585{1}.name),cellstr(nao_CMIP6_scen585{2}.name),cellstr(nao_CMIP6_scen585{3}.name),...
        cellstr(nao_CMIP6_scen585{4}.name),cellstr(nao_CMIP6_scen585{5}.name),cellstr(nao_CMIP6_scen585{6}.name),...
        cellstr(nao_CMIP6_scen585{7}.name),cellstr(nao_CMIP6_scen585{8}.name)']);
    title(['number of negative NAO values - CMIP6 SSP585 (' datestr(day_start_fut) ' - ' datestr(day_end_fut) ')']);
    xlim([x_min4 x_max4]);
    orient(h3,'landscape');
    print(h3,'-append','-dpsc','negposNAOStatistics.ps','-fillpage');
    
    % positive, historical
    h4 = plotPosNegBars(max_months,sev_pos_CMIP6_hist,sev_pos_ref_dat);
    legend([cellstr(nao_CMIP6_hist{1}.name),cellstr(nao_CMIP6_hist{2}.name),cellstr(nao_CMIP6_hist{3}.name),...
        cellstr(nao_CMIP6_hist{4}.name),cellstr(nao_CMIP6_hist{5}.name),cellstr(nao_CMIP6_hist{6}.name),...
        cellstr(nao_CMIP6_hist{7}.name),cellstr(nao_CMIP6_hist{8}.name),cellstr(nao_CMIP6_hist{9}.name),...
        cellstr(nao_CMIP6_hist{10}.name),'NOAA','CRU','ERA5']);
    title(['number of positive NAO values - CMIP6 historical (' datestr(day_start_hist) ' - ' datestr(day_end_hist) ')']);
    xlim([x_min4 x_max4]);
    orient(h4,'landscape');
    print(h4,'-append','-dpsc','negposNAOStatistics.ps','-fillpage');
    
    % positive, SSP245
    h5 = plotPosNegBars(max_months,sev_pos_CMIP6_scen245);
    legend([cellstr(nao_CMIP6_scen245{1}.name),cellstr(nao_CMIP6_scen245{2}.name),cellstr(nao_CMIP6_scen245{3}.name),...
        cellstr(nao_CMIP6_scen245{4}.name),cellstr(nao_CMIP6_scen245{5}.name),cellstr(nao_CMIP6_scen245{6}.name),...
        cellstr(nao_CMIP6_scen245{7}.name),cellstr(nao_CMIP6_scen245{8}.name)]);
    title(['number of positive NAO values - CMIP6 SSP245 (' datestr(day_start_fut) ' - ' datestr(day_end_fut) ')']);
    xlim([x_min4 x_max4]);
    orient(h5,'landscape');
    print(h5,'-append','-dpsc','negposNAOStatistics.ps','-fillpage');
    
    % positive, SSP585
    h6 = plotPosNegBars(max_months,sev_pos_CMIP6_scen585_start);
    legend([cellstr(nao_CMIP6_scen585{1}.name),cellstr(nao_CMIP6_scen585{2}.name),cellstr(nao_CMIP6_scen585{3}.name),...
        cellstr(nao_CMIP6_scen585{4}.name),cellstr(nao_CMIP6_scen585{5}.name),cellstr(nao_CMIP6_scen585{6}.name),...
        cellstr(nao_CMIP6_scen585{7}.name),cellstr(nao_CMIP6_scen585{8}.name)]);
    title(['number of positive NAO values - CMIP6 SSP585 (' datestr(day_start_fut) ' - ' datestr(day_end_fut) ')']);
    xlim([x_min4 x_max4]);
    orient(h6,'landscape');
    print(h6,'-append','-dpsc','negposNAOStatistics.ps','-fillpage');
end




