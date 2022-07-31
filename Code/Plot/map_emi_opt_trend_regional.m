% regional trend of optimized emission
clear 

path =  'D:\data\';
% EC:29 35 57 62; Aus: 13 20 57 70; EU: 33 37 35 43; IP: 26 31 51 55; US: 30 35 12 23; Aus:

lat1 = 30;
lat2 = 34;
lon1 = 58;
lon2 = 62;

yr_sta = 2008;
yr_end = 2018;
yrs = yr_sta:1:yr_end;
yr_len = length(yrs);
thre_r = 1;
thre_n = 800;
mul = 1E+3 * 3600 * 365 * 24; % g/m2/yr

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;
map_land = reshape(repmat(map_land, 1, yr_len*12), [46, 72, 12*yr_len]);
opt = load([path, 'IASI\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).E;
geo = load([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.Total_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).data;

% fill the nan in iasi by geos-chem
emi = opt;
emi(isnan(emi)) = 0;
emi = emi + geo .* (isnan(opt));

emi = emi .* (map_land > 0)*mul;
emi(emi == 0) = NaN;
% emi(emi > 10) = NaN;

emi = reshape(emi, [46, 72, 12, yr_len]);
emi = squeeze(nanmean(emi, 3));
emi_mean = nanmean(emi, 3);

[emi_tre, emi_test] = Trend(emi, 46, 72, yr_len);
emi_tre_mean = nanmean(nanmean(emi_tre(lat1:lat2, lon1:lon2)));
emi_test = emi_test(lat1:lat2, lon1:lon2);

tre_rela = emi_tre(lat1:lat2, lon1:lon2)./emi_mean(lat1:lat2, lon1:lon2)*1000;
tre_rela(tre_rela>1000) = NaN;
tre_rela(tre_rela<-1000) = NaN;

tre_rela_mean = nanmean(nanmean(tre_rela));

% regridded lon and lat grid
lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon(lon1:lon2);
lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
lat = lat(lat1:lat2);
[x,y] = meshgrid((lon) , (lat));

max = 200;
% draw 
figure()
m_proj('Equidistant Cylindrical','lat',[double(lat(1)), double(lat(end))],'lon',[double(lon(1)), double(lon(end))]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, tre_rela, 2000);
set(h,'LineColor','none');
shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max max]);
cmp1 = importdata('D:\data\\colormap\bwr.txt');
colormap(cmp1(:,1:3));

[p_lat, p_lon] = find(emi_test < 0.05);
p_lat = lat(p_lat);
p_lon = lon(p_lon);
m_scatter(p_lon, p_lat, 30, 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', '.') ;% mark the p 

title(['Trend = ', num2str(roundn(tre_rela_mean, -1)), ' %']);
