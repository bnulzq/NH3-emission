%joint the figure of NH3 concentrations mean and trend from IASI and GEOS-Chem
clear 

path =  'E:\AEE\data\';
fig_name = ['(a)'; '(b)'; '(c)'; '(d)'];

yr_sta = 2008;
yr_end = 2018;
yrs = yr_sta:1:yr_end;
yr_len = length(yrs);

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

iasi = NaN([46, 72, yr_len, 12]);
geo = NaN([46, 72, yr_len, 12]);

for y = yrs

    year = num2str(y);
    for m = 1:12
        
        month = num2str(m, '%02d');
        iasi(:,:,y-yr_sta+1,m) = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, month, '.nc'], 'averaging nh3 filter') .* map_land;
        geo(:,:,y-yr_sta+1,m) = ncread([path, '\GEOS-Chem\concentration_month\GEOS-Chem_', year, month, '.nc'], ['GEOS-Chem daytime simulation_', year, month])' .* map_land;

    end
end

iasi(iasi == 0) = NaN;
geo(geo == 0) = NaN;
save([path, 'IASI_monthly_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'iasi');
save([path, 'GEOS-Chem_monthly_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'geo');

iasi = nanmean(iasi, 4);
geo = nanmean(geo, 4);

% Mean
iasi_mean = nanmean(iasi, 3);
geo_mean = nanmean(geo, 3);

% Trend
[iasi_tre, iasi_test] = Trend(iasi, 46, 72, yr_len);
[geo_tre, geo_test] = Trend(geo, 46, 72, yr_len);


% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon;
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

figure();
set (gcf,'Position',[0,0,800*2+40,300*4], 'Units', 'normalized', 'OuterPosition', [0 0 1 1]); %[left bottom width height]
t = tiledlayout(2,2,'TileSpacing', 'tight', 'Position', [0.08,0.1,0.775,0.8]);

% IASI mean 1
ax1 = nexttile;
max1 = 5;
mul1 = 1E4;

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2, 'xtick', []);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, iasi_mean*mul1, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max1]);
cmp1 = importdata('E:\AEE\data\colormap\Reds.txt');
colormap(ax1, cmp1(:,1:3));

title('IASI', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 
text(-4, -0.5, 'Mean', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold','rotation', 90)
text(-3, -1, '(a)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')

% GEOS-Chem mean 2
ax2 = nexttile;

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2, ...
    'ytick',[], 'xtick',[]);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, geo_mean*mul1, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max1]);
cmp1 = importdata('E:\AEE\data\colormap\Reds.txt');
colormap(ax2, cmp1(:,1:3));

title('GEOS-Chem', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 
cb1 = colorbar('eastoutside','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb1, 'YTick', 0:1:max1, 'Position', [0.87 0.56 0.023 0.36]);
text(4.4, -0.6, '10^{-4} mol m^{-2}','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal', 'rotation',90)
text(-3, -1, '(b)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')

% IASI absolute trend 3
ax3 = nexttile;
p = 0.05;
max2 = 5;
mul2 = 1E6;

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2, 'xtick',[-120, -60, 0, 60, 120]);
alpha(0.5)
hold on

[p_lat, p_lon] = find(iasi_test < p);
p_lat = lat(p_lat);
p_lon = lon(p_lon);

[C,h] = m_contourf(x, y, iasi_tre*mul2, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
m_scatter(p_lon, p_lat, 20, 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', '.') ;% mark the p 

caxis([-max2 max2]);
cmp = importdata('E:\AEE\data\colormap\bwr.txt');
colormap(ax3, cmp(:,1:3));

text(-4, -0.5, 'Trend', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold', 'rotation', 90)
text(-3, -1, '(c)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')

% GEOS-Chem absolute trend 4
ax4 = nexttile;

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2, ...
    'ytick',[], 'xtick',[-120, -60, 0, 60, 120]);
alpha(0.5)
hold on

[p_lat, p_lon] = find(geo_test < p);
p_lat = lat(p_lat);
p_lon = lon(p_lon);
m_scatter(p_lon, p_lat, 30, 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', '.') ;% mark the p 

[C,h] = m_contourf(x, y, geo_tre*mul2, 1000);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
m_scatter(p_lon, p_lat, 20, 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', '.') ;% mark the p 

caxis([-max2 max2]);
cmp = importdata('E:\AEE\data\colormap\seismic.txt');
colormap(ax4, cmp(:,1:3));

cb2 = colorbar('eastoutside','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb2, 'YTick', -max2:2:max2, 'Position', [0.87 0.16 0.019 0.30]);
text(4.4, -1, '10^{-6} mol m^{-2} a^{-1}','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal', 'rotation',90)
text(-3, -1, '(d)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')

f = t;
%exportgraphics(f,['C:\Users\Administrator\Desktop\Pap\Method\fig1.png'],'Resolution',300)
exportgraphics(f,['E:\AEE\Pap\Full\figure\fig1.png'],'Resolution',300)
