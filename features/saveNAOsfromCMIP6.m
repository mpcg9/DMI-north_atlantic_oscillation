%% saveNAOsfromCMIP6
% this script loads CMIP6 pressure data, computes the 'straighforward' NAO
% as pressure differences between two boxes over iceland and the azores and
% saves the results
%
% susann.aschenneller@uni-bonn.de, 08/2019

%% settings
clearvars; clc;
addpath(genpath(cd), genpath(['..' filesep 'data' filesep 'nao']),...
    genpath(['..' filesep 'functions']));

%% load/save paths
[file, path] = uigetfile({'*.mat', 'MATLAB binary file (*.mat)'}, 'Please select one file to read. All files will be added automatically');
folderContents = dir(strcat(path, '*.mat'));

[~, s_path] = uiputfile({'.mat', 'MATLAB binary file (*.mat)'}, 'Save plots as...');

%% load, compute NAO, save
for i = 1:size(folderContents, 1)
    load(strcat(path,folderContents(i).name));    
    nao_temp = compute_NAO(data);
    
    % recompute from "days since xx.xx.xxxx" into real date
    % *** INPUT: reference date ***
    refdate = datetime(0000,1,1);
    time = datetime(refdate + days(data.time),'Format','dd.MM.yyyy');
    
    nao = struct('time',time);
    nao = setfield(nao,'nao',nao_temp);
    save(strcat(s_path, 'diffNAO_', folderContents(i).name),'nao');
end
