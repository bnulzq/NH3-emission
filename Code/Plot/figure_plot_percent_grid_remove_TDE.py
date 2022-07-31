'''draw the monthly percentage of removed grid cells in filtering over different regions''' 

import numpy as np
import netCDF4 as nc
import scipy.io as scio
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Arial', 'font.weight':'light', 'font.size':10}
rcParams.update(params)

# monthly data
def Monthly(data, mul, map):

    data = data[list(data.keys())[-1]] * mul
    lat, lon = np.shape(data)[0], np.shape(data)[1]
    yr_len = int(np.shape(data)[2]/12)
    data = np.reshape(data, [lat, lon, yr_len, 12]) # year, month
    data = data * map # mask ocean
    data[data == 0] = np.nan

    return data

path = 'E:\\AEE\\data\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
thre_n = 800
thre_r = 1
mul = 3600 * 24 * 365/12 * 1E-9 # Tg/month/m2

# regional extent (grid index: bottom, left, top, right)
res_name = ['US', 'SA', 'EU', 'TA', 'IP', 'CA', 'EC']
us = [29, 10, 36, 26] # north America
sa = [14, 20, 24, 30] # south America
eu = [32, 34, 39, 42] # Europe
ta = [19, 32, 28, 49] # Tropical Africa
ip = [25, 50, 31, 55] # India Peninsula
pp = [31, 48, 34, 53] # Pamir Plateau
ec = [30, 56, 35, 62] # eastern China
res = [us, sa, eu, ta, ip, pp, ec]

# import data
## land
map = nc.Dataset('E:\\AEE\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
land = np.reshape(np.repeat(map_land, yr_len*12), [46, 72, yr_len, 12]) 
land_yr = np.sum(land, 3)

## area
area = nc.Dataset(path + 'GEOS-Chem\\OutputDir2008\\\GEOSChem.Budget.20080101_0000z.nc4')['AREA'][:] # m2
area = np.reshape(np.repeat(area, yr_len*12), [46, 72, yr_len, 12]) 

## biased emission
data = scio.loadmat(path + 'IASI\\Emission\\NHx lifetime_with adjustment_optimized_emi_n=800_r=1_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
bias_emi = Monthly(data, mul, land) * area

## iasi
data = scio.loadmat(path + 'IASI\\IASI_filter\\IASI_filter_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
data_iasi = data[list(data.keys())[-1]]

rem = []
for re in res:

    emi = np.count_nonzero(~np.isnan(bias_emi[re[0]:re[2], re[1]:re[3], :, :]))
    iasi = np.count_nonzero(~np.isnan(data_iasi[re[0]:re[2], re[1]:re[3], :, :]))
    rem.append((1-emi/iasi)*100)



# draw
fig = plt.figure(1, (4, 2), dpi = 250, tight_layout = True)
ax = plt.subplot(1, 1, 1)
ax.bar(res_name, rem, width = 0.5)

ax.set_title('Total percentage of excluding grid cells')
ax.set_ylabel('%')
ax.set_xlabel('Region')

plt.savefig(fname = 'E:\\AEE\\Pap\\ACP\\figure\\figS4.png', format = 'png', bbox_inches = 'tight')

plt.show()