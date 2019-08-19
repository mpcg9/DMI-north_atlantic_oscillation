
%% settings
clearvars; close all; clc;
f = filesep;
addpath(genpath(cd), genpath(['..' f 'functions']), genpath(['..' f 'data' f 'nao']));

%% NAO data preparation
% general settings
truncate = 1979;
extractMonths = [12 1 2];
extractNegPos = false;

%% already calculated naos downloaded from NOAA/CRU
% for details of the different files have a look at 'nao_overview.ods'
% settings
folderName = 'NOAA_CRU_already calculated';
reshape_1 = true;
replace_1 = -99.99;

% NOAA monthly
[~,~,nao_1_wint] = prepareNAOs([folderName f 'nao_1.data'],...
    reshape_1,replace_1,truncate, extractMonths,extractNegPos);
% CRU monthly
[~,~,nao_2_wint] = prepareNAOs([folderName f 'nao_2.data'],...
    reshape_1,replace_1,truncate, extractMonths,extractNegPos);

%% computed as pressure differences with data from ERA5
% settings
folderName = 'ERA5';
reshape_2 = false;
replace_2 = [];

[~,~,nao_ERA5_wint] = prepareNAOs([folderName f 'diffNAO_ERA5.mat'],...
    reshape_2,replace_2,truncate, extractMonths,extractNegPos);

%% computed as pressure differences with data from CMIP6 - historical
% settings
reshape_3 = false;
replace_3 = [];

path = '..\data\nao\CMIP6_psl historical\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    [~,~,nao_CMIP6_hist{i}] = prepareNAOs(strcat(path,folderContents(i).name),...
        reshape_3,replace_3,truncate, extractMonths,extractNegPos);
    nao_CMIP6_hist{i}.name = strrep(folderContents(i).name,'_',' ');
end

%% computed as pressure differences with data from CMIP6 - scenario ssp245
% settings
reshape_4 = false;
replace_4 = [];

path = '..\data\nao\CMIP6_psl_scenarios_ssp245\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    [~,~,nao_CMIP6_scen245{i}] = prepareNAOs(strcat(path,folderContents(i).name),...
        reshape_4,replace_4,truncate, extractMonths,extractNegPos);
    nao_CMIP6_scen245{i}.name = strrep(folderContents(i).name,'_',' ');
end

%% computed as pressure differences with data from CMIP6 - scenario ssp585
% settings
reshape_5 = false;
replace_5 = [];

path = '..\data\nao\CMIP6_psl_scenarios_ssp585\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    [~,~,nao_CMIP6_scen585{i}] = prepareNAOs(strcat(path,folderContents(i).name),...
        reshape_5,replace_5,truncate, extractMonths,extractNegPos);
    nao_CMIP6_scen585{i}.name = strrep(folderContents(i).name,'_',' ');
end

clear truncate extractMonths extractNegPos reshape_1 reshape_2 reshape_3...
    reshape_4 reshape_5 replace_1  replace_2 replace_3 replace_4 replace_5...
    folderName folderContents f path

%% Mean Computation
% for CMIP6_historical, CMIP6_scen245 and CMIP6_scen585 individual
% mean over all models for each sceanrio respectively

[nao_CMIP6_hist_mean,time_interp_hist] = compute_mean_NAOs(nao_CMIP6_hist);
[nao_CMIP6_scen245_mean,time_interp_scen245] = compute_mean_NAOs(nao_CMIP6_scen245);
[nao_CMIP6_scen585_mean,time_interp_scen585] = compute_mean_NAOs(nao_CMIP6_scen585);

%% Filtering
a = 1;
% windows size for monthly data
ws = 3; % average of 3 values
b = (1/ws)*ones(1,ws);

% compute filtered time series
nao_1_filt = filter(b,a,nao_1_wint.nao);
nao_2_filt = filter(b,a,nao_2_wint.nao);
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

%% NAO data plots
%% axis definitions
ax_1 = nao_1_wint.time;
ax_2 = nao_2_wint.time;
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

%% ALL TOGETHER: CMIP6 historical simulations AND future projections compared to NOAA/CRU/ERA5
% axis settings
x_min2 = min(ax_1); x_max2 = datetime(2100,1,1);
y_min2 = -6; y_max2 = 5;

% LineWidth
lw = 2;

% Colors!
orange = [0.9290, 0.6940, 0.1250];
darkgreen = [0, 0.5, 0];
lila = [138,43,226] ./ 255;
greenyellow = [173,255,47] ./ 255;
DarkGoldenrod1 = [255,185,15] ./ 255;
MediumPurple4 = [93,71,139] ./ 255;
IndianRed = [255,106,106] ./ 255;
turquoise4 = [0,134,139] ./ 255;

figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;

for k = 1 : length(nao_CMIP6_hist_filt)    
    if k > 1
       plot(ax_CMIP6_hist{k},nao_CMIP6_hist_filt{k},'-.','Color',IndianRed,...
        'LineWidth',1.2,'HandleVisibility','off'); % without legend
    else
         plot(ax_CMIP6_hist{k},nao_CMIP6_hist_filt{k},'-.','Color',IndianRed,...
        'LineWidth',1.2,'DisplayName','CMIP6 historical pressure differences'); % with legend
    end
