'''draw scatters of IASI NH3 with Van Dammes''' 

import mat73 as m73
import numpy as np
import netCDF4 as nc
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':7}
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

path = 'E:\\AEE\\data\\'
yr_sta = 2008
yr_end = 2016
mul = 1E-15

# import data
map = nc.Dataset('E:\\AEE\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
map_land = map_land[5:41, :]

iasi_ = m73.loadmat(path + '\\IASI\\IASI_filter\\IASI_filter_' + str(yr_sta) + '-' + str(yr_end) + '.mat') # molecule cm-2
iasi_v = m73.loadmat(path + '\\IASI\\ANNI-NH3\\ANNI-NH3\\IASI_01_' + str(yr_sta) + '-' + str(yr_end) + '.mat')
iasi_ = iasi_['iasi_mean'] * mul
iasi_v = iasi_v['data'] * mul


iasi_land = iasi_ * map_land
iasi_oce = iasi_ * ~map_land
iasi_land[iasi_land == 0] = np.nan
iasi_oce[iasi_oce == 0] = np.nan

iasi_v_land = iasi_v * map_land
iasi_v_oce = iasi_v * ~map_land
iasi_v_land[iasi_v_land == 0] = np.nan
iasi_v_oce[iasi_v_oce == 0] = np.nan

data_, data_v = Overlap(iasi_, iasi_v)
fits = np.polyfit(np.log(data_v), np.log(data_), 1)
r = np.corrcoef(data_, data_v)[0, 1]
r2 = r**2
rmse = np.sqrt(np.mean((data_- data_v) ** 2))
bias = np.mean(data_- data_v)

min = -3
max = 4
x = np.arange(min, max +1)
# draw
fig = plt.figure(1, (3, 2.5), dpi = 250)
ax = plt.subplot(1, 1, 1)

ax.set_xlim([min, max])
ax.set_ylim([min, max])

ax.scatter(np.log(iasi_v_land), np.log(iasi_land), s = .5, c = 'g')
ax.scatter(np.log(iasi_v_oce), np.log(iasi_oce), s = .5, c = 'b')

ax.plot(x, x, linewidth = 1, c = 'gray',linestyle = 'dashed')
ax.plot(x, x*fits[0]+fits[1], linewidth = 2, c = 'k', )

plt.xticks([-3, -1, 0, 1, 3], ['10$^{-3}$', '10$^{-1}$', '10$^{0}$', '10$^{1}$', '10$^{3}$'])
plt.yticks([-3, -1, 0, 1, 3], ['10$^{-3}$', '10$^{-1}$', '10$^{0}$', '10$^{1}$', '10$^{3}$'])

ax.set_xlabel('Van Damme et. al (2018)')
ax.set_ylabel('Our study (after filtering)')
ax.set_title('IASI concentrations (10$^{15}$ molecules cm$^{-2}$)')

ax.text(-2.5, 2.5, 'Land', color = 'g')
ax.text(-2.5, 2, 'Ocean', color = 'b')

ax.text(1.5, -1, 'R$^2$ = ' + str('%.2f' % r2))
ax.text(1.5, -1.5, 'RMSE = ' + str('%.2f' % rmse))
ax.text(1.5, -2, 'Bias = ' + str('%.2f' % bias))

plt.subplots_adjust(left = 0.2, bottom = 0.2, wspace = 0.2, hspace =0.3)
plt.savefig(fname = r'C:\Users\bnulzq\Desktop\test\scatter_IASI_compare.png', format = 'png', bbox_inches = 'tight')

plt.show()

