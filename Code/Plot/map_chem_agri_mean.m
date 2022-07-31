% mean spatial distribution of GEOS-Chem Agriculture emissions (CEDS)
clear all

path = 'D:\data\GEOS-Chem\Emissions\';

yr_sta = 2008;
yr_end = 2017;
yr = yr_sta:1:yr_end;
yr_len = length(yr);

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

% total = load([path, 'Total\HEMCO_diagnostics_NH3.Total_2008-2018.mat']).data;
% total = total(:, ;, yr_sta - 2017:yr_end - 2017);

agri = NaN([46, 72, yr_len*12], 'double');
total = NaN([46, 72, yr_len*12], 'double');
for i = yr

    year = num2str(i);

    for j = 1:12

        month = num2str(j, '%02d');
        
        data = ncread([path, 'Agriculture\HEMCO_sa.diagnostics.', year, month, '010000.nc'], 'EmisNH3_Anthro');
        agri(:, :, (i-yr_sta)*12 + j) = nansum(data, 3)';
        data = ncread([path, 'Total\HEMCO_diagnostics_NH3.', year, month, '.nc'], 'Anthro');
        total(:, :, (i-yr_sta)*12 + j) = nansum(data, 3)';
        
    end

end

r = agri./total;
save([path, 'Agriculture_ratio_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'r');
save([path, 'Agriculture_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'agri');

r = nanmean(r, 3);
r(r == 0) = NaN;

% regridded lon and lat grid
lon = ncread([path, 'Agriculture\HEMCO_sa.diagnostics.', year, month, '010000.nc'], 'lon');
lon = lon;
lat = ncread([path, 'Agriculture\HEMCO_sa.diagnostics.', year, month, '010000.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

max = 1;
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
set(cb, 'YTick', 0:.5:max);
set (gca,'Position',[0.09,0.1,0.80,0.80])
sp = 20;

[C,h] = m_contourf(x, y, r, 500);
set(h,'LineColor','none');
shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(flipud(hot));

space(1 : 150) = 32; 
title(strcat('GEOS-Chem Agriculture Proportion', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
% text(-3, -1, '(a)', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')

axis normal;
%saveas(fig, ['C:\Users\Administrator\Desktop\output\GEOS-Chem emi.png']);
f = gcf;
exportgraphics(f,['C:\Users\Administrator\Desktop\output\Chem_agri_propor.png'],'Resolution',300)
