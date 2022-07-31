'''visualize mean and trend CH4 livestock emissions over different regions''' 
import numpy as np
import netCDF4 as nc
import pytab as pt
import matplotlib.pyplot as plt

path = 'D:\\data\\methane\\GlobalInv_livestock_nonwetland.nc'
mul = 1E-3 * 3600 * 24 * 365 * 1E-6

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

## area
area = nc.Dataset('D:\\data\\GEOS-Chem\\OutputDir2008\\\GEOSChem.Budget.20080101_0000z.nc4')['AREA'][:] # m-2

## emission
prior = nc.Dataset(path)['prior_livestock'][:]
prior = prior * map_land * area
prior[prior == 0] = np.nan

retrend = nc.Dataset(path)['posterior_relative_trend'][:]
trend = retrend * prior
retrend = retrend * 100

post_fac = nc.Dataset(path)['posterior_scaling_factor'][:]
post = prior * post_fac

# regional
mean, tre, ret = [], [], []
for i in range(len(res)):

    re = res[i]

    mean.append('%.0f' % np.nansum(np.nansum(post[re[0]:re[2], re[1]:re[3]])))
    ret.append('%.2f' % np.nanmean(np.nanmean(retrend[re[0]:re[2], re[1]:re[3]])))
    tre.append('%.2f' % np.nansum(np.nansum(trend[re[0]:re[2], re[1]:re[3]])))

# visualize
data = {'Mean (Mt)': mean, 'Trend (Mt/yr)': tre,'Relative trend (%)': ret}
pt.table(data = data, rows = res_name, th_c = 'lightblue', td_c = 'lightgray', fontsize = 30, figsize = (5,5), data_loc = 'center')
# plt.tight_layout()
plt.savefig('C:\\Users\\Administrator\\Desktop\\output\\tab_ch4_livestock_mean_trend.svg', format = 'svg', bbox_inches = 'tight')
pt.show()