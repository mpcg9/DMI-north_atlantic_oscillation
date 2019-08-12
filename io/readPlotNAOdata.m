
%% 0. settings
clearvars; close all; clc;
f = filesep;
addpath(genpath(cd), genpath(['..' f 'data' f 'nao']));

%% 1. load files
% for details of the files have a look at 'nao_overview.ods'
nao_1 = load('nao_1.data'); % NOAA monthly
nao_2 = load('nao_2.data'); % CRU monthly
nao_3 = load('nao_3.data'); % NOAA daily

%% 2. reshape/prepare files
nao_1_re = reshapeNAO(nao_1);
nao_2_re = reshapeNAO(nao_2);
nao_3(nao_3 == -99.99) = NaN;

%% 3. NAO data plots
% for comparison of the different data sets
% axis (months as fractions of a year)
ax_1 = nao_1_re(:,1) + nao_1_re(:,2)./12;
ax_2 = nao_2_re(:,1) + nao_2_re(:,2)./12;
% axis (days as fractions of a year)
for k = 1 : length(nao_3)
    % consecutive number of days within a year
    nao3_num(k) = date2num(nao_3(k,1),nao_3(k,2),nao_3(k,3));
end
ax_3 = nao_3(:,1) + nao3_num'./365;

figure; hold on;
plot(ax_2, nao_2_re(:,3),'- .','LineWidth',1);
plot(ax_3, nao_3(:,4),'- .','LineWidth',1);
plot(ax_1, nao_1_re(:,3),'- .','LineWidth',1);
% stem(ax_1, nao_1_re(:,3), '.', 'MarkerSize',0.1);
% stem(ax_2, nao_2_re(:,3), '.', 'MarkerSize',0.1);
hold off;
title('NAO data comparison');
legend('data set 1: NOAA monthly', 'data set 2: CRU monthly', 'data set 3: NOAA daily');

%% can't see anything out of these lines. try a filter
a = 1;
% windows size for monthly data
windowSize1 = 50; % average of 50 values... this is quite coarse
b1 = (1/windowSize1)*ones(1,windowSize1);
% windows size for daily data
windowSize2 = 50*ceil(365/12); % average of 50 values... this is quite coarse
b2 = (1/windowSize2)*ones(1,windowSize2);

nao_1_filt = filter(b1,a,nao_1_re(:,3));
nao_2_filt = filter(b1,a,nao_2_re(:,3));
nao_3_filt = filter(b2,a,nao_3(:,4));

figure; grid on; hold on;
plot(ax_1,nao_1_filt);
plot(ax_2,nao_2_filt);
plot(ax_3,nao_3_filt);
hold off;
title('NAO data comparison filtered (very coarse)');
legend('data set 1: NOAA monthly', 'data set 2: CRU monthly', 'data set 3: NOAA daily');

%% try different filter windows
a = 1;
windowSize1 = 1; b1 = (1/windowSize1)*ones(1,windowSize1);
windowSize2 = 5; b2 = (1/windowSize2)*ones(1,windowSize2);
windowSize3 = 10; b3 = (1/windowSize3)*ones(1,windowSize3);

nao_1_filt1 = filter(b1,a,nao_1_re(:,3));
nao_1_filt2 = filter(b2,a,nao_1_re(:,3));
nao_1_filt3 = filter(b3,a,nao_1_re(:,3));

figure; hold on;
plot(ax_1,nao_1_filt1);
plot(ax_1,nao_1_filt2);
plot(ax_1,nao_1_filt3);
hold off;
legend('1','2','3');

%% 4. NAO maps
% ... what?






