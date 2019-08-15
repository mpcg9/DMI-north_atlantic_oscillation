
%% settings
clearvars; close all; clc;
addpath(genpath(cd), genpath(['..' filesep 'data' filesep 'nao']),...
    genpath(['..' filesep 'functions']));

%% load/save paths
[file, path] = uigetfile({'*.mat', 'MATLAB binary file (*.mat)'}, 'Please select one file to read. All files will be added automatically');
folderContents = dir(strcat(path, '*.mat'));

[~, s_path] = uiputfile({'.mat', 'MATLAB binary file (*.mat)'}, 'Save plots as...');

%% load, compute NAO, save
for i = 1:size(folderContents, 1)
    load(strcat(path,folderContents(i).name));    
    NAO = compute_NAO(data);
    save(strcat(s_path, 'NAO_', file),'NAO');
end

