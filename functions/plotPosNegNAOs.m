function [] = plotPosNegNAOs(time_np,size,negpos)
% [] = plotPosNegNAOs(time_np,size,negpos)
% creates a stem-like plot of positive/negative NAOs over time, that have
% all the same length
% INPUT
%   time_np     -   datetime vector with the dates of positive/negative NAO
%   size        -   desired length of the stems
%   negpos      -   'neg' for negative NAO, 'pos' for positive NAO
%
% susann.aschenneller@uni-bonn.de

% length and color of the bars
num = length(time_np);
if negpos == 'neg'
    yvalues = -size*(ones(num,1));
    color = 'b';
elseif negpos == 'pos'
    yvalues = size*(ones(num,1));
    color = 'r';
end

bar(time_np,yvalues,'FaceColor',color);

% axis limitations
y_min3 = -2 * size; y_max3 = 2 * size;
ylim([y_min3 y_max3]);

end