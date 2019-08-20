function [ data_subset ] = select_timespan( data, day_start, day_end, force_no_boundary_usage )

if nargin == 3
    force_no_boundary_usage = false;
end

% Find out which variables exist
data_fields = fieldnames(data);
bnds_time_exist = false;
for i = 1:length(data_fields)
    if strcmp(data_fields{i}, 'time')
        timename = data_fields{i};
    elseif strcmp(data_fields{i}, 'time_bnds') ||...
           strcmp(data_fields{i}, 'time_bounds')
        bnds_time_exist = true;
        timebndsname = data_fields{i};
    end
end

if isdatetime(day_start)
    data = convert_times(data);
end

% Select subset of time
if bnds_time_exist && ~force_no_boundary_usage
    time_idx = data.(timebndsname)(2,:) > day_start & data.(timebndsname)(1,:) < day_end;
else
    time_idx = data.(timename) >= day_start & data.(timename) <= day_end;
end

% Create data subset
data_subset = struct;
for i = 1:length(data_fields)
    if      strcmp(data_fields{i}, 'plev') ||...
            strcmp(data_fields{i}, 'units') ||...
            strcmp(data_fields{i}, 'lat') ||...
            strcmp(data_fields{i}, 'latitude') ||...
            strcmp(data_fields{i}, 'lat_bnds') ||...
            strcmp(data_fields{i}, 'lat_bounds') ||...
            strcmp(data_fields{i}, 'lon') ||...
            strcmp(data_fields{i}, 'longitude') ||...
            strcmp(data_fields{i}, 'lon_bnds') ||...
            strcmp(data_fields{i}, 'lon_bounds')
                data_subset.(data_fields{i}) = data.(data_fields{i});
    elseif  strcmp(data_fields{i}, timename)
                data_subset.(data_fields{i}) = data.(data_fields{i})(time_idx);
    elseif  bnds_time_exist && strcmp(data_fields{i}, timebndsname)
                data_subset.(data_fields{i}) = data.(data_fields{i})(:, time_idx);
    else
                if length(size(data.(data_fields{i}))) == 4
                    data_subset.(data_fields{i}) = data.(data_fields{i})(:, :, :, time_idx);
                else
                    data_subset.(data_fields{i}) = data.(data_fields{i})(:, :, time_idx);
                end
    end
end
end