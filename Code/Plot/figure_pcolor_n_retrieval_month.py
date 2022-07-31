'''draw data coverage of number of retrievals binned by latitude, with one-month bin '''
import numpy as np
import netCDF4 as nc
import scipy.io as scio
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Arial', 'font.weight':'bold', 'font.size':10}
rcParams.update(params)

# create 3 dimension NaN array
def Nan3Array(x, y, z):

    data = np.zeros([x, y, z])
    data[:] = np.nan

    return data

yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
thre_r = 1
thre_n = 800

# import data
path = 'E:\\AEE\\data\\IASI\\IASI_filter\\IASI_filter_AM_Cloud_10_'

## land 
map = nc.Dataset('E:\\AEE\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
# land = map_land.reshape([46, 72])

## r
r = scio.loadmat('E:\\AEE\\data\\GEOS-Chem\\transport_to_emission_2008-2018.mat')['r']
r = r < thre_r

n_re = Nan3Array(46, 72, yr_len*12)

for y in range(yr_sta, yr_end +1):

    yr = str(y)

    for m in range(1, 13):

        mon = str(m).zfill(2)
        n_re_m = nc.Dataset(path + yr + mon + '.nc')['Monthly number of retrievals'][:]
        n_re[:, :, (y-yr_sta)*12 + m-1] = n_re_m.T * map_land # orginal
        # n_re[:, :, (y-yr_sta)*12 + m-1] = np.nanmean(n_re_m, 0).T * map_land * r[:, :, (y-yr_sta)*12 + m-1] # tansport/emission > r

n_re[n_re == 0] = np.nan
lat = nc.Dataset(path + yr + mon + '.nc')['lat'][:]

n_re = np.nanmean(n_re, 1)

nmax = thre_n*2
# draw
fig = plt.figure(1, (6, 2), dpi = 300) 
plt.yticks([7.5, 15, 22.5, 30, 37.5], ['60S', '30S', 0, '30N', '60N'])
plt.xticks(np.arange(0, yr_len*12, 12), ())

ax = fig.add_subplot(111)
c = ax.pcolor(n_re, cmap='RdBu_r', vmin = 0, vmax = nmax, edgecolors = 'k', linewidths = 0.1)

ax.set_title('IASI number of retrievals (month$^{-1}$)')
#ax.set_title('IASI number of retrievals (N month$^{-1}$) (Trans < Emi)')
# ax.set_title('Second filter')
ax.set_ylabel('Latitude ($^\circ$)')
cbar = fig.colorbar(c, ax=ax, ticks=[0, thre_n, nmax])
cbar.ax.set_yticklabels(['0', str(thre_n), '> '+ str(nmax)]) 
plt.grid(axis = 'x')
for i in range(yr_sta, yr_end+1):
    
    fig.text((i-yr_sta)*0.063+0.12, 0.05, str(i))
# fig.text(0.08, 0.9, '(b)')
fig.tight_layout()
# plt.savefig(fname = 'C:\\Users\\Administrator\\Desktop\\output\\data coverage of number of retrievals in lat.png', format = 'png', bbox_inches = 'tight')
plt.savefig(fname = r'E:\AEE\Pap\Full\figure\figS1.png', format = 'png', bbox_inches = 'tight')
plt.show()

