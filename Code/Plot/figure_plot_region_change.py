'''draw annual NH3 change over different region in GEOS-Chem/IASI''' 

import netCDF4 as nc
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':10}
rcParams.update(params)

# create 3 dimension NaN array
def Nan3Array(x, y, z):

    data = np.zeros([x, y, z])
    data[:] = np.nan

    return data

# get the regional land area
def RegionLand(data, map, extent):

    x1 = extent[0]
    x2 = extent[2]
    y1 = extent[1]
    y2 = extent[3]

    land = data[y1:y2, x1:x2] * map[y1:y2, x1:x2]
    land[land == 0] = np.nan
    land = np.nanmean(np.nanmean(land))

    return land

path = 'D:\\data\\'

yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
mul = 1E-15*6.02214179E19

# regional extent (grid index: left, bottom, right, top)
ic = [36, 39, 39, 50]
af = [33, 14, 47, 32]
sa = [20, 9, 30, 26]
re = ['West Russia', 'Africa', 'South America']

# import data
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180

g_ic, g_af, g_sa, i_ic, i_af, i_sa = [], [], [], [], [], []

for yr in range(yr_sta, yr_end +1):

    year = str(yr)
    print('Year: ', year)

    g_mon = Nan3Array(46, 72, 12)
    i_mon = Nan3Array(46, 72, 12)

    for m in range(1, 13):

        month = str(m).zfill(2)
        chem = nc.Dataset(path + 'GEOS-Chem\\concentration_month\\GEOS-Chem_' + year + month + '.nc') # GEOS-Chem 
        g_mon[:, :, m-1] = chem.variables['GEOS-Chem daytime simulation_' + year + month][:]*mul

        iasi = nc.Dataset(path + 'IASI\\filter\\IASI_filter_AM_Cloud_10_' + year + month + '.nc') # IASI
        i_mon[:, :, m-1] = (iasi.variables['averaging nh3 filter'][:]*mul).T

    g_yr = np.nanmean(g_mon, 2)
    i_yr = np.nanmean(i_mon, 2)

    g_ic.append(RegionLand(g_yr, map_land, ic))
    i_ic.append(RegionLand(i_yr, map_land, ic))
    g_af.append(RegionLand(g_yr, map_land, af))
    i_af.append(RegionLand(i_yr, map_land, af))
    g_sa.append(RegionLand(g_yr, map_land, sa))
    i_sa.append(RegionLand(i_yr, map_land, sa))

ic = [g_ic, i_ic]
af = [g_af, i_af]
sa = [g_sa, i_sa]
model = ['GEOS-Chem', 'IASI']

# draw
ymax = 6
ymin = -0.5
fig = plt.figure(1, (7, 3.5), dpi = 250) 
for i in range(2):   

    ax = plt.subplot(1, 2, i+1)
    ax.set_title(model[i])
    ax.set_xlim([yr_sta, yr_end])
    ax.set_ylim([ymin, ymax])

    x = np.arange(yr_sta, yr_end+1, 1)
    ax.xticks = x

    ax.plot(x, ic[i], c = 'purple', linewidth = 2, label = re[0])
    ax.plot(x, af[i], c = 'peru', linewidth = 2, label = re[1])
    ax.plot(x, sa[i], c = 'yellowgreen', linewidth = 2, label = re[2])

    if i == 0:
        ax.legend(loc = 'best', frameon = False, edgecolor = 'black', ncol = 1)

# fig.text(0.27, 0.03, 'Frequency',  fontsize = 10)
fig.text(0.08, 0.2, 'Concentrations (10$^{15}$ molecules cm$^{-2}$)', fontsize = 10, rotation = 90,)

plt.subplots_adjust(left = 0.14, bottom = 0.12, wspace = 0.15, hspace =0.3)

plt.savefig(fname = path + 'IASI&Chem_annual change.png', format = 'png', bbox_inches = 'tight')

plt.show()


# import matplotlib.pyplot as plt
# plt.imshow(np.flipud(g_yr[14:32, 33:47]), cmap='Oranges')
# # plt.imshow(np.flipud(map_land[14:32, 33:47]),cmap='Oranges')
# plt.show()

