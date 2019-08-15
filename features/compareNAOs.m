
%% 0. settings
clearvars; close all; clc;
addpath(genpath(cd), genpath(['..' filesep 'data' filesep 'nao']),...
    genpath(['..' filesep 'functions']));

%% NAO data preparation
% for details of the different nao-files have a look at 'nao_overview.ods'
[~,~,nao_1_wint] = prepareNAOs('nao_1.data',true,-99.99,2000,[12 1 2],false); % NOAA monthly
[~,~,nao_2_wint] = prepareNAOs('nao_2.data',true,-99.99,2000,[12 1 2],false); % CRU monthly
[~,~,nao_3_wint] = prepareNAOs('nao_3.data',true,-99.99,2000,[12 1 2],false); % NOAA daily
[~,~,nao_5_wint] = prepareNAOs('nao_5.mat',true,-99.99,2000,[12 1 2],false); % ERA5 pressure

%% NAO data plots
%% axis definitions
% for comparison of the different data sets
% axis (months as fractions of a year)
ax_1 = nao_1(:,1) + nao_1(:,2)./12;
ax_2 = nao_2(:,1) + nao_2(:,2)./12;
% axis (days as fractions of a year)
for k = 1 : length(nao_3)
    % consecutive number of days within a year
    nao3_num(k) = date2num(nao_3(k,1),nao_3(k,2),nao_3(k,3));
end
ax_3 = nao_3(:,1) + nao3_num'./365;

%% unfiltered
figure; hold on;
plot(ax_2, nao_2(:,3),'- .','LineWidth',1);
plot(ax_3, nao_3(:,4),'- .','LineWidth',1);
plot(ax_1, nao_1(:,3),'- .','LineWidth',1);
% stem(ax_1, nao_1_re(:,3), '.', 'MarkerSize',0.1);
% stem(ax_2, nao_2_re(:,3), '.', 'MarkerSize',0.1);
hold off;
title('NAO data comparison');
legend('data set 1: NOAA monthly', 'data set 2: CRU monthly', 'data set 3: NOAA daily');

%% can't see anything out of these lines. try a filter
a = 1;
% windows size for monthly data
ws1 = 3; % average of 3 values
b1 = (1/ws1)*ones(1,ws1);
% windows size for daily data
ws2 = ws1*ceil(365/12);
b2 = (1/ws2)*ones(1,ws2);

nao_1_filt = filter(b1,a,nao_1(:,3));
nao_2_filt = filter(b1,a,nao_2(:,3));
nao_3_filt = filter(b2,a,nao_3(:,4));

figure; grid on; hold on;
plot(ax_1,nao_1_filt);
plot(ax_2,nao_2_filt);
plot(ax_3,nao_3_filt);
hold off;
title(['NAO data comparison full year, filtered, windows size: ' num2str(ws1)]);
legend('data set 1: NOAA monthly', 'data set 2: CRU monthly', 'data set 3: NOAA daily');

%% try different filter windows
a = 1;
ws1 = 1; b1 = (1/ws1)*ones(1,ws1);
ws2 = 5; b2 = (1/ws2)*ones(1,ws2);
windowSize3 = 10; b3 = (1/windowSize3)*ones(1,windowSize3);

nao_1_filt1 = filter(b1,a,nao_1(:,3));
nao_1_filt2 = filter(b2,a,nao_1(:,3));
nao_1_filt3 = filter(b3,a,nao_1(:,3));

figure; hold on;
plot(ax_1,nao_1_filt1);
plot(ax_1,nao_1_filt2);
plot(ax_1,nao_1_filt3);
hold off;
legend('1','2','3');

%% winter plots
figure; grid on; hold on;
plot(nao_1_winter.time,nao_1_winter.nao);
plot(nao_2_winter.time,nao_2_winter.nao);
plot(nao_3_winter.time,nao_3_winter.nao);
hold off;
title('NAO data comparison winter months (DJF)');
legend('data set 1: NOAA monthly', 'data set 2: CRU monthly', 'data set 3: NOAA daily');

