'''draw monthly timeseries of NH3 lifetime (M/E and M/L) and emissions (IASI and GEOS-Chem)''' 
import numpy as np
import netCDF4 as nc
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'bold', 'font.size':15}
rcParams.update(params)

# create 3 dimension NaN array
def Nan2Array(x, y, z):

    data = np.zeros([x, y, z])
    data[:] = np.nan

    return data

# mean timeseries
def Timeseries(data, lat_sta, lat_end, lon_sta, lon_end):

    data = data[lat_sta:lat_end+1, lon_sta:lon_end+1, :]
    data[data == 0] = np.nan
    data = np.nanmean(np.nanmean(data, 0), 0)
    
    return data

yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
lat_sta = 36
lat_end = 39
lon_sta = 39
lon_end = 50

# import data
path = 'D:\\data\\'
# lon and lat
lon = nc.Dataset(path + 'GEOS-Chem\\concentration_month\GEOS-Chem_200801.nc')['lon'][:]
lat = nc.Dataset(path + 'GEOS-Chem\\concentration_month\GEOS-Chem_200801.nc')['lat'][:]

## land 
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
land = map_land.reshape([46, 72])

t1 = Nan2Array(46, 72, yr_len*12) # M/L
C_iasi = Nan2Array(46, 72, yr_len*12)
C_geo = Nan2Array(46, 72, yr_len*12)
E_geo = Nan2Array(46, 72, yr_len*12)

for y in range(yr_sta, yr_end +1):

    yr = str(y)

    for m in range(1, 13):

        mon = str(m).zfill(2)        
        t1[:, :, (y-yr_sta)*12 + m-1] = nc.Dataset(path + 'GEOS-Chem\\Budget\\GEOS-Chem_lifetime_' + yr + mon + '.nc')['lifetime'][:].T*map_land
        C_iasi[:, :, (y-yr_sta)*12 + m-1] = nc.Dataset(path + 'IASI\\filter\\IASI_filter_AM_Cloud_10_' + yr + mon + '.nc')['averaging nh3 filter'][:].T*map_land
        E_geo[:, :, (y-yr_sta)*12 + m-1] = nc.Dataset(path + 'GEOS-Chem\\Emissions\\HEMCO_diagnostics_NH3.' + yr + mon + '.nc')['Total'][:]*map_land
        C_geo[:, :, (y-yr_sta)*12 + m-1] = nc.Dataset(path + 'GEOS-Chem\\concentration_month\GEOS-Chem_' + yr + mon + '.nc')['GEOS-Chem daytime simulation_' + yr + mon][:]*map_land

m_geo = C_geo * 17/1000/3600
m_iasi = C_iasi * 17/1000/3600
E_geo[E_geo == 0] = np.nan
m_geo[m_geo == 0] = np.nan
t2 = m_geo/E_geo # M/E

t1[t1 > 100] = np.nan
t2[t2 > 100] = np.nan
t1[t1 < 0] = np.nan
t2[t2 < 0] = np.nan
emi1 = m_iasi/t1
emi2 = m_iasi/t2

emi2 = Timeseries(emi2, lat_sta, lat_end, lon_sta, lon_end)
emi1 = Timeseries(emi1, lat_sta, lat_end, lon_sta, lon_end)
emi3 = Timeseries(E_geo, lat_sta, lat_end, lon_sta, lon_end)
t1 = Timeseries(t1, lat_sta, lat_end, lon_sta, lon_end)
t2 = Timeseries(t2, lat_sta, lat_end, lon_sta, lon_end)

mul = 1E+11
max1 = 43
min1 = 0
min2 = 0
max2 = 42
# draw
fig = plt.figure(1, (9, 3), dpi = 250) 
ax1 = fig.add_subplot(111)
plt.grid(axis = 'x')
plt.rcParams['xtick.direction'] = 'in'
x = range(yr_len*12)
ax1.plot(x, t1, color = 'lime', label = 'Lifetime (M/L)')
ax1.plot(x, t2, color = 'gold', label = 'Lifetime (M/E)')
ax1.set_ylabel('Lifetime (hours)')
ax1.set_title('Lifetime and Emissions (' + str(int(abs(lat[lat_sta]))) + 'N-' + str(int(lat[lat_end])) + 'N;' + str(int(lon[lon_sta])) + 'E-' + str(int(lon[lon_end])) + 'E)')
ax1.set_ylim([min1, max1])

ax2 = ax1.twinx()

plt.xticks(np.arange(0, yr_len*12, 12), ())
ax2.set_xlim([0, yr_len*12-1])
ax2.set_ylim([min2, max2])
ax2.plot(x, emi1*mul, color = 'red', label = 'IASI emissions (livetime = M/L)')
ax2.plot(x, emi2*mul, color = 'blue', label = 'IASI emissions (livetime = M/E)')
ax2.plot(x, emi3*mul, color = 'k', label = 'GEOS-Chem emissions')
ax2.set_ylabel('Emissions (10$^{-11}$ kg m$^{-2}$ s$^{-1}$)')
ax2.legend(loc = 'upper left', frameon = False, edgecolor = 'black', fontsize  = 6, ncol = 3)
ax1.legend(loc = 'best', frameon = False, edgecolor = 'black', fontsize  = 6, ncol = 2)

for i in range(yr_sta, yr_end+1):
    
    fig.text((i-yr_sta)*0.077+0.085, 0.05, str(i))

plt.subplots_adjust(left = 0.08, right = 0.92)
plt.savefig(fname = path + 'lifetime and emissions.png', format = 'png', bbox_inches = 'tight')

plt.show()

# import matplotlib.pyplot as plt
# plt.imshow(np.flipud(land[33:39, 39:54]), cmap='Oranges')
# plt.show()
