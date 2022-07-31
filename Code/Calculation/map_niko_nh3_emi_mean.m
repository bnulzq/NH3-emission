% mean spatial distribution of NH3 emissions from Nikolaos over 2008-2016
clear

path = 'E:\AEE\data\Nikolaos\';

yr_sta = 2008;
yr_end = 2017;
lat_sta = 6;
lat_end = 41;
yrs = yr_sta:1:yr_end;
yr_len = length(yrs);

% import data
% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_201601.nc'], 'lon');
lon = lon;
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_201601.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;
land = repmat(map_land, 1, 1, yr_len);

% area
grid_area = ncread(['E:\AEE\data\GEOS-Chem\OutputDir2008\GEOSChem.Budget.20080101_0000z.nc4'], 'AREA')'; % m-2
grid_area = repmat(grid_area, 1, 1, yr_len);

% lon and lat
data_lat  = ncread([path, 'NH3sflx_720x360_2008_kgm2s.nc'], 'latitude');
data_lon  = ncread([path, 'NH3sflx_720x360_2008_kgm2s.nc'], 'longitude');

data = NaN([46, 72, yr_len, 12], 'double');

for yr = yrs

    data_yr = ncread([path, 'NH3sflx_720x360_', num2str(yr), '_kgm2s.nc'], 'NH3sflx');
    for i = 1:46

        lati = lat(i);
        for j = 2:72

            lonj = lon(j);
            geo_lon = (data_lon < (lonj +2.5)) & (data_lon > (lonj -2.5));
            geo_lat = (data_lat < (lati +2)) & (data_lat > (lati -2));
            
            dataij = data_yr(geo_lon, geo_lat, :);
            data(i, j, yr - yr_sta +1, :) = nanmean(nanmean(dataij, 2), 1);

        end

        geo_lon = find((data_lon < (-177.5)) | (data_lon > (177.5)));
        geo_lat = find((data_lat < (lati +2)) & (data_lat > (lati -2)));

        dataij = data_yr(geo_lon, geo_lat, :);
        data(i, j, yr - yr_sta +1, :) = nanmean(nanmean(dataij, 2), 1);

    end
end

save([path, 'NH3_sflx_46x72_', num2str(yr_sta), '-', num2str(yr_end), '.nc'], 'data');

data = nanmean(data, 4);
data_emi = data .* grid_area * 3600 * 24 *365 * 1E-9 .* (land > 0); % Tg 
data_emi = squeeze(nansum(nansum(data_emi, 2), 1));
data = nanmean(data, 3) .* (map_land > 0);
data(data == 0) = nan;

mul = 1E+11;
max = 5;

% draw
fig = figure(i);
set (gcf,'Position',[232,400,580,300]);

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, data*mul, 100);
set(h,'LineColor','none');
caxis([0 max]);
colormap(jet);
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
hold on 

space(1 : 150) = 32; 
set (gca,'Position',[0.09,0.1,0.86,0.8]) %[left bottom width height]
title(strcat('Nikolaos NH3 flux (10^{-11} kg/m^{2}/s)', space(1:20),  num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 

axis normal;
saveas(gcf,['C:\Users\bnulzq\Desktop\test\Nikolaos_', num2str(yr_sta), '-', num2str(yr_end), '.png'])
