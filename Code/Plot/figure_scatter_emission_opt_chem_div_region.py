'''draw comparison of optimized and GEOS-Chem emissions divided by sub-regions'''
import numpy as np
import netCDF4 as nc
import scipy.io as scio
import pandas as pd
from scipy import stats
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':4}
rcParams.update(params)

# Summary statistics including sample size (N), root mean square error (RMSE), fractional bias (FB), least square error regression slope, and R square (R2)
def Statistics(opt, mod):

    d1, d2 = opt, mod
    # filter 0 and NaN
    d1[d1 == 0] = np.nan
    d2[d2 == 0] = np.nan
    d1 = d1[~pd.isnull(d1)]
    d2 = d2[~pd.isnull(d2)]

    n = d1.size
    rmse = np.sqrt(((d1-d2) ** 2).mean())
    fb = ((d1 - d2).sum()/((d1 + d2).sum()/2))*100
    s, intercept, r, p_value, std_err = stats.linregress(d1, d2) # x, y
    r2 = r * r

    return [n, rmse, fb, s, r2]

path = 'D:\\data\\'
yr_sta = '2008'
yr_end = '2018'
lat_sta = 5 # 70S
lat_end = 40 # 70N
thre_n = '800'
thre_r = '1'
mul = 1E3 * 3600 * 24 * 365

# regional extent (grid index: bottom, left, top, right)
res_name = ['70$^\circ$N-70$^\circ$S', 'US', 'SA', 'EU', 'CA', 'IP', 'PP', 'EC']
all = [5, 0, 41, 72] # 70S-70N
us = [29, 10, 36, 26] # north America
sa = [14, 20, 24, 30] # south America
eu = [32, 34, 39, 42] # Europe
ca = [21, 33, 27, 47] # central Africa
ip = [25, 49, 31, 55] # India Peninsula
pp = [31, 48, 34, 53] # Pamir Plateau
ec = [30, 56, 35, 62] # eastern China
res = [all, us, sa, eu, ca, ip, pp, ec]

# import data
## land
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180

## latitude and longitude
lat = nc.Dataset(path + 'GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.200801.nc')['lat'][:]
lon = nc.Dataset(path + 'GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.200801.nc')['lon'][:]

## GEOS-Chem
geo = scio.loadmat(path + 'GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Total_' + yr_sta + '-' + yr_end + '.mat')
geo = geo['data'] * mul

## IASI
iasi = scio.loadmat(path + 'IASI\\optimized_emi_n=' + thre_n + '_r=' + thre_r + '_'+ yr_sta + '-' + yr_end + '.mat')
iasi = iasi['E'] * mul

# intersect
o1 = ~np.isnan(geo) * ~np.isnan(iasi)
geo = geo * o1
iasi = iasi * o1
geo[geo == 0] = np.nan
iasi[iasi == 0] = np.nan
geo = np.nanmean(geo, 2) * map_land
iasi = np.nanmean(iasi, 2) * map_land
geo[geo == 0] = np.nan
iasi[iasi == 0] = np.nan
iasi = iasi[lat_sta:lat_end+1, :]
geo = geo[lat_sta:lat_end+1, :]

# draw
re_sca = []
co = ['gray', 'r', 'b', 'orange', 'm', 'g', 'c', 'y']
max = 2.6
min = -6.5
fig = plt.figure(1, (2.5, 4), dpi = 300) 
ax = plt.subplot(1, 1, 1)
for i in range(len(res)):

    re = res[i]
    opti = iasi[re[0]:re[2], re[1]:re[3]]
    geoi = geo[re[0]:re[2], re[1]:re[3]]
    re_sca.append(ax.scatter(np.log(opti), np.log(geoi), s = .8, c = co[i], marker = 'o', alpha = .7))
    n, rmse, fb, s, r2 = Statistics(opti, geoi)

    x = np.arange(min, max +1)
    ax.plot(x, x, linewidth = 1, c = 'k', linestyle = 'dashed')
    ax.set_xlim([min, max])
    ax.set_ylim([min, max])

    d1 = -2.5
    d2 = -5.5
    if i < 4:
        ax.text(max*1*i+min, min+d1, res_name[i], fontweight = 'bold')
        ax.text(max*1*i+min, min+d1-0.5, 'N = ' + str(n))
        ax.text(max*1*i+min, min+d1-1, 'RMSE = ' + str('%.2f' % rmse))
        ax.text(max*1*i+min, min+d1-1.5, 'FB = ' + str('%.0f' % fb) + ' %')
        ax.text(max*1*i+min, min+d1-2, 'Slope = ' + str('%.2f' % s))
        ax.text(max*1*i+min, min+d1-2.5, '$R^{2}$ = ' + str('%.2f' % r2))

    else:
        ax.text(max*1*(i-4)+min, min+d2, res_name[i], fontweight = 'bold')
        ax.text(max*1*(i-4)+min, min+d2-0.5, 'N = ' + str(n))
        ax.text(max*1*(i-4)+min, min+d2-1, 'RMSE = ' + str('%.1f' % rmse))
        ax.text(max*1*(i-4)+min, min+d2-1.5, 'FB = ' + str('%.0f' % fb) + ' %')
        ax.text(max*1*(i-4)+min, min+d2-2, 'Slope = ' + str('%.2f' % s))
        ax.text(max*1*(i-4)+min, min+d2-2.5, '$R^{2}$ = ' + str('%.2f' % r2))

plt.xticks(np.arange(-6, 4, 2), ['$10^{-6}$', '$10^{-4}$', '$10^{-2}$', '$10^{0}$', '$10^{2}$'], fontsize = 4)
plt.yticks(np.arange(-6, 4, 2), ['$10^{-6}$', '$10^{-4}$', '$10^{-2}$', '$10^{0}$', '$10^{2}$'], fontsize = 4)

plt.subplots_adjust(left = 0.18, bottom = 0.45, wspace = 0.2, hspace =0.3)
plt.legend(re_sca, res_name, frameon = True, fontsize = 4, loc = 'best', ncol = 2)
plt.xlabel('Optimized emission (g m$^{-2}$ yr$^{-1}$)')
plt.ylabel('Prior emission (g m$^{-2}$ yr$^{-1}$)')
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\Pap\\Results\\fig5.png', format = 'png', bbox_inches = 'tight')
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\Pap\\Results\\fig5.svg', format = 'svg', bbox_inches = 'tight')

plt.show()

# import matplotlib.pyplot as plt
# re = ec
# plt.figure(1)
# plt.imshow(np.flipud(map_land[re[0]:re[2], re[1]:re[3]]),cmap='Greys', alpha=0.5)

# plt.show()