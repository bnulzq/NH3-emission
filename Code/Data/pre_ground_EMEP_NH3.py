'''
extract the groud based (EMEP, EANET, AMoN) NH3 to csv file
'''

import pandas as pd
import glob as gb
import numpy as np



path = 'E:\\AEE\\data\\Ground\\'

# EMEP
mul1 = 1.44 # ug N m-3 to ppb
emep = pd.DataFrame()
for file in gb.glob(f'{path}EMEP\\Ebas_NH3\\*.nas'):
    print(file)
    with open(file, 'r') as f:
        data = f.readlines()
        sta = data[2][:5]
        
        i = 20

        while data[i][:9] != 'Startdate':
            i = i+1
        start = data[i][30:42]

        while data[i][:16] != 'Station latitude':
            i = i+1
        lat = data[i][30:37]

        while data[i][:17] != 'Station longitude':
            i = i+1
        lon = data[i][30:37]
        
        while data[i][:5] != 'start':
            i = i+1

        # print(lon)
        # print(lat)
        time0 = pd.to_datetime(start, format='%Y%m%d%H%M')
        nh3 = pd.DataFrame(columns = data[i].split())
        for j, nh3_j in enumerate(data[i+1:]):
            nh3.loc[j] = nh3_j.split()

        nh3['time0'] = time0
        nh3.starttime = nh3.time0 + pd.to_timedelta(nh3.starttime.astype(float), unit='d')
        nh3.endtime = nh3.time0 + pd.to_timedelta(nh3.endtime.astype(float), unit='d')
        nh3.NH3 = nh3.NH3.astype(float)
        # replace the flag_NH3
        if 'flag' in nh3:
            print("flag!")
            nh3.columns = ['starttime', 'endtime', 'NH3', 'NH3_1', 'flag_NH3', 'time0']
            
        nh3.flag_NH3 = nh3.flag_NH3.astype(float)
        nh3 = nh3[nh3.flag_NH3 == 0]

        nh3_mon_sta = nh3.groupby(nh3.starttime.dt.to_period('M')).NH3.mean()
        nh3_mon_end = nh3.groupby(nh3.endtime.dt.to_period('M')).NH3.mean()
        nh3_mon = pd.DataFrame(columns = ['NH3', 'time'])
        nh3_mon.NH3 = (nh3_mon_sta + nh3_mon_end)*mul1  # ppb
        nh3_mon.time = nh3_mon.index
        nh3_mon = nh3_mon.dropna()

        nh3_mon['station'] = sta
        nh3_mon['longitude'] = lon
        nh3_mon['latitude'] = lat

    emep = pd.concat([emep, nh3_mon])

emep.to_csv(f'{path}EMEP_monthly.csv', index = False)

