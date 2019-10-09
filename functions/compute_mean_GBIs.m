function [GBI_mean,refdates] = compute_mean_GBIs(GBI_data)
% nao_mean = compute_mean_GBIs(nao_data)
% INPUT:
%   GBI_data:   cell containing structs with the fields time, GBI,
%               name(optional)
% OUTPUT:
%   GBI_mean:   mean for the GBIs over all models, interpolated 
%   refdates:   the corresponding timestamps

% find min/max year of all models
dat_temp = cell2mat(GBI_data);
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

% interpolate the GBIs to the reference time set
for k = 1 : length(GBI_data)
    GBI_interp{k} = interp1(GBI_data{k}.time,GBI_data{k}.GBI,refdates);
end
GBI_interp = cell2mat(GBI_interp);
GBI_mean = mean(GBI_interp,2,'omitnan');

end