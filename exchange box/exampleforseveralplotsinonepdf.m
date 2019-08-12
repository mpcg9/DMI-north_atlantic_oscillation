%% VLBI seminar - Modelling temperature and thermal expansion behaviour of the Onsala 20m radio telescope
%
% main part 2: evaluate Data
% contents:
%       1. split a (1-year-)dataset into several timeseries
%           1.1 preparation: kick out single missing values
%           1.2 preparation: generate start-stop list out of incomplete days
%           1.3 preparation: generate start-stop list out of several sequent missing values (-999)
%           1.4 preparation: combine all start-stop lists
%           1.5 splitting
%       2. Auto-Correlation
%       3. Filtering of the time series to regular 10-minute steps
%       4. Cross-correlation of the original filtered time series
%       5. Time delays
%       6. move the original time series by dt
%       7. Cross-Correlation of the moved time series
%       8. plots
%
% fault repair:
%       - if saving of the files doesn't work, try setting current
%         directory to the folder of this main-file
%
% other instructions:
%       - when *** INPUT *** appears there are parameters you can change
%
% Susann Aschenneller, 2019

%% 0. settings
clearvars -except Pcomb Wcomb day month year daysNum misValP misValW misValPs misValWs incDayP incDayW
clc; close all;
addpath(genpath(cd))

%% 1. split a (1-year-)dataset into several timeseries
%% 1.1 preparation: kick out single missing values

% compare misValW and misValsWs
if exist('misValW','var') == 1 && exist('misValsWs','var') == 1
    temp = ~ismember(misValW,misValWs);
    singmisVal = unique(temp .* misValW(:,1));
    singmisVal(1) = [];
    Wcomb(singmisVal,:) = [];
elseif exist('misValW','var') == 1 && exist('misValsWs','var') == 0
    Wcomb(misValW(:,1),:) = [];
end

clear temp singmisVal

%% 1.2 preparation: generate start-stop list out of incomplete days

% out of incDayP
if exist('incDayP','var') == 1
    stlistW_iP = generateStartStopListInc(Wcomb,incDayP(:,1));
    stlistP_iP = generateStartStopListInc(Pcomb,incDayP(:,1));
else
    stlistW_iP = []; stlistP_iP = [];
end

% out of incDayW
if exist('incDayW','var') == 1
    stlistW_iW = generateStartStopListInc(Wcomb,incDayW(:,1));
    stlistP_iW = generateStartStopListInc(Pcomb,incDayW(:,1));
else
    stlistW_iW = []; stlistP_iW = [];
end

%% 1.3 preparation: generate start-stop list out of several sequent missing values (-999)
if exist('misValWs','var') == 1
    noDataWs = misVals2noData(misValWs);
    stlistW_mW = generateStartStopListInc(Wcomb,noDataWs);
    stlistP_mW = generateStartStopListInc(Pcomb,noDataWs);
else
    stlistW_mW = []; stlistP_mW = [];
end

%% 1.4 preparation: combine all start-stop lists
if isempty(stlistW_iP) == 0 || isempty(stlistW_iW) == 0 || isempty(stlistW_mW) == 0
    stlistW = [stlistW_iP;stlistW_iW;stlistW_mW];
    stlistW1 = unique(stlistW(:,1)); stlistW2 = unique(stlistW(:,2));
    stlistW = [stlistW1 stlistW2];
end
clear stlistW_iP stlistW_iW stlistW_mW stlistW1 stlistW2

if isempty(stlistP_iP) == 0 || isempty(stlistP_iW) == 0 || isempty(stlistP_mW) == 0
    stlistP = [stlistP_iP;stlistP_iW;stlistP_mW];
    stlistP1 = unique(stlistP(:,1)); stlistP2 = unique(stlistP(:,2));
    stlistP = [stlistP1 stlistP2];
end
clear stlistP_iP stlistP_iW stlistP_mW stlistP1 stlistP2

% if no values are missing: create a dummy vector for the
% makeBlocks-function
if exist('stlistW','var') == 0
    stlistW = [0 0];
end
if exist('stlistP','var') == 0
    stlistP = [0 0];
end

%% 1.5 splitting
% *** INPUT ***: number of days in a block/timeseries
ndiab = 15;

% DO NOT CHANGE
nmeaspdW = 1440; nmeaspdP = 288; % number of measurements per day
try
    Wblx = makeBlocks(Wcomb,ndiab,nmeaspdW,stlistW);
    Pblx = makeBlocks(Pcomb,ndiab,nmeaspdP,stlistP);
catch
    error('not enough data')
end

% split pisa blocks into 19 and 20
for k = 1:length(Pblx)
    P19blx{1,k} = [Pblx{1,k}(:,1) Pblx{1,k}(:,2)];
    P20blx{1,k} = [Pblx{1,k}(:,1) Pblx{1,k}(:,3)];
