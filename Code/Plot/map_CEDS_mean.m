% mean spatial distribution of CEDS total emissions 
clear all

path = 'D:\data\CEDS\grid\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
lat_sta = 6;
lat_end = 41;
secs_name = {'Energy', 'Industry', 'Traffic', 'Residential and Commercial', 'Manure management', 'Soil emissions', 'Waste'};

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

emi = zeros([yr_len, 72, 46], 'double');
for i = 1:length(secs_name)

    sec_name = char(secs_name(i));
    sec = ncread([path, 'CEDS_' sec_name, '_', num2str(yr_sta), '-', num2str(yr_end), '.nc'], sec_name);
    emi = emi + sec;

end

save([path, 'CEDS_total_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'emi');

emi = squeeze(nanmean(emi, 1))' .* (map_land > 0);
emi(emi == 0) = nan;

% regridded lon and lat grid
lon = ncread(['D:\data\IASI\filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lon');
lon = lon;
lat = ncread(['D:\data\IASI\filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lat');
lat = lat;
[x,y] = meshgrid((lon) , (lat));

mul = 1E-6;
max = 300; 


% draw
fig = figure();
set (gcf,'Position',[232,400,623.5,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0)
hold on

sp = 30;
[C,h] = m_contourf(x, y, emi*mul, 500);
set(h,'LineColor','none');
shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(flipud(pink));

cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', 0:50:max);
set (gca,'Position',[0.09,0.1,0.78,0.80])


%set (gca,'Position',[0.09,0.1,0.86,0.8])
space(1 : 150) = 32; 
title(strcat('CEDS Emissions (Kt) SUM = ', num2str(round(nansum(nansum(emi*mul)))), space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
%text(-3, -1, '(b)', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')
axis normal;
% saveas(fig, ['C:\Users\Administrator\Desktop\output\IASI_E=M_τ_n=', num2str(thre), '.png']);
f = gcf;
exportgraphics(f,['C:\Users\Administrator\Desktop\output\CEDS.png'],'Resolution',300)

