% trend spatial distribution of optimized emissions 
clear all

path = 'D:\data\IASI\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
thre_n = 30;
thre_r = 1;

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

load([path, 'optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_', num2str(yr_sta), '-', num2str(yr_end), '.mat']) % E

emi = NaN([46, 72, yr_len]);
for i = 1:yr_len
        
    emi(:, :, i) = nanmean(E(:, :, (i-1)*12+1:(i)*12), 3);
    
end

% trend
[tre, test] = Trend(emi, 46, 72, yr_len);
tre = tre .* (map_land>0);
test = test .* (map_land >0);
tre(tre == 0) = nan;
test(test == 0) = nan;

% tre = tre ./ nanmean(emi, 3)*100;

% regridded lon and lat grid
lon = ncread([path, 'IASI_filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lon');
lon = lon;
lat = ncread([path, 'IASI_filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

mul = 1E+12;
p = 0.05;
max = 10; 

% draw
fig = figure();
set(gcf,'Position',[232,400,620,300]);

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on
% day
[p_lat, p_lon] = find(test < p);
p_lat = lat(p_lat);
p_lon = lon(p_lon);

[C,h] = m_contourf(x, y, tre*mul, 2000);
set(h,'LineColor','none');

m_scatter(p_lon, p_lat, 20,'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', '.') ;% mark the p 

shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
cmp = importdata('D:\data\\colormap\bwr.txt');
colormap(cmp(:,1:3));
caxis([-max max]);

cb = colorbar('eastoutside','fontsize', 15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', -max:5:max);
set (gca,'Position',[0.09,0.1,0.80,0.80])
space(1 : 150) = 32; 
title(strcat('Optimized Trend (10^{-12} kg/m^{2}/s/yr)', space(1:30), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
axis normal;

f = gcf;
exportgraphics(f,['C:\Users\Administrator\Desktop\output\Opt_trend.png'],'Resolution',300)
