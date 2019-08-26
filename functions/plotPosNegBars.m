function [] = plotPosNegBars(max_months,varargin)

num = zeros(max_months,length(varargin));
for k = 1 : length(varargin)
    for j = 1 : length(varargin{k})
        num(j,k) = length(varargin{k}{j});
    end
end

bar(num);

end