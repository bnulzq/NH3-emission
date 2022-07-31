'''draw mean NH3 fertilizer and manure emissions from FAOSTAT over different regions''' 
import numpy as np
import netCDF4 as nc
import pandas as pd
from statsmodels.formula.api import ols
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':10}
rcParams.update(params)

path = 'D:\\data\\FAO\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1

ef_syn = 0.1256 # Ma, 2014
ef_man = 0.17 # Riddick, 2016
mul1 = 1E-6
mul2 = 1E-9
# regional extent (grid index: bottom, left, top, right)
res_name = ['USA', 'SA', 'EU', 'CA', 'IP', 'PP', 'CHN']
us = 'USA' # north America
sa = [13, 20, 23, 30] # south America
eu = [31, 34, 38, 43] # Europe
ca = [20, 33, 28, 47] # central Africa
ip = [25, 49, 32, 55] # India Peninsula
pp = [32, 49, 35, 54] # Pamir Plateau
ec = 'CHN' # eastern China
res = [us, sa, eu, ca, ip, pp, ec]

# import data
## land
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
land = np.reshape(np.repeat(map_land, yr_len), [46, 72, yr_len]) 

## synthetic N 
data = nc.Dataset(path + 'N fertilizer use\\N_Agricultural_Use_' + str(yr_sta) + '-'+ str(yr_end) + '.nc')['N_Agricultural_Use'][:] # t
data_fer = data * land * mul1
data_fer[data_fer == 0] = np.NaN

data_coun_fer = pd.read_csv(path + 'N fertilizer use\\FAOSTAT_data_4-16-2021.csv')

## manure N
data = nc.Dataset(path + 'N manure\\N_manure_' + str(yr_sta) + '-'+ str(yr_end) + '.nc')['N_manure'][:] # kg
data_man = data * land * mul2
data_man[data_man == 0] = np.NaN

data_coun_man = pd.read_csv(path + 'N manure\\FAOSTAT_data_5-8-2021.csv')

fer, man = [], []
# regional 
for i in range(len(res)):

    re = res[i]

    if re == 'USA':

        fer.append((data_coun_fer[(data_coun_fer['Area Code'] == 'USA') & (data_coun_fer.Element == 'Agricultural Use')].Value*mul1).mean()*ef_syn)
        man.append((data_coun_man[(data_coun_man['Area Code'] == 'USA')].groupby('Year').agg({'Value':'sum'}).Value*mul2).mean()*ef_man)

    elif re == 'CHN':

        fer.append((data_coun_fer[(data_coun_fer['Area Code'] == 'CHN') & (data_coun_fer.Element == 'Agricultural Use')].Value*mul1).mean()*ef_syn)
        man.append((data_coun_man[(data_coun_man['Area Code'] == 'CHN')].groupby('Year').agg({'Value':'sum'}).Value*mul2).mean()*ef_man)

    else:

        fer.append((np.nansum(np.nansum(data_fer[re[0]:re[2], re[1]:re[3], :], 1), 0)).mean()*ef_syn)
        man.append((np.nansum(np.nansum(data_man[re[0]:re[2], re[1]:re[3], :], 1), 0)).mean()*ef_man)

# draw
width = 0.4
ind = np.arange(len(res))
fig = plt.figure(1, (5, 3), dpi = 250) 

ax = plt.subplot(1, 1, 1)
ax.bar(ind, fer, width, color = 'darkslateblue', label = 'Fertilizer, Total = ' + str('%.2f' % (sum(fer))))
ax.bar(ind+width, man, width, color = 'darkorange', label = 'Manure, Total = ' + str('%.2f' % (sum(man))))

plt.xticks(ind+width/2, res_name)
ax.legend(frameon = False)
fig.text(0.04, 0.25, 'Emissions (Tg annual)', rotation = 90)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\bar_FAO_emi_fertilizer&manure.svg', format = 'svg', bbox_inches = 'tight')

plt.show()