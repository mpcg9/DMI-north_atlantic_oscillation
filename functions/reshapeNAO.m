function nao_x_fin = reshapeNAO(nao)
% nao_x_fin = reshapeNAO(nao)
% INPUT
%   monthly nao time series arranged in a matrix, 12 months per line with
%   the years at the beginning of the lines [nx13]
% OUTPUT
%   [nx3], col 1: year, col 2: month, col 3: nao

% matrix to vector
nao_re = reshape(nao',[],1); 
% kick out the year dates in between
k = 1; j = 1;
while k < length(nao_re)
    if nao_re(k) > 1000
        year1(j) = nao_re(k);
        nao_re(k) = [];
        j = j + 1;
    end
    k = k + 1;
end
% create a corresponding year vector
m = 1;
for k = year1(1) : year1(end)
   for j = 1:12
      year2(m,1) = k;
      m = m + 1;
   end
end
% create a corresponding month vector
month = [1:12]'; month = repmat(month,length(year1),1);

% put everything together
nao_x_fin = struct('time',datetime(year2,month,1,'Format','dd.MM.yyyy'));
nao_x_fin = setfield(nao_x_fin,'nao',nao_re);

end