function readClimateDataRecursive(startPath, varargin)
%% Options
options = struct(...  % setting defaults...
        'Longitudes', false,...
        'Latitudes', false,...
        'Plev', 0,...
        'convertTime', true...
    );

% read the acceptable names
optionNames = fieldnames(options);

% count arguments
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
   error('EXAMPLE needs propertyName/propertyValue pairs')
end

for pair = reshape(varargin,2,[]) % pair is {propName;propValue}
   inpName = pair{1}; 
   if any(strcmp(inpName,optionNames))
      % overwrite options. 
      options.(inpName) = pair{2};
   else
      error('%s is not a recognized parameter name',inpName)
   end
end

%% Check if there are *.nc-Files in this folder, if so, read this folder and save mat-file
folderContentsNc = dir(strcat(startPath, '/*.nc'));
if size(folderContentsNc, 1) > 0
    disp(['reading *.nc-files in folder: ', startPath]);
    try
        data = readClimateDataFolder(startPath, 'Longitudes', options.Longitudes, 'Latitudes', options.Latitudes, 'Plev', options.Plev, 'convertTime', options.convertTime);
        disp('saving *.mat-file...');
        save(strcat(startPath, '.mat'), 'data');
    catch ERROR_DETAILS
        warning('Something went wrong during intake, skipping...');
        disp('Details: ');
        disp(ERROR_DETAILS.message);
    end
else
    disp(['no *.nc-files found in folder: ', startPath]);
end

%% Recursive call for subfolders
clear data;
folderContents = dir(startPath);
for i = 1:size(folderContents, 1)
    if folderContents(i).isdir && ~strcmp(folderContents(i).name, '..') && ~strcmp(folderContents(i).name, '.')
        readClimateDataRecursive(strcat(startPath, '/', folderContents(i).name) ,'Longitudes', options.Longitudes, 'Latitudes', options.Latitudes, 'Plev', options.Plev, 'convertTime', options.convertTime);
    end
end

end