end
%  number of blocks:
numblxW = length(Wblx); numblxP = length(Pblx);
if numblxW < numblxP
    numblx = numblxW;
else
    numblx = numblxP;
end

%% 2. Auto-Correlation
for k = 1 : numblx
    K_tempW{k} = computeAutoCorrelationFunction(Wblx{k}(:,2));
    K_tempP19{k} = computeAutoCorrelationFunction(P19blx{k}(:,2));
    K_tempP20{k} = computeAutoCorrelationFunction(P20blx{k}(:,2));
end

clear Pblx ndiab nmeaspdW nmeaspdP numblxW numblxP

%% 3. Filtering of the time series to regular 10-minute steps
% --- weather ---
% original: 1440 measurements per day -> 1 measurement per 1 minute
for k = 1:numblx
    WFilt{1,k} = filterMedianData(Wblx{1,k},10);
end
% --- pisa ---
% original: 288 measurements per day -> 1 measurement per 5 minutes
% thermometer n°19
for k = 1:numblx
    P19Filt{1,k} = filterMedianData(P19blx{1,k},2);
end

% thermometer n°20
for k = 1:numblx
    P20Filt{1,k} = filterMedianData(P20blx{1,k},2);
end

clear Wblx P19blx P20blx

%% 4. Cross-correlation of the original filtered time series
for k = 1 : numblx
    Kc_tempW_tempP19{k} = computeCrossCorrelationFunction(WFilt{k}(:,2),P19Filt{k}(:,2));
    Kc_tempW_tempP20{k} = computeCrossCorrelationFunction(WFilt{k}(:,2),P20Filt{k}(:,2));
end

%% 5. Time delays
% out of cross correlation: how many 10-minute-steps needs a pisa
% thermometer to adapt to the outside-thermometer; visually: the first peak
for k = 1 : numblx
    [~,locs] = findpeaks(Kc_tempW_tempP19{k});
    if isempty(locs) == 0
        dt19{k} = locs(1);
    else
        dt19{k} = 1*10-10;
    end
    
    [~,locs] = findpeaks(Kc_tempW_tempP20{k});
    if isempty(locs) == 0
        dt20{k} = locs(1);
    else
        dt20{k} = 1*10-10;
    end
end

for k = 1:length(dt19)
    dt19comb(k) = dt19{k};
    dt20comb(k) = dt20{k};
end

save(['data' filesep 'dt19_' num2str(year) '.mat'],'dt19comb');
save(['data' filesep 'dt20_' num2str(year) '.mat'],'dt20comb');

%% 6. move the original time series by dt

% change timestamps
% used for plots of the time series
for k = 1 : numblx
    P19mov{k}(:,1) = P19Filt{k}(:,1) - dt19{k}*1/144; % 10 minutes equals 1/144 day
    P19mov{k}(:,2) = P19Filt{k}(:,2);
    P20mov{k}(:,1) = P20Filt{k}(:,1) - dt20{k}*1/144;
    P20mov{k}(:,2) = P20Filt{k}(:,2);
end

% truncate time series
% used for recalculation of the cross correlation function
% weather data: truncate before last dt+1 measurements
% pisa data: truncate after first dt measurements
for k = 1 : numblx
    if dt19{k} ~= 0
        WP19red{k} = WFilt{k}(1 : end - dt19{k} + 1,:); % weather reduced by dt19
        P19red{k} = P19Filt{k}(dt19{k} : end,:); % P19 reduced by dt19
    else
        WP19red{k} = WFilt{k};
        P19red{k} = P19Filt{k};
    end
    if dt20{k} ~= 0
        WP20red{k} = WFilt{k}(1 : end - dt20{k} + 1,:); % weather reduced by dt20
        P20red{k} = P20Filt{k}(dt20{k} : end,:); % P20 reduced by dt19
    else
        WP20red{k} = WFilt{k};
        P20red{k} = P20Filt{k};
    end
end

%% 7. Cross-Correlation of the moved time series

% compute new cross correlation
% = normalized cross correlation function?
% normierte Kreuzkorrelationsfunktion?
for k = 1 : numblx
    Kc_WP19red_P19red{k} = computeCrossCorrelationFunction(WP19red{k}(:,2),P19red{k}(:,2));
    Kc_WP20red_P20red{k} = computeCrossCorrelationFunction(WP20red{k}(:,2),P20red{k}(:,2));
end

%% 8. plots
%% 8.1 plots n°19

