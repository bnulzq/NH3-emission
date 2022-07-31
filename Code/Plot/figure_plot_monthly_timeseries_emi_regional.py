'''draw monthly timeseries of NH3 emissions from GEOS-Chem and adjusted over different region''' 

import numpy as np
import netCDF4 as nc
import scipy.io as scio
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':10}
rcParams.update(params)

# data overlap, fill the NaN in optimized emissions by GEOS-Chem simulations
def Overlap(data1, data0):

    data1_nan = np.isnan(data1) # Nan in data1
    data1_nan = data0 * data1_nan
    data1[np.isnan(data1)] = 0 # set nan as 0
    data1 = data1 + data1_nan
    data1[data1 == 0] = np.nan

    return data1

path = 'D:\\data\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
seas = ['JFM', 'AMJ', 'JAS', 'OND']
thre_n = 800
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
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
land = np.reshape(np.repeat(map_land, yr_len*12), [46, 72, 12*yr_len])

area = nc.Dataset(path + 'GEOS-Chem\\OutputDir2008\\GEOSChem.Budget.20080101_0000z.nc4')['AREA'][:] # m-2
area = np.reshape(np.repeat(area, yr_len*12), [46, 72, 12*yr_len])

data = scio.loadmat(path + '\\IASI\\optimized_emi_n=' + str(thre_n) +'_r=' + str(thre_r) + '_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
iasi_emi = data[list(data.keys())[-1]] * mul * land * area
iasi_emi[iasi_emi == 0] = np.nan
# iasi_emi[iasi_emi > 20] = np.NaN

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Total_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_tot = data[list(data.keys())[-1]] * mul * land * area

# fill IASI emissions
adj_emi = Overlap(iasi_emi, geo_emi_tot)

adj, geo = np.zeros([len(res), 12*yr_len]), np.zeros([len(res), 12*yr_len])

for i in range(len(res)):

    re = res[i]

    adj[i, :] = np.nansum(np.nansum(adj_emi[re[0]:re[2], re[1]:re[3], :], 1), 0)
    geo[i, :] = np.nansum(np.nansum(geo_emi_tot[re[0]:re[2], re[1]:re[3], :], 1), 0)
 
# draw
ind = np.arange(12*yr_len)
ymax = 3.5
ymax2 = 20
ymin2 = 2
fig = plt.figure(1, (10, 5), dpi = 250) 
for i in range(len(res)):

    print('Region: ' + str(geo[i, :].mean()))
    ax = plt.subplot(len(res), 1, i+1)
    ax.text(1, ymax*0.7, res_name[i])
    ax.vlines(np.arange(yr_len+1)*12-0.5, 0, ymax, linewidth = 0.5, color = 'gray')
    # ax.hlines(1, 0, 12*yr_len, linewidth = 0.5, color = 'red')
    # ax.set_title(res_name[i])
    ax.set_xlim([0, 12*yr_len-1+yr_len])
    ax.set_ylim([0, ymax])

    # plot and text value
    ax2 = ax.twinx()
    ax2.set_ylim([ymin2, ymax2])
    yr_sum = []
    ind2 = []
    for j in range(11):

        ind2.append(j*12 + 5)
        yr_sum.append(adj[i, j*12:j*12+12].sum())
        ax2.text(j*12 + 5, yr_sum[j], str('%.1f' % yr_sum[j]), fontsize = 8)
    
    a_sum = ax2.plot(ind2, yr_sum, color = 'sienna', linestyle = 'dashed')
    ax2.plot(np.arange(132, 132+yr_len), yr_sum, color = 'sienna')

    g = ax.plot(ind, geo[i, :], color = 'steelblue')
    a = ax.plot(ind, adj[i, :], color = 'chocolate')

    if i == 0:
        plt.legend((g[0], a[0], a_sum[0]), ('GEOS-Chem', 'Optimized Monthly', 'Optmized Annual'), frameon = False, fontsize = 9, ncol = 3)

    if i == 4:
        plt.xticks(np.arange(yr_len)*12, [])
    else:
        plt.xticks([])

fig.text(0.06, 0.3, 'Emissions (Mt per month)', rotation = 90)
fig.text(0.94, 0.3, 'Emissions (Mt annual)', rotation = 90)
# fig.text(0.94, 0.4, r'Ratio ($\frac{Adjust}{GEOS-Chem}$)', rotation = 90)
for j in range(yr_sta, yr_end+1):
    fig.text((j-yr_sta)*0.066+0.13, 0.07, str(j))
fig.text(0.84, 0.07, '2008-2018')
plt.subplots_adjust(top = 0.99, hspace =0.0)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\plot_emission_of_IASI&GEOS-Chem.svg', format = 'svg', bbox_inches = 'tight')
plt.show()

# import matplotlib.pyplot as plt
# re = ec
# plt.figure(1)
# plt.imshow(np.flipud(map_land[re[0]:re[2], re[1]:re[3]]),cmap='Greys', alpha=0.5)
# plt.figure(2)
# plt.imshow(np.flipud(iasi_emi[:,:,34][re[0]:re[2], re[1]:re[3]]),cmap='Oranges')
# plt.show()