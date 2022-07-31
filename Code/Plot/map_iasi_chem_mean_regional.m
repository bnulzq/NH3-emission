% average mean difference between IASI and GEOS-Chem monthly data
clear

path = 'D:\data\';

% Aus: 16 20 59 68; IP: 25 31 51 55; EU: 31 42 34 47; US: 30 36 13 25 
lat1 = 25;
lat2 = 30;
lon1 = 51;
lon2 = 55;

yr_sta = 2008;
yr_end = 2018;

% import data
iasi = load([path, 'IASI_monthly_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).iasi;
geo = load([path, 'GEOS-Chem_monthly_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).geo;

% mean difference
iasi = nanmean(nanmean(iasi(lat1:lat2, lon1:lon2,:,:), 4), 3)*1E4;
geo = nanmean(nanmean(geo(lat1:lat2, lon1:lon2,:,:), 4), 3)*1E4;
iasi_mean = nanmean(nanmean(iasi, 2), 1);
iasi_std = nanstd(nanstd(iasi));
geo_mean = nanmean(nanmean(geo, 2), 1);
geo_std = nanstd(nanstd(geo));
d_g = (iasi - geo)./geo*100;
d_i = (geo - iasi)./iasi*100;

% regridded lon and lat grid
lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon(lon1:lon2);
lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
lat = lat(lat1:lat2);
[x,y] = meshgrid((lon) , (lat));

max = 250;
% draw
data = d_g;
%data_mean = nanmean(nanmean(data));
data_mean = (iasi_mean - geo_mean)/geo_mean*100;
data_std = nanstd(nanstd(data));
figure()
m_proj('Equidistant Cylindrical','lat',[double(lat(1)), double(lat(end))],'lon',[double(lon(1)), double(lon(end))]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, data, 2000);
set(h,'LineColor','none');
shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max max]);
cmp1 = importdata('D:\data\\colormap\bwr.txt');
colormap(cmp1(:,1:3));

title(['MRD = ', num2str(roundn(data_mean, -2)), '% ± ', num2str(roundn(data_std, -2)), '%; IASI = ',...
    num2str(roundn(iasi_mean, -2)), ' ± ', num2str(roundn(iasi_std, -2)),...
    ' GEOS-Chem = ', num2str(roundn(geo_mean, -2)), ' ± ', num2str(roundn(geo_std, -2))]);