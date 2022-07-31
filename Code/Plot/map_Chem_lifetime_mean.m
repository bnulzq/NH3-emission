% mean spatial distribution of GEOS-Chem lifetime (τ)
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
        lifetime = ncread([path, year, mon, '.nc'], 'lifetime');
        t(:, :, (y - yr_sta)*12 + m) = lifetime .* (rm<thre_r) .* (N>thre_n);
        %t(:, :, (y - yr_sta)*12 + m) = lifetime;
        
    end
end

%t(t<0) = NaN;
% t(t>1000) = NaN;
t(t == 0) = nan;
save([path, num2str(yr_sta), '-', num2str(yr_end), '.mat'], 't');

t = nanmean(t, 3) .* (map_land > 0);
t(t == 0) = nan;


lon = ncread([path, year, mon, '.nc'], 'lon');
lon = lon;
lat = ncread([path, year, mon, '.nc'], 'lat');
lat = lat(lat_sta:lat_end);
[x,y] = meshgrid((lon) , (lat));

max = 72;
min = 0;

% draw
fig = figure();
set (gcf,'Position',[232,400,700,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
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
colormap(cmp(:,1:3));

cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', min:24:max);
set (gca,'Position',[0.09,0.1,0.70,0.80])

space(1 : 150) = 32; 
title(strcat('Modelled lifetime (NHx)'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
%title(strcat('Modelled lifetime (hours)', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
text(4, -1.2, '[hours]', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'normal')
axis normal;
saveas(gcf, ['C:\Users\bnulzq\Desktop\test\lifetime_nhx.png']);
% f = gcf;
% exportgraphics(f,['C:\Users\bnulzq\Desktop\test\lifetime_nhx_adj.png'],'Resolution',300)

