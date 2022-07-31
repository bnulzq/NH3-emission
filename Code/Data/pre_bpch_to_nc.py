'''convert the individual bpch file to nc'''

import netCDF4 as nc
import PseudoNetCDF as pnc
import numpy as np

path = 'D:\\data\\ND51\\'

# import data
name = 'pm.20100222'
gcf = pnc.pncopen(path+name+'.bpch', format='bpch')
data = gcf.variables['IJ-AVG-$_NH3']

lat = gcf.variables['latitude']
lon = gcf.variables['longitude']

data[data == 0] = np.nan
data = np.nanmean(data, 0)

# write nc file
f_w = nc.Dataset(path + 'GEOS-Chem.' + name + '.nc', 'w', format = 'NETCDF4') 

f_w.createDimension('lat', 46)   
f_w.createDimension('lon', 72) 

f_w.createVariable('lat', np.float32, ('lat'))  
f_w.createVariable('lon', np.float32, ('lon'))

f_w.variables['lon'][:] = lon  
f_w.variables['lat'][:] = lat  

f_w.createVariable(name, np.float32, ('lat','lon'))
f_w.variables[name][:] = data[0, :, :] 

f_w.close()