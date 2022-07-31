% monthly mean spatial distribution of number of retrievals for IASI
% filtered daily data and emission data
clear all

path = 'D:\data\IASI\IASI_filter\IASI_filter_AM_Cloud_10_';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
mons = 'JFMAMJJASOND';

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;
n_re = NaN([46, 72, 12*yr_len]);
load([ 'D:\data\GEOS-Chem\transport_to_emission_2008-2018.mat']); % transport/emission
r = r(:,:,(yr_sta-2008)*12+1:(yr_end-2008+1)*12);
thre_r = 1;

for y = yr
    
    year = num2str(y);

    for m = 1:12

        mon = num2str(m, '%02d');
        n_reym = ncread([path, year, mon, '.nc'], 'Number of retrievals');
         n_re(:, :, (y-yr_sta)*12+m) = nanmean(n_reym, 3) .* (r(:, :, (y-yr_sta)*12+m) < thre_r); % transport/emission < r
%        n_re(:, :, (y-yr_sta)*12+m) = nanmean(n_reym, 3); % original
    end
end

n_re = nanmean(n_re, 3) .* (map_land > 0);
n_re(n_re == 0) = NaN;

% regridded lon and lat grid
lon = ncread([path, year, mon, '.nc'], 'lon');
lon = lon;
lat = ncread([path, year, mon, '.nc'], 'lat');
lat = lat;
[x,y] = meshgrid((lon) , (lat));

max = 100;
% draw

fig = figure();
set (gcf,'Position',[232,400,623.5,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70, 70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, n_re, 100);
set(h,'LineColor','none');

shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(jet);

space(1 : 150) = 32; 
cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', 0:20:max);
set (gca,'Position',[0.09,0.1,0.80,0.80])
%title(strcat('IASI number of retrievals (n/day)', space(1:35), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
title(strcat('IASI number of retrievals (n/day) (Trans < Emi0)', space(1:10), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
%text(4, -1.2, '[N grid^{-1} day^{-1}]', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'normal')
%text(-3, -1, '(a)', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')

axis normal;
f = gcf;
exportgraphics(f,['C:\Users\Administrator\Desktop\output\IASI_n.png'],'Resolution',300)
%close
