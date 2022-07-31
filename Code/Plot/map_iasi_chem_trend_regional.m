% average trend difference between IASI and GEOS-Chem monthly data
clear

path = 'E:\AEE\data\';

% Aus: 16 20 59 68; IP: 25 31 51 55; EU: 33 37 35 43; US: 31 35 12 23; EC:29 35 57 62; TA: 19 28 33 45  
% CHN: 29 35 55 62
lat1 = 25;
lat2 = 31;
lon1 = 51;
lon2 = 55;

yr_sta = 2008;
yr_end = 2018;
yr_len = yr_end-yr_sta+1;

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

iasi = load([path, 'IASI_monthly_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).iasi;
geo = load([path, 'GEOS-Chem_monthly_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).geo;

iasi = squeeze(nanmean(iasi, 4));
geo = squeeze(nanmean(geo, 4));

% Trend
[iasi_tre, iasi_test] = Trend(iasi, 46, 72, yr_len);
[geo_tre, geo_test] = Trend(geo, 46, 72, yr_len);

iasi_tre = iasi_tre .* (map_land>0);
iasi_test = iasi_test.* (map_land>0);

geo_tre = geo_tre .* (map_land>0);
geo_test = geo_test.* (map_land>0);

iasi_test = iasi_test(lat1:lat2, lon1:lon2);
geo_test = geo_test(lat1:lat2, lon1:lon2);


% mean
iasi = squeeze(nanmean(iasi(lat1:lat2, lon1:lon2,:,:), 3));
geo = squeeze(nanmean(geo(lat1:lat2, lon1:lon2,:,:), 3));

iasi_mean = nanmean(nanmean(iasi_tre(lat1:lat2, lon1:lon2)))*1E6;
iasi_std = nanstd(nanstd(iasi_tre(lat1:lat2, lon1:lon2)))*1E6;

geo_mean = nanmean(nanmean(geo_tre(lat1:lat2, lon1:lon2)))*1E6;
geo_std = nanstd(nanstd(geo_tre(lat1:lat2, lon1:lon2)))*1E6;

i_test_mean = nanmean(nanmean(iasi_test));
g_test_mean = nanmean(nanmean(geo_test));

i_t_r = iasi_tre(lat1:lat2, lon1:lon2)./iasi*100;
g_t_r = geo_tre(lat1:lat2, lon1:lon2)./geo*100;

% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon(lon1:lon2);
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
lat = lat(lat1:lat2);
[x,y] = meshgrid((lon) , (lat));

set (gcf,'Position',[0,0,100,50*1], 'Units', 'normalized', 'OuterPosition', [0 0 1 1]); %[left bottom width height]
t = tiledlayout(1,2,'TileSpacing', 'tight', 'Position', [0.08,0.1,0.775,0.8]);

max = 5;
% draw iasi
ax1 = nexttile;
data = i_t_r;
data(data>500) = NaN;
data(data<-500) = NaN;
data_mean = nanmean(nanmean(data));
data_std = nanstd(nanstd(data));
m_proj('Equidistant Cylindrical','lat',[double(lat(1)), double(lat(end))],'lon',[double(lon(1)), double(lon(end))]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, data, 500);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max max]);
cmp1 = importdata('E:\AEE\data\colormap\bwr.txt');
colormap(ax1, cmp1(:,1:3));

[p_lat, p_lon] = find(iasi_test < 0.05);
p_lat = lat(p_lat);
p_lon = lon(p_lon);
m_scatter(p_lon, p_lat, 1000, 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', '.') ;% mark the p 
text(-0.15, 0.15, '(a)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')

title(['IASI Trend = ', num2str(roundn(data_mean, -1)), '% a^{-1}, p = ',num2str(roundn(i_test_mean, -2))], 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');

% draw geo
ax2 = nexttile;

data = g_t_r;
data_mean = nanmean(nanmean(data));
data_std = nanstd(nanstd(data));

m_proj('Equidistant Cylindrical','lat',[double(lat(1)), double(lat(end))],'lon',[double(lon(1)), double(lon(end))]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, data, 500);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max max]);
cmp1 = importdata('E:\AEE\data\\colormap\bwr.txt');
colormap(ax2, cmp1(:,1:3));


[p_lat, p_lon] = find(geo_test < 0.05);
p_lat = lat(p_lat);
p_lon = lon(p_lon);
m_scatter(p_lon, p_lat, 1000, 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', '.') ;% mark the p 

title(['GEOS-Chem Trend = ', num2str(roundn(data_mean, -1)), '% a^{-1}, p = ',num2str(roundn(g_test_mean, -2))], 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');
cb1 = colorbar('eastoutside','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb1, 'YTick', -max:2:max, 'Position', [0.87 0.1 0.03 0.8]);
% text(0.29, 0.2, '10^{-6} mol m^{-2} a^{-1}','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal', 'rotation',90)
text(-0.15, 0.15, '(b)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')
f = t;
exportgraphics(f,['E:\AEE\Pap\ACP\figure\figc.png'],'Resolution',500)