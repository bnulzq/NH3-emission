% mean spatial distribution of SO2 burden from GEOS-Chem
clear

path = 'E:\AEE\data\GEOS-Chem\';
yr_sta = 2008;
yr_end = 2018;
yr_len = yr_end - yr_sta +1;

data = NaN([46, 72, yr_len], 'double');
for yr = yr_sta:yr_end

    year = num2str(yr);

    datayr = NaN([46, 72, 12], 'double');
    for m = 1:12

        month = num2str(m,'%02d');
        datayrm = ncread([path, 'OutputDir', num2str(year), '\GEOSChem.SpeciesConc.', year, month, '01_0000z.nc4'], 'SpeciesConc_SO2');
        datayr(:,:,m) = sum(datayrm, 3)';
        
    end
    data(:,:,yr-yr_sta+1) = mean(datayr, 3);
    
end

save([path, 'chem_so2_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'data');

% mean
data = mean(data, 3);

% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon+2.5;
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

mul = 1E9;
max = 50;
% draw
m_proj('Equidistant Cylindrical','lat',[-90,90],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0.5)
hold on

[C,h] = m_contourf(x, y, data*mul, 100);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(flipud(pink));

cb = colorbar('eastoutside','fontsize', 15, 'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2, 'TickLength', 0.03);
set(cb, 'YTick', [0:10:max]);

space(1 : 150) = 32; 
title(strcat('SO_2 burden (nmol mol^{-1})', space(1:25), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 

% f = gcf;
% exportgraphics(f,['C:\Users\Administrator\Desktop\Pap\figure\figS3.png'],'Resolution',300)
