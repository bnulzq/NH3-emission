% mean spatial distribution of concentration difference between IASI and GEOS-Chem
clear all

path = 'D:\data\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);

% import data
% land
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

D = NaN([46, 72, yr_len*12], 'double');

for y = yr

    year = num2str(y);

    for m = 1:12

        mon = num2str(m, '%02d');
        
        geo = ncread([path, 'GEOS-Chem\concentration\GEOS-Chem_Total column_', year, mon, '.nc'], 'GEOS-Chem monthly mean NH3')'; % mol m-2
        iasi = ncread([path, 'IASI\filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'averaging nh3 filter'); % mol m-2
        D(:, :, (y-yr_sta)*12 + m) = iasi-geo;

    end
end

D = nanmean(D, 3) .* map_land;

% regridded lon and lat grid
lon = ncread([path, 'IASI\filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'lon');
lon = lon;
lat = ncread([path, 'IASI\filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'lat');
lat = lat;
[x,y] = meshgrid((lon) , (lat));

mul = 1E+5;
max = 10; 

% draw
fig = figure();
set (gcf,'Position', [232,400,580,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,80],'lon',[-180,180]);
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
colormap(jet);

cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', -max:5:max);
set (gca,'Position',[0.09,0.1,0.78,0.8])

space(1 : 150) = 32; 
title(strcat('IAIS - GEOS-Chem (10^{-5} mol m^{-2})', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
axis normal;
saveas(fig, ['C:\Users\Administrator\Desktop\output\IASI-Chem.png']);
