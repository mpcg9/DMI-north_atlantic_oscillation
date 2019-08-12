function num = date2num(year,month,day)
% date2num(year,month,day)
% calculates the consecutive number of days within a year
% year,month,day have to be numbers
% e.g. 01.01. is the first day of the year
% year is required because of leap years

if nargin < 1
    year = 2019; month = 2; day = 8;
end

% number of days per month
jan = 31; feb = 28;
if floor(year/4) == (year/4)
    feb = 29;
end
mar = 31; apr = 30; may = 31; jun = 30; jul = 31; aug = 31; sep = 30;
oct = 31; nov = 30; dec = 31;

numPerMonth = [jan feb mar apr may jun jul aug sep oct nov dec];
clear jan feb mar apr may jun jul aug sep oct nov dec

% consecutive number of days within a year
if month == 1
    num = day;
else
    k = 1;
    num = 0;
    while k < month
        num = num + numPerMonth(k);
        k = k + 1;
    end
    num = num + day;
end

end