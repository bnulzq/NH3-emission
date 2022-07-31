'''extract the national N agriculture use to nc'''
import netCDF4 as nc
import numpy as np
import pandas as pd

path = 'D:\\data\\FAO\\N fertilizer use\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1

# import data 
data = pd.read_csv(path + 'FAOSTAT_data_4-16-2021.csv')
data = data[data.Element == 'Agricultural Use']
data['Area Code'].replace('206', 'SDN', inplace = True) # Sudan (former)
# data[data['Area Code'] == '206']

coun = set(data['Area Code'])
coun.remove('41') # china mainland

coun_loc = nc.Dataset('D:\\data\\map\\iso3c\\countrymask_0.1x0.1.nc')['CountryID'][:][0] # country mask
coun_id = pd.read_csv('D:\\data\\map\\iso3c\\countrylist.csv', engine = 'python') # country id

lat = nc.Dataset('D:\\data\\GEOS-Chem\\concentration\\GEOS-Chem_Total column_200801.nc').variables['lat'][:]
lon = nc.Dataset('D:\\data\\GEOS-Chem\\concentration\\GEOS-Chem_Total column_200801.nc').variables['lon'][:]

# grid the multi-year by country 
data_grid = np.zeros([1800, 3600, yr_len], 'double')
for c in coun:

    try:
        c_agr = data[data['Area Code'] == c].Value
        c_id = coun_id[coun_id.iso3c == c].iso3n.values
    except:
        print(c)

    area = len(coun_loc[coun_loc == c_id])
    # no area
    if area == 0:
        print(c + ': ' + str(c_id) + ', N input =' + str(c_agr.sum()))
    
    if len(c_agr) != yr_len:
        
        print(c + ', Year: ' + str(data[data['Area Code'] == c].Year.iloc[0]) + '-' + str(data[data['Area Code'] == c].Year.iloc[-1]))
        data_grid[coun_loc == c_id, yr_len-len(c_agr):] = c_agr/area

    else:
        data_grid[coun_loc == c_id, :] = c_agr/area

print(data_grid.sum())

# regrid
data_4_5 = np.zeros([46, 72, yr_len])

scale = 10
## 88-90
for j in range(72):
    
    data_4_5[0, j, :] = np.nansum(np.nansum(data_grid[0:2*scale, j*5*scale:(j+1)*5*scale, :], 1), 0)
    data_4_5[45, j, :] = np.nansum(np.nansum(data_grid[178*scale:180*scale, j*5*scale:(j+1)*5*scale, :], 1), 0)

for i in range(1, 45):
    for j in range(72):
        data_4_5[i, j, :] = np.nansum(np.nansum(data_grid[i*4*scale-2*scale:(i+1)*4*scale-2*scale, j*5*scale:(j+1)*5*scale, :], 1), 0)

print(data_4_5.sum())
data_4_5[data_4_5 == 0] = np.NaN
# data_4_5 = data_4_5.reshape([yr_len, 72, 46])

# save sectors to nc
name = 'N_Agricultural_Use'
f_w = nc.Dataset(path + name + '_' + str(yr_sta) + '-' + str(yr_end)+ '.nc', 'w', format = 'NETCDF4') 

f_w.createDimension('lat', 46)   
f_w.createDimension('lon', 72) 
f_w.createDimension('year', yr_len) 

f_w.createVariable('lat', np.float32, ('lat'))  
f_w.createVariable('lon', np.float32, ('lon'))
f_w.createVariable('year', np.float32, ('year'))

f_w.variables['lon'][:] = lon  
f_w.variables['lat'][:] = lat      
f_w.variables['year'][:] = np.arange(yr_sta, yr_end +1)

sector = f_w.createVariable(name, np.float32, ('lat','lon', 'year'))
f_w.variables[name][:] = data_4_5

sector.units = 't'
f_w.close()