% mean spatial distribution of emission difference between IASI and GEOS-Chem
clear all

path = 'E:\AEE\data\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
thre_n = 30;
thre_r = 1;

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;
geo = load([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.Total_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).data;
iasi = load([path, 'IASI\optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).E; % adjusted emissions


D = nanmean(iasi - geo, 3) .* (map_land>0);
D (D == 0) = nan;

% regridded lon and lat grid
lon = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lon');
lon = lon;
lat = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lat');
lat = lat;
[x,y] = meshgrid((lon) , (lat));

mul = 1E+11;
max = 10; 

% draw
fig = figure();
set (gcf,'Position', [232,400,620,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0)
hold on

sp = 20;
[C,h] = m_contourf(x, y, D*mul, 500);
set(h,'LineColor','none');
shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max max]);
cmp = importdata([path, '\colormap\seismic.txt']);
colormap(cmp(:,1:3));

cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', -max:4:max);
set (gca,'Position',[0.09,0.1,0.80,0.80])

space(1 : 150) = 32; 
title(strcat('Optimized - GEOS-Chem (10^{-11} kg/m^{2}/s)', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
%title(strcat('Optimized - GEOS-Chem (10^{-11} kg/m^{2}/s) (Trans < Emi0)', space(1:5), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 

axis normal;
f = gcf;
exportgraphics(f,['C:\Users\Administrator\Desktop\output\IASI_Chem_emi_diff_.png'],'Resolution',300)
