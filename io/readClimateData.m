clc, clear, close all;
[file, path] = uigetfile('*.nc', 'Please select file to read');
addpath('./scripts');
data = readNetCDF2(strcat(path,file));
uisave('data', file);