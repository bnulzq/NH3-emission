% mean spatial distribution of GEOS-Chem τ
clear all

path = 'D:\data\GEOS-Chem\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);

% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

C = NaN([46, 72, yr_len*12], 'double');
E = NaN([46, 72, yr_len*12], 'double');

for i = yr

    year = num2str(i);

    for j = 1:12

        month = num2str(j, '%02d');

        C(:, :, (i-yr_sta)*12 + j) = ncread([path, 'concentration_month\GEOS-Chem_', year, month, '.nc'], ['GEOS-Chem daytime simulation_', year, month])';
        E(:, :, (i-yr_sta)*12 + j) = ncread([path, 'Emissions\HEMCO_diagnostics_NH3.', year, month, '.nc'], 'Total')';
        
    end    
end

E(E == 0) = NaN;
C(C == 0) = NaN;
M = C.*17/1000/3600;
data = M./E;
data(data > 100) = NaN;
data = nanmean(data, 3);
data = data.*map_land;
lon = ncread([path, 'concentration_month\GEOS-Chem_', year, month, '.nc'], 'lon');
lon = lon;
lat = ncread([path, 'concentration_month\GEOS-Chem_', year, month, '.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

mul = 1;
max = 48;
min = 0;

% draw
fig = figure();
set (gcf,'Position',[232,400,580,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0)
hold on

sp = 50;
[C,h] = m_contourf(x, y, data*mul, 500);
set(h,'LineColor','none');
shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([min max]);
colormap(jet);
% 
% cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
% set(cb, 'YTick', min:5:max);
set (gca,'Position',[0.09,0.1,0.86,0.8])

space(1 : 150) = 32; 
title(strcat('τ = M/E (hours)', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
axis normal;
saveas(fig, ['C:\Users\Administrator\Desktop\output\GEOS-Chem_τ.png']);
