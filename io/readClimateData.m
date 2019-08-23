clc, clear, close all;
[file, path] = uigetfile('*.nc', 'Please select file to read');
addpath('./scripts');
data = readNetCDF2_new(strcat(path,file),'Latitudes', [60 80],'Longitudes', [-80 -20]);
% data = readNetCDF2_new(strcat(path,file));
uisave('data', file);