'''draw mean seasonal NH3 emissions from GEOS-Chem and adjusted over different region''' 

import numpy as np
import netCDF4 as nc
import scipy.io as scio
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
seas = ['JFM', 'AMJ', 'JAS', 'OND']
thre_n = 30
thre_r = 1
mul = 1E-3 * 3600 * 24 * 365/4 * 1E-6

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

# data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\HEMCO_diagnostics_NH3.Natural_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
# geo_emi_nat = Monthly(data, mul, land)
# geo_emi_nat = Overlap(geo_emi_nat, iasi_emi)

# emission category ratio
anth_r = geo_emi_anth/geo_emi_tot
bb_r = geo_emi_bb/geo_emi_tot
geo_emi_oth = geo_emi_tot - geo_emi_anth - geo_emi_bb
oth_r = (geo_emi_oth)/geo_emi_tot
# nat_r = geo_emi_nat/geo_emi_tot

# emissions category
adj_emi_anth = anth_r * adj_emi
adj_emi_bb = bb_r * adj_emi
adj_emi_oth = oth_r * adj_emi

adj_tot, adj_anth, adj_bb, adj_oth = np.zeros([4, len(res)]), np.zeros([4, len(res)]), np.zeros([4, len(res)]), np.zeros([4, len(res)])
geo_tot, geo_anth, geo_bb, geo_oth = np.zeros([4, len(res)]), np.zeros([4, len(res)]), np.zeros([4, len(res)]), np.zeros([4, len(res)])
for i in range(4):

    sea = seas[i]
    print('Import season: ' + sea)

    geo_toti = np.nanmean(np.nanmean(geo_emi_tot[:, :, :, i*3:(i+1)*3], 3), 2) * area
    geo_anthi = np.nanmean(np.nanmean(geo_emi_anth[:, :, :, i*3:(i+1)*3], 3), 2) * area
    geo_bbi = np.nanmean(np.nanmean(geo_emi_bb[:, :, :, i*3:(i+1)*3], 3), 2) * area
    geo_othi = np.nanmean(np.nanmean(geo_emi_oth[:, :, :, i*3:(i+1)*3], 3), 2) * area

    adj_toti = np.nanmean(np.nanmean(adj_emi[:, :, :, i*3:(i+1)*3], 3), 2) * area
    adj_anthi = np.nanmean(np.nanmean(adj_emi_anth[:, :, :, i*3:(i+1)*3], 3), 2) * area
    adj_bbi = np.nanmean(np.nanmean(adj_emi_bb[:, :, :, i*3:(i+1)*3], 3), 2) * area
    adj_othi = np.nanmean(np.nanmean(adj_emi_oth[:, :, :, i*3:(i+1)*3], 3), 2) * area

    for j in range(len(res)):

        re = res[j]

        adj_tot[i, j] = (np.nansum(np.nansum(adj_toti[re[0]:re[2], re[1]:re[3]])))
        geo_tot[i, j] = (np.nansum(np.nansum(geo_toti[re[0]:re[2], re[1]:re[3]])))

        adj_anth[i, j] = np.nansum(np.nansum(adj_anthi[re[0]:re[2], re[1]:re[3]]))
        geo_anth[i, j] = np.nansum(np.nansum(geo_anthi[re[0]:re[2], re[1]:re[3]]))

        adj_bb[i, j] = np.nansum(np.nansum(adj_bbi[re[0]:re[2], re[1]:re[3]]))
        geo_bb[i, j] = np.nansum(np.nansum(geo_bbi[re[0]:re[2], re[1]:re[3]]))

        adj_oth[i, j] = np.nansum(np.nansum(adj_othi[re[0]:re[2], re[1]:re[3]]))
        geo_oth[i, j] = np.nansum(np.nansum(geo_othi[re[0]:re[2], re[1]:re[3]]))

# draw
ymax = 4.5
width = 0.4
ind = np.arange(len(res))
fig = plt.figure(1, (5, 5), dpi = 250) 
for i in range(4):

    ax = plt.subplot(2, 2, i+1)
    ax.set_title(seas[i])
    ax.set_ylim([0, ymax])

    anth_oth_g = ax.bar(ind, geo_anth[i], width, color = 'darkorange')
    anth_oth_a = ax.bar(ind+width, adj_anth[i], width, color = 'tan')

    bb_g = ax.bar(ind, geo_bb[i], width, color = 'seagreen', bottom = geo_anth[i])
    bb_a = ax.bar(ind+width, adj_bb[i], width, color = 'darkseagreen', bottom = adj_anth[i])

    nat_g = ax.bar(ind, geo_oth[i], width, bottom = geo_anth[i] + geo_bb[i], color = 'dodgerblue')
    nat_a = ax.bar(ind+width, adj_oth[i], width, bottom = adj_bb[i] + adj_anth[i], color = 'lightblue')

    plt.xticks(ind+width/2, res_name)
    # plt.yticks(np.arange(0, 81, 10))

    if i == 0:
        plt.legend((anth_oth_g[0], bb_g[0], nat_g[0]),
        ('Anthropogenic (Mod)', 'Biomass burning (Mod)', 'Others (Mod)'),
        frameon = False, ncol = 1, fontsize = 6, loc = 'upper left')

    if i == 1:

        plt.legend((anth_oth_a[0], bb_a[0], nat_a[0]),
        ('Anthropogenic (Opt)', 'Biomass burning (Opt)', 'Others (Opt)'),
        frameon = False, ncol = 1, fontsize = 6, loc = 'upper left')

    ax.set_title(seas[i])

plt.subplots_adjust(wspace = 0.15, hspace =0.35)
fig.text(0.03, 0.4, 'Emissions (Mt per season)', rotation = 90)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\bar_emission_of_IASI&GEOS-Chem.svg', format = 'svg', bbox_inches = 'tight')
plt.show()


# draw annual 
adj_tot = np.sum(adj_tot, 0)
geo_tot = np.sum(geo_tot, 0)

width = 0.4
ind = np.arange(len(res))
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':15}
rcParams.update(params)

# draw whole year
fig = plt.figure(1, (5, 5), dpi = 250) 
ax = plt.subplot(1, 1, 1)
# ax.set_ylim([0, ymax])

g = ax.bar(ind, geo_tot, width, color = 'g')
a = ax.bar(ind+width, adj_tot, width, color = 'r')

plt.xticks(ind+width/2, res_name)
# plt.yticks(np.arange(0, 81, 10))
plt.legend((a[0], g[0]),('Optimized', 'GEOS-Chem'), frameon = False, ncol = 1)
plt.subplots_adjust(left = 0.16, wspace = 0.15, hspace =0.35)
fig.text(0.02, 0.3, 'Emissions (Mt annual)', rotation = 90)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\bar_emission_opt&geos-chem.svg', format = 'svg', bbox_inches = 'tight')

plt.show()



# import matplotlib.pyplot as plt
# # re = ca
# # # plt.figure(1)
# # # plt.imshow(np.flipud(map_land[re[0]:re[2], re[1]:re[3]]),cmap='Greys', alpha=0.5)
# plt.figure(2)
# plt.imshow(np.flipud(anth_oth_r[:,:,2,11]),cmap='Oranges')
# plt.show()