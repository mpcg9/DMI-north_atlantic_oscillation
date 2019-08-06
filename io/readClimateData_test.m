clc, clear, close all;
addpath(genpath(cd));
data = readNetCDF2('../binary_data/NetCDF/ta_Amon_EC-Earth3_historical_r1i1p1f1_gr_201201-201212.nc');

disp(size(data.ta)); % To find out the dimensions of data.ta. 
% This information can be used together with the dimension data of time,
% latitude, longitude and elevation to find out which dimension of data.ta 
% is which.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Let's see if it's always the same! (Write down your findings here)
% <File>: [Order of dimensions], (dimension of dimensions)
%
% ta_Amon_EC-Earth3_historical_r1i1p1f1_gr_201201-201212.nc: [Lon, Lat, Elev, Time], (512, 256, 19, 12)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%