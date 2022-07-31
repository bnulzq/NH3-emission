'''draw SO2, NO2, NH3 emissions change (trend) over different region''' 
import numpy as np
import netCDF4 as nc
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Arial', 'font.weight':'light', 'font.size':10}
rcParams.update(params)

path = 'E:\\AEE\\data\\GEOS-Chem\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
mul = 3600 * 24 * 365 * 1E-9 # kg/s -> Tg/anual

# regional extent (grid index: bottom, left, top, right)
res_name = ['US', 'SA', 'EU', 'TA', 'IP', 'PP', 'EC']
us = [29, 10, 36, 26] # north America
sa = [14, 20, 24, 30] # south America
eu = [32, 34, 39, 42] # Europe
ta = [19, 32, 28, 49] # Tropical Africa
ip = [25, 49, 31, 55] # India Peninsula
pp = [31, 48, 34, 53] # Pamir Plateau
ec = [30, 56, 35, 62] # eastern China
res = [us, sa, eu, ta, ip, pp, ec]

# import data
## land
map = nc.Dataset('E:\\AEE\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
land = np.reshape(np.repeat(map_land, yr_len), [46, 72, yr_len]) 

## area
area = nc.Dataset(path + 'OutputDir2008\\HEMCO_diagnostics.200801010000.nc')['AREA'][:] # m2
area = np.reshape(np.repeat(area, yr_len), [46, 72, yr_len]) 

## SO2, NO2, NH3 emission
so2 = np.zeros([46, 72, yr_len], 'double')
no2 = np.zeros([46, 72, yr_len], 'double')
nh3 = np.zeros([46, 72, yr_len], 'double')

for yr in range(yr_sta, yr_end +1):

    year = str(yr)
    so2_mon = np.zeros([46, 72, 12], 'double')
    no2_mon = np.zeros([46, 72, 12], 'double')
    nh3_mon = np.zeros([46, 72, 12], 'double')

    for m in range (1, 13):
        
        mon = str(m).zfill(2)
        # SO2
        data_so2 = nc.Dataset(path + 'OutputDir' + year + '\\HEMCO_diagnostics.' + year + mon + '010000.nc')['EmisSO2_Anthro'][:] # kg/m2/s
        data_so2 = data_so2 + nc.Dataset(path + 'OutputDir' + year + '\\HEMCO_diagnostics.' + year + mon + '010000.nc')['EmisSO2_Aircraft'][:] # kg/m2/s
        data_so2 = data_so2 + nc.Dataset(path + 'OutputDir' + year + '\\HEMCO_diagnostics.' + year + mon + '010000.nc')['EmisSO2_Ship'][:] # kg/m2/s

        so2_mon[:, :, m-1] = np.squeeze(np.sum(data_so2, 1))

        # NO2
        data_no2 = nc.Dataset(path + 'OutputDir' + year + '\\HEMCO_diagnostics.' + year + mon + '010000.nc')['EmisNO2_Anthro'][:] # kg/m2/s
        data_no2 = data_no2 + nc.Dataset(path + 'OutputDir' + year + '\\HEMCO_diagnostics.' + year + mon + '010000.nc')['EmisNO2_Ship'][:] # kg/m2/s
        no2_mon[:, :, m-1] = np.squeeze(np.sum(data_no2, 1))

        # NH3
        data_nh3 = nc.Dataset(path + 'OutputDir' + year + '\\HEMCO_diagnostics.' + year + mon + '010000.nc')['EmisNH3_Anthro'][:] # kg/m2/s
        data_nh3 = data_nh3 + nc.Dataset(path + 'OutputDir' + year + '\\HEMCO_diagnostics.' + year + mon + '010000.nc')['EmisNH3_Ship'][:] # kg/m2/s
        nh3_mon[:, :, m-1] = np.squeeze(np.sum(data_nh3, 1))


    so2[:, :, yr - yr_sta] = np.mean(so2_mon, 2)
    no2[:, :, yr - yr_sta] = np.mean(no2_mon, 2)
    nh3[:, :, yr - yr_sta] = np.mean(nh3_mon, 2)

so2 = so2 * area * land * mul
so2[so2 == 0] = np.nan

no2 = no2 * area * land * mul
no2[no2 == 0] = np.nan

nh3 = nh3 * area * land * mul
nh3[nh3 == 0] = np.nan

# draw 
ymax = 89
fig = plt.figure(1, (8, 3), dpi = 250)
x = np.arange(yr_sta, yr_end +1)

col_num = 4
for i in range(len(res_name)):

    ax = plt.subplot(2, col_num, i+1)
    ax.set_xlim([yr_sta-0.5, yr_end+0.5])
    ax.set_ylim([0, ymax])
    re = res[i]

    so2i = np.nansum(np.nansum(so2[re[0]:re[2], re[1]:re[3], :], 1), 0)
    no2i = np.nansum(np.nansum(no2[re[0]:re[2], re[1]:re[3], :], 1), 0)
    nh3i = np.nansum(np.nansum(nh3[re[0]:re[2], re[1]:re[3], :], 1), 0)

    # text region name
    ax.text(yr_sta, ymax*0.87, res_name[i])

    # emi
    so2_p = ax.plot(x, so2i.data, color = 'goldenrod')
    no2_p = ax.plot(x, no2i.data, color = 'orangered')
    nh3_p = ax.plot(x, nh3i.data, color = 'indigo')
    ax.vlines(2013, 0, ymax, color = 'gray', linestyle = 'dashed')

# set ticks
    if i != 0 and i != col_num:
        ax.set_yticks([])
    # else:
    #     ax.set_yticklabels( fontsize = 8)

    if i < 3:
        ax.set_xticks([])
    else:
        ax.set_xticks(np.arange(yr_sta, yr_end+1, 2))
        ax.set_xticklabels(np.arange(yr_sta, yr_end+1, 2), fontsize = 8, weight = 'normal')

    if i == len(res_name) -1:
        plt.legend((so2_p[0], no2_p[0], nh3_p[0]), 
        ('SO$_2$', 'NO$_2$', 'NH$_3$'), 
        frameon = False, loc = (1.1, 0.1))


    x0 = 2008
    if i == 2:
        d, d0 = 0.4, 0.85
    else:
        d, d0 = 0.85, 0.85

    ax.text(x0+2, ymax*d0, '2008-2013', fontsize = 6, fontweight = 'light')
    ax.text(x0+5.5, ymax*d0, '2014-2018', fontsize = 6, fontweight = 'light')
    ax.text(x0+1, ymax*(d-0.1), 'SO$_2$', fontsize = 6, color = 'goldenrod')
    ax.text(x0+1, ymax*(d-0.2), 'NO$_2$', fontsize = 6, color = 'orangered')
    ax.text(x0+1, ymax*(d-0.3), 'NH$_3$', fontsize = 6, color = 'indigo')
    ax.text(x0+3, ymax*(d-0.1), str('%.1f' % (so2i[0:6].mean())), color = 'goldenrod', fontsize = 6)
    ax.text(x0+6, ymax*(d-0.1), str('%.1f' % (so2i[6:].mean())), color = 'goldenrod', fontsize = 6)
    ax.text(x0+3, ymax*(d-0.2), str('%.1f' % (no2i[0:6].mean())), color = 'orangered', fontsize = 6)
    ax.text(x0+6, ymax*(d-0.2), str('%.1f' % (no2i[6:].mean())), color = 'orangered', fontsize = 6)
    ax.text(x0+3, ymax*(d-0.3), str('%.1f' % (nh3i[0:6].mean())), color = 'indigo', fontsize = 6)
    ax.text(x0+6, ymax*(d-0.3), str('%.1f' % (nh3i[6:].mean())), color = 'indigo', fontsize = 6)

fig.text(0.01, 0.6, 'Emissions (Tg a$^{-1}$)', rotation = 90)
fig.text(0.51, 0.03, 'Year')
plt.subplots_adjust(left = 0.07, right = 0.99, wspace =0.05, hspace = 0.1, bottom = 0.15)

plt.savefig(fname = 'E:\\AEE\\Pap\\Full\\figure\\figs3.png', format = 'png', bbox_inches = 'tight')

plt.show()
