function [h] = plotPosNegBars(max_months,varargin)

h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);

for k = 1 : length(varargin) % through input
    if iscell(varargin{k}{1}) == 1 % if there's CMIP6-data in varargin, this must be a cell
        num{k} = zeros(max_months,length(varargin{k}));
        for m = 1 : length(varargin{k}) % through models
            for j = 1 : length(varargin{k}{m}) % through the data in one model
                num{k}(j,m) = length(varargin{k}{m}{j});
            end
        end
    end
end

num_all = zeros(max_months,1);
for k = 1 : length(num)
    num_all = [num_all num{k}];
end
bar(2:max_months+1,num_all);
set(gca,'XTick',1:1:max_months);

end