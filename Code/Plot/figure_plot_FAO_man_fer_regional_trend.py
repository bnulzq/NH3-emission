'''draw NH3 fertilizer and manure emissions trends from FAOSTAT over different regions''' 
import numpy as np
import netCDF4 as nc
import pandas as pd
from statsmodels.formula.api import ols
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Arial', 'font.weight':'normal', 'font.size':10}
rcParams.update(params)
  
# trend and p value
def TrendP(x, y):

    data = pd.DataFrame({'x':x, 'y':y})
    model = ols('y~x', data).fit()
    slo = model.params[1]
    inter = model.params[0]
    p = model.pvalues[1]
    # print(p)
    if p < 0.01:
        pp = '**'
    elif p < 0.05:
        pp = '*'
    else:
        pp = ''

    return inter, slo, pp

path = 'E:\\AEE\\data\\FAO\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1

ef_syn = 0.13 # Ma, 2014
ef_man = 0.17 # Riddick, 2016
mul1 = 1E-6
mul2 = 1E-9

# regional extent (grid index: bottom, left, top, right)
res_name = ['US', 'SA', 'EU', 'TA', 'IP', 'CA', 'China']
us = 'USA' # America
sa = [13, 20, 23, 30] # south America
eu = [31, 34, 38, 43] # Europe
ta = [19, 32, 28, 49] # tropical Africa
ip = [25, 49, 32, 55] # India Peninsula
pp = [32, 49, 35, 54] # Pamir Plateau
ec = 'CHN' # China
res = [us, sa, eu, ta, ip, pp, ec]

# import data
## land
map = nc.Dataset('E:\\AEE\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
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

        fer.append((data_coun_fer[(data_coun_fer['Area Code'] == 'USA') & (data_coun_fer.Element == 'Agricultural Use')].Value*mul1)*ef_syn)
        man.append((data_coun_man[(data_coun_man['Area Code'] == 'USA')].groupby('Year').agg({'Value':'sum'}).Value*mul2)*ef_man)

    elif re == 'CHN':

        fer.append((data_coun_fer[(data_coun_fer['Area Code'] == 'CHN') & (data_coun_fer.Element == 'Agricultural Use')].Value*mul1)*ef_syn)
        man.append((data_coun_man[(data_coun_man['Area Code'] == 'CHN')].groupby('Year').agg({'Value':'sum'}).Value*mul2)*ef_man)

    else:

        fer.append((np.nansum(np.nansum(data_fer[re[0]:re[2], re[1]:re[3], :], 1), 0))*ef_syn)
        man.append((np.nansum(np.nansum(data_man[re[0]:re[2], re[1]:re[3], :], 1), 0))*ef_man)

# draw 
x = np.arange(yr_sta, yr_end +1)
ymaxs = [2, 4, 2.5, 6, 3.5, 1, 5]
ymins = [1, 0, 1, 0, 2.5, 0, 2]
fig = plt.figure(1, (8, 3), dpi = 250)
col_num = 4
for i in range(len(res_name)):

    ax = plt.subplot(2, col_num, i+1)
    ax.set_xlim([yr_sta-0.5, yr_end+0.5])
    ymax, ymin = ymaxs[i], ymins[i]
    
    re = res[i]

    # text region name
    ax.text(yr_sta, (ymax-ymin)*0.87+ymin, res_name[i])

    fer_inter, fer_tre, fer_p = TrendP(x, fer[i])
    man_inter, man_tre, man_p = TrendP(x, man[i])

    f = ax.plot(x, fer[i], color = 'dodgerblue')
    m = ax.plot(x, man[i], color = 'brown')
    f_t = ax.plot(x, x*fer_tre + fer_inter, color = 'dodgerblue', linestyle = 'dashed', linewidth = 1)
    m_t = ax.plot(x, x*man_tre + man_inter, color = 'brown', linestyle = 'dashed', linewidth = 1)

    # set ticks
    if ymax - ymin <= 1.5:
        ax.set_yticks(np.arange(ymin, ymax+0.5,0.5))
        ax.set_yticklabels(np.arange(ymin, ymax+.5,.5), fontsize = 8)
    elif ymax - ymin <= 3:
        ax.set_yticks(np.arange(ymin, ymax+1,1))
        ax.set_yticklabels(np.arange(ymin, ymax+1,1), fontsize = 8)
    else:
        ax.set_yticks(np.arange(ymin, ymax+1,2))
        ax.set_yticklabels(np.arange(ymin, ymax+1,2), fontsize = 8)

    if i < 3:
        ax.set_xticks([])
    else:
        ax.set_xticks(np.arange(yr_sta, yr_end+1, 2))
        ax.set_xticklabels(np.arange(yr_sta, yr_end+1, 2), fontsize = 8)

    x0 = yr_sta
    d = 0.9
    ax.text(x0+5, (ymax-ymin)*d+ymin, 'Trend', fontsize = 6)
    ax.text(x0+7, (ymax-ymin)*d+ymin, 'Mean', fontsize = 6)
    # ax.text(x0+7, (ymax-ymin)*d+ymin, r'$\frac{Trend}{Mean}$', fontsize = 6)
    ax.text(x0+2, (ymax-ymin)*(d-d/9)+ymin, 'Fertilizer', fontsize = 6, color = 'dodgerblue')
    ax.text(x0+2, (ymax-ymin)*(d-d/5)+ymin, 'Manure', fontsize = 6, color = 'brown')
    ax.text(x0+5, (ymax-ymin)*(d-d/9)+ymin, str('%.2f' % (fer_tre*10)) + fer_p, color = 'dodgerblue', fontsize = 6)
    ax.text(x0+5, (ymax-ymin)*(d-d/5)+ymin, str('%.2f' % (man_tre*10)) + man_p, color = 'brown', fontsize = 6)
    ax.text(x0+7, (ymax-ymin)*(d-d/9)+ymin, str('%.2f' % (fer[i].mean())), color = 'dodgerblue', fontsize = 6)
    ax.text(x0+7, (ymax-ymin)*(d-d/5)+ymin, str('%.2f' % (man[i].mean())), color = 'brown', fontsize = 6)
    # ax.text(x0+7, (ymax-ymin)*(d-d/9)+ymin, str('%.1f' % (fer_tre/fer[i].mean()*1000) + '%'), color = 'dodgerblue', fontsize = 6)
    # ax.text(x0+7, (ymax-ymin)*(d-d/5)+ymin, str('%.1f' % (man_tre/man[i].mean()*1000) + '%'), color = 'brown', fontsize = 6)

    if i == len(res_name) -1:
        plt.legend((f[0], m[0]), 
        ('Fertilizer input', 'Manure amount'), 
        frameon = False, loc = (1.1, 0.3))
    ax.set_ylim([ymin, ymax])

fig.text(0.01, 0.6, 'Emissions (Tg a$^{-1}$)', rotation = 90)
fig.text(0.51, 0.03, 'Year')
plt.subplots_adjust(left = 0.07, right = 0.99, wspace =0.18, hspace = 0.1, bottom = 0.15)
plt.savefig(fname = 'E:\\AEE\\Pap\\ACP\\figure\\fig4.png', format = 'png', bbox_inches = 'tight')

plt.show()
