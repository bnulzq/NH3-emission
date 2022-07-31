'''
extract the groud based (EMEP, EANET, AMoN) NH3 to csv file
'''

import pandas as pd
import numpy as np

path = 'E:\\AEE\\data\\Ground\\'

# EANET
## site info
site = pd.read_csv(f'{path}\\EANET\\Site_Information_Acid_Deposition_Monitoring.csv')
site.Site = site.Site.str.lstrip()
site.Site = site.Site.str.strip()

eanet = pd.DataFrame()
yrs = [2008, 2013, 2018]
mons = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
for yr in yrs:
    print(yr)
    data = pd.read_excel(f'{path}\\EANET\\Dry{yr}Monthly.xlsx', sheet_name = 'NH3', skiprows = 3)
    data = data.dropna(subset = ['Site'])
    data = data[data['Unnamed: 2'] == 'Mean']

    data.loc[data.Site == 'Cheju', 'Site'] = 'Cheju(Kosan)'
    data.loc[data.Site == 'Khanchanaburi', 'Site'] = 'Kanchanaburi(Vajiralongkorn Dam)'
    data.loc[data.Site == 'Chiangmai', 'Site'] = 'Mae Hia'

    data['year'] = str(yr)
    for mon in mons:
        nh3_mon = data[['Site', mon, 'year']]
        nh3_mon[mon] = pd.to_numeric(nh3_mon[mon], errors='coerce')
        nh3_mon = nh3_mon.dropna()
        nh3_mon['time'] = pd.to_datetime(nh3_mon.year+mon, format='%Y%b').dt.strftime('%Y-%m')
        nh3_mon = nh3_mon.merge(site, on = 'Site')
        nh3_mon['longitude'] = nh3_mon.Longitude_degree + nh3_mon.Longitude_minute/60
        nh3_mon['latitude'] = nh3_mon.Latitude_degree + nh3_mon.Latitude_minute/60
        nh3_mon = nh3_mon[[mon, 'time', 'Site', 'longitude', 'latitude']].dropna()
        nh3_mon.columns = ['NH3', 'time', 'station', 'longitude', 'latitude']

        eanet = pd.concat([eanet, nh3_mon])

eanet.to_csv(f'{path}EANET_monthly.csv', index = False)