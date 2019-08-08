clc, clear, close all;
[file, path] = uigetfile('*.nc', 'Please select file to read');
data = readNetCDF2(strcat(path,file));
save(strcat(path, '../mat_files/', file, '.mat'), 'data');