% mean spatial distribution of IASI
clear all

path = 'E:\AEE\data\IASI\monthly\';

year = 2010;
mon_sta = 1;
mon_end = 12;
months = linspace(mon_sta, mon_end, mon_end);
mon_len = length(months);

% map
map = ncread('E:\AEE\code\fun\map.nc', 'map');
map_lon = ncread('E:\AEE\code\fun\map.nc', 'lon');
map = map';
m = map(:,1:180);
map(:,1:180) = map(:,181:360);
map(:,181:360) = m;
map_land = (map ~= 0 & map ~= 2);

nh3_day = zeros([46, 72, mon_len], 'double');
nh3_nig = zeros([46, 72, mon_len], 'double');

for i = 1:mon_len

    % import data
    month = num2str(i,'%02d');
    disp(['Year: ', num2str(year), ' Month: ', month])
    day = ncread([path, 'IASI_METOPA_L3_NH3_', num2str(year), month, '_ULB-LATMOS_V3R.0.0.nc'], 'NH3gridDAY');
    night = ncread([path, 'IASI_METOPA_L3_NH3_', num2str(year), month, '_ULB-LATMOS_V3R.0.0.nc'], 'NH3gridNIGHT');

    % missing value (-999)
    day(day == -999) = nan;
    night(night == -999) = nan;

    % mask ocean
    day = day .* map_land;
    night = night .* map_land;
    day(day == 0) = nan;
    night(night == 0) = nan;

    % interpolation
    nh3_day(:,:,i) = IASIregrid(day, 72, 46);
    nh3_nig(:,:,i) = IASIregrid(night, 72, 46);

end

% original lon and lat
lon0 = ncread([path, 'IASI_METOPA_L3_NH3_', num2str(year), month, '_ULB-LATMOS_V3R.0.0.nc'], 'longitude');
% lat0 = ncread([path, 'IASI_METOPA_L3_NH3_', num2str(year), month, '_ULB-LATMOS_V3R.0.0.nc'], 'latitude');

% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_', num2str(year), month, '.nc'], 'lon');
lon = lon + 2.5;
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_', num2str(year), month, '.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

nh3 = nanmean(nh3_day, 3);
%draw map
m_proj('Equidistant Cylindrical','lat',[-90,90],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

mul = 1E-15 *1/6.02214076E19;
max = 15; 

[C,h] = m_contourf(x, y, nh3*mul, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(flipud(hot));

cb = colorbar('southoutside','fontsize', 15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', 0:5:max);

space(1 : 150) = 32; 
title(strcat('IASI (10^{15} molecules cm^{-2})', space(1:45), num2str(year)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 

