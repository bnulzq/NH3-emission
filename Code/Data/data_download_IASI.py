import calendar

path = 'D:\\data\\ND51\\'

curl1 = 'curl --insecure https://cds-espri.ipsl.fr/iasial2/iasi_nh3/V3R.0.0/'
curl2 = '/IASI_METOPA_L2_NH3_'
curl3 = '_ULB-LATMOS_V3R.0.0.nc -O'

for yr in range(2018, 2019):
    y = str(yr)

    for mon in range(3, 4):

        m = str(mon).zfill(2)
        n_day = str(calendar.monthrange(yr, mon)[1])
        print(curl1 + y + '/' + m + curl2 + y + m + '[01-' + n_day + ']' + curl3)

