function datFilt = monthlyMeanFilter(data)
% datFilt = monthlyMeanFilter(data)
%
% Compute the monthly mean of a daily timeseries.
% This is the same as meanFilter, with the difference that blocksize is
% exactly a month length.
%
%   INPUT
%       data        -   original time series, struct with fields 'GBI' and 'time'
%                       calculated
%   OUTPUT
%       datFilt     -   filtered time series, new timestamp is the
%                       middle of the old time-vector, struct
%
% susann.aschenneller@uni-bonn.de, 08/2019

% blocksizes for each month
bsz{1} = 31;
bsz{2} = 28;
bsz{3} = 31;
bsz{4} = 30;
bsz{5} = 31;
bsz{6} = 30;
bsz{7} = 31;
bsz{8} = 31;
bsz{9} = 30;
bsz{10} = 31;
bsz{11} = 30;
bsz{12} = 31;

% % initialize blocksize for the first value
% blocksize = bsz{month(data.time(1))};

j = 1; k = 1;
curr_mon = bsz{month(data.time(1))}; % length of the current month
while j + curr_mon - 1 <= length(data.GBI)
    blocksize = bsz{month(data.time(j))};       
    temp = data.GBI(k: k+blocksize-1);
    datFilt.GBI(k,1) = mean(temp);
    datFilt.time(k,1) = data.time(floor(j + blocksize/2));
    foll_mon = bsz{month(data.time(j + blocksize))}; % the length of the following month  
    j = j + foll_mon;
    curr_mon = foll_mon;  
    k = k + 1;
end

end