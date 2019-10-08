clc, clear, close all;
[file, path] = uigetfile('*.nc', 'Please select file to read');
addpath('./scripts');
data = readNetCDF2_new(strcat(path,file),'Latitudes', [20 85],'Longitudes', [-90 40]);
% data = readNetCDF2_new(strcat(path,file));
uisave('data', file);