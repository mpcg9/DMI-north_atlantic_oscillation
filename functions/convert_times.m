function [ data, options ] = convert_times( data, options )

if nargin == 1 || length(fieldnames(options)) == 0
    options = struct;
    options.checkIrregularities = true;
end

data_fields = fieldnames(data);
time_bnds_exist = 0;
for i = 1:length(data_fields)
    if strcmp(data_fields{i},'time')
        timename = data_fields{i};
    elseif strcmp(data_fields{i}, 'units')
        unitsname = data_fields{i};
    elseif strcmp(data_fields{i}, 'time_bnds') ||...
           strcmp(data_fields{i}, 'time_bounds')
        time_bnds_exist = true;
        timebndsname = data_fields{i};
    end
end

% if the new data ingestion method isn't used, find time unit
if ~isstruct(data.(unitsname))
    for i = 1:length(data.(unitsname))
        if strncmpi(data.(unitsname){i}, 'days since ', 11) ||...
           strncmpi(data.(unitsname){i}, 'hours since ', 12)
            timeunit = data.(unitsname){i};
        end
    end
else
    timeunit = data.(unitsname).(timename);
end

% find start date in unit
timeunit = split(timeunit);
unit = timeunit{1};
if length(timeunit) == 4
    datestrings = arrayfun(@str2double, split(timeunit{3}, '-'));
    timestrings = arrayfun(@str2double, split(timeunit{4}, ':'));
    if length(timestrings) == 3
        starttime = datetime(datestrings(1), datestrings(2), datestrings(3), timestrings(1), timestrings(2), timestrings(3));
    else
        starttime = datetime(datestrings(1), datestrings(2), datestrings(3), timestrings(1), timestrings(2), 0);
    end
else
    datestrings = arrayfun(@str2double, split(timeunit(3), '-'));
    starttime = datetime(datestrings(1), datestrings(2), datestrings(3));
end

% detect monthly data with irregularities
if ~isdatetime(data.(timename)) && options.checkIrregularities && strcmpi(unit, 'days')
    options.uses30daymonths = false;
    options.usesnoleapyears = false;
    if all(diff(data.(timename)) == 30) % detect 30-day months / 360-day years
        options.uses30daymonths = true;
    elseif length(data.(timename)) > 96 && all(diff(data.(timename)(1:12:end)) == 365) % detect omitted leap years
        options.usesnoleapyears = true;
    end
end

% convert times to datetimes (if not yet done)
if ~isdatetime(data.(timename))
    if options.uses30daymonths
        data.(timename) = starttime + calmonths(floor(data.(timename)(1) / 30)) + days(rem(data.(timename)(1), 30)) + calmonths(0:1:(length(data.(timename))-1));
    elseif options.usesnoleapyears
        data.(timename) = starttime + years(floor(data.(timename)(1) / 365)) + days(rem(data.(timename)(1), 365)) + calmonths(0:1:(length(data.(timename))-1));
    elseif strcmpi(unit, 'days')
        data.(timename) = starttime + days(data.(timename));
    elseif strcmpi(unit, 'hours')
        data.(timename) = starttime + hours(data.(timename));
    end
end
if time_bnds_exist && ~isdatetime(data.(timebndsname))
    if options.uses30daymonths
        data.(timebndsname) = starttime + calmonths(floor(data.(timebndsname)(1,1) / 30)) + days(rem(data.(timebndsname)(1,1), 30)) + [calmonths(0:1:(length(data.(timename))-1)); calmonths(1:1:length(data.(timename)))];
    elseif options.usesnoleapyears
        data.(timebndsname) = starttime + years(floor(data.(timebndsname)(1,1) / 365)) + days(rem(data.(timebndsname)(1,1), 365)) + [calmonths(0:1:(length(data.(timename))-1)); calmonths(1:1:length(data.(timename)))];
    elseif strcmpi(unit, 'days')
        data.(timebndsname) = starttime + days(data.(timebndsname));
    elseif strcmpi(unit, 'hours')
        data.(timebndsname) = starttime + hours(data.(timebndsname));
    end
end