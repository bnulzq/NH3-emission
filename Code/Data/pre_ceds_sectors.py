'''extract the NH3 emissions sectors from CEDS to nc'''

import netCDF4 as nc
import numpy as np
import matplotlib.pyplot as plt

time_sta = 456
time_end = 576
# path = '/pdiskdata/zhangyuzhonggroup/luozhenqi/nh3/CEDS/CEDS_2000-2014/'
# name = 'NH3-em-anthro_input4MIPs_emissions_CMIP_CEDS-2017-05-18_gn_200001-201412.nc'

path = '/pdiskdata/zhangyuzhonggroup/luozhenqi/nh3/CEDS/CEDS_GBD-MAPS_CO_NOx_SO2_NH3_gridded_total_anthro_emissions_by_sector_input4CMIP_1970-2017/'
name = 'NH3-em-total-anthro_input4CMIP_emissions_CEDS-2020-v1_gn_197001-201712.nc'

data = nc.Dataset(path + name)['NH3_em_anthro'][time_sta:time_end, :, :, :]
data_time = nc.Dataset(path+ name)['time'][time_sta:time_end]
data_lat = nc.Dataset(path+ name)['lat'][:]
data_lon = nc.Dataset(path+ name)['lon'][:]

# sector = ['Agriculture', 'Energy', 'Industrial', 'Transportation', 'Residential, Commercial, Other', 
#     'Solvents production and application', 'Waste', 'International Shipping']

sector = ['Agriculture', 'Energy', 'Industrial', 'Non-Road_Other Transportation', 'Road', 'Residential', 'Commercial', 'Other', 'Solvents production and application', 'Waste', 'International Shipping']

for i in range(len(sector)):

    data_name = sector[i]
    print(data_name + ' is dealing!')
    datai = data[:,i,:,:]

    # write nc file
    f_w = nc.Dataset(path + 'CEDS_' + data_name + '_2008-2017.nc', 
        'w', format = 'NETCDF4') 

    f_w.createDimension('lat', data_lat.size)   
    f_w.createDimension('lon', data_lon.size) 
    f_w.createDimension('time', data_time.size) 

    f_w.createVariable('lat', np.float32, ('lat'))  
    f_w.createVariable('lon', np.float32, ('lon'))
    f_w.createVariable('time', np.float32, ('time'))

    f_w.variables['lon'][:] = data_lon 
    f_w.variables['lat'][:] = data_lat  
    f_w.variables['time'][:] = data_time  

    v = f_w.createVariable(data_name, np.float32, ('time', 'lat', 'lon'))
    f_w.variables[data_name][:] = datai

    v.units = 'kg m-2 s-1'

    f_w.close()