%% saveGBIsfromCMIP6
% this script loads CMIP6 geopotential data, computes the GBI and saves the
% results
%
% susann.aschenneller@uni-bonn.de, 08/2019

%% settings
clearvars; clc;
addpath(genpath(cd), genpath(['..' filesep 'functions']));

%% load/save paths
% [file, path] = uigetfile({'*.mat', 'MATLAB binary file (*.mat)'}, 'Please select one file to read. All files will be added automatically');
path = 'D:\cmip6\zg_GBI_historical\mat-files\';
file = 'zg_Amon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn.mat';
folderContents = dir(strcat(path, '*.mat'));

[~, s_path] = uiputfile({'.mat', 'MATLAB binary file (*.mat)'}, 'Save plots as...');

%% load, compute NAO, save
for i = 1:size(folderContents, 1)
    load(strcat(path,folderContents(i).name));
    GBI_temp = compute_GBI(data);
    
    data = convert_times(data);
    data = setfield(data,'time',datetime(data.time,'Format','dd.MM.yyyy'));
    
    GBI = struct('time',data.time);
    GBI = setfield(GBI,'GBI',GBI_temp);
    save(strcat(s_path, 'GBI_', folderContents(i).name),'GBI');
end
