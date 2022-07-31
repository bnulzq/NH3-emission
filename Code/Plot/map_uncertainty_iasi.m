% draw mean uncertainty spatial distribution of IASI daily filtered data
clear all

path = 'D:\data\IASI\IASI_filter\IASI_filter_AM_Cloud_10_';

yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

reer = NaN([46, 72, yr_len], 'double');
num = NaN([46, 72, yr_len], 'double');

for y = yr
    year = num2str(y);
    for m = 1:12
        
        month = num2str(m, '%02d');
        reer(:, :, (y-yr_sta)*12 + m) = ncread([path, year, month, '.nc'], 'averaging relative error');
        num(:, :, (y-yr_sta)*12 + m) = ncread([path, year, month, '.nc'], 'averaging Number of retrievals');

    end
end

uncer = reer ./ sqrt(num*30);

save([path, 'Uncertainty_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'uncer');
uncer = nanmean(uncer, 3) .* (map_land > 0);
uncer(uncer == 0) = NaN;
% regridded lon and lat grid
lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_', year, month, '.nc'], 'lon');
lon = lon;
lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_', year, month, '.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

max = 100;
% draw
fig = figure();
set (gcf,'Position',[232,400,623,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0)
hold on

sp = 20;
[C,h] = m_contourf(x, y, uncer, 500);
set(h,'LineColor','none');
shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(jet);

cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', 0:20:max);
set (gca,'Position',[0.09,0.1,0.80,0.80])

space(1 : 150) = 32; 
title(strcat('Uncertainty of IASI Total Columns (%)', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
axis normal;
f = gcf;
exportgraphics(f,['C:\Users\Administrator\Desktop\output\IASI_uncertainty.png'],'Resolution',300)


