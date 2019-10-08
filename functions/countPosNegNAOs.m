function timesev = countPosNegNAOs(time_np)
% timesev = countPosNegNAOs(time_np)
% for evaluation of several sequent only positive or only negative NAOs
% INPUT:
%   time_np     -   dates of only negative/positive NAOs
% OUTPUT:
%   timesev     -   struct with the dates of several sequent
%                   negative/positive NAOs with startmonth and endmonth. 
%                   The number of the cell is equal to the number of directly 
%                   following months. E.g. all dates in the 3. cell are the 
%                   start days of in total three negative/positive months.
%
% susann.aschenneller@uni-bonn.de, 08/2019

% start values
timesev_start{1} = time_np;
k = 2;

% find iterative several sequent values; the array-index equals the number
% of several sequent values.
while 1
    timediff = hours(diff(timesev_start{k-1})) / 24;
    ind = find(timediff == 28 | timediff == 29 | timediff == 30 | timediff == 31 | ...
        timediff == -28 | timediff == -29 | timediff == -30 | timediff ==  -31); 
    if isempty(ind) == 1
        break
    end
    timesev_start{k,1} = timesev_start{k-1}(ind);

    ind_extra = ind(diff(ind) > 1) + 1;
    num = length(ind_extra);
    if isempty(ind) == 0
        ind_extra(num+1,1) = ind(end) + 1;
        ind_fin = unique(cat(1,ind,ind_extra));
        timesev_start{k-1}(ind_fin) = [];
    end
    k = k + 1;
end

for k = 1 : length(timesev_start)
    timesev_end{k} = timesev_start{k} + calendarDuration(0,k,0);
    timesev{k} = [timesev_start{k} timesev_end{k}];
end

end