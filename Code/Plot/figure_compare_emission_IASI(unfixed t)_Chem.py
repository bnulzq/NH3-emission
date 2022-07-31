'''draw comparison of optimized and GEOS-Chem emissions'''
import netCDF4 as nc
import scipy.io as scio
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':5}
rcParams.update(params)

# data overlap 
def Overlap(data1, data2):
    
    ol = (data1 > 0) * (data2 > 0)
    d1 = ol * data1
    d2 = ol * data2
    d1 = d1.reshape([1, d1.size])
    d2 = d2.reshape([1, d2.size])

    # filter 0 and NaN
    d1[d1 == 0] = np.nan
    d2[d2 == 0] = np.nan
    d1 = d1[~pd.isnull(d1)]
    d2 = d2[~pd.isnull(d2)]

    return d1, d2

path = 'D:\\data\\'
ts = [12]
yr_sta = '2008'
yr_end = '2018'
yr_len = int(yr_end)-int(yr_sta) +1
lat_sta = 5
lat_end = 40
thre_n = '800'
thre_r = '1'

# import data
## land 
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
land = np.repeat(map_land, yr_len*12).reshape([46, 72, yr_len*12])

## latitude
lat = nc.Dataset(path + 'GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.200801.nc')['lat'][:]

## GEOS-Chem
geo = scio.loadmat(path + 'GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Total_' + yr_sta + '-' + yr_end + '.mat')
geo = geo['data']
geo = geo * land

## IASI
iasi = scio.loadmat(path + 'IASI\\optimized_emi_n=' + thre_n + '_r=' + thre_r + '_'+ yr_sta + '-' + yr_end + '.mat')
iasi = iasi['E']
iasi = iasi * land

# filter nan and intersects
iasi, geo = Overlap(iasi[lat_sta:lat_end+1, :, :], geo[lat_sta:lat_end+1, :, :])

rmse = np.sqrt(((iasi-geo) ** 2).mean())
mfb = ((iasi - geo).sum()/((geo + iasi).sum()/2))*100
# log
# ia = np.log10(iasi)
# ge = np.log10(geo)

xmax = 50
xmin = 0
ymax = 50
ymin = 0
mul = 1E+11
fig = plt.figure(1, (2.3, 2), dpi = 300) 
# draw
for i in range(1):

    ax = plt.subplot(1, 1, i+1)

    ax.scatter(iasi*mul, geo*mul, s = .05, c = 'darkgray', marker = 'o', alpha = .7)

    x = np.arange(xmin, xmax +1)
    ax.plot(x, x, linewidth = 1, c = 'k', linestyle = 'dashed')
    ax.text(0.5, xmax*0.9, 'RMSE = ' + str('%.2f' % (rmse*mul)))
    ax.text(0.5, xmax*0.8, 'FB = ' + str('%.0f' % (mfb)) + '%')
    ax.text(35, 33, '1:1')
    ax.set_title(str(int(abs(lat[lat_sta]))) + '$^\circ$N-' + str(int(lat[lat_end])) + '$^\circ$S')
    ax.set_xlim([xmin, xmax])
    ax.set_ylim([ymin, ymax])

plt.subplots_adjust(left = 0.17, bottom = 0.19, wspace = 0.2, hspace =0.3)

fig.text(0.03, 0.2, 'GEOS-Chem emission (10$^{-11}$ Kg m$^{-2}$ s$^{-1}$)', fontsize = 5, rotation = 90)
fig.text(0.25, 0.05, 'Optimized emission (10$^{-11}$ Kg m$^{-2}$ s$^{-1}$)',  fontsize = 5)

plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\Pap\\Comparison_emission_r=' + thre_r + '_n=' + thre_n + '.svg', format = 'svg', bbox_inches = 'tight')
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\Pap\\Comparison_emission_r=' + thre_r + '_n=' + thre_n + '.png', format = 'png', bbox_inches = 'tight')


plt.show()



# import matplotlib.pyplot as plt
# plt.imshow(np.flipud(land[:, :, 109]), cmap='Oranges')
# plt.show()