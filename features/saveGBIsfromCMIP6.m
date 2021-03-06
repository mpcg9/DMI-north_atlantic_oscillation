%% saveGBIsfromCMIP6
% loads CMIP6 geopotential data, computes the GBI and saves the
% results
%
% susann.aschenneller@uni-bonn.de, 08/2019

%% settings
clearvars; clc;
addpath(genpath(cd), genpath(['..' filesep 'functions']));

%% load/save paths
[file, path] = uigetfile({'*.mat', 'MATLAB binary file (*.mat)'}, 'Please select one file to read. All files will be added automatically');
% path = 'D:\cmip6\zg_GBI_historical\mat-files\';
% file = 'zg_Amon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn.mat';
folderContents = dir(strcat(path, '*.mat'));

% s_path = 'C:\Users\Lenovo\Documents\Master\DMI-north_atlantic_oscillation\data\GBI\CMIP6_zg_historical\';
[~, s_path] = uiputfile({'.mat', 'MATLAB binary file (*.mat)'}, 'Save plots as...');

%% load, compute GBI, save
for i = 1:size(folderContents, 1)
    load(strcat(path,folderContents(i).name));
    
    % *** INPUT *** (see function description of 'compute_GBI')
    % (data) for the 'classical' GBI
    % (data,60,80) for all longitudes, latitudes between 60� and 80�
    GBI_temp = compute_GBI(data,60,80);
    
    data_conv = convert_times(data);
    % keep only the dates (without time)
    data_conv = setfield(data_conv,'time',datetime(data_conv.time,'Format','dd.MM.yyyy'));
    
    GBI = struct('time',data_conv.time);
    GBI = setfield(GBI,'GBI',GBI_temp);
    save(strcat(s_path, 'GBI_', folderContents(i).name),'GBI');
end
