% mean spatial distribution of IASI emissions (a box model)
clear all

path = 'D:\data\IASI\filter\IASI_filter_AM_Cloud_10_';

t = 12;
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);

data = NaN([46, 72, yr_len*12], 'double');
for i = yr

    year = num2str(i);

    for j = 1:12

        month = num2str(j, '%02d');

        data(:, :, (i-yr_sta)*12 + j) = ncread([path, year, month, '.nc'], 'averaging nh3 filter');
        
    end    
end

data = data*17/1000/t/3600;
save([path, 'emission_', num2str(yr_sta), '-', num2str(yr_end), '_τ=', num2str(t),'.mat'], 'data');
data = nanmean(data, 3);

% regridded lon and lat grid
lon = ncread([path, year, month, '.nc'], 'lon');
%lon = lon + 2.5;
lat = ncread([path, year, month, '.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

mul = 1E+11;
max = 10; 
%draw map
fig = figure();
set (gcf,'Position',[232,400,580,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0)
hold on

% colorbar
if t == 12
    
    cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
    set(cb, 'YTick', 0:2:max);
    set (gca,'Position',[0.09,0.1,0.80,0.8])
    sp = 10;
    
else
    
    set (gca,'Position',[0.09,0.1,0.86,0.8])
    sp = 15;
    
end

[C,h] = m_contourf(x, y, data*mul, 500);
set(h,'LineColor','none');
shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(jet);

space(1 : 150) = 32; 
title(strcat('IASI emissions (10^{-11} kg/m^{2}/s)', space(1:sp), num2str(yr_sta), '-', num2str(yr_end), ' (τ=', num2str(t), 'h)'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
axis normal;
saveas(fig, ['C:\Users\Administrator\Desktop\output\IASI emi_τ=',num2str(t),'.png']);


