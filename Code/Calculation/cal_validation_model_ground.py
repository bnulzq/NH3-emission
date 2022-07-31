'''
validation against ground-based observations and model simulations
'''

import pandas as pd
import netCDF4 as nc
import scipy.io as scio
import numpy as np

# get statitical information
def Statis(x, y):

    # fits = np.polyfit(x, y, 1)
    num = len(x)
    r = np.corrcoef(x, y)[0, 1]
    r2 = r**2
    rmse = np.sqrt(np.mean((x - y) ** 2))
    mfb = 2 * np.sum(y-x) /np.sum(x+y) 
    xy10 = sum(x/y > 10)/len(x)*100
    yx10 = sum(y/x > 10)/len(x)*100

    print(f'N: {num}')
    print(f'R2: {r2:.2f}')
    print(f'RMSE: {rmse:.2f}')
    print(f'MFB: {mfb:.2f}')

    return 


path = 'E:\\AEE\\data\\'
yrs = [2008, 2013, 2018]
mul = 1E+9 # mol/mol to ppb
thre_r = 1
thre_n = 800

# import data
# r = scio.loadmat(path + '\\GEOS-Chem\\transport_to_emission_2008-2018.mat')['r']
amon = pd.read_csv(f'{path}Ground\\AMoN_monthly.csv')
eanet = pd.read_csv(f'{path}Ground\\EANET_monthly.csv')
emep = pd.read_csv(f'{path}Ground\\EMEP_monthly.csv')
gro = pd.concat([amon, eanet, emep], sort=False)



# grid number
gro['lat_n'] = round((gro.latitude + 90)/4)
gro['lon_n'] = round((gro.longitude + 180)/5)

val = pd.DataFrame()
val_mons = pd.DataFrame()
# extract validation in month in a grid
for yr in yrs:

    print(yr)

    gro_yr = gro[gro.time > f'{yr}']
    gro_yr = gro_yr[gro_yr.time < f'{yr+1}']
    val_yr = pd.DataFrame()
    for m in range(1, 13):

        mon = str(m).zfill(2)
        geo = nc.Dataset(f'{path}GEOS-Chem\\OutputDir{yr}\\GEOSChem.SpeciesConc.{yr}{mon}01_0000z.nc4')['SpeciesConc_NH3'][0,0,:,:]*mul
        geo_nhx = nc.Dataset(f'{path}GEOS-Chem\\validation2\\GEOSChem.SpeciesConc.{yr}{mon}01_0000z.nc4')['SpeciesConc_NH3'][0,0,:,:]*mul

        gro_mon = gro_yr[gro_yr.time == f'{yr}-{mon}']
        gro_mon = gro_mon.groupby(['lat_n', 'lon_n']).NH3.mean()
        gro_mon = gro_mon.reset_index()

        geo_site = geo[gro_mon.lat_n.astype(int),:][:,gro_mon.lon_n.astype(int)]
        gro_mon['NH3_pri'] = np.diagonal(geo_site)

        geo_site = geo_nhx[gro_mon.lat_n.astype(int),:][:,gro_mon.lon_n.astype(int)]
        gro_mon['NH3_pos'] = np.diagonal(geo_site)

        gro_mon['year'] = yr
        gro_mon['month'] = int(m)

        val_yr = pd.concat([val_yr, gro_mon])

    val_mons = pd.concat([val_mons, val_yr])
    # annual statistical
    print('Prior:')
    Statis(val_yr.NH3, val_yr.NH3_pri)
    print('Posterior:')
    Statis(val_yr.NH3, val_yr.NH3_pos)

    val_yr = val_yr.groupby(['lat_n', 'lon_n']).mean()
    val_yr = val_yr.reset_index()

    val = pd.concat([val, val_yr])

val['lon'] = val.lon_n*5 - 180
val['lat'] = val.lat_n*4 - 90

val.to_csv(f'{path}GEOS-Chem\\validation2\\Annual_surface.csv', index = False)
val_mons.to_csv(f'{path}GEOS-Chem\\validation2\\Monthly_surface.csv', index = False)