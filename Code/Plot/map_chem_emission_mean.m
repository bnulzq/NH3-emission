% mean spatial distribution of GEOS-Chem emissions (HEMCO_diagnostics_NH3)
clear all

path = 'E:\AEE\data\GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.';

yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
emi_name = 'Natural';
thre_n = 800;
thre_r = 1;

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

% area
area = ncread('E:\AEE\data\GEOS-Chem\\OutputDir2008\\GEOSChem.Budget.20080101_0000z.nc4', 'AREA')'; % m-2

data = NaN([46, 72, yr_len*12], 'double');
E_yr = NaN([46, 72, yr_len], 'double');

for i = yr

    year = num2str(i);
    E_mon = NaN([46, 72, 12], 'double');
    for j = 1:12

        month = num2str(j, '%02d');
        
        e = ncread([path, year, month, '.nc'], emi_name)';
        data(:, :, (i-yr_sta)*12 + j) = e;
        E_mon(:, :, j) = e;
    end    
    E_mon(E_mon == 0) = nan;
    E_yr(:,:, i-yr_sta+1) = nanmean(E_mon, 3) .* (map_land > 0) .* area * 3600*24*365/1E+9;

end

emi = squeeze(nansum(nansum(E_yr, 1), 2));
emi_ave = mean(emi);
emi_std = std(emi);

save([path, emi_name, '_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'data'); % kg/m2/s

% iasi = load(['E:\AEE\data\IASI\optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_', num2str(yr_sta), '-', num2str(yr_end), '.mat']); % adjusted emissions
% iasi = iasi.E;
% data = data .* ~isnan(iasi);
% data(data == 0) = NaN;
% data = nanmean(data, 3) .* (map_land > 0) .* area' * 1E-6 * 3600*24*365; % total mass
data = nanmean(data, 3) .* (map_land > 0);

data(data == 0) = nan;

% regridded lon and lat grid
lon = ncread([path, year, month, '.nc'], 'lon');
lon = lon;
lat = ncread([path, year, month, '.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

mul = 1E+11;
max = 5; 
%draw map
fig = figure();
set (gcf,'Position',[232,400,620,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0)
hold on

% colorbar
cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', 0:2:max);
set (gca,'Position',[0.09,0.1,0.80,0.80])
sp = 30;

[C,h] = m_contourf(x, y, data*mul, 500);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(jet);

space(1 : 150) = 32; 
title(strcat('GEOS-Chem emissions', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
% text(-3, -1, '(a)', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')

axis normal;
saveas(fig, ['C:\Users\bnulzq\Desktop\test\Chem_emi.png']);

