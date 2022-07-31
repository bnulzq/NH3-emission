'''draw Optimize/GEOS-Chem NH3 emissions proportion of data quantity over different region''' 

import numpy as np
import netCDF4 as nc
import scipy.io as scio
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':10}
rcParams.update(params)

path = 'D:\\data\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
seas = ['JFM', 'AMJ', 'JAS', 'OND']
thre_n = 30
thre_r = 1
emi_name = ['Manure management', 'Soil emissions', 'Other anthropogenic', 'Biomass burning']

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
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
land = np.reshape(np.repeat(map_land, yr_len*12), [46, 72, 12*yr_len])

data = scio.loadmat(path + '\\IASI\\IASI_emi_n=' + str(thre_n) +'_r=' + str(thre_r) + '_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
iasi_emi = data[list(data.keys())[-1]] * land
iasi_emi[iasi_emi == 0] = np.nan

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\HEMCO_diagnostics_NH3.Total_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi = data[list(data.keys())[-1]] * land
geo_emi[geo_emi == 0] = np.nan

# draw
n_bin = 15
max = 38
fig = plt.figure(1, (7, 4), dpi = 250)
for i in range(len(res_name)):

    ax = plt.subplot(2, 4, i+1)
    ax.set_xlim([0, 100])
    ax.set_ylim([0, max])
    ax.text(5, 33, res_name[i])

    re = res[i]
    opt_emii = iasi_emi[re[0]:re[2], re[1]:re[3], :] > 0
    geo_emii = geo_emi[re[0]:re[2], re[1]:re[3], :] > 0

    pro = np.nansum(np.nansum(opt_emii, 1), 0)/np.nansum(np.nansum(geo_emii, 1), 0)*100 
    ax.hist(pro, bins = n_bin)
    ax.vlines(50.5, 0, max, color = 'r', linestyle = 'dashed', linewidth = 0.5)

    ax.text(8, 30, 'Proportion:', color = 'r', fontsize = 7)
    ax.text(8, 27, '> 50 %: ' + str('%.0f' % ((pro>50).sum()/12/yr_len*100)) + '%', color = 'r', fontsize = 7)
    ax.text(8, 24, '< 10 %: ' + str('%.0f' % ((pro<10).sum()/12/yr_len*100)) + '%', color = 'r', fontsize = 7)

    if i < 3:
        plt.xticks([])
    else:
        plt.xticks(np.arange(10, 95, 20))

    if i != 0 and i != 4:
        plt.yticks([])

fig.text(0.04, 0.3, 'Number of months', rotation = 90)
fig.text(0.3, 0.05, r'Proportion of grid number ($\frac{Optimized}{GEOS-Chem}$) (%)')
plt.subplots_adjust(left = 0.1, right = 0.97, wspace =0.0, bottom = 0.16, hspace = 0)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\emission_proportion_regional.svg', format = 'svg', bbox_inches = 'tight')

plt.show()