% mean spatial distribution of GEOS-Chem simuilation
clear all

path =  'D:\data\GEOS-Chem\concentration_month\';

year = 2010;
mon_sta = 1;
mon_end = 12;
months = linspace(mon_sta, mon_end, mon_end);
mon_len = length(months);

% import data
nh3_day = zeros([72, 46, mon_len], 'double');
nh3_night = zeros([72, 46, mon_len], 'double');

for i = 1:mon_len
    month = num2str(i,'%02d');
    disp(['Year: ', num2str(year), ' Month: ', month])
    day = ncread([path, 'GEOS-Chem_', num2str(year), month, '.nc'], ['GEOS-Chem daytime simulation_', num2str(year), month]);
    night = ncread([path, 'GEOS-Chem_', num2str(year), month, '.nc'], ['GEOS-Chem nighttime simulation_', num2str(year), month]);

    nh3_day(:,:,i) = day;
    nh3_night(:,:,i) = night;
end

lon = ncread([path, 'GEOS-Chem_', num2str(year), month, '.nc'], 'lon');
lon = lon + 2.5;
lat = ncread([path, 'GEOS-Chem_', num2str(year), month, '.nc'], 'lat');

% nh3_day_inter = zeros([180, 360, mon_len], 'double');
% nh3_nig_inter = zeros([180, 360, mon_len], 'double');
% regridded lon and lat grid
% re = 1;
% lon = -180 + re/2: re : 180-re/2;
% lat = -90 + re/2 : re : 90 -re/2;
[x,y] = meshgrid((lon) , (lat));
%lon_num = length(lon);

% interpolation
% for i = mon_len
%     nh3_day_inter(:, :, i) = interp2(lon0, lat0, nh3_day(:, :, i)', x, y, 'linear');
%     nh3_nig_inter(:, :, i) = interp2(lon0, lat0, nh3_night(:, :, i)', x, y, 'linear');
% end

% mean
nh3_day = nanmean(nh3_day, 3);
nh3_nig = nanmean(nh3_night, 3);

% map
map = ncread('C:\Users\Administrator\Desktop\code\fun\map.nc', 'map');
map = map';
m = map(:,1:180);
map(:,1:180) = map(:,181:360);
map(:,181:360) = m;
map_land = (map ~= 0 & map ~= 2);
map_land = MapReclass(map_land, 72, 46);

nh3 = nh3_nig' .* map_land;
%nh3(nh3 == 0) = nan;
%draw map
m_proj('Equidistant Cylindrical','lat',[-90,90],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

mul = 1E+5;
max = 25; 

[C,h] = m_contourf(x, y, nh3*mul, 100);
set(h,'LineColor','none');
shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(flipud(hot));

cb = colorbar('southoutside','fontsize', 15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', 0:5:max);

space(1 : 150) = 32; 
title(strcat('GEOS-Chem simulation (10^{-5} Mol m^{-2})', space(1:15), num2str(year)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 



















% for i = 1:4
    
%     disp(['Figure: ', num2str(i)])
%     nh3_sea = nh3(:,:,:,i);
%     nh3_sea = squeeze(nanmean(nh3_sea, 3)).*single(map_land);
%     seai = sea(i);
    
%     % draw map
%     fig = figure('name', ['Figure: ', num2str(i)]);
%     %set(gcf, 'position', [1000 1000 500 500]);
%     m_proj('Equidistant Cylindrical','lat',[-90,90],'lon',[-180,180]);
%     m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
%     m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
%     alpha(0.5)
%     hold on

%     mul = 1E+4;
%     max = 5; 

%     [C,h] = m_contourf(x, y, nh3_sea*mul, 500);
%     set(h,'LineColor','none');
%     shp = shaperead('C:\Users\bnulzq\Documents\scientific research\extreme_ prediction\code\map\country\country.shp');
%     boundary_x=[shp(:).X];
%     boundry_y=[shp(:).Y];
%     m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
%     caxis([0 max]);
%     colormap(flipud(hot));
    
%     if strcmp(name1, 'Reanalyzed_day_2008-2016') && i == 1
%         cb = colorbar('southoutside','fontsize', 15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
%         set(cb, 'YTick', 0:1:max);
%     end
%     space(1 : 150) = 32; 
    
%     title(strcat('Standard Night (10^{-4} Mol m^{-2})', space(1:15), char(seai), ' (2008-2017)'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
%     %title(strcat('Reanalyzed Day (10^{-4} Mol m^{-2})', space(1:20), char(seai), ' (2008-2016)'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
%     hold on
%     set(gca,'position',[0.09,0,0.85,1] );
    
%     saveas(fig, [path, char(seai), '.tif'])
% end

