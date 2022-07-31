% trend spatial distribution of CH4 emission flux from livestock sources
clear all

path = 'D:\data\methane\GlobalInv_livestock_nonwetland.nc';

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

prior = ncread(path, 'prior_livestock')';
retrend = ncread(path, 'posterior_relative_trend')';

tre = retrend .* prior .* (map_land > 0);
tre(tre == 0) = nan;

% regridded lon and lat grid
lon = ncread(['D:\data\IASI\filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lon');
lon = lon;
lat = ncread(['D:\data\IASI\filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lat');
lat = lat;
[x,y] = meshgrid((lon) , (lat));

mul = 1E+12;
max = 5; 

% draw
fig = figure();
set(gcf,'Position',[232,400,620,300]);

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, tre*mul, 500);
set(h,'LineColor','none');

shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max max]);
cmp = importdata('D:\data\\colormap\bwr.txt');
colormap(cmp(:,1:3));

cb = colorbar('eastoutside','fontsize', 15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', -max:2:max);
set (gca,'Position',[0.09,0.1,0.80,0.80])
space(1 : 150) = 32; 
title(strcat('Posterior Trend (10^{-12} kg/m^{2}/s/yr)', space(1:30), 'Livestock'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
axis normal;

f = gcf;
exportgraphics(f,['C:\Users\Administrator\Desktop\output\ch4_livestock_trend.png'],'Resolution',300)
