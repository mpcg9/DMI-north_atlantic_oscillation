function data=readNetCDF2(filename)
% Reads netCDF Version 3 and 4 files in Matlab
%
% INPUT: filename ... filename including path
%
% OUTPUT: data ... struct with netCDF data
%
% Note: All scale factors, add_offsets etc. will be applied so the
% resulting data should have the units decribed in the "units" cell array
% which is included inside the data struct.
%
% Uebbing 06/2016

ncid = netcdf.open(filename, 'NC_NOWRITE'); % oeffnen der Datei

[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

for j=0:nvars-1
    [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,j);
    data.(varname) = double(netcdf.getVar(ncid, j)); % einlesen der daten
    
    scaleFac = 1;
    addOff=0;
    fillVal=NaN;
    for k=0:natts-1
        attname = netcdf.inqAttName(ncid,j,k);
        switch attname
            
            case 'scale_factor'
                scaleFac = netcdf.getAtt(ncid,j,'scale_factor');  % Scaling factor
            case 'add_offset'
                addOff = netcdf.getAtt(ncid,j,'add_offset'); % Additionskonstante
            case '_FillValue'
                fillVal = netcdf.getAtt(ncid,j,'_FillValue'); % Fillvalue (NaN)
            case 'units'
                units{j+1} = netcdf.getAtt(ncid,j,'units'); % Einheit
            otherwise
                %nix
                
        end
        
    end
    
    % Transformieren der Daten in richtige Einheit
    if (isnan(fillVal)==0)
        data.(varname)(data.(varname)==fillVal)=NaN;
    end
    data.(varname) = data.(varname)*double(scaleFac) + double(addOff);
    
%     data.(varname)=adat;
    
end

data.units = units;
netcdf.close(ncid);
