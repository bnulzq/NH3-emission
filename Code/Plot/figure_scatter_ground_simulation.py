'''draw comparison of ground-based NH3 measurements with GEOS-Chem simulation (validation)
With the Mann-Whitney U test
'''   
import pandas as pd
import numpy as np
from scipy.stats import mannwhitneyu
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Arial', 'font.weight':'light', 'font.size':10}
rcParams.update(params)


# get statitical information
def Statis(x, y):
    # fits = np.polyfit(x, y, 1)
    num = len(x)
    r = np.corrcoef(x, y)[0, 1]
    r2 = r**2
    rmse = np.sqrt(np.mean((x - y) ** 2))
    mfb = 2 * np.sum(y-x) /np.sum(x+y) 
    xy10 = sum(x/y > 10)/len(x)*100
    yx10 = sum(y/x > 10)/len(x)*100
    stat, p = mannwhitneyu(x, y)
    print(p)
    # interpret
    alpha = 0.05
    if p > 0.05:
        t = ''
    else:
        if p < 0.01:
            t = '**'
        else:
            t = '*'
    # print(f'N: {num}')
    # print(f'R2: {r2:.2f}')
    # print(f'RMSE: {rmse:.2f}')
    # print(f'MFB: {mfb:.2f}')
    return num, rmse, mfb, t


path = 'E:\\AEE\\data\\'
data = pd.read_csv(f'{path}GEOS-Chem\\validation2\\Monthly_surface.csv')
# data = pd.read_csv(f'{path}GEOS-Chem\\validation2\\Monthly_surface.csv')

n, rmse1, mfb1, t = Statis(data.NH3, data.NH3_pri)
n, rmse2, mfb2, t = Statis(data.NH3, data.NH3_pos)


min = 10**-4
max = 10**2
max2 = 30
x = np.arange(min, max, min)
# draw annual
# fig = plt.figure(1, (6, 3), dpi = 250)
# ax1 = plt.subplot(1, 2, 1)
# ax2 = plt.subplot(1, 2, 2)

# ax1.set_xlim(min, max)
# ax1.set_ylim(min, max)

# ax2.set_xlim(0, max2)
# ax2.set_ylim(0, max2)

# ax1.plot(x, x, color = 'gray', linewidth = 1)
# data.plot.scatter(x = 'NH3', y = 'NH3_pri', s = 0.1,  ax = ax1, color = 'g', label = 'BUE1')
# data.plot.scatter(x = 'NH3', y = 'NH3_pos', s = 0.1,  ax = ax1, color = 'r', label = 'TDE')

# ax1.set_yscale('log')
# ax1.set_xscale('log')

# ax2.plot(x, x, color = 'gray', linewidth = 1)
# data.plot.scatter(x = 'NH3', y = 'NH3_pri', s = 0.1,  ax = ax2, color = 'g', label = 'BUE1')
# data.plot.scatter(x = 'NH3', y = 'NH3_pos', s = 0.1,  ax = ax2, color = 'r', label = 'TDE')

# ax1.set_ylabel('Simulated NH$_3$ (ppb)')
# ax1.set_xlabel('Measured NH$_3$ (ppb)')

# ax1.get_legend().remove()
# ax2.get_legend().remove()

# ax1.text(min, max*0.4, 'BUE1', color = 'g')
# ax1.text(min, max*0.15, f'RMSE = {rmse1:.2f}', color = 'g')
# ax1.text(min, max*0.05, f'FB = {mfb1:.2f}', color = 'g')

# ax1.text(min, max*0.015, 'TDE', color = 'r')
# ax1.text(min, max*0.005, f'RMSE = {rmse2:.2f}', color = 'r')
# ax1.text(min, max*0.002, f'FB = {mfb2:.2f}', color = 'r')


# ax2.set_ylabel('')
# ax2.set_xlabel('Measured NH$_3$ (ppb)')
# plt.suptitle(f'Comparison with observations (N = {n} grid-month)')
# plt.subplots_adjust(bottom = 0.2)

# plt.show()

# draw seasonal
d1 = 0.00015
sea_name = ['JFM', 'AMJ', 'JAS', 'OND']
fig = plt.figure(1, (6, 6), dpi = 250)
for i in range(2):
    for j in range(2):

        sea = i*2+j+1
        ax = plt.subplot(2, 2, sea)
        seas = np.arange(sea*3 -2, sea*3+1)
        print(seas)

        ax.set_xlim(min, max)
        ax.set_ylim(min, max)
        data_ij = data.loc[data.month.isin(seas)]

        n, rmse1, mfb1, t = Statis(data_ij.NH3, data_ij.NH3_pri)
        n, rmse2, mfb2, t = Statis(data_ij.NH3, data_ij.NH3_pos)
        n1, rmse3, mfb3, t = Statis(data_ij.NH3_pri, data_ij.NH3_pos)

        ax.set_title(f'{sea_name[sea-1]} (N = {n} grid-month)')

        ax.plot(x, x, color = 'gray', linewidth = 1)
        data_ij.plot.scatter(x = 'NH3', y = 'NH3_pri', s = 0.1,  ax = ax, color = 'g', label = 'BUE1')
        data_ij.plot.scatter(x = 'NH3', y = 'NH3_pos', s = 0.1,  ax = ax, color = 'r', label = 'TDE')
        
        ax.text(d1, max*0.35, 'BUE1', color = 'g', fontsize = 6)
        ax.text(d1, max*0.1, f'RMSE = {rmse1:.2f}', color = 'g', fontsize = 6)
        ax.text(d1, max*0.03, f'FB = {mfb1:.2f}', color = 'g', fontsize = 6)

        ax.text(d1, max*0.01, f'TDE{t}', color = 'r', fontsize = 6)
        ax.text(d1, max*0.003, f'RMSE = {rmse2:.2f}', color = 'r', fontsize = 6)
        ax.text(d1, max*0.001, f'FB = {mfb2:.2f}', color = 'r', fontsize = 6)

        ax.set_yscale('log')
        ax.set_xscale('log')

        ax.get_legend().remove()

        if j != 0:

            ax.set_yticks([])
            ax.set_ylabel('')
        else:
            ax.set_ylabel('Simulated NH$_3$ (ppb)')

        if i == 0:

            ax.set_xticks([])
            ax.set_xlabel('')
        else:
            ax.set_xlabel('Measured NH$_3$ (ppb)')

plt.subplots_adjust(bottom = 0.2, top = 0.94)
plt.savefig(fname = 'E:\\AEE\\Pap\\ACP\\figure\\fig8.png', format = 'png', bbox_inches = 'tight')
plt.show()


