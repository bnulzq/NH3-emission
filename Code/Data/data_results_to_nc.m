% output data of results to nc 
clear

path = 'E:\AEE\data\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
lat_sta = 6;
lat_end = 41;

% import data
lon = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lon');
lat = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lat');
lat = lat(lat_sta:lat_end);

tde = load([path, 'IASI\Emission\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=800_r=1_w=0.05_2008-2018.mat']).E; %kg/m2/s
tde = tde(lat_sta:lat_end, :, :);

bue = load([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.Total_2008-2018.mat']).data; %kg/m2/s
bue = bue(lat_sta:lat_end, :, :);

nh3_o = load([path, 'IASI_monthly_2008-2018.mat']).iasi; % mol/m2
nh3_o = nh3_o(lat_sta:lat_end, :, :);

nh3_m = load([path, 'GEOS-Chem_monthly_2008-2018.mat']).geo; % mol/m2
nh3_m = nh3_m(lat_sta:lat_end, :, :);

t = load([path, 'GEOS-Chem\Budget\GEOS-Chem_lifetime_2008-2018.mat']).t; %hour
t = t(lat_sta:lat_end, :, :);

for y = yr
    year = num2str(y);
    for m = 1:12
        
        mon = num2str(m, '%02d');

        tde_mon = tde(:,:, (y-yr_sta)*12+m);
        bue_mon = bue(:,:, (y-yr_sta)*12+m);
        nh3_o_mon = nh3_o(:,:, (y-yr_sta)*12+m);
        nh3_m_mon = nh3_m(:,:, (y-yr_sta)*12+m);
        t_mon = t(:,:, (y-yr_sta)*12+m);
        
        % output
        ncid = netcdf.create([path, 'Results\NH3_emission\NH3_Emission_', year, mon, '.nc'], 'CLOBBER');
        
        % global attribute
        varid = netcdf.getConstant('GLOBAL');
        netcdf.putAtt(ncid, varid, 'description', 'Global monthly averaged ammonia (NH3) emissions over land based on IASI observations');
        netcdf.putAtt(ncid, varid, 'citation', 'Contact zl725@cornell.edu');
        
        % dimension
        dimidy = netcdf.defDim(ncid, 'lon', 72);   
        dimidx = netcdf.defDim(ncid, 'lat', 36);
        
        % variables
        var_lon = netcdf.defVar(ncid, 'lon', 'double', dimidy);
        var_lat = netcdf.defVar(ncid, 'lat', 'double', dimidx);
        var_tde = netcdf.defVar(ncid, 'TDE', 'double', [dimidx dimidy]);
        var_bue = netcdf.defVar(ncid, 'BUE', 'double', [dimidx dimidy]);
        var_nh3_o = netcdf.defVar(ncid, 'NH3_obs', 'double', [dimidx dimidy]);
        var_nh3_m = netcdf.defVar(ncid, 'NH3_mod', 'double', [dimidx dimidy]);
        var_t = netcdf.defVar(ncid, 'NH3_lifetime', 'double', [dimidx dimidy]);
        
        netcdf.putAtt(ncid, var_lat, 'units', 'degrees_north');                                                    
        netcdf.putAtt(ncid, var_lon, 'units', 'degrees_east'); 
        netcdf.putAtt(ncid, var_tde, 'units', 'kg/m^2/s'); 
        netcdf.putAtt(ncid, var_bue, 'units', 'kg/m^2/s'); 
        netcdf.putAtt(ncid, var_nh3_o, 'units', 'mol/m^2'); 
        netcdf.putAtt(ncid, var_nh3_m, 'units', 'mol/m^2'); 
        netcdf.putAtt(ncid, var_t, 'units', 'hour'); 

        netcdf.putAtt(ncid, var_lat, 'longname', 'latitude');                                                    
        netcdf.putAtt(ncid, var_lon, 'longname', 'longitude'); 
        netcdf.putAtt(ncid, var_tde, 'longname', 'NH3 top-down emission (TDE) estimate'); 
        netcdf.putAtt(ncid, var_bue, 'longname', 'NH3 bottom-up emission (BUE) inventory'); 
        netcdf.putAtt(ncid, var_nh3_o, 'longname', 'observed NH3 column density'); 
        netcdf.putAtt(ncid, var_nh3_m, 'longname', 'simulated NH3 column density'); 
        netcdf.putAtt(ncid, var_t, 'longname', 'NH3 lifetime'); 
        
        netcdf.endDef(ncid);
        
%         ncwriteatt([path, 'Results\NH3_Emission_', year, mon, '.nc'], '/', 'geospatial_lat_units','degrees_north');

%         
        netcdf.putVar(ncid, var_lon, lon);
        netcdf.putVar(ncid, var_lat, lat);
        netcdf.putVar(ncid, var_tde, tde_mon);
        netcdf.putVar(ncid, var_bue, bue_mon);
        netcdf.putVar(ncid, var_nh3_o, nh3_o_mon);
        netcdf.putVar(ncid, var_nh3_m, nh3_m_mon);
        netcdf.putVar(ncid, var_t, t_mon);

        

        netcdf.close(ncid);       
    
    end
end


