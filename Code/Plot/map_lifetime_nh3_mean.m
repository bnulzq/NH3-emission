% mean spatial distribution of GEOS-Chem lifetime (nh3)
% original and adjustment
clear all

path = 'E:\AEE\data\GEOS-Chem\Budget\GEOS-Chem_lifetime_';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
lat_sta = 1;
lat_end = 46;
thre_n = 800;
thre_r = 1;

% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;
r = load(['E:\AEE\data\GEOS-Chem\transport_to_emission_2008-2018.mat']); % transport/emission
r = r.r;
t = NaN([46, 72, yr_len*12], 'double');

for y = yr

    year = num2str(y);

    for m = 1:12

        mon = num2str(m, '%02d');
        N = ncread(['E:\AEE\data\IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'Monthly number of retrievals'); 
        rm = r(:,:,(y - yr_sta)*12 + m);
        lifetime = ncread([path, year, mon, '.nc'], 'NHx lifetime');
        t(:, :, (y - yr_sta)*12 + m) = lifetime;% .* (rm<thre_r) .* (N>thre_n);
        
    end
end

t(t <= 0) = nan;
save([path, 'NH3_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 't');

t = nanmean(t, 3).* (map_land > 0); % .* (map_land > 0)
t(t == 0) = nan;

lon = ncread([path, year, mon, '.nc'], 'lon');
lat = ncread([path, year, mon, '.nc'], 'lat');
lat = lat(lat_sta:lat_end);
[x,y] = meshgrid((lon) , (lat));

max = 50;
min = 0;

% draw
fig = figure();
set (gcf,'Position',[232,400,580+40,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial','fontsize', 15, 'LineWidth', 2);
alpha(0)
hold on

sp = 20;
[C,h] = m_contourf(x, y, t, 500);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([min max]);
cmp = importdata('E:\AEE\data\\colormap\BuPu.txt');
colormap(jet(10));
% 
cb = colorbar('eastoutside','fontsize',15,'FontName','Arial' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', min:5:max, ...
    'TickLabels', {'0', '5', '10', '15', '20', '25', '30', '35', '40', '45', '>50 (h)'});
set (gca,'Position',[0.09,0.1,0.74,0.78])

space(1 : 150) = 32; 
title(['Modelled lifetime of ','NH_{3}'], 'FontSize' , 15 , 'FontName' ,'Arial'); 
axis normal;
saveas(gcf, ['E:\AEE\Pap\Full\figure\fig6.png']);