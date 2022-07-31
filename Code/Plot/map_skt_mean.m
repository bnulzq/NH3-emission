% mean spatial distribution of ERA5 skin temperature
clear

path = 'E:\AEE\data\ERA5\skin_temperature\';

yr_sta = 2008;
yr_end = 2018;

% import data
skt = ncread([path, 'ERA5_skin_temperature_2008-2018_Mean.nc'], 'skin temperature')';
lon = ncread([path, 'ERA5_skin_temperature_2008-2018_Mean.nc'], 'lon');
lat = ncread([path, 'ERA5_skin_temperature_2008-2018_Mean.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

min = 200;
max = 330;
% draw
m_proj('Equidistant Cylindrical','lat',[-90,90],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, skt, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([min max]);
colormap(jet);

cb = colorbar('eastoutside','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2, 'TickLength', 0.03);
set(cb, 'YTick', [200, 230, 263, 300, 330]);
% set(cb,'YTickLabel',{'200', '240', '263', '290', '330'}) %具体刻度赋值

space(1 : 150) = 32; 
title(strcat('Skin temperature (K)', space(1:20), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Arial'); 

f = gcf;
exportgraphics(f,['E:\AEE\Pap\Results\figure\figS1.png'],'Resolution',300)
