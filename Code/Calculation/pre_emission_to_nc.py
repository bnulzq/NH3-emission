'''extract the NH3 emissions from HEMCO to nc'''

import netCDF4 as nc
import numpy as np

def ExtractData(data, var_name):

    var = data.variables[var_name][:].squeeze()
    
    # missing value (-999) and 0
    var[var == -999] = np.nan
    var[var == 0] = np.nan

    # sum
    if  len(var.shape) == 3:
        var = np.nansum(var, 0)

    return var

path_in = '/pdiskdata/zhangyuzhonggroup/luozhenqi/GEOS-Chem/'
path_ou = '/pdiskdata/zhangyuzhonggroup/luozhenqi/GEOS-Chem/Emissions/'
var_names = ['Anthro', 'BioBurn', 'Ship', 'Seabirds', 'Total', 'Natural']



for year in range(2008, 2019):
    print('Year: ' + str(year))
    for mon in range(1, 13):
        print('Month:' + str(mon))

        # import data
        data = nc.Dataset(path_in + str(year) + 'Output' + '/merra2_4x5_tropchem/OutputDir/HEMCO_diagnostics.' + str(year) + str(mon).zfill(2) + '010000.nc')

        lat = data.variables['lat'][:]
        lon = data.variables['lon'][:]
        # write to nc file
        f_w = nc.Dataset(path_ou + 'HEMCO_diagnostics_NH3.' + str(year) + str(mon).zfill(2) + '.nc', 'w', format = 'NETCDF4') 

        f_w.createDimension('lat', lat.size)   
        f_w.createDimension('lon', lon.size)

        f_w.createVariable('lat', np.float32, ('lat'))  
        f_w.createVariable('lon', np.float32, ('lon'))

        f_w.variables['lon'][:] = lon  
        f_w.variables['lat'][:] = lat  

        # variables
        for var in var_names:

            v = f_w.createVariable(var, np.float32, ('lat','lon'))
            f_w.variables[var][:] = ExtractData(data, 'EmisNH3_' + var)
            v.units = 'kg/m2/s'

        f_w.close()

