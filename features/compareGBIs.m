%% compareGBIs
% comparison of GBIs from NOAA, ERA5 and CMIP6 historical simulations
%
% susann.aschenneller@uni-bonn.de, 08/2019

%% settings
clearvars; close all; clc;
f = filesep;
addpath(genpath(cd), genpath(['..' f 'functions']), genpath(['..' f 'data' f 'GBI']));

%% load data
% NOAA downloaded GBI
temp = load('GBI1.data');
gbi_NOAA = struct('time',datetime(temp(:,1),temp(:,2),temp(:,3),'Format','dd.MM.yyyy'));
gbi_NOAA = setfield(gbi_NOAA,'GBI',temp(:,4));
clear temp;

% ERA5 geopotential
gbi_ERA5 = load('GBI_ERA5.mat');
gbi_ERA5 = gbi_ERA5.GBI;

path = '..\data\GBI\CMIP6_zg_historical\';
folderContents = dir(strcat(path, '*.mat'));

for i = 1 : size(folderContents, 1)
    temp = load(strcat(path,folderContents(i).name));
    gbi_CMIP6_hist{i} = temp.GBI;
    gbi_CMIP6_hist{i}.name = strrep(folderContents(i).name,'_',' ');
end

%% Filtering
a = 1;
% windows size for daily data
ws = 30;
b = (1/ws)*ones(1,ws);

% compute filtered time series
gbi_NOAA_filt = filter(b,a,gbi_NOAA.GBI);

%% plots
% axis settings
x_min = datetime(1979,1,1); x_max = datetime(2019,7,1);
y_min = 4600; y_max = 6600;

% LineWidth
lw1 = 1; lw2 = 1.2;

% Part 1
figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
plot(gbi_NOAA.time,gbi_NOAA_filt,'k','DisplayName','NOAA (daily) download','LineWidth',lw1);
plot(gbi_ERA5.time,gbi_ERA5.GBI,'DisplayName','ERA5 (monthly)','LineWidth',lw1);
for k = 1 : 5
    plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist{k}.GBI,'LineWidth',lw2,'DisplayName',['CMIP6 historical ' gbi_CMIP6_hist{k}.name]); % with legend
end

xlim([x_min x_max]);
ylim([y_min y_max]);
legend show
hold off;

% % Part 2
% figure('units','normalized','outerposition',[0 0 1 1]); grid on; hold on;
% plot(gbi_NOAA.time,gbi_NOAA.GBI,'DisplayName','NOAA (daily) download','LineWidth',lw1);
% plot(gbi_ERA5.time,gbi_ERA5.GBI,'DisplayName','ERA5 (monthly)','LineWidth',lw1);
% for k = 6 : length(gbi_CMIP6_hist)
%     plot(gbi_CMIP6_hist{k}.time,gbi_CMIP6_hist{k}.GBI,'LineWidth',lw2,'DisplayName',['CMIP6 historical ' gbi_CMIP6_hist{k}.name]); % with legend
% end
% 
% xlim([x_min x_max]);
% ylim([y_min y_max]);
% legend show
% hold off;

