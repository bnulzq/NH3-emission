% seasonal trend spatial distribution of NH3 emissions
clear all

path = 'D:\data\GEOS-Chem\Emissions\HEMCO_diagnostics_NH3.';

yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
season = [[1, 2, 3]; [4, 5, 6]; [7, 8, 9]; [10, 11, 12]]; 
season_name = ['JFM'; 'AMJ'; 'JAS'; 'OND'];
%emi_name = {'Anthro', 'Total', 'Natural'};
emi_name = {'BioBurn', 'Ship', 'Seabirds', 'Natural'};

for k = 1:length(emi_name)
    emi = cell2mat(emi_name(k));
    disp(['Emission: ', emi])

    for sea = 1:4
        
        mon = season(sea, :);
        disp(['Season: ', season_name(sea, :)])
        emi_sea = zeros([46, 72, yr_len], 'double');
        
        for i = 1:yr_len
            
            year = num2str(yr(i));
            emi_mon = zeros([46, 72, 3], 'double');

            % import data 
            
            for j = 1:3

                month = num2str(mon(j), '%02d');
                data = ncread([path, year, month, '.nc'], emi);
                
                data(data == 0) = nan;
                % mask ocean
                % day = MaskOcean_1x1(day);
                % night = MaskOcean_1x1(night);

                emi_mon(:, :, j) = data';
            end

            % seasonal mean
            emi_sea(:, :, i) = nanmean(emi_mon, 3);

        end


        % trend
        [tre, test]= Trend(emi_sea, 46, 72, yr_len);
    %    save([path, season_name(sea, :), '_Daytime_IASI.mat'], 'nh3_day')

        % regridded lon and lat grid
        lon = ncread([path, year, month, '.nc'], 'lon');
        %lon = lon + 2.5;
        lat = ncread([path, year, month, '.nc'], 'lat');
        [x,y] = meshgrid((lon) , (lat));

        p = 0.05;
        mul = 1E+15;
        max = 25;
        %draw map
        fig = figure(sea);
        set (gcf,'Position',[232,400,580,300]); %[left bottom width height]

        m_proj('Equidistant Cylindrical','lat',[-90,90],'lon',[-180,180]);
        m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
        m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
        alpha(0)
        hold on
        
         % colorbar
        if sea == 4 && strcmp(emi, 'Total')
            cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
            set(cb, 'YTick', -max:10:max);
            set (gca,'Position',[0.09,0.1,0.78,0.8])
            sp = 25;
        else
            sp = 30;
            set (gca,'Position',[0.09,0.1,0.86,0.8]) %[left bottom width height]
        end
        
        [p_lat, p_lon] = find(test < p);
        p_lat = lat(p_lat);
        p_lon = lon(p_lon);
        m_scatter(p_lon, p_lat, 15,'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'Marker', '.') ;% mark the p 

        [C,h] = m_contourf(x, y, tre*mul, 500);
        set(h,'LineColor','none');
        shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
        boundary_x=[shp(:).X];
        boundry_y=[shp(:).Y];
        m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
        caxis([-max max]);
        colormap(jet);

        space(1 : 150) = 32; 
        title(strcat(emi, ' (10^{-15} kg/m^{-2}/s/yr)', space(1:sp), season_name(sea,:), ' (', num2str(yr_sta), '-', num2str(yr_end), ')'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
        axis normal;
        saveas(fig, ['C:\Users\Administrator\Desktop\output\', emi, '_' season_name(sea,:), '.svg'])
        
        clear boundary_x, clear boundry_y
        close
    end
end