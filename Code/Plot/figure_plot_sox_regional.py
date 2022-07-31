'''draw SO2, SO4, SO4s concentration (trend) over EC and IP''' 
import scipy.io as scio
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from statsmodels.formula.api import ols
from matplotlib import rcParams
params={'font.family':'Arial', 'font.weight':'light', 'font.size':8}
rcParams.update(params)

# trend and p value
def TrendP(y, x):

    data = pd.DataFrame({'x':x, 'y':y})
    model = ols('y~x', data).fit()
    slo = model.params
    p = model.pvalues[1]
    # print(p)
    if p < 0.01:
        pp = '**'
    elif p < 0.05:
        pp = '*'
    else:
        pp = ''

    return slo, pp, p

path = 'E:\\AEE\\data\\GEOS-Chem'

yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
mul = 6.02214076E23 * 1E-4 /(2.69E16)

# names = ['$SO_2$', '$SO_4$', '$SO_4s$', 'OMPS $SO_2$']
names = ['$SO_2$', '$SO_4^{2-}$']

# regional extent (grid index: bottom, left, top, right)
res_name = ['IP', 'EC']

ip = [25, 49, 31, 55] # India Peninsula
ec = [30, 56, 35, 62] # eastern China
res = [ip, ec]

# import data
## so2 
data = scio.loadmat(path + '\\SO2_concentration_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
so2 = data[list(data.keys())[-1]] * mul

## so4
data = scio.loadmat(path + '\\SO4_concentration_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
so4 = data[list(data.keys())[-1]] * mul

## so4s
data = scio.loadmat(path + '\\SO4s_concentration_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
so4s = data[list(data.keys())[-1]] * mul

## omps so2
data = scio.loadmat('E:\AEE\data\OMPS\\OMPS_SO2_annually_2012-' + str(yr_end) + '.mat')
so2o = data[list(data.keys())[-1]] * mul

data = [so2, so4, so4s, so2o]
# draw
fig = plt.figure(1, (2.5, 3), dpi = 250)
cos = ['blue', 'lime']
cos1 = ['orange', 'red']
x = np.arange(yr_sta, yr_end +1)
so2_yr = []
x0= 2008
y0 = [.4, .3]
y1 = [.2, .4]
yy = [y0, y1]
d = [2.7, 2.5]
text_size = 6
ax_names = ['(a)', '(b)']
for j in range(len(names)):

    dataj = data[j]

    ax = plt.subplot(2, 1, j+1)

    ax.set_ylim([0.1, 0.6])
    ax.set_title(names[j])

    if j != 2:
        ax.set_ylabel('DU')
    else:
        ax.set_yticks([])

    if j == 0:
        ax.set_xticks([])
    else:

        ax.set_xlabel('Year')
        ax.set_xticks(np.arange(yr_sta, yr_end+1, 2))
        ax.set_xticklabels(np.arange(yr_sta, yr_end+1, 2), weight = 'normal', rotation = 45)
    
    re_plot = []
    res_tre = []
    for i in range(len(res)):
        
        re = res[i]
        
        dataij = np.nanmean(np.nanmean(dataj[re[0]:re[2], re[1]:re[3], :], 1), 0)

        if len(dataij) == yr_len:
            re_plot.append(ax.plot(x, dataij , color = cos[i], label = res_name[i]))
        else:
            ax.plot(x[yr_len - len(dataij):], dataij , color = cos[i], label = res_name[i])

        tre1, p1, pp1 = TrendP(dataij, x)
        tre2, p2, pp2 = TrendP(dataij[4:], x[4:])
        # # print(pp1, pp2)

        # ax.plot(x, tre1[1]*x + tre1[0], color = 'r', linestyle = 'dashed')
        ax.plot(x[4:], tre2[1]*x[4:] + tre2[0], color = cos1[i], linestyle = 'dashed', label = res_name[i] + ' Trend')
        
        ax.text(x0, yy[j][i], res_name[i] + ' Trend = ' +  str('%.1f' % ((tre2[1])/np.mean(dataij[4:])*100))  + ' % a$^{-1}$' + ' (p = ' + str('%.1f' % pp2) + ')',
            fontsize = text_size) 
        # ax.text(x0, y0+d+(i+1)*.15, 'Mean', fontsize = text_size)
        # ax.text(x0+1, y0+d+(i+1)*.15, '2008-2018=' + str('%.2f' % (np.mean(dataij))) + 'DU', color = 'r', fontsize = text_size)
        # ax.text(x0+5, y0+d+(i+1)*.15, '2012-2018=' + str('%.2f' % (np.mean(dataij[4:]))) + 'DU', color = 'orange', fontsize = text_size)

    ax.text(2007.5, 0.5, ax_names[j])

plt.legend(frameon = False, loc = 'best', ncol = 2, fontsize = text_size)

plt.subplots_adjust(hspace = 0.25, left = 0.17, bottom = 0.17)

# plt.savefig(fname = r'C:\Users\bnulzq\Desktop\test\plot_annual_sox_concentration_geos-chem.png', format = 'png', bbox_inches = 'tight')
plt.savefig(fname = 'E:\\AEE\\Pap\\Full\\figure\\figS5.png', format = 'png', bbox_inches = 'tight')

plt.show()
