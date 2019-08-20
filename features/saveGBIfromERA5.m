%% saveGBIfromERA5

%% settings
clearvars; clc;
addpath(genpath(cd), genpath(['..' filesep 'functions']));

load('D:\ERA5\geopotential\adaptor.mars.internal-1566223570.0957482-19304-5-2da8c9ee-9fe4-40c2-9616-3fb4e947442b.nc.mat');
% [file,path] = uigetfile('*.mat', 'Please select file to read');
% load(strcat(path,file));

% *** INPUT *** --- mean latitude
lat = 70; % [°]

% compute latitude-dependent gravitational acceleration
% this comes from wikipedia: https://en.wikipedia.org/wiki/Gravitational_acceleration
g_poles = 9.832; g45 = 9.806; g_equat = 9.780; % [m/s^2]
g = g45 - 0.5 * (g_poles - g_equat) * cos(2*lat*pi/180);
% g = 9.80665; % (standard)

% % now its getting crazy: geopotential changes with height
% g = sqrt(g);

z_meters = data.z ./ g;
data = setfield(data,'z_meters',z_meters);

% compute GBI
GBI_temp = compute_GBI(data);
% convert time
refdate = datetime('01.01.1900','Format','dd.MM.yyyy');
time = refdate + hours(data.time);

% put everything in a struct
GBI = struct('time',time);
GBI = setfield(GBI,'GBI',GBI_temp);

% save
% uisave('GBI','GBI_ERA5');
save('C:\Users\Lenovo\Documents\Master\DMI-north_atlantic_oscillation\data\GBI\ERA5\GBI_ERA5.mat','GBI');

