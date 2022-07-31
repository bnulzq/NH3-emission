'''draw comparison of IASI NH3 with GEOS-Chem (validation)'''   
import mat73 as m73
import scipy.io as scio
import numpy as np
import netCDF4 as nc
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

# get statitical information
def Statis(x, y):

    fits = np.polyfit(x, y, 1)
    r = np.corrcoef(x, y)[0, 1]
    r2 = r**2
    rmse = np.sqrt(np.mean((x - y) ** 2))
    mfb = 2 * np.sum(y-x) /np.sum(x+y) 
    xy10 = sum(x/y > 10)/len(x)*100
    yx10 = sum(y/x > 10)/len(x)*100

    return fits, r2, rmse, mfb, xy10, yx10

path = 'E:\\AEE\\data\\'
yr = '2008'
mul = 1E+5
thre_r = 1
thre_n = 800

# import data
map = nc.Dataset('E:\\AEE\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
map_land = map_land[5:41, :]

r = scio.loadmat(path + '\\GEOS-Chem\\transport_to_emission_2008-2018.mat')['r']

geo_nhx_mon = np.zeros([36, 72, 12])
geo_mon = np.zeros([36, 72, 12])
geo_12_mon = np.zeros([36, 72, 12])
iasi_mon = np.zeros([36, 72, 12])

for m in range(1, 13):

    mon = str(m).zfill(2)
    geo = nc.Dataset(path + 'GEOS-Chem\\concentration\\GEOS-Chem_Total column_'+ yr+ mon+ '.nc')['GEOS-Chem monthly mean NH3'][:]
    geo_nhx = nc.Dataset(path + 'GEOS-Chem\\validation1\\GEOS-Chem_Total column_' + yr + mon + '_NHx.nc')['GEOS-Chem monthly mean NH3'][:]
    # geo_12 = nc.Dataset(path + 'GEOS-Chem\\validation\\GEOS-Chem_Total column_' + yr + mon + '_12h.nc')['GEOS-Chem monthly mean NH3'][:]
    iasi = nc.Dataset(path + 'IASI\\IASI_filter\\IASI_filter_AM_Cloud_10_' + yr + mon + '.nc')['averaging nh3 filter'][:].T
    n = nc.Dataset(path + 'IASI\\IASI_filter\\IASI_filter_AM_Cloud_10_' + yr + mon + '.nc')['Monthly number of retrievals'][:].T
 
    r_m = r[5:41, :, (int(yr) - 2008)*12 + m-1]

    geo = geo[5:41, :] *  mul * map_land  #* (n[5:41, :] > thre_n) * (r_m > thre_r) 
    geo_nhx = geo_nhx[5:41, :]  * mul* map_land #* (n[5:41, :] > thre_n) * (r_m > thre_r) 
    # geo_12 = geo_12[5:41, :]  * mul * map_land # * (n[5:41, :] > thre_n) * (r_m > thre_r) * map_land
    iasi = iasi[5:41, :]  * mul  * map_land #* (n[5:41, :] > thre_n) * (r_m > thre_r)
    
    geo_nhx_mon[:, :, m-1] = geo_nhx
    # geo_12_mon[:, :, m-1] = geo_12
    iasi_mon[:, :, m-1] = iasi
    geo_mon[:, :, m-1] = geo

geo1, iasi1 = Overlap(geo_mon, iasi_mon)
geo2, iasi2 = Overlap(geo_nhx_mon, iasi_mon)
# geo3, iasi3 = Overlap(geo_12_mon, iasi_mon)

n = len(iasi1)

fits1, r2_1, rmse1, mfb1, xy10_1, yx10_1 = Statis(iasi1, geo1)
fits2, r2_2, rmse2, mfb2, xy10_2, yx10_2 = Statis(iasi2, geo2)
# fits3, r2_3, rmse3, mfb3, xy10_3, yx10_3 = Statis(iasi3, geo3)

max = 200
x = np.arange(0, max +1)

# draw 1
fig = plt.figure(1, (6, 1.8), dpi = 250)
ax = plt.subplot(1, 3, 1)

ax.set_xlim([0, max])
ax.set_ylim([0, max])

ax.scatter(iasi1, geo1, s = .5, c = 'gray')

ax.plot(x, x, linewidth = 1, c = 'k',linestyle = 'dashed')
ax.plot(x, x*fits1[0]+fits1[1], linewidth = 1, c = 'k', )

ax.set_xlabel('IASI (10$^{-5}$ mol m$^{-2}$)')
ax.set_ylabel('GEOS-Chem (10$^{-5}$ mol m$^{-2}$)')
ax.set_title(yr + ' Model input inventory')

x0 = max*0.65
y0 = max*0.25
d = max*0.05
ax.text(x0, y0, 'R$^2$ = ' + str('%.2f' % r2_1))
ax.text(x0, y0-d, 'RMSE = ' + str('%.2f' % rmse1))
ax.text(x0, y0-2*d, 'FB = ' + str('%.2f' % mfb1))
ax.text(x0*0.3, y0*3, 'N = ' + str(n))
ax.text(x0, y0-3*d, 'X/Y > 10 = ' + str('%.2f' % xy10_1))
ax.text(x0, y0-4*d, 'Y/X > 10 = ' + str('%.2f' % yx10_1))

# draw 2
ax = plt.subplot(1, 3, 2)

ax.set_xlim([0, max])
ax.set_ylim([0, max])

ax.scatter(iasi2, geo2, s = .5, c = 'gray')

ax.plot(x, x, linewidth = 1, c = 'k',linestyle = 'dashed')
ax.plot(x, x*fits2[0]+fits2[1], linewidth = 1, c = 'k', )

ax.set_xlabel('IASI (10$^{-5}$ mol m$^{-2}$)')
ax.set_ylabel('GEOS-Chem (10$^{-5}$ mol m$^{-2}$)')
ax.set_title(yr + ' This study')

ax.text(x0, y0, 'R$^2$ = ' + str('%.2f' % r2_2))
ax.text(x0, y0-d, 'RMSE = ' + str('%.2f' % rmse2))
ax.text(x0, y0-2*d, 'FB = ' + str('%.2f' % mfb2))
ax.text(x0, y0-3*d, 'X/Y > 10 = ' + str('%.2f' % xy10_2))
ax.text(x0, y0-4*d, 'Y/X > 10 = ' + str('%.2f' % yx10_2))

# draw 3
# ax = plt.subplot(1, 3, 3)

# ax.set_xlim([0, max])
# ax.set_ylim([0, max])

# # ax.scatter(iasi3, geo3, s = .5, c = 'gray')

# ax.plot(x, x, linewidth = 1, c = 'k',linestyle = 'dashed')
# # ax.plot(x, x*fits3[0]+fits3[1], linewidth = 1, c = 'k', )

# ax.set_xlabel('IASI (10$^{-5}$ mol m$^{-2}$)')
# ax.set_ylabel('GEOS-Chem (10$^{-5}$ mol m$^{-2}$)')
# ax.set_title(yr + ' Lifetime = 12h')

# ax.text(x0, y0, 'R$^2$ = ' + str('%.2f' % r2_3))
# ax.text(x0, y0-d, 'RMSE = ' + str('%.2f' % rmse3))
# ax.text(x0, y0-2*d, 'FB = ' + str('%.2f' % mfb3))
# ax.text(x0, y0-3*d, 'X/Y > 10 = ' + str('%.2f' % xy10_3))
# ax.text(x0, y0-4*d, 'Y/X > 10 = ' + str('%.2f' % yx10_3))


plt.subplots_adjust(bottom = 0.2, wspace = 0.3)
# plt.savefig(fname = r'C:\Users\bnulzq\Desktop\test\scatter_IASI_GEOS-Chem_compare_' + yr + '.png', format = 'png', bbox_inches = 'tight')

plt.show()
