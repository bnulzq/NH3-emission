% average mean difference between optimized emission and GEOS-Chem monthly data
clear

path = 'E:\AEE\data\';
% EC:29 35 57 62; EU: 33 37 35 43; IP: 26 31 51 55; US: 30 35 12 23; Aus:
% 13 20 57 70; SA: 12 25 20 33; TA: 19 27 33 48
lat1 = 29;
lat2 = 35;
lon1 = 57;
lon2 = 62;

yr_sta = 2008;
yr_end = 2018;

thre_n = '800';
thre_r = '1';
mul = 1E3 * 36000 * 24 * 365;

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

opt = load([path, 'IASI\Emission\NHx lifetime_with adjustment_optimized_emi_n=', thre_n,'_r=', thre_r, '_', num2str(yr_sta), '-', num2str(yr_end), '.mat']);
opt = opt.E;
geo = load([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.Total_', num2str(yr_sta), '-', num2str(yr_end), '.mat']);
geo = geo.data;



% mean difference
geo = geo .* ~isnan(opt);
geo(geo == 0) = NaN;

opt_mon = squeeze(nanmean(nanmean(opt(lat1:lat2, lon1:lon2,1))))*mul/12;
%opt = opt(:,:,1);
%geo = geo(:,:,1);
opt = nanmean(opt, 3) .* (map_land > 0);
geo = nanmean(geo, 3) .* (map_land > 0);

opt(opt == 0) = NaN;
geo(geo == 0) = NaN;

opt = opt(lat1:lat2, lon1:lon2)*mul;
geo = geo(lat1:lat2, lon1:lon2)*mul;

opt_mean = nanmean(nanmean(opt));
geo_mean = nanmean(nanmean(geo));

d_g = (opt - geo)./geo*100;
d_mean = (opt_mean - geo_mean)/geo_mean*100;

% regridded lon and lat grid
lon = ncread([path, 'GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon(lon1:lon2);
lat = ncread([path, 'GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
lat = lat(lat1:lat2);
[x,y] = meshgrid((lon) , (lat));

max = 100;
% draw
fig = figure()
set (gcf,'Position',[232,400,620,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[double(lat(1)), double(lat(end))],'lon',[double(lon(1)), double(lon(end))]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, d_g, 2000);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max max]);
cmp1 = importdata([path, 'colormap\bwr.txt']);
colormap(cmp1(:,1:3));

cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', -max:50:max);
set (gca,'Position',[0.09,0.1,0.76,0.80])
axis normal;

title(['MRD = ', num2str(roundn(d_mean, -2)), '%; Top-down = ', num2str(roundn(opt_mean, -2)),...
    ' Bottom-up = ', num2str(roundn(geo_mean, -2))]);

saveas(fig, ['C:\Users\bnulzq\Desktop\test\emi_IASI-Chem_nhx.png']);
