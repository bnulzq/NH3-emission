% joint the figure of ratio of transport(-) to deposition and transport(+) to emisssion
clear

path = 'E:\AEE\data\GEOS-Chem\transport_to_';

yr_sta = 2008;
yr_end = 2018;

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

t_emi = load([path, 'emission_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).r;
t_dep = load([path, 'deposition_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).r;

t_emi = nanmean(t_emi, 3) .* (map_land > 0);
t_dep = nanmean(t_dep, 3) .* (map_land > 0);

t_emi(t_emi == 0) = NaN;
t_dep(t_dep == 0) = NaN;

max = 2;
figure();
set (gcf,'Position',[0,0,580+40,300*2]); %[left bottom width height]
t = tiledlayout(2,1,'TileSpacing', 'none', 'Padding', 'normal', 'Position', [0.08,0.1,0.775,0.8]);

% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon;
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

% tran/emi 1
ax1 = nexttile;

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, t_emi, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
cmp = importdata('E:\AEE\data\\colormap\PiYG.txt');
colormap(flipud(cmp(:,1:3)));

space(1 : 150) = 32; 
title(strcat('Transport/Emission', space(1:30), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Arial'); 
text(-3, -1, '(a)', 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold')

% tran/dep 2
ax2 = nexttile;

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, t_dep, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
cmp = importdata('E:\AEE\data\colormap\PiYG.txt');
colormap(flipud(cmp(:,1:3)));
title(strcat('Transport/Deposition', space(1:30), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Arial'); 

cb1 = colorbar('eastoutside','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb1, 'YTick', [0:1:max], 'Position', [0.9 0.15 0.04 0.7]);
set(cb1, 'YTickLabel', {'0', '1', '>2'});

text(-3, -1, '(b)', 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold')

f = gcf;
exportgraphics(f,['E:\AEE\Pap\Full\figure\figS4.png'],'Resolution',300)