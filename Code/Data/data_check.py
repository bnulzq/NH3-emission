'''check the missing file of the IASI daily datasets'''

import calendar

path = 'D:\\data\\IASI\\daily\\IASI_METOPA_L2_NH3_'
yr_sta = 2008
yr_end = 2018

data = []
file = 0
for yr in range(yr_sta, yr_end +1):
    #file = 0
    y = str(yr)
    for mon in range(1, 13):


        m = str(mon).zfill(2)
        n_day = calendar.monthrange(yr, mon)[1]

        for day in range(1, n_day +1):

            d = str(day).zfill(2)

            try:
                f = open(path + y + m + d + '_ULB-LATMOS_V3R.0.0.nc')
                f.close()

            except IOError:
                file = file +1
                print(y+m+d)
                data.append(y + m +d)

    print('file number: ', file)