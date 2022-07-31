% plot the spatial distribution of uincertainty and sensitivity for MH3 emission over 2008-2018
clear

path = 'E:\\AEE\\data\\';
yr_sta = '2008';
yr_end = '2018';
yr_len = 11;

life = [50, 200];
ratio = [0.2, 5];
num = [400, 1200];
mul = 3600 * 24 * 365 * 1E3; % kg/m2/s -> g/a/m2

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

% emission
emi_data = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=800_r=1_w=0.05_', yr_sta, '-', yr_end, '.mat']).E;
emi = nanmean(emi_data, 3);

% uncertainty
un_life_bo = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_', num2str(life(2)), '%_NHx lifetime_with adjustment_optimized_emi_n=800_r=1_w=0.05_', yr_sta, '-', yr_end, '.mat']).E;
un_life_bo = nanmean(un_life_bo, 3);

un_life_up = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_', num2str(life(1)), '%_NHx lifetime_with adjustment_optimized_emi_n=800_r=1_w=0.05_', yr_sta, '-', yr_end, '.mat']).E;
un_life_up = nanmean(un_life_up, 3);

un_iasi = load([path, 'uncertainty\\Uncertainty_IASI_emi_', yr_sta, '-', yr_end, '.mat']).un;
un_iasi(un_iasi < 0) = NaN;
un_iasi = (nanmean(un_iasi, 3)/(12));

un_so2_up = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=800_r=1_w=0.06_', yr_sta, '-', yr_end, '.mat']).E;
un_so2_bo = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=800_r=1_w=0.04_', yr_sta, '-', yr_end, '.mat']).E;
un_so2_up = nanmean(un_so2_up, 3);
un_so2_bo = nanmean(un_so2_bo, 3);

un(:,:,1) = un_life_bo;
un(:,:,2) = un_life_up;
% un(:,:,6) = un_iasi + emi;
% un(:,:,5) = -un_iasi + emi;
un(:,:,3) = un_so2_up;
un(:,:,4) = un_so2_bo;

un(un<0) = NaN;

un_ia = un_iasi./emi*100.* (map_land>0);

un_ia_mean = un_iasi * mul .* (map_land>0);
un_mean(:, :, 1) = (nanmax(un, [], 3) - nanmin(un, [], 3)) * mul .* (map_land>0);
un_mean(:, :, 2) = un_ia_mean;

un_per = (nanmax(un, [], 3) - nanmin(un, [], 3))./emi*100 .* (map_land>0);

un1(:,:,1) = un_per;
un1(:,:,2) = un_ia;

% sensitivity
se_n_bo = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=', num2str(num(1)), '_r=1_w=0.05_', yr_sta, '-', yr_end, '.mat']).E;
se_n_bo = nanmean(se_n_bo, 3);

se_n_up = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=', num2str(num(2)), '_r=1_w=0.05_', yr_sta, '-', yr_end, '.mat']).E;
se_n_up = nanmean(se_n_up, 3);

se_r_up = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=800_r=', num2str(ratio(1)), '_w=0.05_', yr_sta, '-', yr_end, '.mat']).E;
se_r_up = nanmean(se_r_up, 3);

se_r_bo = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=800_r=', num2str(ratio(2)), '_w=0.05_', yr_sta, '-', yr_end, '.mat']).E;
se_r_bo = nanmean(se_r_bo, 3);

se(:,:,1) = se_n_bo;
se(:,:,2) = se_n_up;
se(:,:,3) = se_r_up;
se(:,:,4) = se_r_bo;
se(se<0) = NaN;

un_mean(:,:, 3) = (nanmax(se, [], 3) - nanmin(se, [], 3)) * mul .* (map_land>0);
se_per = (nanmax(se, [], 3) - nanmin(se, [], 3))./emi*100 .* (map_land>0);

un1(:,:,3) = se_per;
un_se = nanmax(un1, [], 3);

un2 = nanmax(un1, [], 3)/2;
un2(un2 > 100) = 100;
un2(un2 <= 0) = NaN;
un_mean_all = nanmax(un_mean, [], 3);
un_mean_all(un_mean_all <= 0) = NaN;

% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon;
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

% draw
% max1 = 100;
% max2 = 1;
% fig = figure();
% set (gcf,'Position',[232,400,700,300]); %[left bottom width height]
% 
% m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
% m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
% m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
% alpha(0)
% hold on
% 
% [C,h] = m_contourf(x, y, un2, 500);
% set(h,'LineColor','none');
% shp = shaperead('E:\AEE\code\fun\country\country.shp');
% boundary_x=[shp(:).X];
% boundry_y=[shp(:).Y];
% m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
% caxis([0 max1]);
% colormap(jet);
% 
% title('Relative uncertainty', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 
% % text(-3, -1, '(a)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')
% 
% cb = colorbar('eastoutside','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
% set(cb, 'YTick', 0:20:max1, ...
%     'TickLabels', {'0', '20', '40', '60', '80', '>100 (%)'});
% 
% set (gca,'Position',[0.09,0.1,0.70,0.80])
% axis normal;
% saveas(gcf, ['E:\AEE\Pap\ACP\figure\fig7.png']);
% 
figure();
set (gcf,'Position',[0,0,800*2+40,300], 'Units', 'normalized', 'OuterPosition', [0 0 1 1]); %[left bottom width height]
t = tiledlayout(1,2,'TileSpacing', 'tight', 'Position', [0.08,0.1,0.775,0.8]);

% uncertainty 1
ax1 = nexttile;
max1 = 100;  

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2,...
    'xtick', [-120, -60, 0, 60, 120]);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, un2, 500);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max1]);
colormap(ax1, jet);

cb = colorbar('eastoutside','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', 0:20:max1, ...
    'TickLabels', {'0', '20', '40', '60', '80', '>100 (%)'});

title('Relative', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 
text(-3, -1, '(a)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')


% sensitivity 2
ax2 = nexttile;
max2 = 1;

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2, ...
     'xtick',[-120, -60, 0, 60, 120]);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, un_mean_all, 500);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max2]);
colormap(ax2, jet);

title('Absolute', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 

cb = colorbar('eastoutside','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
text(-3, -1, '(b)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')

text(4, -0.3, 'g a^{-1} m^{-2}','fontsize', 15, 'FontName','Arial' , 'FontWeight' , 'normal', 'rotation',90)

f = t;
exportgraphics(f,['E:\AEE\Pap\ACP\figure\fig8.png'],'Resolution',300)

% uncertainty orf IASI
% fig = figure();
% set (gcf,'Position',[0,0,800+40,300], 'Units', 'normalized', 'OuterPosition', [0 0 .5 .5]); %[left bottom width height]
% m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
% m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
% m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 12, 'LineWidth', 2, 'xtick', []);
% alpha(0.5)
% hold on
% 
% [C,h] = m_contourf(x, y, un_ia, 500);
% set(h,'LineColor','none');
% shp = shaperead('E:\AEE\code\fun\country\country.shp');
% boundary_x=[shp(:).X];
% boundry_y=[shp(:).Y];
% m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
% caxis([0 max1]);
% colormap(jet);
% 
% title('Uncertainty from IASI observations', 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 
% % text(-3, -1, '(a)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')
% 
% cb = colorbar('eastoutside','fontsize', 20, 'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
% % text(-3, -1, '(b)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')
% set(cb, 'YTick', 0:20:max1, 'fontsize', 15,...
%     'TickLabels', {'0', '20', '40', '60', '80', '>100 (%)'});

