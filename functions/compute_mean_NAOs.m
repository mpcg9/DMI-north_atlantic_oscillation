function [nao_mean,refdates] = compute_mean_NAOs(nao_data)
% nao_mean = compute_mean_NAOs(nao_data)
% INPUT:
%   nao_data:   cell containing structs with the fields time, nao,
%               name(optional)
% OUTPUT:
%   nao_mean:   mean for the NAOs over all models, interpolated 
%   refdates:   the corresponding timestamps

% find min/max year of all models
dat_temp = cell2mat(nao_data);
dat_temp = dat_temp.time;
minyear = year(min(dat_temp));
maxyear = year(max(dat_temp));

% find the used months
months = unique(month(dat_temp));

% create a synthetical reference time dataset
years = minyear : maxyear;
ind = 1;
for k = 1 : length(years)
    for j = 1 : length(months)
        refdates(ind) = datetime(years(k),months(j),15,'Format','dd.MM.yyyy');
        ind = ind + 1;
    end
end
refdates = refdates';

% interpolate the NAOs to the reference time set
for k = 1 : length(nao_data)
    nao_interp{k} = interp1(nao_data{k}.time,nao_data{k}.nao,refdates);
end
nao_interp = cell2mat(nao_interp);
nao_mean = mean(nao_interp,2,'omitnan');

end