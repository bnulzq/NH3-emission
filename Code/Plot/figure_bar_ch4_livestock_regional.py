'''draw mean CH4 livestock emissions over different regions''' 
import numpy as np
import netCDF4 as nc
import scipy.io as scio
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'normal', 'font.size':10}
rcParams.update(params)

path = 'D:\\data\\methane\\GlobalInv_livestock_nonwetland.nc'
mul = 1E-3 * 3600 * 24 * 365 * 1E-6

# regional extent (grid index: bottom, left, top, right)
res_name = ['US', 'SA', 'EU', 'CA', 'IP', 'PP', 'EC']
us = [29, 10, 37, 26] # north America
sa = [13, 20, 23, 30] # south America
eu = [31, 34, 38, 43] # Europe
ca = [20, 33, 28, 47] # central Africa
ip = [25, 49, 32, 55] # India Peninsula
pp = [32, 49, 35, 54] # Pamir Plateau
ec = [28, 56, 35, 62] # eastern China
res = [us, sa, eu, ca, ip, pp, ec]

# import data
## land
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180

## area
area = nc.Dataset('D:\\data\\GEOS-Chem\\OutputDir2008\\\GEOSChem.Budget.20080101_0000z.nc4')['AREA'][:] # m-2

## emission
prior = nc.Dataset(path)['prior_livestock'][:]
prior = prior * map_land * area
prior[prior == 0] = np.nan

post_fac = nc.Dataset(path)['posterior_scaling_factor'][:]
post = prior * post_fac
post[post == 0] = np.nan

# regional
pri_re, post_re = [], []
for i in range(len(res)):

    re = res[i]

    pri_re.append(np.nansum(np.nansum(prior[re[0]:re[2], re[1]:re[3]])))
    post_re.append(np.nansum(np.nansum(post[re[0]:re[2], re[1]:re[3]])))

# draw
ind = np.arange(len(res))
width = 0.4
fig = plt.figure(1, (5, 5), dpi = 250) 
ax = plt.subplot(1, 1, 1)
# ax.set_ylim([0, ymax])

pr = ax.bar(ind, pri_re, width, color = 'darkorange')

po = ax.bar(ind+width, post_re, width, color = 'seagreen')

plt.xticks(ind+width/2, res_name)
# plt.yticks(np.arange(0, 81, 10))

plt.legend((pr[0], po[0]),('Prior', 'Postrior'), frameon = False, ncol = 1)

plt.subplots_adjust(wspace = 0.15, hspace =0.35)

fig.text(0.03, 0.4, 'Emissions (Mt annual)', rotation = 90)

plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\bar_emission_ch4_livestock.svg', format = 'svg', bbox_inches = 'tight')

plt.show()

