'''draw monthly timeseries of NH3 lifetime (M/E and M/L) and emissions''' 
import pandas as pd
import numpy as np
import netCDF4 as nc
import scipy.io as scio
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'bold', 'font.size':10}
rcParams.update(params)

# create 3 dimension NaN array
def Nan2Array(x, y, z):

    data = np.zeros([x, y, z])
    data[:] = np.nan

    return data

# mean timeseries
def Timeseries(data, lat_sta, lat_end):

    data = data[lat_sta:lat_end+1, :, :]
    data[data == 0] = np.nan
    data = np.nanmean(np.nanmean(data, 0), 0)
    
    return data

yr_sta = '2008'
yr_end = '2018'
yr_len = yr_end - yr_sta +1
lat_sta = 5
lat_end = 40
thre_n = '30'
thre_r = '1'

# import data
path = 'D:\\data\\'
# lon and lat
lon = nc.Dataset(path + 'GEOS-Chem\\concentration_month\GEOS-Chem_200801.nc')['lon'][:]
lat = nc.Dataset(path + 'GEOS-Chem\\concentration_month\GEOS-Chem_200801.nc')['lat'][:]

## land 
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
land = np.repeat(map_land, yr_len*12).reshape([46, 72, yr_len*12])

## GEOS-Chem
geo = scio.loadmat(path + 'GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Total_' + yr_sta + '-' + yr_end + '.mat')
geo = geo['data']
geo = geo * land

## IASI
iasi = scio.loadmat(path + 'IASI\\optimized_emi_n=' + thre_n + '_r=' + thre_r + '_'+ yr_sta + '-' + yr_end + '.mat')
iasi = iasi['E']
iasi = iasi * land

## lifetime
t = scio.loadmat(path + 'GEOS-Chem\\Budget\\GEOS-Chem_lifetime_' +  str(yr_sta) + '-' + str(yr_end) + '.mat')
t = t['t']
t = t * land

# timeseries
emi_i = Timeseries(iasi, lat_sta, lat_end)
emi_g = Timeseries(geo, lat_sta, lat_end)
time = Timeseries(t, lat_sta, lat_end)

mul = 1E+11
max1 = 40
min1 = 10
min2 = 0
max2 = 5
# draw
fig = plt.figure(1, (6, 2), dpi = 300) 
ax1 = fig.add_subplot(111)
plt.grid(axis = 'x')
plt.rcParams['xtick.direction'] = 'in'
x = range(yr_len*12)
l = ax1.plot(x, time, color = 'lime', label = 'Lifetime')
# ax1.plot(x, t2, color = 'gold', label = 'Lifetime (M/E)')
ax1.set_ylabel('Lifetime (hours)')
# ax1.set_title('Lifetime and Emissions (' + str(int(abs(lat[lat_sta]))) + 'S-' + str(int(lat[lat_end])) + 'N) n>' + str(thre))
ax1.set_title(str(int(abs(lat[lat_sta]))) + '$^\circ$N-' + str(int(lat[lat_end])) + '$^\circ$S')
ax1.set_ylim([min1, max1])
ax2 = ax1.twinx()

plt.xticks(np.arange(0, yr_len*12, 12), ())
ax2.set_xlim([0, yr_len*12-1])
ax2.set_ylim([min2, max2])
#ax2.plot(x, emi1*mul, color = 'red', label = r'IASI emissions (M/$\top$)')
e_geo = ax2.plot(x, emi_g*mul, color = 'blue', label = 'Emissions (GEOS-Chem)')
e_opt = ax2.plot(x, emi_i*mul, color = 'k', label = 'Emissions (Optimized)')
ax2.set_ylabel('Emissions (10$^{-11}$ kg m$^{-2}$ s$^{-1}$)')
ax1.legend((l[0], e_geo[0], e_opt[0]), ('Lifetime', 'Emissions (GEOS-Chem)', 'Emissions (Optimized)'), frameon = False, edgecolor = 'black', fontsize  = 7, ncol = 3, loc = 'upper left')

for i in range(int(yr_sta), int(yr_end)+1):
    
    fig.text((i-int(yr_sta))*0.075+0.084, 0.05, str(i))

plt.subplots_adjust(left = 0.08, right = 0.89)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\Pap\\lifetime_and_emissions.png', format = 'png', bbox_inches = 'tight')
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\Pap\\lifetime_and_emissions.svg', format = 'svg', bbox_inches = 'tight')

plt.show()

# import matplotlib.pyplot as plt
# plt.imshow(np.nanmean(m_iasi, 2), cmap='Oranges')
# plt.show()


















