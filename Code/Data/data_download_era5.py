 
import cdsapi

path = 'D:\\data\\ERA5\\skin_temperature\\'
c = cdsapi.Client()
c.retrieve('reanalysis-era5-single-levels', { 

    'product_type': 'reanalysis',

    'variable': 'skin_temperature',

    'year': '2008',
    
    'month': '01',

    'time': ['09:00', '10:00'],

    'day':'01',

    'format': 'netcdf',                # Output needs to be regular lat-lon, so only works in combination with 'grid'!
}, path + 'ERA5-skin_temperature-test.nc')     # Output file. Adapt as you wish.

