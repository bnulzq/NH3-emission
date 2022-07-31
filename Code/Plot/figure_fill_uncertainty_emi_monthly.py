'''draw monthly timeseries of NH3 emissions uncertainty over different region''' 

import numpy as np
import scipy.io as scio
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':10}
rcParams.update(params)

path = 'E:\\AEE\\data\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
thre_n = 800
thre_r = 1
life = [50, 200]
ratio = [0.2, 5]
num = [400, 1200]

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

mul1 = 1E-9

# import data 
data_iasi = scio.loadmat(path + 'Uncertainty_IASI_emi_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
data_iasi = data_iasi[list(data_iasi.keys())[-1]] * mul1

emi = scio.loadmat(path + 'uncertainty_lifetime_100%_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
emi = emi[list(emi.keys())[-1]] * mul1

data_life_bo = scio.loadmat(path + 'uncertainty_lifetime_' + str(life[1]) + '%_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
data_life_bo = data_life_bo[list(data_life_bo.keys())[-1]] * mul1

data_life_up = scio.loadmat(path + 'uncertainty_lifetime_' + str(life[0]) + '%_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
data_life_up = data_life_up[list(data_life_up.keys())[-1]] * mul1

# data_r_up = scio.loadmat(path + 'uncertainty_trans_r_' + str(ratio[0]) + '_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
# data_r_up = data_r_up[list(data_r_up.keys())[-1]] * mul1

# data_r_bo = scio.loadmat(path + 'uncertainty_trans_r_' + str(ratio[1]) + '_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
# data_r_bo = data_r_bo[list(data_r_bo.keys())[-1]] * mul1

# data_n_up = scio.loadmat(path + 'uncertainty_number_n_' + str(num[1]) + '_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
# data_n_up = data_n_up[list(data_n_up.keys())[-1]] * mul1

# data_n_bo = scio.loadmat(path + 'uncertainty_number_n_' + str(num[0]) + '_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
# data_n_bo = data_n_bo[list(data_n_bo.keys())[-1]] * mul1

# draw
x = np.arange(12*yr_len)
ymax = 3.9
fig = plt.figure(1, (10, 5), dpi = 250) 
for r in range(len(res)):

    re = res[r]
    ei = np.nansum(np.nansum(emi[re[0]:re[2], re[1]:re[3], :], 1), 0)

    ia_u = np.nansum(np.nansum(data_iasi[re[0]:re[2], re[1]:re[3], :]**2, 1), 0)**0.5 + ei
    ia_b = -np.nansum(np.nansum(data_iasi[re[0]:re[2], re[1]:re[3], :]**2, 1), 0)**0.5 + ei

    li_u = np.nansum(np.nansum(data_life_up[re[0]:re[2], re[1]:re[3], :], 1), 0)
    li_b = np.nansum(np.nansum(data_life_bo[re[0]:re[2], re[1]:re[3], :], 1), 0)

    # r_u = np.nansum(np.nansum(data_r_up[re[0]:re[2], re[1]:re[3], :], 1), 0)
    # r_b = np.nansum(np.nansum(data_r_bo[re[0]:re[2], re[1]:re[3], :], 1), 0)

    # n_u = np.nansum(np.nansum(data_n_up[re[0]:re[2], re[1]:re[3], :], 1), 0)
    # n_b = np.nansum(np.nansum(data_n_bo[re[0]:re[2], re[1]:re[3], :], 1), 0)

    ax = plt.subplot(len(res), 1, r+1)
    ax.text(1, ymax*0.7, res_name[r])
    ax.set_xlim([0, 12*yr_len])
    ax.set_ylim([0, ymax])

    ax.plot(x, ei, color = 'r')
    i = ax.fill_between(x, ia_u, ia_b, color = 'orange', alpha = 0.2, label = 'IASI')
    # tr = ax.fill_between(x, r_u, r_b, color = 'skyblue', alpha = 0.2, label = 'Ratio')
    l = ax.fill_between(x, li_u, li_b, color = 'gray', alpha = 0.2, label = 'Lifetime')
    # n = ax.fill_between(x, n_u, n_b, color = 'seagreen', alpha = 0.2, label = 'Number')

    if r == 0:

        ax.legend(frameon = False, fontsize = 9, ncol = 4)
        ax.set_title('Uncertainty: ' + 'Lifetime = ' + str(life[0]) + '-' + str(life[1]) + '%; Number = ' 
            + str(num[0]) + '-' + str(num[1]) + '; Tran/Emi = ' + str(ratio[0]) + '-' + str(ratio[1]))

    if r == len(res) -1:
        plt.xticks(np.arange(yr_len)*12, [])
    else:
        plt.xticks([])


fig.text(0.06, 0.3, 'Emissions (Mt per month)', rotation = 90)
for j in range(yr_sta, yr_end+1):
    fig.text((j-yr_sta)*0.07+0.15, 0.07, str(j))
plt.subplots_adjust(top = 0.94, hspace =0.0)

# plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\IASI_emission_uncertainty.svg', format = 'svg', bbox_inches = 'tight')
plt.show()