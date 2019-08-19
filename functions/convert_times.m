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
        if strncmpi(data.(unitsname){i}, 'days since ', 11)
            timeunit = data.(unitsname){i};
        end
    end
else
    timeunit = data.(unitsname).(timename);
end

% find start date in unit
timeunit = split(timeunit);
starttime = datetime(timeunit{3}, 'InputFormat', 'uuuu-M-d');

% convert times to datetimes (if not yet done)
if ~isdatetime(data.(timename))
    data.(timename) = starttime + days(data.(timename));
end
if time_bnds_exist && ~isdatetime(data.(timebndsname))
    data.(timebndsname) = starttime + days(data.(timebndsname));
end

