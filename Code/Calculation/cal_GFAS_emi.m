% calculate the GFAS (0.1°×0.1°) NH3 emissions
clear

path = 'D:\data\GFAS\Monthly\GFAS_';
yr_sta = 2008;
yr_end = 2015;
yr_len = yr_end - yr_sta +1;
mul = 3600 * 24 * 1E-9; % Tg yr-1
% import data
area = ncread(['D:\data\GEOS-Chem\OutputDir2008\GEOSChem.Budget.20080101_0000z.nc4'], 'AREA')';
area = reshape(repmat(area, yr_len, 1), [46, 72, yr_len]);
lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_201601.nc'], 'lon');
lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_201601.nc'], 'lat');
data_lon = ncread([path, '200801.nc'], 'lon');
data_lat = ncread([path, '200801.nc'], 'lat');

data01 = zeros(1800, 3600, yr_len);
for yr = yr_sta:1:yr_end

    year = num2str(yr);
    disp(year);
    datayr = zeros(1800, 3600, 12);
    for m = 1:12

        month = num2str(m, '%02d');
        datayrm = ncread([path, year, month, '.nc'], 'nh3fire');
        datayrm = nansum(datayrm,3);
        datayr(:,:,m) = datayrm';

    end
    
    data01(:,:,yr - yr_sta+1) = nansum(datayr,3);
    
end


data = NaN([46, 72, yr_len]);
% regrid
for i = 2:45
    lati = lat(i);
    for j = 1:72

        lonj = lon(j)+180;

        geo_lon = (data_lon < (lonj +5)) & (data_lon > (lonj ));
        geo_lat = (data_lat < (lati +2)) & (data_lat > (lati -2));
        
        dataij = data01(geo_lat, geo_lon,:);
        data(i, j, :) = nanmean(nanmean(dataij,2),1);

    end
end

lati = lat(1);
for j = 1:72

    lonj = lon(j);

    geo_lon = (data_lon < (lonj +5)) & (data_lon > (lonj));
    geo_lat = (data_lat < (lati +1)) & (data_lat > (lati -1));
    
    dataij = data01(geo_lat, geo_lon,:);
    data(1, j,:) = nanmean(nanmean(dataij, 2),1);

end

lati = lat(46);
for j = 1:72

    lonj = lon(j);

    geo_lon = (data_lon < (lonj +5)) & (data_lon > (lonj));
    geo_lat = (data_lat < (lati +1)) & (data_lat > (lati -1));
    
    dataij = data01(geo_lat, geo_lon,:);
    data(46, j,:) = nanmean(nanmean(dataij, 2),1);

end

emi = data .* area;
emi = squeeze(nansum(nansum(emi, 2),1))*mul;