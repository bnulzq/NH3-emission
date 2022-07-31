% calculate the IASI (0.01°×0.01°) emissions (12h lifetime) over 2008-2016
clear

path = 'E:\AEE\data\';
t = 12; % h
mul = 1/6.02214076E19 * 17 / 1000 / 3600; % kg s-1
mul1 = 1E-9 * 3600 * 24 * 365; % Tg yr-1
% import data
iasi = load([path, 'IASI\ANNI-NH3\ANNI-NH3\IASI_01_2008-2016.mat']);
iasi = iasi.data;
area = ncread([path, 'GEOS-Chem\OutputDir2008\GEOSChem.Budget.20080101_0000z.nc4'], 'AREA')';
area = area(6:41,:);

% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_201601.nc'], 'lon');
lon = lon;
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_201601.nc'], 'lat');
lat = lat(6:41);
[x,y] = meshgrid((lon) , (lat));

% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

% emission
emi = iasi/t .* area * mul;
data = iasi/t .* mul.* (map_land(6:41,:)>0); % .* (map_land(6:41,:)>0)
data(data == 0) = nan;
emi_total = nansum(nansum(data.*area)) * mul1;

max = 5;
mul2 = 1E+11;
% % draw
fig = figure(1);
set (gcf,'Position',[232,400,620,300]);

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, data*mul2, 100);
set(h,'LineColor','none');
caxis([0 max]);
colormap(jet);
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
hold on 

space(1 : 150) = 32; 
set (gca,'Position',[0.09,0.1,0.86,0.8]) %[left bottom width height]
title(strcat('Emission (IASI 0.01x0.01, lifetime = 12h)', space(1:20), '2008-2016'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 

axis normal;
saveas(fig, 'C:\Users\bnulzq\Desktop\test\IASI_01_emi.png');
