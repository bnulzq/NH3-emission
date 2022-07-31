% joint the figure of so2 burden and no2 burden
clear

path = 'E:\AEE\data\GEOS-Chem\';
yr_sta = 2008;
yr_end = 2018;
yr_len = yr_end - yr_sta +1;

% import data
so2 = load([path, 'chem_so2_2008-2018.mat']);
so2 = mean(so2.data, 3);

no2 = load([path, 'chem_no2_2008-2018.mat']);
no2 = mean(no2.data, 3);

% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon+2.5;
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

mul = 1E9;
max = 50;

% draw
figure(1);
set (gcf,'Position',[0,0,580+40,300*2]); %[left bottom width height]
t = tiledlayout(2,1,'TileSpacing', 'tight', 'Padding', 'normal', 'Position', [0.08,0.1,0.775,0.8]);

% so2
ax1 = nexttile;

m_proj('Equidistant Cylindrical','lat',[-90,90],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 12, 'LineWidth', 2, 'xtick', []);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, so2*mul, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(flipud(pink));

space(1 : 150) = 32; 
title(strcat('SO_2 burden (nmol mol^{-1})', space(1:25), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
text(-3, -1, '(a)', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')

% no2
ax2 = nexttile;

m_proj('Equidistant Cylindrical','lat',[-90,90],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 12, 'LineWidth', 2, 'xtick', []);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, no2*mul, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(flipud(pink));

cb = colorbar('eastoutside','fontsize', 15, 'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2, 'TickLength', 0.03);
set(cb, 'YTick', [0:10:max], 'Position', [0.9 0.15 0.04 0.7]);
%set(cb, 'YTickLabel', {'0', '1', '>2'});


space(1 : 150) = 32; 
title(strcat('NO_2 burden (nmol mol^{-1})', space(1:25), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
text(-3, -1, '(b)', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')

f = gcf;
exportgraphics(f,['E:\AEE\Pap\Results\figure\figS4.png'],'Resolution',300)

