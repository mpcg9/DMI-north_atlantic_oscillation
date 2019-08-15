function [fig] = plot_map( data, projectionType, Bounds_lon, Bounds_lat, varargin )
%SAVE_MAP Summary of this function goes here
%   Detailed explanation goes here

% Find out some which variable to plot
varName = getVariableName(data);

% Treat name-value pairs
options = struct(...  % setting defaults...
    'markMaxPosition', false,... 
    'markMinPosition', false,... 
    'modifyPapersize', false,...
    'title', '',...
    'Interpreter', 'none',...
    'colorbarlimits', false,...
    'colormap', 'jet',...
    'Visible', 'on'...
    );

% read the acceptable names
optionNames = fieldnames(options);

% count arguments
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
   error('EXAMPLE needs propertyName/propertyValue pairs')
end

for pair = reshape(varargin,2,[]) % pair is {propName;propValue}
   inpName = pair{1}; 
   if any(strcmp(inpName,optionNames))
      % overwrite options. 
      options.(inpName) = pair{2};
   else
      error('%s is not a recognized parameter name',inpName)
   end
end
    
    
% Create figure
fig = figure('Visible', options.Visible);
if size(options.modifyPapersize) > 1
    fig.PaperUnits = 'Centimeters';
    fig.PaperSize = options.modifyPapersize;
end

hold on;
if length(options.colorbarlimits) > 1
    caxis(options.colorbarlimits);
end
colormap(options.colormap);

m_proj(projectionType, 'long', Bounds_lon, 'lat', Bounds_lat);
m_image(data.lon, data.lat, data.(varName)');
m_coast('linewidth', 1, 'color', 'black');
m_grid;
if length(options.markMinPosition) > 1
    m_plot(data.lon(options.markMinPosition(1)), data.lat(options.markMinPosition(2)), '*r');
end
if length(options.markMaxPosition) > 1
    m_plot(data.lon(options.markMaxPosition(1)), data.lat(options.markMaxPosition(2)), '*b');
end
xlabel(options.title, 'Interpreter', options.Interpreter);
colorbar('southoutside');
hold off;

end

