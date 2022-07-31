'''draw Optimize NH3 emissions monthly trend over different region''' 
import numpy as np
import netCDF4 as nc
import scipy.io as scio
import pandas as pd
from statsmodels.formula.api import ols
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':10}
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

# data overlap
def Overlap(data1, data0):

    data1_nan = np.isnan(data1) # Nan in data1
    data1_nan = data0 * data1_nan
    data1[np.isnan(data1)] = 0 # set nan as 0
    data1 = data1 + data1_nan
    data1[data1 == 0] = np.nan

    return data1

# trend and p value
def TrendP(y, x):

    data = pd.DataFrame({'x':x, 'y':y})
    model = ols('y~x', data).fit()
    slo = model.params[1]
    p = model.pvalues[1]
    # print(p)
    if p < 0.01:
        pp = '**'
    elif p < 0.05:
        pp = '*'
    else:
        pp = ''

    return slo, pp

path = 'D:\\data\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
thre_n = 30
thre_r = 1
mul = 1E-3 * 3600 * 24 * 365/12 * 1E-6

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
area = nc.Dataset(path + 'GEOS-Chem\\OutputDir2008\\\GEOSChem.Budget.20080101_0000z.nc4')['AREA'][:] # m-2
area = np.reshape(np.repeat(area, yr_len*12), [46, 72, yr_len, 12]) 

## optimize emission
data = scio.loadmat(path + '\\IASI\\optimized_emi_n=' + str(thre_n) +'_r=' + str(thre_r) + '_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
iasi_emi = Monthly(data, mul, land) * area

## geos-chem emission
data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Total_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_tot = Monthly(data, mul, land) * area

# fill IASI emissions
adj_emi = Overlap(iasi_emi, geo_emi_tot)

# draw
mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
co = ['r', 'b', 'orange', 'gray', 'g', 'c', 'y']

x = np.arange(1, 13)
fig = plt.figure(1, (5, 3), dpi = 250)
sca = []
for i in range(len(res)):

    re = res[i]

    # regional trend and relative trends
    opt_emii = np.nansum(np.nansum(iasi_emi[re[0]:re[2], re[1]:re[3], :, :], 1), 0)
    tres, re_tre = [], []
    for j in range(12):

        emiij = opt_emii[:, j]
        tre, p = TrendP(emiij, np.arange(yr_sta, yr_end +1))
        re_tre.append(tre/np.nanmean(emiij)*100)
        tres.append(tre)
    
    ax = plt.subplot(2, 1, 1)
    
    ax2 = plt.subplot(2, 1, 2)
    ax.set_xlim([0, 13])
    ax2.set_xlim([0, 13])
    ax2.set_ylim([-21, 21])

    sca.append(ax.scatter(x, tres, s = 8, color = co[i], marker = 'o'))
    ax2.scatter(x, re_tre, s = 8, color = co[i], marker = 'o')

ax.hlines(0, 0, 13, linestyle = 'dashed', color = 'lightgray')
ax2.hlines(0, 0, 13, linestyle = 'dashed', color = 'lightgray')
ax.set_title('Monthly Trends')
# ax.set_ylabel('Emission trend (Mt yr$^{-1}$)')
# ax2.set_ylabel('Emission trend (% yr$^{-1}$)')
ax.set_xticks([])
plt.xticks(x, mon)
ax.legend(sca, res_name, ncol = 2, frameon = True, fontsize = 7)
fig.text(0.01, 0.4, 'Emissions trend', rotation = 90)
fig.text(0.04, 0.6, '(Mt yr$^{-1}$)', rotation = 90)
fig.text(0.04, 0.2, '(% yr$^{-1}$)', rotation = 90)

plt.subplots_adjust(left = 0.15, right = 0.93, wspace =0.0, hspace = 0)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\emission_monthly_trend_regional.svg', format = 'svg', bbox_inches = 'tight')
plt.show() 