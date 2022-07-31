'''draw monthly timeseries of NH3 agriculture emissions (GEOS-Chem and CEDS 2 versions) and their proportions''' 
import netCDF4 as nc
import numpy as np
import scipy.io as scio
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'bold', 'font.size':10}
rcParams.update(params)

# geos-chem mean timeseries
def GEOStimeseris(data, lat_sta, lat_end):

    data[data == 0] = np.nan
    data = np.nanmean(np.nanmean(data[lat_sta:lat_end+1, :, :], 1), 0)

    return data

# ceds mean timeseries
def CEDStimeseris(data, lat_sta, lat_end):

    data[data == 0] = np.nan
    data = np.nanmean(np.nanmean(data[:, lat_sta:lat_end+1, :], 1), 0)

    return data

lat_sta = 5
lat_end = 40
mul = 1E12
# import data 
path = 'D:\\data\\'
## lon and lat
lon = nc.Dataset(path + 'GEOS-Chem\\concentration_month\GEOS-Chem_200801.nc')['lon'][:]
lat = nc.Dataset(path + 'GEOS-Chem\\concentration_month\GEOS-Chem_200801.nc')['lat'][:]

## geos-chem 2008-2018
geo = scio.loadmat(path + 'GEOS-Chem\\Emissions\\Agriculture_ratio_2008-2018.mat')['r']
geo_r = GEOStimeseris(geo, lat_sta, lat_end)

geo = scio.loadmat(path + 'GEOS-Chem\\Emissions\\Agriculture_2008-2018.mat')['agri']
geo = GEOStimeseris(geo, lat_sta, lat_end)*mul

## CEDS 2008-2014
c1 = scio.loadmat(path + 'CEDS\\CEDS_grid_2008-2014\\CEDS_Agriculture_ratio_2008-2014.mat')['r']
c1_r = CEDStimeseris(c1, lat_sta, lat_end)

c1 = scio.loadmat(path + 'CEDS\\CEDS_grid_2008-2014\\CEDS_Agriculture_2008-2014.mat')['agri']
c1 = CEDStimeseris(c1, lat_sta, lat_end)*mul

## CEDS 2008-2017
c2 = scio.loadmat(path + 'CEDS\\CEDS_grid_2008-2017\\CEDS_Agriculture_ratio_2008-2017.mat')['r']
c2_r = CEDStimeseris(c2, lat_sta, lat_end)

c2 = scio.loadmat(path + 'CEDS\\CEDS_grid_2008-2017\\CEDS_Agriculture_2008-2017.mat')['agri']
c2 = CEDStimeseris(c2, lat_sta, lat_end)*mul

max1 = 15
min1 = 3
max2 = 1
min2 = 0.4
# draw
fig = plt.figure(1, (6, 2), dpi = 300) 
ax1 = fig.add_subplot(111)
ax1.plot(np.arange(len(geo)), geo, linewidth = 1, color = 'k')
ax1.plot(np.arange(len(c1)), c1, linewidth = 1, color = 'b')
ax1.plot(np.arange(len(c2)), c2, linewidth = 1, color = 'c')
ax1.set_ylabel('Emissions (10$^{-11}$ kg m$^{-2}$ s$^{-1}$)')
ax1.set_title('70$^\circ$N-70$^\circ$S')
ax1.set_ylim([min1, max1])
ax1.set_xlim([0, 132])
ax2 = ax1.twinx()

ax2.plot(np.arange(len(geo_r)), geo_r, color = 'k', linewidth = 1, linestyle = 'dashed')
ax2.plot(np.arange(len(c1_r)), c1_r, color = 'b', linewidth = 1, linestyle = 'dashed')
ax2.plot(np.arange(len(c2_r)), c2_r, color = 'c', linewidth = 1, linestyle = 'dashed')
ax2.set_ylim([min2, max2])
ax2.set_ylabel('Proportion')
plt.xticks([])
fig.text(0.2, 0.8, 'GEOS-Chem', color = 'k')
fig.text(0.4, 0.8, 'CEDS (2008-2014)', color = 'b')
fig.text(0.7, 0.8, 'CEDS (2008-2017)', color = 'c')

for i in range(int(2008), int(2018)+1):
    
    fig.text((i-int(2008))*0.07+0.14, 0.05, str(i))

plt.show()