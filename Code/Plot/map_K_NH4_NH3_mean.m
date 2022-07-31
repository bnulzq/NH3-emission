% mean spatial distribution of GEOS-Chem K (NH4/NH3) in ammonia-water equilibrium
clear all

path = 'D:\data\GEOS-Chem\concentration\GEOS-Chem_Total column_';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
lat_sta = 6;
lat_end = 41;

K = NaN([46, 72, yr_len*12], 'double');
for y = yr

    year = num2str(y);

    for m = 1:12

        mon = num2str(m, '%02d');
        nh4 = ncread([path, year, mon, '.nc'], 'GEOS-Chem monthly mean NH4')';
        nh3 = ncread([path, year, mon, '.nc'], 'GEOS-Chem monthly mean NH3')';
        K(:, :, (y - yr_sta)*12 + m) = nh4./nh3; % NH4+/NH3

    end
end

K = nanmean(K(lat_sta:lat_end, : ,:), 3);
thre = [50, 100, 200, 500];

for i = 1:4
   
    Ki = K;
    Ki(Ki>thre(i)) = nan;

    % lon and lat
    lon = ncread([path, year, mon, '.nc'], 'lon');
    lon = lon;
    lat = ncread([path, year, mon, '.nc'], 'lat');
    lat = lat(lat_sta:lat_end);
    [x,y] = meshgrid((lon) , (lat));

    max = 10;

    % draw
    fig = figure();
    set (gcf,'Position',[232,400,580,300]); %[left bottom width height]

    m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0)
    hold on

    sp = 40;
    [C,h] = m_contourf(x, y, Ki, 100);
    set(h,'LineColor','none');
    shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    caxis([0 max]);
    colormap(jet);
    
    if i == 4
        cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
        set(cb, 'YTick', 0:5:max);
        set (gca,'Position',[0.09,0.1,0.80,0.77])
    else
        set (gca,'Position',[0.09,0.1,0.86,0.77])
    end
    
    space(1 : 150) = 32; 
    title(strcat('K [NH^+_4/NH_3] (K<', num2str(thre(i)), ')', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    axis normal;
    saveas(fig, ['C:\Users\Administrator\Desktop\output\GEOS-Chem_k_', num2str(thre(i)), '.png']);

end

