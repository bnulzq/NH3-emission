'''draw scatters of NH3 emissions from GEOS-Chem and adjusted over different region''' 

import numpy as np
import netCDF4 as nc
import scipy.io as scio
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':10}
rcParams.update(params)

# data overlap
def Overlap(data1, data0, mul):

    data1 = data1[list(data1.keys())[-1]] * mul
    lat, lon = np.shape(data1)[0], np.shape(data1)[1]
    yr_len = int(np.shape(data1)[2]/12)
    data1 = np.reshape(data1, [lat, lon, yr_len, 12]) # year, month
    data1 = data1 * ~np.isnan(data0)
    data1[data1 == 0] = np.nan
    
    return data1

path = 'D:\\data\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
thre_n = 30
thre_r = 1
mul = 1E+11
emi_name = ['Anthropogenic', 'Biomass burning', 'Others']

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

data = scio.loadmat(path + '\\IASI\\optimized_emi_n=' + str(thre_n) +'_r=' + str(thre_r) + '_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
adj_emi = data[list(data.keys())[-1]] * mul * land
adj_emi = np.reshape(adj_emi, [46, 72, yr_len, 12])
adj_emi[adj_emi <= 0] = np.nan
# iasi_emi[iasi_emi > 20] = np.NaN

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Total_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_tot = Overlap(data, adj_emi, mul)

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Anthro_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_anth = Overlap(data, adj_emi, mul)

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.BioBurn_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_bb = Overlap(data, adj_emi, mul)

# data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\HEMCO_diagnostics_NH3.Natural_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
# geo_emi_nat = Overlap(data, iasi_emi, mul)

## ceds emission
# ceds_emi_ene = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Energy_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Energy'][:]
# ceds_emi_ind = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Industry_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Industry'][:]
# ceds_emi_rc = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Residential and Commercial_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Residential and Commercial'][:]
# ceds_emi_was = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Waste_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Waste'][:]
# ceds_emi_oth = ceds_emi_rc + ceds_emi_was + ceds_emi_ind + ceds_emi_ene

# ceds_emi_man = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Manure management_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Manure management'][:]
# ceds_emi_soi = nc.Dataset(path + '\\CEDS\\grid\\CEDS_Soil emissions_' + str(yr_sta) + '-' + str(yr_end) + '.nc')['Soil emissions'][:]
# ced_emi_tot = ceds_emi_oth + ceds_emi_man + ceds_emi_soi

# emission category ratio
anth_r = geo_emi_anth/geo_emi_tot
bb_r = geo_emi_bb/geo_emi_tot
geo_emi_oth = geo_emi_tot - geo_emi_anth - geo_emi_bb
oth_r = (geo_emi_oth)/geo_emi_tot

# adjusted emissions category
adj_emi_anth = anth_r * adj_emi
adj_emi_bb = bb_r * adj_emi
adj_emi_oth = oth_r * adj_emi

adj_emi = [adj_emi_anth, adj_emi_bb, adj_emi_oth]
geo_emi = [geo_emi_anth, geo_emi_bb, geo_emi_oth]

# co = ['gold', 'darkorange', 'dodgerblue', 'seagreen']
co = ['darkorange', 'seagreen', 'dodgerblue']
# draw
max = [52, 11, 7]
fig = plt.figure(1, (8, 5), dpi = 250)
for i in range(len(emi_name)):

    opt_emii = adj_emi[i]
    geo_emii = geo_emi[i]

    for j in range(len(res)):

        ax = plt.subplot(len(emi_name), len(res), i*len(res)+j+1)

        re = res[j]
        optij = opt_emii[re[0]:re[2], re[1]:re[3], :]
        geoij = geo_emii[re[0]:re[2], re[1]:re[3], :]

        optij = np.reshape(optij, [optij.size, 1])
        geoij = np.reshape(geoij, [geoij.size, 1])
        geoij[np.isnan(optij)] == np.nan
        optij[np.isnan(geoij)] == np.nan

        if i == 0:
            ax.set_title(res_name[j])

        # text sectors
        if j == len(res) -1:
            ax.text(max[i]*1.08, max[i]/5, emi_name[i], fontsize = 8, rotation = 90)

        ax.set_xlim([0, max[i]])
        ax.set_ylim([0, max[i]])
        re_sca = []
        
        ax.plot(np.arange(max[i]+1), np.arange(max[i]+1), color = 'k', linestyle = '--', linewidth = 0.3)
            
        re_sca.append(ax.scatter(optij, geoij, color = co[i], s=.1, alpha = 1))

        rmse = np.sqrt(np.nanmean((optij-geoij) ** 2))
        mfb = np.nansum(optij - geoij)/np.nansum((geoij + optij)/2)*100
        

        ax.text(max[i]/50, max[i]/1.2, 'RMSE = ' + str('%.2f' % (rmse)), fontsize = 6)
        ax.text(max[i]/50, max[i]/1.1, 'FB = ' + str('%.1f' % (mfb)) + '%', fontsize = 6)

        if j != 0:
            plt.yticks([])

        # if i != 3:
        #     plt.xticks([])
    
    # if i == 0:
    #     plt.legend(re_sca, emi_name, frameon = False, fontsize = 6, loc = 'lower right')

fig.text(0.03, 0.25, 'GEOS-Chem emission (10$^{-11}$ Kg m$^{-2}$ s$^{-1}$)', rotation = 90)
# fig.text(0.04, 0.3, '(10$^{-11}$ Kg m$^{-2}$ s$^{-1}$)', rotation = 90)
fig.text(0.35, 0.08, 'Optimized emission (10$^{-11}$ Kg m$^{-2}$ s$^{-1}$)')

plt.subplots_adjust(left = 0.1, right = 0.97, wspace = 0.1, bottom = 0.16, hspace = 0.27)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\scatter_emission_of_IASI&GEOS-Chem.png', format = 'png', bbox_inches = 'tight')

plt.show()



## test
# for i in range(len(emi_name)):

#     opt_emii = adj_emi[i]
#     geo_emii = geo_emi[i]

#     for j in range(len(res)):
        
#         re = res[j]
#         print(emi_name[i] + ', ' + res_name[j] + ':')
#         optij = opt_emii[re[0]:re[2], re[1]:re[3], :]
#         geoij = geo_emii[re[0]:re[2], re[1]:re[3], :]

#         optij = np.reshape(optij, [optij.size, 1])
#         geoij = np.reshape(geoij, [geoij.size, 1])

#         geoij[np.isnan(optij)] == np.nan
#         optij[np.isnan(geoij)] == np.nan

#         print(np.nanmean((optij - geoij)))
#         print(np.nanmean((optij + geoij))/2)
#         print(np.nanmean((optij - geoij))/np.nanmean((optij + geoij))/2*100)