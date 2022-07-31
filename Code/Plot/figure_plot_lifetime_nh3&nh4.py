'''draw monthly timeseries of NH3 lifetime (NH3 and NH4)''' 
import netCDF4 as nc
import numpy as np 
import mat73 as m73
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'bold', 'font.size':10}
rcParams.update(params)


yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
lat_sta = 5
lat_end = 40

# import data
path = 'E:\\AEE\\data\\'

# lon and lat
lon = nc.Dataset(path + 'GEOS-Chem\\concentration_month\GEOS-Chem_200801.nc')['lon'][:]
lat = nc.Dataset(path + 'GEOS-Chem\\concentration_month\GEOS-Chem_200801.nc')['lat'][:]

## land 
map = nc.Dataset('E:\\AEE\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
land = np.repeat(map_land, yr_len*12).reshape([46, 72, yr_len*12])

## ifetime
nhx = m73.loadmat(path + 'GEOS-Chem\\Budget\\GEOS-Chem_lifetime_2008-2018.mat')
nh3 = m73.loadmat(path + 'GEOS-Chem\\Budget\\GEOS-Chem_lifetime_NH3_2008-2018.mat')
nhx = nhx['t'] * land
nh3 = nh3['t'] * land
nhx = nhx[lat_sta:lat_end+1,:,:]
nh3 = nh3[lat_sta:lat_end+1,:,:]

nhx = np.nanmean(np.nanmean(nhx, 1), 0)
nh3 = np.nanmean(np.nanmean(nh3, 1), 0)

min  = 5
max = 40

# draw
fig = plt.figure(1, (6, 2), dpi = 300) 
ax1 = fig.add_subplot(111)
plt.grid(axis = 'x')
x = range(yr_len*12)
t_nh3 = ax1.plot(x, nh3, color = 'lime', label = 'Lifetime')
t_nhx = ax1.plot(x, nhx, color = 'blue', label = 'Lifetime')
ax1.set_ylabel('Lifetime (hours)')
ax1.set_ylim([min, max])
ax1.set_xlim([0, yr_len*12-1])
# ax1.set_title('Lifetime (hour)')

ax1.legend((t_nh3[0], t_nhx[0]), ('NH3', 'NHx'), frameon = False, edgecolor = 'black', fontsize  = 7, ncol = 3, loc = 'upper left')
plt.xticks(np.arange(0, yr_len*12, 12), ())
plt.rcParams['xtick.direction'] = 'in'

for i in range(int(yr_sta), int(yr_end)+1):
    
    fig.text((i-int(yr_sta))*0.071+0.14, 0.05, str(i), fontsize  = 7)

plt.savefig(fname = r'C:\Users\bnulzq\Desktop\test\lifetime.png', format = 'png', bbox_inches = 'tight')

plt.show()


