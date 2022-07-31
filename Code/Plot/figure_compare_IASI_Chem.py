'''draw comparison of seasonal IASI and GEOS-Chem simulated concentrations'''

import scipy.io as scio
import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression as skl
from sklearn.metrics import mean_squared_error as mse
from math import sqrt as ms
import matplotlib.pyplot as plt
from matplotlib.pyplot import MultipleLocator as mpm
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':10}
rcParams.update(params)

# data overlap 
def Overlap(data1, data2, thre):

    ol = (data1 > thre) * (data2 > thre)
    d1 = ol * data1
    d2 = ol * data2
    d1 = d1.reshape([1, d1.size])
    d2 = d2.reshape([1, d2.size])

    # filter 0 and NaN
    d1[d1 == 0] = np.nan
    d2[d2 == 0] = np.nan
    d1 = d1[~pd.isnull(d1)]
    d2 = d2[~pd.isnull(d2)]

    return d1, d2

# get results from LinearRegression: R2, RMSE, slope, intercept
def LR(x, y):
    
    # 2-D array
    x = x[:, np.newaxis]
    y = y[:, np.newaxis]

    # build a linear model
    model = skl()
    model.fit(x, y) # independent variable, dependent variable
    predicts = model.predict(x) # predicted value
    R2 = model.score(x, y) # fitting degree: R2
    coef = model.coef_ # slope
    intercept = model.intercept_ # intercept
    rmse = ms(mse(y, predicts)) # root-mean-square error: RMSE

    return R2, rmse, coef[0][0], intercept[0]

season = ['JFM', 'AMJ', 'JAS', 'OND']
#season = ['JFM']
path = 'D:\\data\\'
mul = 1E+4

day, nig = [], []
i_day, i_nig, g_day, g_nig = [], [], [], []
for sea in season:
    print('Import season: ' + sea)

    # import data
    ## IASI
    iasi_day = scio.loadmat(path + 'IASI\\' + sea + '_Daytime_IASI.mat')
    iasi_day = iasi_day['nh3_day'] * mul
    iasi_nig = scio.loadmat(path + 'IASI\\' + sea + '_Nighttime_IASI.mat')
    iasi_nig = iasi_nig['nh3_nig'] * mul
    

    ## GEOS-Chem
    geo_day = scio.loadmat(path + 'GEOS-Chem\\concentration_month\\' + sea + '_Daytime_Chem.mat')
    geo_day = geo_day['nh3_day'] * mul
    geo_nig = scio.loadmat(path + 'GEOS-Chem\\concentration_month\\' + sea + '_Nighttime_Chem.mat')
    geo_nig = geo_nig['nh3_nig'] * mul

    # filter nan
    iasi_day, geo_day = Overlap(iasi_day, geo_day, 0)
    iasi_nig, geo_nig = Overlap(iasi_nig, geo_nig, 0)

    i_day.append(iasi_day)
    i_nig.append(iasi_nig)
    g_day.append(geo_day)
    g_nig.append(geo_nig)

    # LinearRegression
    day.append(LR(geo_day, iasi_day))
    nig.append(LR(geo_nig, iasi_nig))

vmax = 15
yscale = 5
# draw
fig = plt.figure(1, (4, 4), dpi = 250) 
for i in range(4):   

    x1 = g_day[i]
    y1 = i_day[i]
    x2 = g_nig[i]
    y2 = i_nig[i]

    dayi = day[i]
    nigi = nig[i]

    ax = plt.subplot(2, 2, i+1)
    ax.set_xlim([0, vmax])
    ax.set_ylim([0, vmax])

    ## set Y-axis scale
    ax.yaxis.set_major_locator(mpm(yscale)) 

    ax.set_title(season[i])

    ax.scatter(x1, y1, s = .1, c = 'magenta', marker = 'o', alpha = 1)
    ax.scatter(x2, y2, s = .1, c = 'royalblue', marker = 'o', alpha = 1)

    x_day = np.arange(x1.min(), x1.max() +1)
    x_nig = np.arange(x2.min(), x2.max() +1)
    ax.yticks = (np.arange(0, vmax, 5))
    ax.plot(x_day, x_day * dayi[2] + dayi[3], linewidth = 1, c = 'darkmagenta')
    ax.plot(x_nig, x_nig * nigi[2] + nigi[3], linewidth = 1, c = 'b')
    ax.plot(np.arange(vmax+1), np.arange(vmax+1), c = 'k', linewidth = 0.5, linestyle = 'dashed')

    ax.text(0.1, 14, 'Day: ', fontsize = 7, c = 'darkmagenta')
    ax.text(2.4, 14, 'Obs.=' + '%.2f' % y1.mean() + ', Mod.=' + '%.2f' % x1.mean(), fontsize = 7, c = 'darkmagenta')
    ax.text(2.4, 12.5, 'R$^2$=' + '%.2f' % dayi[0] + ', RMSE=' '%.2f' % dayi[1], fontsize = 7, c = 'darkmagenta')

    ax.text(0.1, 11, 'Night: ', fontsize = 7, c = 'b')
    ax.text(3, 11, 'Obs.=' + '%.2f' % y2.mean() + ', Mod.=' + '%.2f' % x2.mean(), fontsize = 7, c = 'b')
    ax.text(3, 9.5, 'R$^2$=' + '%.2f' % nigi[0] + ', RMSE=' '%.2f' % nigi[1], fontsize = 7, c = 'b')

plt.subplots_adjust(left = 0.13, bottom = 0.12, wspace = 0.2, hspace =0.3)

fig.text(0.01, 0.25, 'IASI Concentrations (10$^{-4}$ Mol m$^{-2}$)', fontsize = 10, rotation = 90,)
fig.text(0.20, 0.03, 'GEOS-Chem Concentrations (10$^{-4}$ Mol m$^{-2}$)',  fontsize = 10)

plt.savefig(fname = path + 'Comparison IASI & GEOS-Chem.png', format = 'png', bbox_inches = 'tight')

plt.show()
