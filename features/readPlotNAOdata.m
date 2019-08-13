
%% 0. settings
clearvars; close all; clc;
f = filesep;
addpath(genpath(cd), genpath(['..' f 'data' f 'nao']), genpath(['..' f 'scripts']));

%% NAO
%% load files
% for details of the files have a look at 'nao_overview.ods'
nao_1 = load('nao_1.data'); % NOAA monthly
nao_2 = load('nao_2.data'); % CRU monthly
nao_3 = load('nao_3.data'); % NOAA daily

%% reshape/prepare files
nao_1 = reshapeNAO(nao_1);
nao_2 = reshapeNAO(nao_2);
nao_3(nao_3 == -99.99) = NaN;

%% extract winter months (DJF)
idx1 = nao_1(:,2) == 12 | nao_1(:,2) == 1 | nao_1(:,2) == 2;
idx2 = nao_2(:,2) == 12 | nao_2(:,2) == 1 | nao_2(:,2) == 2;
idx3 = nao_3(:,2) == 12 | nao_3(:,2) == 1 | nao_3(:,2) == 2;

% + convert timestamps to datetime format
nao_1_winter = struct('time', datetime(nao_1(idx1,1),nao_1(idx1,2),1,'Format','dd.MM.yyyy'));
nao_2_winter = struct('time', datetime(nao_2(idx2,1),nao_2(idx2,2),1,'Format','dd.MM.yyyy'));
nao_3_winter = struct('time', datetime(nao_3(idx3,1),nao_3(idx3,2),nao_3(idx3,3),'Format','dd.MM.yyyy'));

nao_1_winter = setfield(nao_1_winter, 'nao',nao_2(idx1,3));
nao_2_winter = setfield(nao_2_winter, 'nao',nao_2(idx2,3));
nao_3_winter = setfield(nao_3_winter, 'nao',nao_3(idx3,4));

%% negative/positive naos
nao_1_neg = nao_1_winter.time(nao_1_winter.nao <= 0);
nao_1_pos = nao_1_winter.time(nao_1_winter.nao > 0);
nao_2_neg = nao_2_winter.time(nao_2_winter.nao <= 0);
nao_2_pos = nao_2_winter.time(nao_2_winter.nao > 0);
nao_3_neg = nao_3_winter.time(nao_3_winter.nao <= 0);
nao_3_pos = nao_3_winter.time(nao_3_winter.nao > 0);

%% NAO data plots
%% unfiltered
keyboard
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
keyboard
a = 1;
% windows size for monthly data
windowSize1 = 50; % average of 50 values... this is quite coarse
b1 = (1/windowSize1)*ones(1,windowSize1);
% windows size for daily data
windowSize2 = 50*ceil(365/12); % average of 50 values... this is quite coarse
b2 = (1/windowSize2)*ones(1,windowSize2);

nao_1_filt = filter(b1,a,nao_1(:,3));
nao_2_filt = filter(b1,a,nao_2(:,3));
nao_3_filt = filter(b2,a,nao_3(:,4));

figure; grid on; hold on;
plot(ax_1,nao_1_filt);
plot(ax_2,nao_2_filt);
plot(ax_3,nao_3_filt);
hold off;
title('NAO data comparison filtered (very coarse)');
legend('data set 1: NOAA monthly', 'data set 2: CRU monthly', 'data set 3: NOAA daily');

%% try different filter windows
keyboard
a = 1;
windowSize1 = 1; b1 = (1/windowSize1)*ones(1,windowSize1);
windowSize2 = 5; b2 = (1/windowSize2)*ones(1,windowSize2);
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

%% NAO maps
% ... what?
% pressure maps at times, when nao is negative/positive

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




