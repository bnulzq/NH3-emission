'''extract the national NH3 emissions from CEDS to nc'''

import netCDF4 as nc
import numpy as np
import pandas as pd

path = 'D:\\data\\CEDS\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
mul = 1E+6

# sectors
ene_name = ['1A1', '1B1', '1B2']
ind_name = ['1A2', '1A5', '2A6', '2B_']
tra_name = ['1A3']
rc_name = ['1A4']
man_name = ['3B_']
soi_name = ['3D_']
was_name = ['5C_', '5E_', '5D_']
secs_name = ['Energy', 'Industry', 'Traffic', 'Residential and Commercial', 'Manure management​', 'Soil emissions​', 'Waste']
secs = [ene_name, ind_name, tra_name, rc_name, man_name, soi_name, was_name]

# import data
ceds_coun_sec = pd.read_csv(path + 'NH3_CEDS_emissions_2008-2018.csv') # national inventory
coun = set(ceds_coun_sec.country)
# coun.remove('fji')
# coun.remove('kir')

sector = pd.read_csv(path + 'CEDS_sector_to_gridding_sector_mapping.csv') # sub sector
sub_sec = set(sector.CEDS_working_sector.apply(lambda r: r[0:3]))

coun_loc = nc.Dataset(path + 'countrymask_0.1x0.1.nc')['CountryID'][:][0] # country mask
coun_id = pd.read_csv(path + 'countrylist.csv', engine = 'python') # country id

data = pd.DataFrame(columns = sub_sec, index = list(coun))
data.loc[:] = 0

lat = nc.Dataset('D:\\data\\GEOS-Chem\\concentration\\GEOS-Chem_Total column_200801.nc').variables['lat'][:]
lon = nc.Dataset('D:\\data\\GEOS-Chem\\concentration\\GEOS-Chem_Total column_200801.nc').variables['lon'][:]

# group the multi-year by country and sector
for c in coun:

    # print(c)
    c_secs = ceds_coun_sec[ceds_coun_sec.country == c]
    coun_sec = c_secs.sector

    for s in coun_sec:
            
        c_secs_yr = c_secs[c_secs.sector == s]
        emi = c_secs_yr.iloc[:, 4:15].values[0]
        s1 =  s[0:3]
        if s1 == '2Ax':
            s1 = '2A6'
        if s1 == '2B2' or s1 == '2B3':
            s1 = '2B_'
        try:
            
            if data.loc[c, s1] == 0:
                data.loc[c, s1] = [0]*yr_len
            c_s = np.array(data.loc[c, s1])
            data.loc[c, s1] = (c_s + emi).tolist()

        except:
            continue

# data.loc['Total'] = data.apply(lambda x: x.sum())

# emission grid
seci = 0
scale = 10
for sec in secs:

    name = secs_name[seci]
    print(name + ':')
    seci = seci+1
    data_grid = np.zeros([180*scale, 360*scale, yr_len], 'double') # 0.25 degree

    for c in coun:

        # print(c)
        try:
            c_id = coun_id[coun_id.iso3c == c.upper()].iso3n.values
        except:
            print(c)

        # sector emission
        emi = np.zeros([1, yr_len])[0]
        for s in sec:
          emi = emi + data.loc[c, s]

        area = len(coun_loc[coun_loc == c_id])
        # no area
        if area == 0:
            print(c + ': ' + str(c_id) + ', emi=' + str(emi.sum()))

        data_grid[coun_loc == c_id,:] = emi/area

    print(data_grid.sum())
    # regrid
    data_4_5 = np.zeros([46, 72, yr_len])

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
    
    f_w = nc.Dataset(path + 'grid\\CEDS_' + name + '_' + str(yr_sta) + '-' + str(yr_end)+ '.nc', 'w', format = 'NETCDF4') 

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
    f_w.variables[name][:] = data_4_5*mul

    sector.units = 'Kg'
    f_w.close()
