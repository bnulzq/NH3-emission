'''draw optimized NH3 emissions sectors change (trend) over different region''' 

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

path = 'D:\\data\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
thre_n = 30
thre_r = 1
mul = 1E-3 * 3600 * 24 * 365/12 * 1E-6
# emi_name = ['Manure management', 'Soil emissions', 'Other anthropogenic', 'Biomass burning']
emi_name = ['Anthropogenic', 'Biomass burning', 'Others']

# regional extent (grid index: bottom, left, top, right)
res_name = ['US', 'SA', 'EU', 'CA', 'IP', 'PP','EC']
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
iasi_emi = Monthly(data, mul, land)
# iasi_emi[iasi_emi > 40] = np.NaN

## geos-chem emission
data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Total_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_tot = Monthly(data, mul, land)

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Anthro_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_anth = Monthly(data, mul, land)

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.BioBurn_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_bb = Monthly(data, mul, land)

## ceds emission
# ceds_emi_ene = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Energy_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Energy'][:]
# ceds_emi_ind = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Industry_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Industry'][:]
# ceds_emi_rc = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Residential and Commercial_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Residential and Commercial'][:]
# ceds_emi_was = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Waste_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Waste'][:]
# ceds_emi_oth = ceds_emi_rc + ceds_emi_was + ceds_emi_ind + ceds_emi_ene

# ceds_emi_man = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Manure management_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Manure management'][:]
# ceds_emi_soi = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Soil emissions_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Soil emissions'][:]
# ced_emi_tot = ceds_emi_oth + ceds_emi_man + ceds_emi_soi

# fill IASI emissions
adj_emi = Overlap(iasi_emi, geo_emi_tot)

# emission category ratio
anth_r = geo_emi_anth/geo_emi_tot
bb_r = geo_emi_bb/geo_emi_tot
geo_emi_oth = geo_emi_tot - geo_emi_anth - geo_emi_bb
oth_r = (geo_emi_oth)/geo_emi_tot

# adjusted emissions category
adj_emi_anth = anth_r * adj_emi * area
adj_emi_bb = bb_r * adj_emi * area
adj_emi_oth = oth_r * adj_emi * area

adj_emi = [adj_emi_anth, adj_emi_bb, adj_emi_oth]

# co = ['gold', 'darkorange', 'dodgerblue', 'seagreen']
co = ['darkorange', 'seagreen', 'dodgerblue']
# draw
x = np.arange(yr_sta, yr_end +1)
max = 19
col_n = 4
fig = plt.figure(1, (8, 3), dpi = 250)
for i in range(len(res)):

    ax = plt.subplot(2, col_n, i+1)
    # ax.set_title(res_name[i])
    ax.set_xlim([yr_sta-0.5, yr_end+0.5])
    ax.set_ylim([0, max])
    re = res[i]

    # text region name
    ax.text(yr_end -2, max*0.9, res_name[i])

    re_plot = []
    for j in range(len(emi_name)):

        emiij = np.nansum(np.nansum(np.nansum(adj_emi[j][re[0]:re[2], re[1]:re[3], :, :], 3), 1), 0)
        data = pd.DataFrame({'x':x, 'y':emiij})
        model = ols('y~x', data).fit()
        slo = model.params[1]
        p = model.pvalues[1]
        if p < 0.01:
            pp = '**'
        elif p < 0.05:
            pp = '*'
        else:
            pp = ''

        # emiij = pre.normalize(emiij[:,np.newaxis], axis=0).ravel()
        re_plot.append(ax.plot(x, emiij, color = co[j]))
        ax.text(yr_sta +0.5, max-j*max/10-max/10, emi_name[j] + ': ' + str('%.3f' % (slo)) + pp, color = co[j], fontsize = 8)
        

    # if i == 0:
    #     plt.legend(re_plot, emi_name, frameon = False)

    if i != 0 and i != col_n:
        plt.yticks([])

    if i < col_n:
        plt.xticks([])

    else:
        plt.xticks(np.arange(yr_sta, yr_end+1), fontsize = 8, rotation = 45)

fig.text(0.01, 0.25,'Optimized emission (Mt annual)', rotation = 90)
plt.subplots_adjust(left = 0.07, right = 0.98, wspace =0.0, hspace = 0)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\emission_trend_sector_regional.svg', format = 'svg', bbox_inches = 'tight')

plt.show()
