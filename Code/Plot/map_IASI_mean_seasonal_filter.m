% seasonal mean spatial distribution of IASI daily filtered/unfiltered data
clear all

path = 'D:\data\IASI\IASI_filter\IASI_filter_AM_Cloud_10_';

yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
season = [[1, 2, 3]; [4, 5, 6]; [7, 8, 9]; [10, 11, 12]]; 
season_name = ['JFM'; 'AMJ'; 'JAS'; 'OND'];
fig_name = ['(a)'; '(b)'; '(c)'; '(d)';];

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

for sea = 1:4
    
    mon = season(sea, :);
    disp(['Season: ', season_name(sea, :)])
    fi_yr = NaN([46, 72, yr_len], 'double');
    ufi_yr = NaN([46, 72, yr_len], 'double');
    
    for i = 1:yr_len
        
        year = num2str(yr(i));
        fi_sea = NaN([46, 72, 3], 'double');
        ufi_sea = NaN([46, 72, 3], 'double');

        % import data 
        for j = 1:3

            month = num2str(mon(j), '%02d');
            fi_sea(:, :, j) = ncread([path, year, month, '.nc'], 'averaging nh3 filter');
%             ufi_sea(:, :, j) = ncread([path, year, month, '.nc'], 'averaging nh3 unfilter');

            % mask ocean
            fi_sea = fi_sea .* (map_land > 0);

        end
        
        fi_sea(fi_sea == 0) = NaN;
        fi_yr(:, :, i) = nanmean(fi_sea, 3);
%         ufi_yr(:, :, i) = nanmean(ufi_sea, 3);
    end

    save([path, season_name(sea, :), '_IASI filter.mat'], 'fi_yr')

    % regridded lon and lat grid
    lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_', year, month, '.nc'], 'lon');
    lon = lon;
    lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_', year, month, '.nc'], 'lat');
    [x,y] = meshgrid((lon) , (lat));

    nh3 = nanmean(fi_yr, 3);

    mul = 1E4;
    max = 5; 
    %draw map
    fig = figure(sea);
    set (gcf,'Position',[232,400,620,300]); %[left bottom width height]

    m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0.5)
    hold on

    % day
    [C,h] = m_contourf(x, y, nh3*mul, 100);
    set(h,'LineColor','none');
    shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    caxis([0 max]);
    cmp = importdata('D:\data\\colormap\Reds.txt');
    colormap(cmp(:,1:3));

    space(1 : 150) = 32; 
    %title(strcat('IASI (10^{15} molecules cm^{-2})', space(1:25), season_name(sea,:), ' (', num2str(yr_sta), '-', num2str(yr_end), ')'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    text(-3, -1, fig_name(sea,:), 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')
    set (gca,'Position',[0.09,0.1,0.8,0.85])
    if sea == 4
        set (gca,'Position',[0.09,0.1,0.9,0.85])
        cb = colorbar('eastoutside','fontsize', 15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
        set(cb, 'YTick', 0:1:max);
    end
    
%     axis normal;
%     saveas(fig, ['C:\Users\Administrator\Desktop\output\IASI_', season_name(sea,:), '.svg'])
    f = gcf;
    exportgraphics(f,['C:\Users\Administrator\Desktop\output\IASI_', season_name(sea,:), '.png'],'Resolution',900)

end