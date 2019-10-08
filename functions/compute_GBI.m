function [ GBI ] = compute_GBI( data, varargin)
% [ GBI ] = compute_GBI( data, lat_min, lat_max, lon_min, lon_max)
% INPUT
%   data    - geopotential height
%   lat_min, lat_max, lon_min, lon_max: optional
%       - if you enter only lat_min and lat_max, the function computes an
%       areal mean of geopotential height over all longitudes in the
%       boundaries of the defined latitudes
%       - if you enter no no boundaries, the function computes the
%       Greenland Blocking Index in the range of it's definition [60,80,-80,-20]


if nargin == 3
    lon_min = 0;
    lon_max = 360;
    lat_min = varargin{1};
    lat_max = varargin{2};
elseif nargin == 1
    lat_min = 60;
    lat_max = 80;
    lon_min = -80;
    lon_max = -20;
else
    lat_min = 60;
    lat_max = 80;
    lon_min = varargin{3};
    lon_max = varargin{4};    
end

varn = getVariableName(data);
data = select_subset(data, lat_min, lat_max, lon_min, lon_max);

% Find Fieldnames
data_fields = fieldnames(data);
for i = 1:length(data_fields)
    if strcmp(data_fields{i},'lat') ||...
       strcmp(data_fields{i},'latitude')
        latname = data_fields{i};
    elseif strcmp(data_fields{i}, 'lon') ||...
           strcmp(data_fields{i}, 'longitude')
        lonname = data_fields{i};
    end
end

weights = cos(data.(latname) .* (pi/180));
weights = weights ./ sum(weights);
% data.(varn) = data.(varn) - mean(data.(varn), 3);
GBI = reshape(mean(sum(data.(varn) .* weights', 2)), size(data.(varn), 3), 1);

end

