'''draw optimized NH3 emissions sectors change (trend) over different region
    adjust trend for EC and IP''' 
import numpy as np
import netCDF4 as nc
import mat73 as m73
import scipy.io as scio
import pandas as pd
from statsmodels.formula.api import ols
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Arial', 'font.weight':'light', 'font.size':10}
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

# data overlap
def Overlap(data1, data0):

    data1_nan = np.isnan(data1) # Nan in data1
    data1_nan = data0 * data1_nan
    data1[np.isnan(data1)] = 0 # set nan as 0
    data1 = data1 + data1_nan
    data1[data1 == 0] = np.nan

    return data1

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

path = 'E:\\AEE\\data\\'
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
thre_n = 800
thre_r = 1
mul = 3600 * 24 * 365/12 * 1E-9 # Tg/month/m2
mul1 = 1E-9 # kg -> Tg
life = [50, 200]
ratio = [0.2, 5]
num = [400, 1200]

# regional extent (grid index: bottom, left, top, right)
res_name = ['US', 'SA', 'EU', 'TA', 'IP', 'CA', 'EC']
us = [29, 10, 36, 26] # north America
sa = [14, 20, 24, 30] # south America
eu = [32, 34, 39, 42] # Europe
ta = [19, 32, 28, 49] # Tropical Africa
ip = [25, 50, 31, 55] # India Peninsula
pp = [31, 48, 34, 53] # Pamir Plateau
ec = [30, 56, 35, 62] # eastern China
res = [us, sa, eu, ta, ip, pp, ec]

