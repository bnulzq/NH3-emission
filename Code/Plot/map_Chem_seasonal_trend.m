% seasonal trend spatial distribution of GEOS-Chem simulation
clear all

path =  'D:\data\GEOS-Chem\concentration_month\';

%sea = 3;
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
season = [[1, 2, 3]; [4, 5, 6]; [7, 8, 9]; [10, 11, 12]]; 
season_name = ['JFM'; 'AMJ'; 'JAS'; 'OND'];
fig_name = ['(b)'; '(d)'; '(f)'; '(h)';];

for sea = 1:4

    mon = season(sea, :);
    disp(['Season: ', season_name(sea, :)])

    load([path, season_name(sea, :), '_Chem.mat']);

    % trend
    [tre_day, test_day]= Trend(nh3_day, 46, 72, yr_len);

    % regridded lon and lat grid
    lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
    lon = lon;
    lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
    [x,y] = meshgrid((lon) , (lat));

    mul = 1E5;
    p = 0.05;
    max = 5;

    % draw
    fig = figure(sea);
    set (gcf,'Position',[232,400,580,300]);

    m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0.5)
    hold on

    % day
    [p_lat, p_lon] = find(test_day < p);
    p_lat = lat(p_lat);
    p_lon = lon(p_lon);

    [C,h] = m_contourf(x, y, tre_day*mul, 100);
    set(h,'LineColor','none');

    m_scatter(p_lon, p_lat, 10,'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', '.') ;% mark the p 

    shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    caxis([-max max]);
    cmp = importdata('D:\data\\colormap\bwr.txt');
    colormap(cmp(:,1:3));

    set (gca,'Position',[0.09,0.1,0.86,0.85]) %[left bottom width height]
    space(1 : 150) = 32; 
    %title(strcat('GEOS-Chem (10^{-6} Mol m^{-2} yr^{-1})', space(1:18), season_name(sea,:), ' (', num2str(yr_sta), '-', num2str(yr_end), ')'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    text(-3, -1, fig_name(sea,:), 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')

    %axis normal;
    %saveas(fig, ['C:\Users\Administrator\Desktop\output\Chem_', season_name(sea,:), '.svg'])
    f = gcf;
    exportgraphics(f,['C:\Users\Administrator\Desktop\output\Chem_', season_name(sea,:), '.png'],'Resolution',300)


end