%% break
% think of putting the following part in another m.file
% or maybe just throw it away :(

% --------------------------------------------------------------
% --------------------------------------------------------------
% --------------------------------------------------------------

%% NAO maps
% pressure maps for negatvie/positive nao
% ... look strangely similar

%% get pressure data
pres_orig = load('C:\Users\Lenovo\Desktop\DMI\data\mean sea level pressure data monthly averaged reanalysis 1979-2019 (DJF)\adaptor.mars.internal-1565608912.895368-18802-19-8d36d923-f2b1-484d-85a0-be67f1649d8d.nc.mat');

%% prepare pressure data
ref_date = datetime('1.1.1900');
pres_date = ref_date + hours(pres_orig.data.time);
pres_date = datetime(pres_date,'Format','dd.MM.yyyy');

%% pressure data at times of positive/negatvie nao
[smw,~] = ismember(pres_date,nao_1_neg);
idx_pres_nao_neg_1 = find(smw == 1);
[smw,~] = ismember(pres_date,nao_2_neg);
idx_pres_nao_neg_2 = find(smw == 1);
% [smw,~] = ismember(pres_date,nao_1_neg); % doesn't work for daily nao
% idx_pres_nao_neg_3 = find(smw == 3);

[smw,~] = ismember(pres_date,nao_1_pos);
idx_pres_nao_pos_1 = find(smw == 1);
[smw,~] = ismember(pres_date,nao_2_pos);
idx_pres_nao_pos_2 = find(smw == 1);
% [smw,~] = ismember(pres_date,nao_1_pos); % doesn't work for daily nao
% idx_pres_nao_pos_3 = find(smw == 3);

pres_nao_neg_1 = pres_orig.data.msl(:,:,idx_pres_nao_neg_1);
pres_nao_neg_2 = pres_orig.data.msl(:,:,idx_pres_nao_neg_2);

pres_nao_pos_1 = pres_orig.data.msl(:,:,idx_pres_nao_pos_1);
pres_nao_pos_2 = pres_orig.data.msl(:,:,idx_pres_nao_pos_2);

%% calculate mean over time of the negative/positive pressures
mean_pres_nao_neg_1 = mean(pres_nao_neg_1,3);
mean_pres_nao_neg_2 = mean(pres_nao_neg_2,3);
mean_pres_nao_pos_1 = mean(pres_nao_pos_1,3);
mean_pres_nao_pos_2 = mean(pres_nao_pos_2,3);

%% plot preparations
% convert longitudes from range [0° 360°] to [-180° +180°]
lon = struct('lon',pres_orig.data.longitude);
lon = convert_longitudes(lon,-180);
lon = lon.lon;

% settings
Bounds_lat = [30, 85]; % Boundaries for latitude [in degrees]
Bounds_lon = [-80, 10]; % Boundaries for longitude [in degrees]
projectionType = 'lambert'; % Select projection to use for plots

%% plots of the negative/positive mean over time
figure
% h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
m_proj(projectionType, 'long', Bounds_lon, 'lat', Bounds_lat);
m_image(lon, pres_orig.data.latitude, mean_pres_nao_neg_1');
m_coast('linewidth', 1, 'color', 'black');
m_grid;
colorbar
title('mean_pres_nao_neg_1');

figure
% h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
m_proj(projectionType, 'long', Bounds_lon, 'lat', Bounds_lat);
m_image(lon, pres_orig.data.latitude, mean_pres_nao_neg_2');
m_coast('linewidth', 1, 'color', 'black');
m_grid;
title('mean_pres_nao_neg_2');

figure
% h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
m_proj(projectionType, 'long', Bounds_lon, 'lat', Bounds_lat);
m_image(lon, pres_orig.data.latitude, mean_pres_nao_pos_1');
m_coast('linewidth', 1, 'color', 'black');
m_grid;
title('mean_pres_nao_pos_1');

figure
% h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
m_proj(projectionType, 'long', Bounds_lon, 'lat', Bounds_lat);
m_image(lon, pres_orig.data.latitude, mean_pres_nao_pos_2');
m_coast('linewidth', 1, 'color', 'black');
m_grid;
title('mean_pres_nao_pos_2');

%% plots of original data
rows = size(pres_nao_neg_1,1); % number of rows
columns = size(pres_nao_neg_1,2); % number of columns
layers = size(pres_nao_neg_1,3); % number of 'layers'

for k = 1 : layers
    h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
    m_proj(projectionType, 'long', Bounds_lon, 'lat', Bounds_lat);
    m_image(lon, pres_orig.data.latitude, pres_orig.data.msl(:,:,k)');
    m_coast('linewidth', 1, 'color', 'black');
    m_grid;
% % %     drawnow
% % %     frame = getframe(h);
% % %     im = frame2im(frame);
% % %     [imind,cm] = rgb2ind(im,256);
% % %     if k == 1
% % %         imwrite(imind,cm,'pressure_orig','gif', 'Loopcount',inf);
% % %     else
% % %         imwrite(imind,cm,'pressure_orig','gif','WriteMode','append');
% % %     end
end




