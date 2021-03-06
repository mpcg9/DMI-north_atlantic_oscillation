clc, clear, close all;

run './scripts/nao_dmi_short.m'
run './scripts/nao_noaa_long.m'

naodmishort = naodmishort';
naodmishort = naodmishort(:);

naonoaalong = naonoaalong';
naonoaalong = naonoaalong(:);

% set missing data to NaN
naodmishort(naodmishort == -99.99) = NaN;
naonoaalong(naonoaalong == -99.99) = NaN;

save('../binary_data/data_NAO.mat', 'naodmishort', 'naonoaalong');