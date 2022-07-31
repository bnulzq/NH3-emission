'''draw regional data coverage of number of retrievals binned over several months, with one-day bin '''
import numpy as np
import netCDF4 as nc
import calendar as cl
import matplotlib.pyplot as plt
from matplotlib import rcParams
params={'font.family':'Times New Roman', 'font.weight':'bold', 'font.size':12}
rcParams.update(params)

# create 3 dimension NaN array
def Nan3Array(x, y, z):

    data = np.zeros([x, y, z])
    data[:] = np.nan

    return data


re = [44, 36, 54, 39] # (grid index: left, bottom, right, top)
yr_sta = 2008
yr_end = 2018
yr_len = yr_end - yr_sta +1
mons = [11, 12, 1, 2]
monthRange = []
for m in range(1, 13):

    monthRange.append(cl.monthrange(2009, m)[1])

# import data 
path = 'D:\\data\\IASI\\filter\\IASI_filter_AM_Cloud_10_'

## land 
map = nc.Dataset('C:\\Users\\Administrator\\Desktop\\code\\fun\\MERRA2.20150101.CN.4x5.nc4')
map_land = np.array(np.squeeze(~((map['FRLAND'][:] < 0.2) * (map['FRLANDIC'][:] < 0.01))))  # -180-180
#land = map_land.reshape([46, 72])

n_re = np.array([])
time_name = []
d = 0
for y in range(yr_sta, yr_end, +1):

    time_name.append(str(y) + '-' + str(y+1))
    for m in mons:

        # new year (Dec. to Jan.)
        if m == 1:
            y = y +1

        yr = str(y)
        mon = str(m).zfill(2)
        print(yr + ', ' + mon)
        
        n_re_d = nc.Dataset(path + yr + mon + '.nc')['Number of retrievals'][:].T
        day_n = n_re_d.shape[2]
        land = np.repeat(map_land, day_n).reshape([46, 72, day_n])
        n_re_d = n_re_d * land
        n_re_d = n_re_d[re[1]:re[3]+1, re[0]:re[2]+1]
        n_re_d[n_re_d == 0] = np.NaN
        n_re_d = np.nanmean(np.nanmean(n_re_d, 0), 0)

        
        # missing daily value
        if day_n < monthRange[m-1]:

            day = nc.Dataset(path + yr + mon + '.nc')['day'][:]
            miss_day = list(set(day)^set(range(1, monthRange[m-1]+1)))

            for md in miss_day:
                n_re_d = np.insert(n_re_d, md-1, values = np.NaN)
        
        # leap month
        if cl.monthrange(y, m)[1] == 29:
            n_re_d = n_re_d[:-1]

        d = d +n_re_d.size
        #print('+ ' + str(n_re_d.size) + ' = ' + str(d))
        n_re = np.append(n_re, n_re_d)

# lon and lat
lon = nc.Dataset(path + yr + mon + '.nc')['lon'][:]
lat = nc.Dataset(path + yr + mon + '.nc')['lat'][:]


n_re = n_re.reshape([yr_len -1, int(n_re.size/(yr_len-1))])
n_mean = np.flipud(np.nanmean(n_re, 1))

nmax = 20
# draw
fig = plt.figure(1, (6, 2), dpi = 250) 
plt.yticks(np.arange(0.5, 10.5), time_name, fontsize = 8)
plt.xticks([0, 30, 61, 92], ['11.1', '12.1', '1.1', '2.1'])

ax = fig.add_subplot(111)
ax.text(120.3, 10.2, 'Mean', fontsize = 8)
for i in range(yr_len):

    ax.text(121, 9.3-i*1.01, '%.1f' % n_mean[i], fontsize = 8)

c = ax.pcolor(n_re, cmap='jet', vmin = 0, vmax = nmax, edgecolors = 'k', linewidths = 0.1)
ax.set_title('Number of retrievals per day (' + str(int(abs(lat[re[1]]))-2) + 'N-' + str(int(lat[re[3]])+2) + 'N;' + str(int(lon[re[0]])-2.5) + 'E-' + str(int(lon[re[2]])+2.5) + 'E)')
ax.set_xlabel('Date')
plt.grid(axis = 'x', color = 'k', linewidth = 2)
#position=fig.add_axes([0.15, 0.05, 0.7, 0.03]) # left, bottom, right, top
fig.colorbar(c, ax=ax)
plt.subplots_adjust(left = 0.1, right = 0.99, bottom = 0.22)

#fig.tight_layout()
plt.savefig(fname = path + 'regional data coverage of daily number of retrievals.png', format = 'png', bbox_inches = 'tight')

plt.show()

# import matplotlib.pyplot as plt
# plt.imshow(np.flipud(np.mean(land, 2)),cmap='Oranges')
# # plt.imshow(np.flipud(map_land[36:47, 44:55]),cmap='Oranges')
# plt.show()