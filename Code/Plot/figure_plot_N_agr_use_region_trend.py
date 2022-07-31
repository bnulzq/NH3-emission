'''draw agriculture N use change (trend) over different region''' 
import numpy as np
import netCDF4 as nc
import pandas as pd
from statsmodels.formula.api import ols
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':10}
rcParams.update(params)

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

path = 'D:\\data\\FAO\\N fertilizer use\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1

mul = 1E-6
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

## N 
data = nc.Dataset(path + 'N_Agricultural_Use_' + str(yr_sta) + '-'+ str(yr_end) + '.nc')['N_Agricultural_Use'][:] # t
data = data * land * mul
data[data == 0] = np.NaN

data_coun = pd.read_csv(path + 'FAOSTAT_data_4-16-2021.csv')

# draw
x = np.arange(yr_sta, yr_end +1)
max = 32
ymin2, ymax2 = 0, 3
fig = plt.figure(1, (7, 4), dpi = 250)
col_num = 4
ax = plt.subplot(1, 1, 1)
ax.set_xlim([yr_sta-0.5, yr_end+0.5])
ax.set_ylim([0, max])
co = ['r', 'b', 'orange', 'gray', 'g', 'c', 'y']

for i in range(len(res_name)):
    
    re = res[i]

    if re == 'USA':
        ni = data_coun[(data_coun['Area Code'] == 'USA') & (data_coun.Element == 'Agricultural Use')].Value*mul
    elif re == 'CHN':
        ni = data_coun[(data_coun['Area Code'] == 'CHN') & (data_coun.Element == 'Agricultural Use')].Value*mul
    else:
        ni = np.nansum(np.nansum(data[re[0]:re[2], re[1]:re[3], :], 1), 0)

    tre, p = TrendP(ni, x)

    a = ax.plot(x, ni, color = co[i])

    ax.text(yr_sta+i*1.5, max*0.8, res_name[i] + ': ' + str('%.2f' % (tre)) + p, color = co[i])
    ax.set_xticks(x)

ax.set_title('Fertilizer')   
fig.text(0.06, 0.3, 'Agricultural Use (Mt annual)', rotation = 90)
plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\plot_annual_N_agriculture_use.svg', format = 'svg', bbox_inches = 'tight')

plt.show()