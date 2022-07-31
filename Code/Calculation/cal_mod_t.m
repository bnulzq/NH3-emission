% calculate the lifetime (𝜏) of GEOS-Chem from the NH3 total column concentration and the total mass rate of change
clear all

path = 'E:\AEE\data\GEOS-Chem\';
yr_sta = 2008;
yr_end = 2018;

% GEOS-Chem lat and lon
lon = ncread([path, 'OutputDir2008\GEOSChem.DryDep.20080101_0000z.nc4'], 'lon');
lat = ncread([path, 'OutputDir2008\GEOSChem.DryDep.20080101_0000z.nc4'], 'lat');

for yr = yr_sta:1:yr_end

    year = num2str(yr);
    disp(['Year: ', year])

    for m = 1:12

        mon = num2str(m,'%02d');
        % import data
        grid_area = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'AREA')'; % m-2
        nh3 = ncread([path, 'concentration\GEOS-Chem_Total column_' year, mon, '.nc'], ['GEOS-Chem monthly mean NH3'])'; % mol m-2
        nh4 = ncread([path, 'concentration\GEOS-Chem_Total column_' year, mon, '.nc'], ['GEOS-Chem monthly mean NH4'])'; % mol m-2
%         M = (nh3*17+nh4*18)/1000.*grid_area; % kg
        M = (nh3*17)/1000.*grid_area; % kg
        %K = nh4./nh3; % unitless
        chem = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'BudgetChemistryFull_NH3')'; % kg s-1
        chem = (chem < 0) .* chem;
        trans_nh3 = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'BudgetTransportFull_NH3')'; % kg s-1
        trans_nh4 = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'BudgetTransportFull_NH4')'; % kg s-1
        nh3_wet = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'BudgetWetDepFull_NH3')'; % kg s-1, 
        nh3_dry = ncread([path, 'OutputDir', year, '\GEOSChem.DryDep.' year, mon, '01_0000z.nc4'], 'DryDep_NH4')'; % molec cm-2 s-1, positive value
        nh4_wet = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'BudgetWetDepFull_NH4')'; % kg s-1, 
        nh4_dry = ncread([path, 'OutputDir', year, '\GEOSChem.DryDep.' year, mon, '01_0000z.nc4'], 'DryDep_NH3')'; % molec cm-2 s-1, positive value
        nh3_dry = -nh3_dry/6.02214179E19*17/1000.*grid_area; % kg s-1
        nh4_dry = -nh4_dry/6.02214179E19*18/1000.*grid_area; % kg s-1
        
        trans = trans_nh3.*(trans_nh3<0); % <0
        
        L = nh3_wet + nh3_dry + nh4_wet + nh4_dry; % <0
        L(L == 0) = NaN;
        
        % 𝜏
        t = -M./(L)/3600; % hour        
        t_nh3 = -M./(nh3_wet + nh3_dry + chem)/3600; % NH3 lifetiem

        % write to nc file
        ncid = netcdf.create([path, 'Budget\GEOS-Chem_lifetime_', year, mon, '.nc'], 'CLOBBER');

        dimidy = netcdf.defDim(ncid, 'lon', 72);   
        dimidx = netcdf.defDim(ncid, 'lat', 46);

        var_lon = netcdf.defVar(ncid, 'lon', 'double', [dimidy]);
        var_lat = netcdf.defVar(ncid, 'lat', 'double', [dimidx]);
        var_M = netcdf.defVar(ncid, 'mass', 'double', [dimidx dimidy]);
        var_trans = netcdf.defVar(ncid, 'transport', 'double', [dimidx dimidy]);
        var_chem = netcdf.defVar(ncid, 'chemistry', 'double', [dimidx dimidy]);
        var_t_nh3 = netcdf.defVar(ncid, 'NH3 lifetime', 'double', [dimidx dimidy]);
        var_t = netcdf.defVar(ncid, 'NHx lifetime', 'double', [dimidx dimidy]);
        var_grid = netcdf.defVar(ncid, 'area', 'double', [dimidx dimidy]);
        var_L = netcdf.defVar(ncid, 'loss', 'double', [dimidx dimidy]);
        var_dry_nh3 = netcdf.defVar(ncid, 'NH3 dry deposition', 'double', [dimidx dimidy]);
        var_dry_nh4 = netcdf.defVar(ncid, 'NH4 dry deposition', 'double', [dimidx dimidy]);
        var_wet_nh3 = netcdf.defVar(ncid, 'NH3 wet deposition', 'double', [dimidx dimidy]);
        var_wet_nh4 = netcdf.defVar(ncid, 'NH4 wet deposition', 'double', [dimidx dimidy]);

        netcdf.putAtt(ncid, var_M, 'units', 'kg/s');                                                    
        netcdf.putAtt(ncid, var_trans, 'units', 'kg/s');                                                    
        netcdf.putAtt(ncid, var_chem, 'units', 'kg/s');                                                    
        netcdf.putAtt(ncid, var_t_nh3, 'units', 'hour');                                                    
        netcdf.putAtt(ncid, var_L, 'units', 'kg/s');  
        netcdf.putAtt(ncid, var_grid, 'units', 'm-2');   
        netcdf.putAtt(ncid, var_t, 'units', 'hour');   
        netcdf.putAtt(ncid, var_dry_nh3, 'units', 'kg/s');  
        netcdf.putAtt(ncid, var_dry_nh4, 'units', 'kg/s');  
        netcdf.putAtt(ncid, var_wet_nh3, 'units', 'kg/s');  
        netcdf.putAtt(ncid, var_wet_nh4, 'units', 'kg/s');  
        
        netcdf.putAtt(ncid, var_M, 'Long Name', 'Mass change rate'); 
        netcdf.putAtt(ncid, var_trans, 'Long Name', 'Transport change rate'); 
        netcdf.putAtt(ncid, var_chem, 'Long Name', 'Chemistry change rate'); 
        netcdf.putAtt(ncid, var_t_nh3, 'Long Name', 'lifetime of NH3'); 
        netcdf.putAtt(ncid, var_L, 'Long Name', 'Total loss rate');  
        netcdf.putAtt(ncid, var_t, 'Long Name', 'lifetime of NHx'); 
        netcdf.putAtt(ncid, var_grid, 'Long Name', 'Grid Area'); 
        netcdf.putAtt(ncid, var_dry_nh3, 'Long Name', 'Dry deposition of NH3'); 
        netcdf.putAtt(ncid, var_dry_nh4, 'Long Name', 'Dry deposition of NH4'); 
        netcdf.putAtt(ncid, var_wet_nh3, 'Long Name', 'Wet deposition of NH3'); 
        netcdf.putAtt(ncid, var_wet_nh4, 'Long Name', 'Wet deposition of NH4'); 

        netcdf.endDef(ncid);

        netcdf.putVar(ncid, var_lon, lon);
        netcdf.putVar(ncid, var_lat, lat);
        netcdf.putVar(ncid, var_M, M);
        netcdf.putVar(ncid, var_trans, trans);
        netcdf.putVar(ncid, var_chem, chem);
        netcdf.putVar(ncid, var_t_nh3, t_nh3);
        netcdf.putVar(ncid, var_L, L);
        netcdf.putVar(ncid, var_t, t);
        netcdf.putVar(ncid, var_grid, grid_area);
        netcdf.putVar(ncid, var_dry_nh3, nh3_dry);
        netcdf.putVar(ncid, var_dry_nh4, nh4_dry);
        netcdf.putVar(ncid, var_wet_nh3, nh3_wet);
        netcdf.putVar(ncid, var_wet_nh4, nh4_wet);
        
        netcdf.close(ncid);
    end
end


