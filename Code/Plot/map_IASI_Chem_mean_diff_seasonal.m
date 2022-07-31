% seasonal mean difference spatial distribution of GEOS-Chem simuilation and IASI
clear all

path =  'D:\data\';

yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
season = [[1, 2, 3]; [4, 5, 6]; [7, 8, 9]; [10, 11, 12]]; 
season_name = ['JFM'; 'AMJ'; 'JAS'; 'OND'];

for sea = 1:4

    disp(['Season: ', season_name(sea, :)])
    
    % import data
    iasi = load([path, '\IASI\filter\', season_name(sea, :), '_IASI filter']).fi_yr;
    geo = load([path, '\GEOS-Chem\concentration_month\', season_name(sea, :), '_Chem']).nh3_day;

    % regridded lon and lat grid
    lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_201801.nc'], 'lon');
    lon = lon;
    lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_201801.nc'], 'lat');
    [x,y] = meshgrid((lon) , (lat));

    nh3 = nanmean(iasi - geo, 3);

    mul = 1E-15*6.02214179E19;
    max = 10; 
    
    %draw map
    fig = figure(sea);
    set (gcf,'Position',[232,400,580,300]); %[left bottom width height]

    m_proj('Equidistant Cylindrical','lat',[-90,90],'lon',[-180,180]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0.5)
    hold on

    % day
    [C,h] = m_contourf(x, y, nh3*mul, 500);
    set(h,'LineColor','none');
    shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    caxis([-max max]);
    colormap(jet);

    space(1 : 150) = 32; 
    
    if sea == 4
        cb = colorbar('eastoutside','fontsize', 15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
        set(cb, 'YTick', -max:10:max);
        set (gca,'Position',[0.09,0.1,0.78,0.8])
        title(strcat('IASI - GEOS-Chem (10^{15} molecules cm^{-2})', space(1:5), season_name(sea,:), ' (', num2str(yr_sta), '-', num2str(yr_end), ')'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
        % rectangle
        annotation(fig, 'rectangle', [0.625 0.52 0.155 0.23], 'Color', [1 0 1], 'LineWidth', 2); % India-China
        annotation(fig, 'rectangle', [0.435 0.33 0.165 0.35], 'Color', [1 0 1], 'LineWidth', 2); % Africa
        annotation(fig, 'rectangle', [0.295 0.24 0.115 0.325], 'Color', [1 0 1], 'LineWidth', 2); % Southern America
            
    else
        set (gca,'Position',[0.09,0.1,0.86,0.8]) %[left bottom width height]
        title(strcat('IASI - GEOS-Chem (10^{15} molecules cm^{-2})', space(1:10), season_name(sea,:), ' (', num2str(yr_sta), '-', num2str(yr_end), ')'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
        % rectangle
        annotation(fig, 'rectangle', [0.68 0.52 0.165 0.23], 'Color', [1 0 1], 'LineWidth', 2); % India-China
        annotation(fig, 'rectangle', [0.47 0.33 0.18 0.35], 'Color', [1 0 1], 'LineWidth', 2); % Africa
        annotation(fig, 'rectangle', [0.32 0.24 0.125 0.33], 'Color', [1 0 1], 'LineWidth', 2); % Southern America
        
    end
    axis normal;
    saveas(fig, ['C:\Users\Administrator\Desktop\output\', season_name(sea,:), '.svg'])
    
end
