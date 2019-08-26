function [] = plotPosNegNAOs(time_np,size,negpos)
% [] = plotPosNegNAOs(time_np,size,negpos)
% that works also with 'bar', but takes much more time.

timediff = diff(month(time_np));

% length and color of the bars
if negpos == 'neg'
    yvalues = -size*(ones(2,1));
    color = 'b';
elseif negpos == 'pos'
    yvalues = size*(ones(2,1));
    color = 'r';
end

for k = 2 : length(timediff)
    if timediff(k-1) == 1 || timediff(k-1) == -11
        temp(1,1) = time_np(k-1);
        temp(2,1) = time_np(k);
        area(temp,yvalues,'FaceColor',color,'EdgeColor',color);
    end
end

% axis limitations
x_min3 = time_np(1); x_max3 = time_np(end);
y_min3 = -2 * size; y_max3 = 2 * size;
xlim([x_min3 x_max3]);
ylim([y_min3 y_max3]);

end