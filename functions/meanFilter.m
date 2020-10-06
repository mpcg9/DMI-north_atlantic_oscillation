function datFilt = meanFilter(data,blocksize)
% datFilt = meanFilter(data,blocksize)
%
% reduces the time series by calculating a mean for each block defined by
% blocksize e.g. if blocksize = 10, only the mean of 10 sequent elements
% remains
%
%   INPUT
%       data        -   original time series, struct with fields 'GBI' and 'time'
%       blocksize   -   the number of days of which the mean is to be
%                       calculated
%   OUTPUT
%       datFilt     -   filtered time series, new timestamp is the
%                       middle of the old time-vector, struct
%
% susann.aschenneller@uni-bonn.de, 08/2019

j = 1; k = 1;
while j + blocksize - 1 <= length(data.GBI)
   % save in cache blocks of x elements of the original data
   dtemp = data.GBI(j:j+blocksize - 1,1);
   % mean of the cache
   datFilt.GBI(k,1) = mean(dtemp);
   datFilt.time(k,1) = data.time(j + blocksize/2);
   j = j + blocksize;
   k = k + 1;
end

end