end

for k = 1 : length(nao_CMIP6_scen245_filt)
    if k > 1
   plot(ax_CMIP6_scen245{k},nao_CMIP6_scen245_filt{k},'r-.',...
       'LineWidth',1.2,'HandleVisibility','off'); % without legend
   plot(ax_CMIP6_scen585{k},nao_CMIP6_scen585_filt{k},'-.','Color',orange,...
       'LineWidth',1.2,'HandleVisibility','off'); % without legend
    else
   plot(ax_CMIP6_scen245{k},nao_CMIP6_scen245_filt{k},'r-.','LineWidth',1.2,...
       'DisplayName','CMIP6 scenario245 pressure differences'); % with legend
   plot(ax_CMIP6_scen585{k},nao_CMIP6_scen585_filt{k},'-.','Color',orange,...
       'LineWidth',1.2,'DisplayName','CMIP6 scenario585 pressure differences'); % with legend
    end
end

% add the mean values over all models
% plot(time_interp_hist,nao_CMIP6_hist_mean_filt,'Color',MediumPurple4,'LineWidth',lw,'DisplayName','CMIP6 historical mean');
% plot(time_interp_scen245,nao_CMIP6_scen245_mean_filt,'LineWidth',lw,'DisplayName','CMIP6 scenario245 mean');
% plot(time_interp_scen585,nao_CMIP6_scen585_mean_filt,'Color',lila,'LineWidth',lw,'DisplayName','CMIP6 scenario585 mean');

% this is only for the title...
% withorwithoutmean =  'with mean values over all models, ';
withorwithoutmean = [];

% add the references
plot(ax_1,nao_1_filt,'Color','b','LineWidth',lw,'DisplayName','downloaded from CRU');
plot(ax_2,nao_2_filt,'Color',turquoise4,'LineWidth',lw,'DisplayName','downloaded from NOAA');
plot(ax_era5,nao_era5_filt,'Color','g','LineWidth',lw,'DisplayName','ERA5 pressure differences');


xlim([x_min2 x_max2]);
ylim([y_min2 y_max2]);
legend show
hold off;
title(['NAO data comparison, CMIP6 historical simulations and future projections'...
    withorwithoutmean 'monthly data, winter months (DJF), filtered (moving average, windows size: ' num2str(ws) ')']);


%% CMIP6 historical simulations compared to NOAA/CRU/ERA5
keyboard
% axis settings
x_min1 = datenum(min(ax_1)); x_max1 = datenum(max(ax_1));
y_min1 = -6; y_max1 = 5;
% LineWidth
lw = 2;
% --- part 1 ---
figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
axis([x_min1 x_max1 y_min1 y_max1]);

plot(ax_1,nao_1_filt,'LineWidth',lw);
plot(ax_2,nao_2_filt,'LineWidth',lw);
plot(ax_era5,nao_era5_filt,'LineWidth',lw);

for k = 1 : 5
    plot(ax_CMIP6_hist{k},nao_CMIP6_hist_filt{k},'-.','LineWidth',1.2);
end

hold off;
title(['NAO data comparison, CMIP6 historical part 1, monthly data, winter months (DJF), filtered (moving average, windows size: ' num2str(ws) ')']);
legend('NOAA monthly', 'CRU monthly', 'from ERA5 pressure differences',...
    [nao_CMIP6_hist{1}.name ' pressure differences'],...
    [nao_CMIP6_hist{2}.name ' pressure differences'],...
    [nao_CMIP6_hist{3}.name ' pressure differences'],...
    [nao_CMIP6_hist{4}.name ' pressure differences'],...
    [nao_CMIP6_hist{5}.name ' pressure differences']);

% --- part 2 ---

figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
axis([x_min1 x_max1 y_min1 y_max1]);

plot(ax_1,nao_1_filt,'LineWidth',lw);
plot(ax_2,nao_2_filt,'LineWidth',lw);
plot(ax_era5,nao_era5_filt,'LineWidth',lw);

for k = 6 : length(nao_CMIP6_hist)
    plot(ax_CMIP6_hist{k},nao_CMIP6_hist_filt{k},'-.','LineWidth',1.2);
end

hold off;
title(['NAO data comparison, CMIP6 historical part 2, monthly data, winter months (DJF), filtered (moving average, windows size: ' num2str(ws) ')']);
legend('NOAA monthly', 'CRU monthly', 'from ERA5 pressure differences',...
    ['from ' nao_CMIP6_hist{6}.name ' pressure differences'],...
    ['from ' nao_CMIP6_hist{7}.name ' pressure differences'],...
    ['from ' nao_CMIP6_hist{8}.name ' pressure differences'],...
    ['from ' nao_CMIP6_hist{9}.name ' pressure differences'],...
    ['from ' nao_CMIP6_hist{10}.name ' pressure differences']);

