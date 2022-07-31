'''
extract the groud based (EMEP, EANET, AMoN) NH3 to csv file
'''

import pandas as pd


path = 'E:\\AEE\\data\\Ground\\'
# AMoN
data = pd.read_csv(f'{path}AMoN\\AMoN-ALL-W.csv')
site = pd.read_csv(f'{path}AMoN\\amon.csv')

sites = set(data.SITEID)
mul1 = 1.44 # ug N m-3 to ppb
amon = pd.DataFrame()
for s in sites:

    data_site = data[data.SITEID == s]
    data_site.startDate = pd.to_datetime(data_site.startDate)
    data_site.endDate = pd.to_datetime(data_site.endDate)

    nh3_mon_sta = data_site.groupby(data_site.startDate.dt.to_period('M')).CONC.mean()
    nh3_mon_end = data_site.groupby(data_site.endDate.dt.to_period('M')).CONC.mean()

    nh3_mon = pd.DataFrame(columns = ['NH3', 'time'])
    nh3_mon.NH3 = (nh3_mon_sta + nh3_mon_end)*mul1  # ppb
    nh3_mon.time = nh3_mon.index
    nh3_mon = nh3_mon.dropna()

    nh3_mon['station'] = s
    try:
        nh3_mon['longitude'] = site[site.siteId == s].longitude.values[0]
        nh3_mon['latitude'] = site[site.siteId == s].latitude.values[0]
    except:
        print(f'Site {s} does not in the list!')

    amon = pd.concat([amon, nh3_mon])

amon.to_csv(f'{path}AMoN_monthly.csv', index = False)