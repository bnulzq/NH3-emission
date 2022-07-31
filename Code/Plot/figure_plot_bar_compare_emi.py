'''draw comparison of optimized NH3 emissions with other results'''
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Arial', 'font.weight':'normal', 'font.size':8}
rcParams.update(params)

path = 'E:\\AEE\\data\\'

yr_sta = 2008
yr_end = 2018
period = '2008-2016'

# import data
data = pd.read_excel(path + 'global emission.xlsx')
data.index = data.Tg
sta_i = data.columns.tolist().index(yr_sta) 
end_i = data.columns.tolist().index(yr_end)

opt = data.loc['Our study']
opt_u = data.loc['Our study top']
opt_b = data.loc['Our study bottom']
td1 = data.loc['Evangeliou 2021'] # 2016-2017
td2 = data.loc['Van Damme 2018'] # mean: 2008-2016
bu1 = data.loc['GEOS-Chem prior'] 
bu2 = data.loc['BUE2'] # 2008-2015
t12 = data.loc['t=12h'] # lifetime is 12h

ymin = 40
ymax = 185
# draw
x = np.arange(yr_sta, yr_end +1)
fig = plt.figure(1, (4, 2), dpi = 250)

ax = plt.subplot(1, 1, 1)
ax.set_xlim([yr_sta-0.5, yr_end+4.5])
ax.set_ylim([ymin, ymax])
o = ax.plot(x, opt.iloc[sta_i:end_i +1], marker = 'D', color = 'r', linewidth = 1, markersize = 3, label = ' ')
ora = ax.fill_between(x, opt_b.iloc[sta_i:end_i +1].tolist(), opt_u.iloc[sta_i:end_i +1].tolist(), color = 'skyblue', alpha = 0.9, label = 'Optimized range')
# e_niko = ax.plot(x, td1.iloc[sta_i:end_i +1], marker = 'v', color = 'b', linewidth = 1, markersize = 3, label = ' ')
e12 = ax.plot(x, t12.iloc[sta_i:end_i +1], marker = '^', color = 'y', linewidth = 1, markersize = 3, label = ' ')
p = ax.plot(x, bu1.iloc[sta_i:end_i +1], marker = 's', color = 'g', linewidth = 1, markersize = 3, label = ' ')
err = [[-opt_b.loc[period]+opt.loc[period]], [opt_u.loc[period]-opt.loc[period]]]
om = ax.bar(yr_end +1, opt.loc[period], 0.6, yerr = err, ecolor = 'skyblue', capsize = 2, color = 'r', label = 'Optimized')
em = ax.bar(yr_end +2, t12.loc[period], 0.6, color = 'y', label = 't = 12h')
Evm = ax.bar(yr_end +4, td1.loc[period], 0.6, color = 'm', label = 'Niko')
# Evm_p = ax.plot(x, td1.iloc[sta_i:end_i +1], marker = 'v', color = 'm', linewidth = 1, markersize = 3, label = 'Niko')
pm = ax.bar(yr_end +3, bu1.loc[period], 0.6, color = 'g', label = 'Prior')

ge = ax.plot(x, bu2.iloc[sta_i:end_i +1], marker = 'o', color = 'b', linewidth = 1, markersize = 3, label = 'GFAS+EDGARv5.0+Natural')

# vm = ax.bar(yr_end +4, td2.loc[period], 0.6, color = 'm', label = 'Van Damme 2018')
ax.vlines(2018.5, 0, 300, linestyle = 'dashed', linewidth = 1)
ax.set_xticks([2008, 2010, 2012, 2014, 2016, 2018, 2020.5])
ax.set_xticklabels([2008, 2010, 2012, 2014, 2016, 2018, '2008-2016'])
ax.set_ylabel('Emissions (Tg a$^{-1}$)')
# ax.set_xlabel('Year')
ax.set_title('Global NH$_3$ emissions')
plt.legend((o[0], e12[0], p[0], om[0], em[0], pm[0], ge[0], Evm[0], ora), 
    (' ', ' ', ' ', 'TDE (this study)', 'Fixed 12h', 'BUE1',  'BUE2', 'Evangeliou, 2021',
     'Emission range'), 
    frameon = False, fontsize = 8, ncol = 3, loc = (0.0, -0.65))
plt.subplots_adjust(bottom = 0.35)
plt.savefig(fname = r'E:\AEE\Pap\ACP\figure\fig5.png', format = 'png', bbox_inches = 'tight')

plt.show()



