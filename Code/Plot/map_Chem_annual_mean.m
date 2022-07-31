% annnual mean spatial distribution of GEOS-Chem simuilation
clear all

path =  'D:\data\GEOS-Chem\concentration_month\';
yr_sta = 2008;
yr_end = 2018;
years = yr_sta:1:yr_end;
yr_len = length(years);

data_yr = zeros([46, 72, yr_len +1], 'double');

for yr = years

    year = num2str(yr);
    disp(['Year: ', year]);
    
    data_mon = zeros([46, 72, 12], 'double');
    for mon = 1:12

        month = num2str(mon, '%02d');
        data_mon(:, :, mon) = ncread([path, 'GEOS-Chem_', year, month, '.nc'], ['GEOS-Chem daytime simulation_', year, month])';

    end

    % annual mean
    data_yr(:, :, yr - yr_sta +1) = nanmean(data_mon, 3);

end

data_yr(:, :, yr_len +1) = nanmean(data_yr(:,:, 1:yr_len), 3);


% regridded lon and lat grid
lon = ncread([path, 'GEOS-Chem_', year, month, '.nc'], 'lon');
lon = lon +2.5;
lat = ncread([path, 'GEOS-Chem_', year, month, '.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

mul = 1E-15*6.02214179E19;
max = 15; 

%draw map
for i = 1:yr_len+1
    
    fig = figure(i);
    set (gcf,'Position',[232,400,580,300]);

    m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0.5)
    hold on

    data = data_yr(:, :, i);
    % day
    [C,h] = m_contourf(x, y, data*mul, 100);
    set(h,'LineColor','none');
    caxis([0 max]);
    colormap(flipud(hot));
    %colormap(jet);
    shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    hold on 

    space(1 : 150) = 32; 
    if i == yr_len+1
        cb = colorbar('eastoutside','fontsize', 15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
        set(cb, 'YTick', 0:5:max);
        set (gca,'Position',[0.09,0.1,0.8,0.8])
        title(strcat('GEOS-Chem (10^{15} molecules cm^{-2})', space(1:20), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
        % rectangle
%         annotation(fig, 'rectangle', [0.63 0.52 0.165 0.23], 'Color', [1 0 1], 'LineWidth', 2); % India-China
%         annotation(fig, 'rectangle', [0.445 0.33 0.165 0.35], 'Color', [1 0 1], 'LineWidth', 2); % Africa
%         annotation(fig, 'rectangle', [0.30 0.24 0.12 0.325], 'Color', [1 0 1], 'LineWidth', 2); % Southern America
        
    else
        set (gca,'Position',[0.09,0.1,0.86,0.8]) %[left bottom width height]
        title(strcat('GEOS-Chem (10^{15} molecules cm^{-2})', space(1:35), num2str(years(i))), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
        % rectangle
        annotation(fig, 'rectangle', [0.68 0.53 0.165 0.28], 'Color', [1 0 1], 'LineWidth', 2); % India-China
        annotation(fig, 'rectangle', [0.47 0.29 0.18 0.40], 'Color', [1 0 1], 'LineWidth', 2); % Africa
        annotation(fig, 'rectangle', [0.32 0.18 0.12 0.38], 'Color', [1 0 1], 'LineWidth', 2); % Southern America
    end

    axis normal;
    saveas(fig, ['C:\Users\Administrator\Desktop\output\', num2str(i), '.png'])
    close
end
