'''draw Optimize/GEOS-Chem NH3 emissions monthly proportion of data quantity over different region''' 
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
iasi_emi = np.reshape(iasi_emi, [46, 72, yr_len, 12])

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\HEMCO_diagnostics_NH3.Total_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi = data[list(data.keys())[-1]] * land
geo_emi[geo_emi == 0] = np.nan
geo_emi = np.reshape(geo_emi, [46, 72, yr_len, 12])

# draw
mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
co = ['r', 'b', 'orange', 'gray', 'g', 'c', 'y']
x = np.arange(1, 13)
fig = plt.figure(1, (5, 3), dpi = 250)
sca = []
for i in range(len(res)):

    ax = plt.subplot(1, 1, 1)
    ax.set_xlim([0, 13])
    re = res[i]
    opt_emii = iasi_emi[re[0]:re[2], re[1]:re[3], :, :] > 0
    geo_emii = geo_emi[re[0]:re[2], re[1]:re[3], :, :] > 0

    pro = np.nanmean(np.nansum(np.nansum(opt_emii, 1), 0)/np.nansum(np.nansum(geo_emii, 1), 0)*100, 0)
    sca.append(ax.scatter(x, pro, s =5, color = co[i], marker = 'o'))
ax.set_ylabel(r'Grid number proportion ($\frac{Optimized}{GEOS-Chem}$) (%)')
plt.xticks(x, mon)
ax.legend(sca, res_name, ncol = 2, frameon = True)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\emission_monthly_proportion_regional.svg', format = 'svg', bbox_inches = 'tight')
plt.show()