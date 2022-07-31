% mean spatial distribution of IASI concentration difference with Van Dammes
clear

path = 'E:\AEE\data\';
yr_sta = 2008;
yr_end = 2016;
yr = yr_sta:1:yr_end;
yr_len = length(yr);

% import data
iasi_ = NaN([36, 72, yr_len*12], 'double');
iasi_v = load([path, 'IASI\ANNI-NH3\ANNI-NH3\IASI_01_', num2str(yr_sta), '-', num2str(yr_end), '.mat']);
iasi_v = iasi_v.data;

for y = yr

    year = num2str(y);

    for m = 1:12

        mon = num2str(m, '%02d');
        
        iasi = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'averaging nh3 filter'); % mol m-2
        iasi_(:,:,(y-yr_sta)*12+m) = iasi(6:41,:,:)*6.02214179E19; % mol m-2 to molecules cm-2

    end
end

iasi_mean = nanmean(iasi_, 3);
save([path, 'IASI\IASI_filter\IASI_filter_', num2str(yr_sta), '-', num2str(yr_end), '.mat']);
D = iasi_v - nanmean(iasi_, 3);
D_r = (iasi_v - nanmean(iasi_, 3))./iasi_v;

% regridded lon and lat grid
lon = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'lon');
lon = lon;
lat = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'lat');
lat = lat(6:41,:);
[x,y] = meshgrid((lon) , (lat));

mul1 = 1E-15;
mul2 = 100;
max1 = 15;
max2 = 100;

% draw
fig1 = figure(1);
set (gcf,'Position', [232,400,620,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0)
hold on

sp = 10;
[C,h] = m_contourf(x, y, D*mul1, 500);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max1, max1]);
cmp = importdata([path, 'colormap\bwr.txt']);
colormap(cmp(:,1:3));

cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', -max1:10:max1);
set (gca,'Position',[0.09,0.1,0.77,0.8])

space(1 : 150) = 32; 
title(strcat('Van - Our study (10^{15} molecules cm^{-2})', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
axis normal;
saveas(fig1, ['C:\Users\bnulzq\Desktop\test\IASI difference.png']);

D_r(abs(D_r) > 10) = nan;
% relative
fig2 = figure(2);
set (gcf,'Position', [232,400,620,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0)
hold on

sp = 30;
[C,h] = m_contourf(x, y, D_r*mul2, 2000);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([-max2, max2]);
cmp = importdata([path, 'colormap\bwr.txt']);
colormap(cmp(:,1:3));

cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', -max2:40:max2);
set (gca,'Position',[0.09,0.1,0.77,0.8])

space(1 : 150) = 32; 
title(strcat('Van - Our study (%)', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
axis normal;
saveas(fig2, ['C:\Users\bnulzq\Desktop\test\relative IASI difference.png']);
