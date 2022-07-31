'''draw mean monthly NH3 emissions variations from GEOS-Chem and optimized over different region''' 

import numpy as np
import netCDF4 as nc
import scipy.io as scio
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':8}
rcParams.update(params)

# monthly data
def Monthly(data, mul, map):

    data = data[list(data.keys())[-1]] * mul
    lat, lon = np.shape(data)[0], np.shape(data)[1]
    yr_len = int(np.shape(data)[2]/12)
    data_mon = np.reshape(data, [lat, lon, yr_len, 12])
    data_mon = data_mon * map # mask ocean
    data_mon[data_mon == 0] = np.nan

    return data_mon

# data overlap, fill the NaN in optimized emissions by GEOS-Chem simulations
def Overlap(data1, data0):

    data1_nan = np.isnan(data1) # Nan in data1
    data1_nan = data0 * data1_nan
    data1[np.isnan(data1)] = 0 # set nan as 0
    data1 = data1 + data1_nan
    data1[data1 == 0] = np.nan

    return data1

path = 'D:\\data\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
thre_n = 30
thre_r = 1
mul = 1E-3 * 3600 * 24 * 365/12 * 1E-6
mon_name = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D']

# regional extent (grid index: bottom, left, top, right)
res_name = ['US', 'SA', 'EU', 'CA', 'IP', 'PP', 'EC']
us = [29, 10, 37, 26] # north America
sa = [13, 20, 23, 30] # south America
eu = [31, 34, 38, 43] # Europe
ca = [20, 33, 28, 47] # central Africa
ip = [25, 49, 32, 55] # India Peninsula
pp = [32, 49, 35, 54] # Pamir Plateau
ec = [28, 56, 35, 62] # eastern China
res = [us, sa, eu, ca, ip, pp, ec]

# import data
## land
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
land = np.reshape(np.repeat(map_land, yr_len*12), [46, 72, yr_len, 12]) 

## area
area = nc.Dataset(path + 'GEOS-Chem\\OutputDir2008\\GEOSChem.Budget.20080101_0000z.nc4')['AREA'][:] # m-2
area = np.reshape(np.repeat(area, yr_len*12), [46, 72, yr_len, 12]) 

data = scio.loadmat(path + 'IASI\\optimized_emi_n=' + str(thre_n) +'_r=' + str(thre_r) + '_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
iasi_emi = Monthly(data, mul, land) * area
# iasi_emi[iasi_emi > 40] = np.NaN

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Total_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_tot = Monthly(data, mul, land) * area

iasi_emi = Overlap(iasi_emi, geo_emi_tot)

# monthly mean
geo = np.nanmean(geo_emi_tot, 2)
adj = np.nanmean(iasi_emi, 2)

# draw
ymax1 = 2.2
ymax2  = 3
ymin2 = 0
col_n = 4
x = np.arange(12)
fig = plt.figure(1, (6, 3), dpi = 250)
for i in range(len(res)):

    re = res[i]
    print('Region: ' + str(np.nansum(np.nansum(geo[re[0]:re[2], re[1]:re[3], :], 1), 0).mean()))
    ax = plt.subplot(2, col_n, i+1)
    
    ax.text(0, ymax1*0.9, res_name[i]) # text region
    ax.set_ylim([0, ymax1])
    
    g = ax.plot(x, np.nansum(np.nansum(geo[re[0]:re[2], re[1]:re[3], :], 1), 0), color = 'g')
    a = ax.plot(x, np.nansum(np.nansum(adj[re[0]:re[2], re[1]:re[3], :], 1), 0), color = 'r')
    print('TDE:' + a)
    
    ax2 = ax.twinx()
    r = ax2.plot(x, np.nansum(np.nansum(adj[re[0]:re[2], re[1]:re[3], :], 1), 0)/np.nansum(np.nansum(geo[re[0]:re[2], re[1]:re[3], :], 1), 0),
        linestyle = 'dashed')
    
    plt.xticks(x, mon_name)

    if i != 0 and i != col_n:
        ax.set_yticks([])

    if i != col_n -1 and i != len(res) -1:
        ax2.set_yticks([])
    else:
        ax2.set_yticks([0, 1, 2])

    if i < col_n -1:
        ax2.set_xticks([])

    ax2.set_ylim([ymin2, ymax2])
    ax2.set_xlim([-0.5, 11.5])
    ax2.hlines(1, -0.5, 12, linewidth = 1, color = 'gray')

    if i == 0:
        plt.legend((g[0], a[0], r[0]), ('GEOS-Chem', 'Optimized', r'Ratio ($\frac{Opt}{Mod}$)'), frameon = False,)

fig.text(0.01, 0.2, 'Emissions (Mt per month)', rotation = 90)
fig.text(0.96, 0.3, r'Ratio ($\frac{Optimized}{GEOS-Chem}$)', rotation = 90)

plt.subplots_adjust(left = 0.09, right = 0.92, wspace =0, hspace = 0)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\plot_monthly_emission_of_IASI&GEOS-Chem.svg', format = 'svg', bbox_inches = 'tight')

plt.show()

# import matplotlib.pyplot as plt
# re = ec
# plt.figure(1)
# plt.imshow(np.flipud(map_land[re[0]:re[2], re[1]:re[3]]),cmap='Greys', alpha=0.5)
# plt.show()