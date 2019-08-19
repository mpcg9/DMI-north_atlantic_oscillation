function [ data ] = convert_times( data )

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
    datestrings = cellfun(@str2double, split(timeunit{3}, '-'));
    timestrings = cellfun(@str2double, split(timeunit{4}, ':'));
    starttime = datetime(datestrings(1), datestrings(2), datestrings(3), timestrings(1), timestrings(2), timestrings(3));
else
    datestrings = cellfun(@str2double, split(timeunit(3), '-'));
    starttime = datetime(datestrings(1), datestrings(2), datestrings(3));
end

% convert times to datetimes (if not yet done)
if ~isdatetime(data.(timename))
    if strcmpi(unit, 'days')
        data.(timename) = starttime + days(data.(timename));
    elseif strcmpi(unit, 'hours')
        data.(timename) = starttime + hours(data.(timename));
    end
end
if time_bnds_exist && ~isdatetime(data.(timebndsname))
    if strcmpi(unit, 'days')
        data.(timebndsname) = starttime + days(data.(timebndsname));
    elseif strcmpi(unit, 'hours')
        data.(timebndsname) = starttime + hours(data.(timebndsname));
    end
end

