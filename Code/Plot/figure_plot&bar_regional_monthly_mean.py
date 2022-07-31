'''draw mean monthly NH3 over different region in GEOS-Chem and IASI (with Ocean background)''' 

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

    land = data[y1:y2, x1-1:x2-1] * map[y1:y2, x1:x2]
    land[land == 0] = np.nan
    land = np.nanmean(np.nanmean(land))

    return land

path = 'D:\\data\\'
mons = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
mul = 1E-15*6.02214179E19

# regional extent (grid index: left, bottom, right, top)
ic = [36, 39, 39, 50]
af = [33, 14, 47, 32]
sa = [20, 9, 30, 26]

# import data
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
map_oc = np.array(np.squeeze(map['FROCEAN'][:] > 0.9))  # -180-180

oc, g_ic, g_af, g_sa, i_ic, i_af, i_sa = [], [], [], [], [], [], []

for m in range(1, 13):

    month = str(m).zfill(2)
    print('Month: ' + month)
    
    g_mon = Nan3Array(46, 72, yr_len)
    i_mon = Nan3Array(46, 72, yr_len)

    for yr in range(yr_sta, yr_end +1):

        year = str(yr)
        ## GEOS-Chem 
        chem = nc.Dataset(path + 'GEOS-Chem\\concentration_month\\GEOS-Chem_' + year + month + '.nc') 
        g_mon[:, :, yr - yr_sta] = chem.variables['GEOS-Chem daytime simulation_' + year + month][:]*mul
        
        ## IASI
        iasi = nc.Dataset(path + 'IASI\\filter\\IASI_filter_AM_Cloud_10_' + year + month + '.nc') 
        i_mon[:, :, yr - yr_sta] = (iasi.variables['averaging nh3 filter'][:]*mul).T

    # monthly mean
    g_yr = np.nanmean(g_mon, 2)
    i_yr = np.nanmean(i_mon, 2)

    # regional
    g_ic.append(RegionLand(g_yr, map_land, ic))
    i_ic.append(RegionLand(i_yr, map_land, ic))
    g_af.append(RegionLand(g_yr, map_land, af))
    i_af.append(RegionLand(i_yr, map_land, af))
    g_sa.append(RegionLand(g_yr, map_land, sa))
    i_sa.append(RegionLand(i_yr, map_land, sa))

    # ocean background
    # ocb = i_yr * map_oc
    # ocb[ocb == 0] = np.nan
    # oc.append(np.nanmean(np.nanmean(ocb)))

iasi = [i_ic, i_af, i_sa]
geo = [g_ic, g_af, g_sa]
reg = ['West Russia', 'Africa', 'South America']

# draw 
ymax = 0.6
ymin = -0.3
wid = 0.7
fig = plt.figure(1, (10, 3), dpi = 250) 
for i in range(3):   

    ax = plt.subplot(1, 3, i+1)
    ax.set_title(reg[i])
    ax.set_xlim([0.5, 12.5])
    ax.set_ylim([ymin, ymax])

    x = np.arange(1, 13, 1)
    plt.xticks(x, mons, fontsize=8)

    if i != 0:
        ax.set_yticks([])

    ax.plot(x, iasi[i], c = 'purple', linewidth = 2, label = 'IASI')
    ax.bar(x, geo[i], wid, color = 'peru', label = 'GEOS-Chem')
    #ax.bar(x, oc, wid, bottom = geo[i], color = 'yellowgreen', label = 'IASI ocean')

    if i == 0:
        ax.legend(loc = 'best', frameon = False, edgecolor = 'black', ncol = 1)

plt.subplots_adjust(left = 0.08, right = 0.95, bottom = 0.12, wspace = 0, hspace =0.3)
fig.text(0.01, 0.13, 'Concentrations (10$^{15}$ molecules cm$^{-2}$)', fontsize = 10, rotation = 90,)
plt.savefig(fname = path + 'IASI&Chem monthly mean.png', format = 'png', bbox_inches = 'tight')

plt.show()

# import matplotlib.pyplot as plt
# plt.imshow(np.flipud(g_yr[25:36,49:62 ]),cmap='Oranges')
# plt.imshow(np.flipud(i_yr[25:36,49:62 ]),cmap='Oranges')
# plt.show()
