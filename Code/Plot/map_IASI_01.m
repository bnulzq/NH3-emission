% mean spatial distribution of IASI (0.01°×0.01°) over 2008-2016
clear all

path = 'E:\AEE\data\IASI\ANNI-NH3\ANNI-NH3\';

% import data
% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_201601.nc'], 'lon');
lon = lon +2.5;
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_201601.nc'], 'lat');
lat = lat(6:41);
[x,y] = meshgrid((lon) , (lat));

data_lon = ncread([path, 'IASI_NH3_9yr_AM.nc'], 'longitude');
data_lat = ncread([path, 'IASI_NH3_9yr_AM.nc'], 'latitude');
data01 = ncread([path, 'IASI_NH3_9yr_AM.nc'], 'NH3_mean');

data = NaN([36, 72], 'double');
for i = 1:36
    
    lati = lat(i);
    for j = 2:72

        lonj = lon(j);
        geo_lon = (data_lon < (lonj +2.5)) & (data_lon > (lonj -2.5));
        geo_lat = (data_lat < (lati +2)) & (data_lat > (lati -2));

        dataij = data01(geo_lat, geo_lon);
        data(i, j) = nanmean(nanmean(dataij));
    end
    
    geo_lon = find((data_lon < (-177.5)) | (data_lon > (177.5)));
    geo_lat = find((data_lat < (lati +2)) & (data_lat > (lati -2)));

    dataij = data01(geo_lat, geo_lon);
    data(i, 1) = nanmean(nanmean(dataij));

end

save([path, 'IASI_01_2008-2016.mat'], 'data');

mul = 1E-15 * 1/6.02214076E19;
max = 15;
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
title(strcat('IASI 0.01x0.01 (10^{15} molecules cm^{-2})', space(1:20), '2008-2016'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
% rectangle
% annotation(fig, 'rectangle', [0.68 0.52 0.165 0.23], 'Color', [1 0 1], 'LineWidth', 2); % India-China
% annotation(fig, 'rectangle', [0.47 0.33 0.18 0.35], 'Color', [1 0 1], 'LineWidth', 2); % Africa
% annotation(fig, 'rectangle', [0.32 0.24 0.125 0.33], 'Color', [1 0 1], 'LineWidth', 2); % Southern America

axis normal;
saveas(fig, 'C:\Users\bnulzq\Desktop\test\IASI_01.png');