for k = 1 : numblx
    % axis configuration for the cross correlations (right)
    xc_min = 0; xc_max = length(Kc_tempW_tempP19{k});
    yc_min = -0.6; yc_max = 1;
    
    % left side: orinal & moved time series
    h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
    subplot(1,2,1); hold on;
    plot(WFilt{k}(:,1),WFilt{k}(:,2));
    plot(P19Filt{k}(:,1),P19Filt{k}(:,2));
    plot(P19mov{k}(:,1),P19mov{k}(:,2));
    xlabel('days in fractions'); ylabel('[°C]');
    title('moved time series for thermometer n°19'); grid on; hold off;
    legend('weather original','pisa n°19 original',['pisa n°19 moved by ' num2str(dt19{k}) ' steps']');
    
    % right side: 'orinal' & 'moved' cross correlation function
    subplot(1,2,2); hold on;
    xaxis = 1 : length(Kc_tempW_tempP19{k});
    plot(xaxis,Kc_tempW_tempP19{k});
    xaxis = 1 : length(Kc_WP19red_P19red{k});
    plot(xaxis,Kc_WP19red_P19red{k});
    xlabel('steps [144 steps are 1 day, 1 step are 10 minutes]'); ylabel('correlation'); grid on;
    axis([xc_min xc_max yc_min yc_max]);
    title(' cross correlation for moved time series for thermometer n°19'); hold off;
    legend('original',['moved by ' num2str(dt19{k}) ' steps']);
    
    % save all plots in one pdf
    orient(h,'landscape');
    print(h,'-append','-dpsc','results outside to inside 19.ps'); 
end

%% 8.2 plots n°20

for k = 1 : numblx
    xc_min = 0; xc_max = length(Kc_tempW_tempP20{k});
    yc_min = 0; yc_max = 1;
    
    % left side: orinal & moved time series
    h = figure('visible','off','units','normalized','outerposition',[0 0 1 1]);
    subplot(1,2,1); hold on;
    plot(WFilt{k}(:,1),WFilt{k}(:,2));
    plot(P20Filt{k}(:,1),P20Filt{k}(:,2));
    plot(P20mov{k}(:,1),P20mov{k}(:,2));
    xlabel('days in fractions'); ylabel('[°C]');
    title('moved time series for thermometer n°20'); grid on; hold off;
    legend('weather original','pisa n°20 original',['pisa n°20 moved by ' num2str(dt20{k}) ' steps']');
    
    % right side: 'orinal' & 'moved' cross correlation function
    subplot(1,2,2); hold on;
    xaxis = 1 : length(Kc_tempW_tempP20{k});
    plot(xaxis,Kc_tempW_tempP20{k});
    xaxis = 1 : length(Kc_WP20red_P20red{k});
    plot(xaxis,Kc_WP20red_P20red{k});
    xlabel('steps [144 steps are 1 day, 1 step are 10 minutes]'); ylabel('correlation'); grid on;
    axis([xc_min xc_max yc_min yc_max]);
    title(' cross correlation for moved time series for thermometer n°20'); hold off;
    legend('original',['moved by ' num2str(dt20{k}) ' steps']);
    
    % save all plots in one pdf
    orient(h,'landscape');
    print(h,'-append','-dpsc','results outside to inside 20.ps'); 
end

%% 8.3 plots of Auto-Correlation
keyboard
for k = 1 : numblx
  
    % left side: original time series
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(3,2,1);  plot(WFilt{k}(:,1),WFilt{k}(:,2)); title('weather');
    xlabel('days in fractions'); ylabel('[°C]');
    
    subplot(3,2,3);  plot(P19Filt{k}(:,1),P19Filt{k}(:,2)); title('inside n°19');
    xlabel('days in fractions'); ylabel('[°C]');
    
    subplot(3,2,5);  plot(P20Filt{k}(:,1),P20Filt{k}(:,2)); title('inside n°20');
    xlabel('days in fractions'); ylabel('[°C]');
    
    % right side: auto correlation functions
    
    % axis configuration
    xc_min = 0; xc_max = length(K_tempW{k});
    yc_min = -0.5; yc_max = 1;
    
    xaxis = 1 : length(K_tempW{k});
    subplot(3,2,2);  plot(xaxis,K_tempW{k}); title('auto-correlation weather');
    axis([xc_min xc_max yc_min yc_max]);
    xlabel('steps [1440 steps are 1 day, 1 step is 1 minute]'); ylabel('correlation'); grid on;
    
    % axis configuration
    xc_min = 0; xc_max = length(K_tempP19{k});
    yc_min = -0.5; yc_max = 1;
    
    xaxis = 1 : length(K_tempP19{k});
    subplot(3,2,4);  plot(xaxis,K_tempP19{k}); title('auto-correlation inside n°19');
    axis([xc_min xc_max yc_min yc_max]);
    xlabel('steps [288 steps are 1 day, 1 step are 5 minutes]'); ylabel('correlation'); grid on;
    
    % axis configuration
    xc_min = 0; xc_max = length(K_tempP20{k});
    yc_min = -0.5; yc_max = 1;
    
    xaxis = 1 : length(K_tempP20{k});
    subplot(3,2,6);  plot(xaxis,K_tempP19{k}); title('auto-correlation inside n°20');
    axis([xc_min xc_max yc_min yc_max]);
    xlabel('steps [288 steps are 1 day, 1 step are 5 minutes]'); ylabel('correlation'); grid on;
end
