% monthly trend spatial distribution of IASI daily filtered data
clear all

path =  'D:\data\IASI\filter\IASI_filter_AM_Cloud_10_';
yr_sta = 2008;
yr_end = 2018;
years = yr_sta:1:yr_end;
yr_len = length(years);
mons = 'JFMAMJJASOND';

data = zeros([46, 72, 12, yr_len], 'double');
% import data
for yr = years

    year = num2str(yr);
    
    data_mon = zeros([46, 72, 12], 'double');
    for mon = 1:12

        month = num2str(mon, '%02d');
        data(:, :, mon, yr - yr_sta +1) = ncread([path, year, month, '.nc'], 'averaging nh3 filter');
    end
end

% trend
tre_mon = zeros([46, 72, 13], 'double');
test_mon = zeros([46, 72, 13], 'double');

for mon = 1:12

    disp(['Month: ', mons(mon)]);
    [tre_mon(:, : , mon), test_mon(:, :, mon) ]= Trend(squeeze(data(:,:,mon,:)), 46, 72, yr_len);
end

[tre_mon(:, : , 13), test_mon(:, :, 13) ]= Trend(nanmean(data, 3), 46, 72, yr_len);

% regridded lon and lat grid
lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_', year, month, '.nc'], 'lon');
lon = lon+ 2.5;
lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_', year, month, '.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

p = 0.05;
mul = 1E-14*6.02214179E19;
max = 5;
%draw map
for i = 1:13

    fig = figure(i);
    set (gcf,'Position',[232,400,580,300]); %[left bottom width height]

    m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0.5)
    hold on

    [p_lat, p_lon] = find(test_mon(:, :, i) < p);
    p_lat = lat(p_lat);
    p_lon = lon(p_lon);

    [C,h] = m_contourf(x, y, tre_mon(:, :, i)*mul, 100);
    set(h,'LineColor','none');

    m_scatter(p_lon, p_lat, 10,'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', '.') ;% mark the p 

    shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    caxis([-max max]);
    colormap(jet);
    
    % colorbar
    space(1 : 150) = 32; 
    if i == 13
        cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
        set(cb, 'YTick', -max:2:max);
        set (gca,'Position',[0.09,0.1,0.8,0.8])
        title(strcat('IASI (10^{14} molecules cm^{-2} yr^{-1})', space(1:35), 'All'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
        % rectangle
%         annotation(fig, 'rectangle', [0.63 0.52 0.165 0.23], 'Color', [1 0 1], 'LineWidth', 2); % India-China
%         annotation(fig, 'rectangle', [0.445 0.33 0.165 0.35], 'Color', [1 0 1], 'LineWidth', 2); % Africa
%         annotation(fig, 'rectangle', [0.30 0.24 0.12 0.325], 'Color', [1 0 1], 'LineWidth', 2); % Southern America
        
    else
        set (gca,'Position',[0.09,0.1,0.86,0.8]) %[left bottom width height]
        title(strcat('IASI (10^{14} molecules cm^{-2} yr^{-1})', space(1:40), mons(i)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
        % rectangle
        annotation(fig, 'rectangle', [0.68 0.53 0.165 0.28], 'Color', [1 0 1], 'LineWidth', 2); % India-China
        annotation(fig, 'rectangle', [0.47 0.29 0.18 0.40], 'Color', [1 0 1], 'LineWidth', 2); % Africa
        annotation(fig, 'rectangle', [0.32 0.18 0.12 0.38], 'Color', [1 0 1], 'LineWidth', 2); % Southern America
    end

    axis normal;
    saveas(fig, ['C:\Users\Administrator\Desktop\output\', num2str(i), '.png'])
    close

end

