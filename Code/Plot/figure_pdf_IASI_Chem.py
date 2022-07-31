'''draw PDF of seasonal IASI and GEOS-Chem simulated concentrations''' 

import scipy.io as scio
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
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

# PDF
def Hist(data, bin, max):

    s = data.size
    n = []
    for i in range(bin):

        thre1 = max/bin*i
        thre2 = max/bin*(i+1)

        ni = ((data > thre1) * (data < thre2)).sum()
        n.append(ni/s)
    
    ni = (data > thre2).sum()
    n.append(ni/s)

    return n

season = ['JFM', 'AMJ', 'JAS', 'OND']
#season = ['JFM']
path = 'D:\\data\\'
mul = 1E+4
bin = 50
max = 2.5

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

    # compute the histogram
    i_day.append(Hist(iasi_day, bin, max))
    i_nig.append(Hist(iasi_nig, bin, max))
    g_day.append(Hist(geo_day, bin, max))
    g_nig.append(Hist(geo_nig, bin, max))


# draw
ymax = 0.2
fig = plt.figure(1, (4, 4), dpi = 250) 
for i in range(4):   

    ax = plt.subplot(2, 2, i+1)
    ax.set_title(season[i])
    ax.set_xlim([0, max])
    ax.set_ylim([0, ymax])

    x = np.arange(0, max+max/bin, max/bin)
    ax.plot(x, i_day[i], c = 'magenta', linewidth = 1, label = 'IASI Day')
    ax.plot(x, i_nig[i], c = 'royalblue', linewidth = 1, label = 'IASI Night')
    ax.plot(x, g_day[i], c = 'darkmagenta', linewidth = 1, linestyle = 'dotted', label = 'GEOS-Chem Day')
    ax.plot(x, g_nig[i], c = 'b', linewidth = 1, linestyle = 'dotted', label = 'GEOS-Chem Night')

    if i == 0:
        ax.legend(loc = 'best', frameon = False, edgecolor = 'black', fontsize  = 7, ncol = 1)

fig.text(0.27, 0.03, 'Concentrations (10$^{-4}$ Mol m$^{-2}$)',  fontsize = 10)
fig.text(0.01, 0.45, 'Frequency', fontsize = 10, rotation = 90,)

plt.subplots_adjust(left = 0.14, bottom = 0.12, wspace = 0.3, hspace =0.3)

plt.savefig(fname = path + 'PDF IASI & GEOS-Chem.png', format = 'png', bbox_inches = 'tight')

plt.show()