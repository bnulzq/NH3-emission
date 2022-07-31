% seasonal mean spatial distribution of GEOS-Chem simuilation
clear all

path =  'D:\data\GEOS-Chem\concentration_month\';

%sea = 4;
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
season = [[1, 2, 3]; [4, 5, 6]; [7, 8, 9]; [10, 11, 12]]; 
season_name = ['JFM'; 'AMJ'; 'JAS'; 'OND'];
fig_name = ['(e)'; '(f)'; '(g)'; '(h)';];

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

for sea = 1:4
    
    mon = season(sea, :);
    disp(['Season: ', season_name(sea, :)])
    nh3_day = zeros([46, 72, yr_len], 'double');
    nh3_nig = zeros([46, 72, yr_len], 'double');

    for i = 1:yr_len

        year = num2str(yr(i));
        

        day_mon = zeros([46, 72, 3], 'double');
        nig_mon = zeros([46, 72, 3], 'double');

        % import data 
        if sum(mon == [12, 1, 2]) == 3

            disp('DJF is unavailable !')

        else

            for j = 1:3

                month = num2str(mon(j), '%02d');
                day_mon(:, :, j) = ncread([path, 'GEOS-Chem_', year, month, '.nc'], ['GEOS-Chem daytime simulation_', year, month])';
         %       nig_mon(:, :, j) = ncread([path, 'GEOS-Chem_', year, month, '.nc'], ['GEOS-Chem nighttime simulation_', year, month])';
                
                % mask ocean
                day_mon = day_mon .* (map_land > 0);
                
            end

        end
        
        day_mon(day_mon == 0) = NaN;
        % seasonal mean
        nh3_day(:, :, i) = mean(day_mon, 3);
        %nh3_nig(:, :, i) = mean(nig_mon, 3);

    end

    save([path, season_name(sea, :), '_Chem.mat'], 'nh3_day')
   %save([path, season_name(sea, :), '_Nighttime_Chem.mat'], 'nh3_nig')

    % regridded lon and lat grid
    lon = ncread([path, 'GEOS-Chem_', year, month, '.nc'], 'lon');
    lon = lon;
    lat = ncread([path, 'GEOS-Chem_', year, month, '.nc'], 'lat');
    [x,y] = meshgrid((lon) , (lat));

    % mean
    nh3_day = nanmean(nh3_day, 3);
    nh3_nig = nanmean(nh3_nig, 3);
    
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
    [C,h] = m_contourf(x, y, nh3_day*mul, 100);
    set(h,'LineColor','none');
    caxis([0 max]);
    cmp = importdata('D:\data\\colormap\Reds.txt');
    colormap(cmp(:,1:3));
    shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    hold on 
    set (gca,'Position',[0.09,0.1,0.8,0.85])
    if sea == 5
        cb = colorbar('eastoutside','fontsize', 15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
        set(cb, 'YTick', 0:5:max);
        
    end

    space(1 : 150) = 32; 
    %title(strcat('GEOS-Chem (10^{15} molecules cm^{-2})', space(1:10), season_name(sea,:), ' (', num2str(yr_sta), '-', num2str(yr_end), ')'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    text(-3, -1, fig_name(sea,:), 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')
%     axis normal;
   % saveas(fig, ['C:\Users\Administrator\Desktop\output\Chem_', season_name(sea,:), '.svg'])
    f = gcf;
    exportgraphics(f,['C:\Users\Administrator\Desktop\output\Chem_', season_name(sea,:), '.png'],'Resolution',900)

end
