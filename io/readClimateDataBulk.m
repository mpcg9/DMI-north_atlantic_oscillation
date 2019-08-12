clc, clear, close all;
[file, path] = uigetfile('*.nc', 'Please select one file to read. All files will be added automatically');
% ATTENTION! Do not use different Variables!

addpath('./scripts');
folderContents = dir(strcat(path, '*.nc'));
data = readNetCDF2(strcat(path,folderContents(1).name));
if size(folderContents, 1) > 1
    for i = 2:size(folderContents, 1)
        data = concatenate_by_time(data, readNetCDF2(strcat(path,folderContents(i).name)));
    end
    data = sort_by_time(data);
end
uisave('data', strcat(path, file, '.mat'));