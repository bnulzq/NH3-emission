% mean spatial distribution of CEDS-2017-05-18 Agriculture emissions (CMIP)
clear all

path = 'D:\data\CEDS\CEDS_grid_2008-2017\CEDS_';

yr_sta = 2008;
yr_end = 2017;
yr = yr_sta:1:yr_end;
yr_len = length(yr);

sectors = {'Agriculture', 'Energy', 'Industrial', 'Non-Road_Other Transportation', 'Road', 'Residential', 'Commercial', 'Other', 'Solvents production and application', 'Waste', 'International Shipping'};

% import data
agri = ncread([path, char(sectors(1)), '_2008-2017.nc'], char(sectors(1)));
total = zeros([720, 360, yr_len*12]);
for s = 1:length(sectors)

    total = total + ncread([path, char(sectors(s)), '_2008-2017.nc'], char(sectors(s)));

end
r = agri./total;
r = Regrid4x5(r, 2, 3);
agri = Regrid4x5(agri, 2, 3);

save([path, 'Agriculture_ratio_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'r');
save([path, 'Agriculture_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'agri');

r = nanmean(r, 3)';
r(r == 0) = NaN;

% regridded lon and lat grid
lon = ncread(['D:\data\GEOS-Chem\Emissions\Agriculture\HEMCO_sa.diagnostics.200801010000.nc'], 'lon');
lon = lon;
lat = ncread(['D:\data\GEOS-Chem\Emissions\Agriculture\HEMCO_sa.diagnostics.200801010000.nc'], 'lat');
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
sp = 40;

[C,h] = m_contourf(x, y, r, 500);
set(h,'LineColor','none');
shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(flipud(hot));

space(1 : 150) = 32; 
title(strcat('CEDS Agriculture Proportion', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
% text(-3, -1, '(a)', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')

axis normal;
%saveas(fig, ['C:\Users\Administrator\Desktop\output\GEOS-Chem emi.png']);
f = gcf;
exportgraphics(f,['C:\Users\Administrator\Desktop\output\cedsv2_agri_propor.png'],'Resolution',300)
