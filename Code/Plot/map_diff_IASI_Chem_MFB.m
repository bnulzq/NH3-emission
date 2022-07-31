% mean spatial distribution of concentration difference with MFB between IASI and GEOS-Chem (validation)
clear

path = 'E:\AEE\data\';
year = '2008';
thre_n = 800;
thre_r = 1;

% import data
% land
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

D_d = NaN([46, 72, 12], 'double');
D_s = NaN([46, 72, 12], 'double');
D_nhx_d = NaN([46, 72, 12], 'double');
D_nhx_s = NaN([46, 72, 12], 'double');
D_12_d = NaN([46, 72, 12], 'double');
D_12_s = NaN([46, 72, 12], 'double');

yr = str2num(year);
load([path, 'GEOS-Chem\transport_to_emission_2008-2018.mat']); % transport/emission
r = r(:,:,(yr-2008)*12+1:(yr-2008+1)*12);

for m = 1:12

    mon = num2str(m, '%02d');

    geo = ncread([path, 'GEOS-Chem\concentration\GEOS-Chem_Total column_', year, mon, '.nc'], 'GEOS-Chem monthly mean NH3');
    geo_nhx = ncread([path, 'GEOS-Chem\validation2\GEOS-Chem_Total column_', year, mon, '_NHx.nc'], 'GEOS-Chem monthly mean NH3'); % mol m-2
    iasi = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'averaging nh3 filter'); % mol m-2
%     geo_12 = ncread([path, 'GEOS-Chem\validation\GEOS-Chem_Total column_', year, mon, '_12h.nc'], 'GEOS-Chem monthly mean NH3'); % mol m-2
    
    % overlap the threshold for number of retrieval and ratio
    N = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'Monthly number of retrievals'); 
    geo = geo';% .* (r(:,:, m) < thre_r) .* (N > thre_n);
%     geo_12 = geo_12';% .* (r(:,:, m) < thre_r) .* (N > thre_n);
    geo_nhx = geo_nhx';% .* (r(:,:, m) < thre_r) .* (N > thre_n);
    %iasi = iasi .* (r(:,:, m) < thre_r) .* (N > thre_n);
    
    D_d(:, :, m) = (geo - iasi);
    D_s(:, :, m) = (iasi + geo);
    D_nhx_d(:, :, m) = (geo_nhx - iasi);
    D_nhx_s(:, :, m) = (geo_nhx + iasi);
%     D_12_d(:, :, m) = (geo_12 - iasi);
%     D_12_s(:, :, m) = (geo_12 + iasi);
    
end

D = 2 * nansum(D_d, 3)./nansum(D_s, 3);
D(D == 0) = NaN;
D_nhx = 2 * nansum(D_nhx_d, 3)./nansum(D_nhx_s, 3);
D_nhx(D_nhx == 0) = NaN;
% D_12 = 2 * nansum(D_12_d, 3)./nansum(D_12_s, 3);
% D_12(D_12 == 0) = NaN;

save([path, 'GEOS-Chem\validation2\FB_IASI_GEOS-Chem_emission_D_d_', year, '.mat'], 'D_d'); % FB
save([path, 'GEOS-Chem\validation2\FB_IASI_GEOS-Chem_emission_D_s_', year, '.mat'], 'D_s'); % FB

save([path, 'GEOS-Chem\validation2\FB_IASI_GEOS-Chem_emission_nhx_D_d_', year, '.mat'], 'D_nhx_d'); % FB
save([path, 'GEOS-Chem\validation2\FB_IASI_GEOS-Chem_emission_nhx_D_s_', year, '.mat'], 'D_nhx_s'); % FB

% save([path, 'GEOS-Chem\validation\FB_IASI_GEOS-Chem_emission_12h_D_d_', year, '.mat'], 'D_12_d'); % FB
% save([path, 'GEOS-Chem\validation\FB_IASI_GEOS-Chem_emission_12h_D_s_', year, '.mat'], 'D_12_s'); % FB

D = D .* map_land;
D_nhx = D_nhx .* map_land;
D_12 = D_12 .* map_land;


% regridded lon and lat grid
lon = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'lon');
lat = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

mul = 100;
max = 200;
sp = 40;

% draw 1
fig = figure(1);
set (gcf,'Position', [232,400,580,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'normal', 'FontName', 'Arial','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, D*mul, 2000);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max max]);
cmp = importdata('E:\AEE\data\colormap\PiYG.txt');
colormap(flipud(cmp(:,1:3)));
% colormap(jet);

% set (gca,'Position',[0.09,0.1,0.78,0.8])

FB = round(2 * nansum(nansum(nansum(D_d, 3)))./nansum(nansum(nansum(D_s, 3)))*100);
text(-3, -0.5, ['FB=', num2str(FB), '%'], 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');
text(-3, -1, '(a)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')

space(1 : 150) = 32; 
title(strcat('BUE1', space(1:sp), year), 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 
axis normal;
saveas(fig, ['C:\Users\bnulzq\Desktop\test\IASI-Chem', year,'.png']);

% draw 2
fig = figure(2);
set (gcf,'Position', [232,400,580,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on
text(-3, -1, '(b)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')
[C,h] = m_contourf(x, y, D_nhx*mul, 2000);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max max]);
colormap(flipud(cmp(:,1:3)));
% colormap(jet);

%set (gca,'Position',[0.09,0.3,0.78,0.7])
FB_nhx = round(2 * nansum(nansum(nansum(D_nhx_d, 3)))./nansum(nansum(nansum(D_nhx_s, 3)))*100);
text(-3, -0.5, ['FB=', num2str(FB_nhx), '%'], 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');

space(1 : 150) = 32; 
title(strcat('TDE', space(1:sp), year), 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 
axis normal;
saveas(fig, ['C:\Users\bnulzq\Desktop\test\IASI-Chem_nhx', year ,'.png']);

% draw 3
fig = figure(3);
set (gcf,'Position', [232,400,625,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, D_12*mul, 2000);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max max]);
colormap(flipud(cmp(:,1:3)));
%colormap(jet);
cb = colorbar('eastoutside','fontsize',15,'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', -max:100:max);

FB_12 = round(2 * nansum(nansum(nansum(D_12_d, 3)))./nansum(nansum(nansum(D_12_s, 3)))*100);
text(-3, -0.5, ['FB=', num2str(FB_12), '%'], 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');

%set (gca,'Position',[0.09,0.3,0.78,0.7])
text(-3, -1, '(c)', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')

space(1 : 150) = 32; 
title(strcat('VD12', space(1:sp), year), 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold'); 
axis normal;
saveas(fig, ['C:\Users\bnulzq\Desktop\test\IASI-Chem_12h_', year ,'.png']);