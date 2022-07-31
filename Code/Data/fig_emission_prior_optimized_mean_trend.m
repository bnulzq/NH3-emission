%joint the figure of NH3 emission mean and trend from optimized and GEOS-Chem
clear   

path =  'E:\AEE\data\';
fig_name = ['(a)'; '(b)'; '(c)'; '(d)'];

yr_sta = 2008;
yr_end = 2018;
yrs = yr_sta:1:yr_end;
yr_len = length(yrs);

thre_r = 1;
thre_n = 800;
mul = 1E+3 * 3600 * 365 * 24; % g/m2/yr
mul2 = 10;
% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

% emission
iasi = load([path, 'IASI\Emission\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_w=0.05_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).E*mul;
%iasi = load([path, 'uncertainty_lifetime_100%_2008-2018.mat']).un*;
geo = load([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.Total_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).data*mul;
iasi(iasi == 0) = NaN;

% fill the nan in iasi by geos-chem
iasi_yr = iasi;
iasi_yr(isnan(iasi_yr)) = 0;
iasi_yr = iasi_yr + geo .* isnan(iasi);
iasi_yr(iasi_yr == 0) = nan;

iasi_yr = reshape(iasi_yr, [46, 72, 12, yr_len]);
iasi_yr = squeeze(nanmean(iasi_yr, 3));

% iasi_2 = reshape(iasi, [46, 72, 12, yr_len]);
% iasi_2 = squeeze(mean(iasi_2, 3));
[iasi_tre, iasi_test] = Trend(iasi_yr, 46, 72, yr_len);

% filter the nan of iasi in geos-chem
geo = geo .* ~isnan(iasi);
geo(geo == 0) = NaN;

dif = nanmean(iasi - geo, 3) .* (map_land>0);
iasi = nanmean(iasi, 3) .* (map_land > 0);
geo = nanmean(geo, 3) .* (map_land > 0);
iasi_tre = iasi_tre .* (map_land > 0);
iasi_test = iasi_test .* (map_land > 0);

iasi(iasi == 0) = NaN;
geo(geo == 0) = NaN;
iasi_tre(iasi_tre == 0) = NaN;
iasi_test(iasi_test == 0) = NaN;
dif(dif == 0) = NaN;

% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon;
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

figure();
set (gcf,'Position',[0,0,800*2+40,300*4], 'Units', 'normalized', 'OuterPosition', [0 0 1 1]); %[left bottom width height]
t = tiledlayout(2,2,'TileSpacing', 'tight', 'Position', [0.08,0.1,0.775,0.8]);

% BUE1 1
ax1 = nexttile;
max1 = 4;  

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2, 'xtick', []);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, geo, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max1]);
cmp1 = importdata('E:\AEE\data\colormap\Reds.txt');
colormap(ax1, cmp1(:,1:3));

title('BUE1', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 
text(-3, -1, '(a)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')

% TDE 2
ax2 = nexttile;

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2, ...
    'ytick',[], 'xtick',[]);alpha(0.5)
hold on

[C,h] = m_contourf(x, y, iasi, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max1]);
colormap(ax2, cmp1(:,1:3));

title('TDE', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 

cb1 = colorbar('eastoutside','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb1, 'YTick', 0:1:max1, 'Position', [0.87 0.57 0.03 0.38]);
text(4., -0.6, 'g m^{-2} a^{-1}','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal', 'rotation',90)
text(-3, -1, '(b)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')


% TDE - BUE1 3
ax3 = nexttile;
max3 = 2;
max2 = 1;

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2,...
    'xtick',[-120, -60, 0, 60, 120]);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, dif, 1000);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max2 max2]);
cmp2 = importdata('E:\AEE\data\colormap\seismic.txt');
colormap(ax3, cmp2(:,1:3));

title('TDE - BUE1', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 
text(-3, -1, '(c)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')
text(-4.3, -1, 'g m^{-2} a^{-1}','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal', 'rotation',90)

cb1 = colorbar('westoutside','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb1, 'YTick', -max2:1:max2, 'Position', [0.03 0.15 0.025 0.38]);

% add rectangle %[left bottom width height]
rectangle('position',[-2.2, .45, 1, .4],'Edgecolor','g', 'linewidth', 2); % US
rectangle('position',[-1.45, -.6, .9, .7],'Edgecolor','g', 'linewidth', 2); % SA
rectangle('position',[-.2, .6, .7, .5],'Edgecolor','g', 'linewidth', 2); % EU
rectangle('position',[-.3, -.3, 1.2, .6],'Edgecolor','g', 'linewidth', 2); % TA
rectangle('position',[1.2, .1, .4, .5],'Edgecolor','g', 'linewidth', 2); % IP
rectangle('position',[1.1, .6, .3, .2],'Edgecolor','g', 'linewidth', 2); % PP
rectangle('position',[1.7, .4, .4, .4],'Edgecolor','g', 'linewidth', 2); % EC

text(-2.7, .7, 'US', 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold');
text(-1.9, -.3, 'SA', 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold');
text(-.7, .8, 'EU', 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold');
text(-.3, -.5, 'TA', 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold');
text(1.2, -.1, 'IP', 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold');
text(1.2, 1, 'CA', 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold');
text(2.2, .4, 'EC', 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold');


% TDE trend 4
ax4 = nexttile;

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2, ...
    'ytick',[], 'xtick', [-120, -60, 0, 60, 120]);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, iasi_tre*mul2, 1000);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max3 max3]);
colormap(ax4, cmp2(:,1:3));

[p_lat, p_lon] = find(iasi_test < 0.05);
p_lat = lat(p_lat);
p_lon = lon(p_lon);

m_scatter(p_lon, p_lat, 20, 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', '.') ;% mark the p 

title('TDE trend', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 

cb2 = colorbar('eastoutside','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb2, 'YTick', -max3:2:max3, 'Position', [0.87 0.15 0.018 0.3]);
text(4., -1, 'g m^{-2} a^{-1} decade^{-1}','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal', 'rotation',90)
text(-3, -1, '(d)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')

f = t;
exportgraphics(f,['E:\AEE\Pap\ACP\figure\fig2.png'],'Resolution',300)
%saveas(f, ['C:\Users\Administrator\Desktop\Pap\Results\fig3.svg'])
