'''total column concentration of NH3'''

import netCDF4 as nc
import PseudoNetCDF as pnc
import numpy as np
import calendar

path1 = '/pdiskdata/zhangyuzhonggroup/luozhenqi/GEOS-Chem/'
path2 = 'Output/merra2_4x5_tropchem/OutputDir/ND51/'

yr_sta = 2008
yr_end = 2018
mon_sta = 1
mon_end = 12

# import data
times = ['am.', 'pm.']
for year in range(yr_sta, yr_end +1):

    print('Year: ', year)

    for mon in range(mon_sta, mon_end +1):

        month = str(mon).zfill(2)
        print('Month: ' + month)
        n_day = calendar.monthrange(year, mon)[1]
        data = np.zeros([2, n_day, 47, 46, 72], 'float32')
        ts = 0

        for time in times:

            for i in range(1, n_day+1):

                date = str(i).zfill(2)
                #print(str(mon) + ',' + date)
                gcf = pnc.pncopen(path1 + str(year) + path2 + time + str(year) + month + date + '.bpch', format='bpch')
                data_ci = gcf.variables['IJ-AVG-$_NH3']/(1E9) # ppb to molec/molec
                data_rhoi = gcf.variables['TIME-SER_AIRDEN'] # molec/cm3
                data_hi = gcf.variables['BXHGHT-$_BXHEIGHT']*100 # m to cm
                data[ts, i-1, :, :, :] = data_ci*data_rhoi*data_hi/(6.02214179E19) # molec/cm2 to mol/m2

            ts = ts +1

        lev = gcf.variables['layer47']
        lat = gcf.variables['latitude']
        lon = gcf.variables['longitude']

        # total column
        data = np.nanmean(data, 1)
        data = np.nansum(data, 1)

        # write nc file
        f_nc = nc.Dataset(path1 + 'concentration_month/' + 'GEOS-Chem_' + str(year) + month + '.nc', 'w', format = 'NETCDF4') 

        #f.createDimension('lev', 47) 
        f_nc.createDimension('lat', 46)   
        f_nc.createDimension('lon', 72) 

        #f.createVariable('lev', np.int, ('lev'))  
        f_nc.createVariable('lat', np.float32, ('lat'))  
        f_nc.createVariable('lon', np.float32, ('lon'))

        #f.variables['lev'][:] = lev  
        f_nc.variables['lon'][:] = lon  
        f_nc.variables['lat'][:] = lat  

        nh3_am_name = 'GEOS-Chem daytime simulation_' + str(year) + month
        nh3_pm_name = 'GEOS-Chem nighttime simulation_' + str(year) + month

        nh3_am = f_nc.createVariable(nh3_am_name, np.float32, ('lat','lon'))
        nh3_pm = f_nc.createVariable(nh3_pm_name, np.float32, ('lat','lon'))

        f_nc.variables[nh3_am_name][:] = data[0, :, :] 
        f_nc.variables[nh3_pm_name][:] = data[1, :, :] 

        nh3_am.units = 'mol m-2' 
        nh3_pm.units = 'mol m-2' 

        f_nc.close()