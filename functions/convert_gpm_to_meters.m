clear; clc;

% load('D:\ERA5\geopotential\adaptor.mars.internal-1566223570.0957482-19304-5-2da8c9ee-9fe4-40c2-9616-3fb4e947442b.nc.mat');
[file,path] = uigetfile('*.mat', 'Please select file to read');
load(strcat(path,file));

% *** INPUT *** --- mean latitude
lat = 70; % [°]

% compute latitude-dependent gravitational acceleration
% this comes from wikipedia: https://en.wikipedia.org/wiki/Gravitational_acceleration
gpoles = 9.832; g45 = 9.806; gequat = 9.780; % [m/s^2]
g = g45 - 0.5 * (gpoles - gequat) * cos(2*lat*pi/180);
z_m = data.z ./ g;
data = setfield(data,'z_m',z_m);

uisave('data',['converted_' file]);