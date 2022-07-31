'''draw GEOS-Chem NH3 emissions sectors change (trend) over different region''' 
import numpy as np
import netCDF4 as nc
import mat73 as m73
import scipy.io as scio
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'light', 'font.size':10}
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

path = 'E:\\AEE\\data\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
thre_n = 800
thre_r = 1
mul = 3600 * 24 * 365/12 * 1E-9 # Tg/month/m2

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
land = np.reshape(np.repeat(map_land, yr_len*12), [46, 72, yr_len, 12]) 

## area
area = nc.Dataset(path + 'GEOS-Chem\\OutputDir2008\\\GEOSChem.Budget.20080101_0000z.nc4')['AREA'][:] # m-2
area = np.reshape(np.repeat(area, yr_len*12), [46, 72, yr_len, 12]) 

## geos-chem emission
data = m73.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Total_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_tot = Monthly(data, mul, land) * area

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Anthro_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_anth = Monthly(data, mul, land) * area

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.BioBurn_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_bb = Monthly(data, mul, land) * area

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Natural_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_nat = Monthly(data, mul, land) * area

geo_emi_oth = (geo_emi_tot - geo_emi_anth - geo_emi_bb - geo_emi_nat)

## geos-chem emission fraction
geo_r_anth = geo_emi_anth/geo_emi_tot *100
geo_r_bb = geo_emi_bb/geo_emi_tot *100
geo_r_nat = geo_emi_nat/geo_emi_tot *100
geo_r_oth = (geo_emi_oth)/geo_emi_tot *100

# draw
un = np.zeros([4, yr_len], 'double')
t = []
x = np.arange(yr_sta, yr_end +1)
max = 100
ymin, ymax = 0, 3
fig = plt.figure(1, (8, 3), dpi = 250)
col_num = 4
for i in range(len(res_name)):

    ax = plt.subplot(2, col_num, i+1)
    ax.set_xlim([yr_sta-0.5, yr_end+0.5])
    ax.set_ylim([0, max])
    re = res[i]

    # text region name
    ax.text(yr_sta, max*0.9, res_name[i], color = 'white')

    anthi = np.nanmean(np.nanmean(np.nanmean(geo_r_anth[re[0]:re[2], re[1]:re[3], :], 3), 1), 0)
    bbi = np.nanmean(np.nanmean(np.nanmean(geo_r_bb[re[0]:re[2], re[1]:re[3], :], 3), 1), 0)
    nati = np.nanmean(np.nanmean(np.nanmean(geo_r_nat[re[0]:re[2], re[1]:re[3], :], 3), 1), 0)
    othi = np.nanmean(np.nanmean(np.nanmean(geo_r_oth[re[0]:re[2], re[1]:re[3], :], 3), 1), 0)

    emi_by_sec = {
        'Biomass burning': bbi,
        'Natural': nati,
        'Anthropogenic': anthi
    }

    ax.stackplot(x, emi_by_sec.values(),
             labels=emi_by_sec.keys(), colors =  ('orange', 'gray', 'b'))

    # set ticks
    if i != 0 and i != col_num:
        ax.set_yticks([])
    if i < 3:
        ax.set_xticks([])
    else:
        ax.set_xticks(np.arange(yr_sta, yr_end+1, 2))
        ax.set_xticklabels(np.arange(yr_sta, yr_end+1, 2), fontsize = 8, weight = 'normal')

    if i == len(res_name) -1:
        ax.legend(frameon = False, fontsize = 6, loc = (1.1, 0.2))

fig.text(0.01, 0.7, 'Sector proportion (%)', rotation = 90)
fig.text(0.51, 0.03, 'Year')   
plt.subplots_adjust(left = 0.07, right = 0.99, wspace =0.05, hspace = 0.1, bottom = 0.15)
plt.savefig(fname = 'E:\\AEE\\Pap\\Results\\figure\\figS5.png', format = 'png', bbox_inches = 'tight')

plt.show()
