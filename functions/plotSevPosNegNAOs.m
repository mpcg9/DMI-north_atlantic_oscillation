function [] = plotSevPosNegNAOs(sev_NAO,size,negpos,varargin)
% [] = plotSevPosNegNAOs
% creates a stem-like plot of several sequent positive or negative NAO
% values following after another. The number of sequent days is represented
% by the widths of the stems and numbers. All stems have the same length.
%
% INPUT
%   sev_NAO     -   struct that comes out of 'countPosNegNAOs'. Each cell
%                   contents start- and end-date of an only positive/negative period
%   size        -   desired length of the stems
%   negpos      -   'neg' for negative NAO, 'pos' for positive NAO
%   varargin    -   axis limitations, x_min
% OUTPUT
%
% susann.aschenneller@uni-bonn.de, 08/2019

if negpos == 'neg'
    yvalues = -size*(ones(2,1));
    color = 'b';
    ytext1 = yvalues(1) - size * 0.07;
    ytext2 = yvalues(1) - size * 0.17;
elseif negpos == 'pos'
    yvalues = size*(ones(2,1));
    color = 'r';
    ytext1 = yvalues(1) + size * 0.07;
    ytext2 = yvalues(1) + size * 0.17;
end
count = 0;

for k = 1 : length(sev_NAO)
    if isempty(sev_NAO{k}) == 0
        for j = 1 : (numel(sev_NAO{k})/2)
            xvalues = [sev_NAO{k}(j,1) sev_NAO{k}(j,2)];
            area(xvalues,yvalues,'FaceColor',color,'EdgeColor',color);
            count = count + 1;
            % try to avoid overlapping numbers
            if mod(count,2) == 0
                ytext = ytext1;
            else
                ytext = ytext2;
            end
            text(xvalues(1),ytext,num2str(k+1),'FontSize',12,'Color',color);
        end
    end
end

if isempty(varargin) == 1    
    y_min = -2 * size; y_max = 2 * size;
    ylim([y_min y_max]);
else
    x_min = varargin{1};
    x_max = x_min + calendarDuration(10,0,0);
    xlim([x_min x_max]);
    y_min = -2 * size; y_max = 2 * size;
    ylim([y_min y_max]);
end

end