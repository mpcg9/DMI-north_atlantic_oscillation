
%% 0. settings
clearvars; close all; clc;
f = filesep;
addpath(genpath(cd), genpath(['..' f 'data' f 'nao']));

%% 1. load files
nao_1 = load('nao_1.data'); % NOAA monthly
nao_2 = load('nao_2.data'); % CRU monthly

%% 2. reshape files
nao_1_re = reshapeNAO(nao_1);
nao_2_re = reshapeNAO(nao_2);

%% 3. NAO data plots
% for comparison of the different data sets
% axis (months as fractions of a year)
ax_1 = nao_1_re(:,1) + nao_1_re(:,2)./12;
ax_2 = nao_2_re(:,1) + nao_2_re(:,2)./12;

figure; hold on;
plot(ax_2, nao_2_re(:,3),'- .','LineWidth',1);
plot(ax_1, nao_1_re(:,3),'- .','LineWidth',1);
% stem(ax_1, nao_1_re(:,3), '.', 'MarkerSize',0.1);
% stem(ax_2, nao_2_re(:,3), '.', 'MarkerSize',0.1);
hold off;
title('NAO data comparison');
legend('data set 1: NOAA monthly', 'data set 2: CRU monthly');

% can't see anything out of these lines. try kernel density plots
nao_1_kd = fitdist(nao_1_re(:,3), 'Kernel');

xaxis = nao_1_re(1,1) : 5 : nao_1_re(end,1);
y_nao_1 = pdf(nao_1_kd,xaxis);

figure; hold on;
plot(xaxis, y_nao_1);
hold off;

%% 4. NAO maps
% ... what?