# import data
## land
map = nc.Dataset('E:\\AEE\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
land = np.reshape(np.repeat(map_land, yr_len*12), [46, 72, yr_len, 12]) 

## area
area = nc.Dataset(path + 'GEOS-Chem\\OutputDir2008\\\GEOSChem.Budget.20080101_0000z.nc4')['AREA'][:] # m2
area = np.reshape(np.repeat(area, yr_len*12), [46, 72, yr_len, 12]) 

## biased emission
data = scio.loadmat(path + 'IASI\\Emission\\NHx lifetime_with adjustment_optimized_emi_n=800_r=1_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
bias_emi = Monthly(data, mul, land) * area

## optimize emission
iasi_emi = scio.loadmat(path + 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=800_r=1_w=0.05_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
adj_emi = Monthly(iasi_emi, mul, land) * area

## geos-chem emission
data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Total_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_tot = Monthly(data, mul, land) * area

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Anthro_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_anth = Monthly(data, mul, land) * area

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.BioBurn_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_bb = Monthly(data, mul, land) * area

data = scio.loadmat(path + '\\GEOS-Chem\\Emissions\\Total\\HEMCO_diagnostics_NH3.Natural_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
geo_emi_nat = Monthly(data, mul, land) * area

# data = scio.loadmat(path + 'IASI\\Emission\\Adjust_EC_emi_n=800_r=1_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
# emi_EC = data[list(data.keys())[-1]] * mul1

# data = scio.loadmat(path + 'IASI\\Emission\\Adjust_IP_emi_n=800_r=1_' + str(yr_sta) + '-'+ str(yr_end) + '.mat')
# emi_IP = data[list(data.keys())[-1]] * mul1

## geos-chem emission fraction
geo_r_anth = geo_emi_anth/geo_emi_tot
geo_r_bb = geo_emi_bb/geo_emi_tot
geo_r_nat = (geo_emi_nat)/geo_emi_tot

## uncertainty
data_iasi =  scio.loadmat(path + 'uncertainty\\Uncertainty_IASI_emi_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
data_iasi = Monthly(data_iasi, mul1, land) * area

data_life_bo = scio.loadmat(path + 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_' + str(life[1]) + '%_NHx lifetime_with adjustment_optimized_emi_n=800_r=1_w=0.05_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
data_life_bo = Monthly(data_life_bo, mul, land) * area

data_life_up = scio.loadmat(path + 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_' + str(life[0]) + '%_NHx lifetime_with adjustment_optimized_emi_n=800_r=1_w=0.05_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
data_life_up = Monthly(data_life_up, mul, land) * area

data_so2_up = scio.loadmat(path + 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=800_r=1_w=0.06_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
data_so2_up = Monthly(data_so2_up, mul, land) * area

data_so2_bo = scio.loadmat(path + 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=800_r=1_w=0.04_' + str(yr_sta) +'-' + str(yr_end) + '.mat')
data_so2_bo = Monthly(data_so2_bo, mul, land) * area

# fill IASI emissions
# adj_emi = Overlap(iasi_emi, geo_emi_tot)

# draw
un = np.zeros([6, yr_len], 'double')
t = []
x = np.arange(yr_sta, yr_end +1)
max = 22
fig = plt.figure(1, (8, 3), dpi = 250)
col_num = 4
for i in range(len(res_name)):

    ax = plt.subplot(2, col_num, i+1)
    ax.set_xlim([yr_sta-0.5, yr_end+0.5])
    ax.set_ylim([0, max])
    re = res[i]

    print(res_name[i])
    # text region name
    ax.text(yr_sta, max*0.87, res_name[i])
    
    # error range
    bias = np.nansum(np.nansum(np.nansum(bias_emi[re[0]:re[2], re[1]:re[3], :, :], 3), 1), 0)

    adji = np.nansum(np.nansum(np.nansum(adj_emi[re[0]:re[2], re[1]:re[3], :, :], 3), 1), 0)
    geoi = np.nansum(np.nansum(np.nansum(geo_emi_tot[re[0]:re[2], re[1]:re[3], :, :], 3), 1), 0)

    ia_u = (np.nansum(np.nansum(np.nansum(data_iasi[re[0]:re[2], re[1]:re[3], :, :]**2, 3), 1), 0))**0.5 + adji.data
    ia_b = -(np.nansum(np.nansum(np.nansum(data_iasi[re[0]:re[2], re[1]:re[3], :, :]**2, 3), 1), 0))**0.5 + adji.data

    li_u = np.nansum(np.nansum(np.nansum(data_life_up[re[0]:re[2], re[1]:re[3], :], 3), 1), 0)
    li_b = np.nansum(np.nansum(np.nansum(data_life_bo[re[0]:re[2], re[1]:re[3], :], 3), 1), 0)

    so2_u = np.nansum(np.nansum(np.nansum(data_so2_up[re[0]:re[2], re[1]:re[3], :], 3), 1), 0)
    so2_b = np.nansum(np.nansum(np.nansum(data_so2_bo[re[0]:re[2], re[1]:re[3], :], 3), 1), 0)

    # opt_anth = np.nansum(np.nansum(np.nansum(geo_r_anth[re[0]:re[2], re[1]:re[3], :]*adj_emi[re[0]:re[2], re[1]:re[3], :, :], 3), 1), 0)
    # opt_bb = np.nansum(np.nansum(np.nansum(geo_r_bb[re[0]:re[2], re[1]:re[3], :]*adj_emi[re[0]:re[2], re[1]:re[3], :, :], 3), 1), 0)
    # opt_oth = np.nansum(np.nansum(np.nansum(geo_r_nat[re[0]:re[2], re[1]:re[3], :]*adj_emi[re[0]:re[2], re[1]:re[3], :, :], 3), 1), 0)

    un[0,:], un[1, :], un[2, :], un[3, :], un[4, :], un[5, :] = ia_u, li_u, ia_b, li_b, so2_u, so2_b
    
    u = np.max(un, 0)
    b = np.min(un, 0)

    a_tre, a_p = TrendP(bias, x)
    g_tre, g_p = TrendP(geoi, x)

    
    # anth = ax.plot(x, opt_anth, color = 'b', linewidth = 1)

    # anth_tre = TrendP(opt_anth, x)
    # bb_tre = TrendP(opt_bb, x)
    # t.append([res_name[i], a_tre, a_tre/adji.mean()*100, '%'])
    r = ax.fill_between(x, u, b, color = 'lightcoral', alpha = 0.5)

    # set ticks
    if i != 0 and i != col_num:
        ax.set_yticks([])
    else:
        ax.set_yticks([0, 10, 20])
        ax.set_yticklabels([0, 10, 20], fontsize = 8)

    if i < 3:
        ax.set_xticks([])
    else:
        ax.set_xticks(np.arange(yr_sta, yr_end+1, 2))
        ax.set_xticklabels(np.arange(yr_sta, yr_end+1, 2), fontsize = 8, weight = 'normal', rotation = 45)

    ## text
    x0 = 2008
    d, d1 = 0.9, 0.1
    ax.text(x0+4, max*d, 'Trend', fontsize = 6, fontweight = 'light')
    ax.text(x0+6, max*d, 'Mean', fontsize = 6, fontweight = 'light')
    ax.text(x0+8, max*d, r'$\rm \frac{Trend}{Mean}$', fontsize = 6, fontweight = 'bold')
    ax.text(x0+2, max*(d-d1), 'TDE', fontsize = 6, color = 'r')
    ax.text(x0+2, max*(d-d1*2), 'BUE1', fontsize = 6, color = 'g')
    ax.text(x0+4, max*(d-d1), str('%.2f' % (a_tre*10)) + a_p, color = 'r', fontsize = 6)
    ax.text(x0+4, max*(d-d1*2), str('%.2f' % (g_tre*10)) + g_p, color = 'g', fontsize = 6)
    ax.text(x0+6, max*(d-d1), str('%.2f' % (bias.mean())), color = 'r', fontsize = 6)
    ax.text(x0+6, max*(d-d1*2), str('%.2f' % (geoi.mean())), color = 'g', fontsize = 6)
    ax.text(x0+8, max*(d-d1), str('%.1f' % (a_tre/bias.mean()*1000) + '%'), color = 'r', fontsize = 6)
    ax.text(x0+8, max*(d-d1*2), str('%.1f' % (g_tre/geoi.mean()*1000) + '%'), color = 'g', fontsize = 6)

    print('TDE/BUE1 2012-2018: ' + str(adji.mean()/geoi.mean()*100))
    
    ## plot
    g = ax.plot(x, geoi, color = 'g')
    if re == ec or re == ip:

        a = ax.plot(x[0:5], adji[0:5], color = 'r')
        adjust = ax.plot(x[4:], adji[4:], color = 'r', linestyle = 'dotted')
        ax.plot(x[4:], bias[4:], color = 'r')

        c_tre, c_p = TrendP(adji[4:], x[4:])
        c_tre_so2u, c_p_so2u = TrendP(so2_u[4:], x[4:])
        c_tre_so2b, c_p_so2b = TrendP(so2_b[4:], x[4:])
        ax.text(x0, max*(d1*2), 'TDE (SO2-corrected)', fontsize = 6, color = 'k')
        ax.text(x0, max*(d1), 'Post 2013', fontsize = 6, color = 'r')
        ax.text(x0+4, max*(d1), str('%.2f' % (c_tre*10)) + c_p, color = 'r', fontsize = 6)
        ax.text(x0+6, max*(d1), str('%.2f' % (adji[4:].mean())), color = 'r', fontsize = 6)
        ax.text(x0+8, max*(d1), str('%.1f' % (c_tre/adji[4:].mean()*1000) + '%'), color = 'r', fontsize = 6)

        cor_tre, cor_p = TrendP(adji, x)
        print(str('%.1f' % (c_tre*10) + ' ' + '%.1f' % (c_tre_so2u*10) + ' ' + '%.1f' % (c_tre_so2b*10)))
        print(str('%.1f' % (c_tre/adji[4:].mean()*1000) + '%' + ' ' + '%.1f' % (c_tre_so2u/so2_u[4:].mean()*1000) + '%' + ' ' + '%.1f' % (c_tre_so2b/so2_b[4:].mean()*1000) + '%'))

    else:
        a = ax.plot(x, adji, color = 'r')
        print(f'TDE: {adji}')

    if i == len(res_name) -1:
        plt.legend((g[0], a[0], adjust[0], r), 
        
        ('BUE1', 'TDE', 'TDE (SO$_2$-corrected)', 'Emission range'), 
        frameon = False, loc = (1.1, -0.2))

fig.text(0.01, 0.6, 'Emissions (Tg a$^{-1}$)', rotation = 90)
fig.text(0.51, -0.05, 'Year')
plt.subplots_adjust(left = 0.07, right = 0.99, wspace =0.05, hspace = 0.1, bottom = 0.15)
plt.savefig(fname = 'E:\\AEE\\Pap\\ACP\\figure\\fig3.png', format = 'png', bbox_inches = 'tight')

plt.show()

# import matplotlib.pyplot as plt
# re = ta
# plt.figure(1)
# plt.imshow(np.flipud(map_land[re[0]:re[2], re[1]:re[3]]),cmap='Greys', alpha=0.5)
# # plt.imshow(np.flipud(np.nanmean(np.nanmean(geo_emi_tot[re[0]:re[2], re[1]:re[3],:,:], 3),2)),cmap='Oranges', alpha=0.5)
# plt.show()