% Spatial correlations between seasonal mean difference (IASI-GEOS-Chem) and 
clear all

path =  'D:\data\';

yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
season = [[1, 2, 3]; [4, 5, 6]; [7, 8, 9]; [10, 11, 12]]; 
season_name = ['JFM'; 'AMJ'; 'JAS'; 'OND'];
%emi_name = {'Anthro', 'BioBurn', 'Ship', 'Seabirds', 'Total', 'Natural'};
emi_name = {'BioBurn', 'Anthro', 'Total'};
%emi_name = {'Natural'};

% regridded lon and lat grid
lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_201801.nc'], 'lon');
lon = lon;
lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_201801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

for k = 1:length(emi_name)
    emi = cell2mat(emi_name(k));
    disp(['Emission: ', emi])

    cor = NaN([46, 72, 4]);
    
    for sea = 1:4

        season = season_name(sea, :);
        disp(['Season: ', season])
        
        % import data
        em = load([path, '\GEOS-Chem\Emissions\HEMCO_diagnostics_NH3.', season, '_', emi, '.mat']).emi_sea;
        iasi = load([path, '\IASI\filter\', season, '_IASI filter']).fi_yr;
        geo = load([path, '\GEOS-Chem\concentration_month\', season, '_Chem']).nh3_day;

        nh3 = iasi - geo;
        
        for i = 1:46
            for j = 1:72

                nh3ij = squeeze(nh3(i, j, :));
                emij = squeeze(em(i, j, :));
                
                if sum(isnan(nh3ij)) ~= yr_len
                    [R, P] = corrcoef(nh3ij, emij, 'rows', 'complete');
                    cor(i, j, sea) = R(2, 1);
                end
            end
        end
    end

    % draw
    for i = 1:4
        
        fig = figure(sea);
        season = season_name(i, :);
        cor_sea = cor(:, :, i);

        set (gcf,'Position',[232,400,580,300]); %[left bottom width height]

        m_proj('Equidistant Cylindrical','lat',[-90,90],'lon',[-180,180]);
        m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
        m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
        alpha(0.5)
        hold on

        % day
        [C,h] = m_contourf(x, y, cor_sea, 100);
        set(h,'LineColor','none');
        shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
        boundary_x=[shp(:).X];
        boundry_y=[shp(:).Y];
        m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
        caxis([-1 1]);
        colormap(jet);

        space(1 : 150) = 32;    

        if i == 4
            cb = colorbar('eastoutside','fontsize', 15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
            set(cb, 'YTick', -1:.5:1);
            set (gca,'Position',[0.09,0.1,0.77,0.8])
            title(strcat(emi, ' v NH3', space(1:35), season, ' (', num2str(yr_sta), '-', num2str(yr_end), ')'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    
        else
            set (gca,'Position',[0.09,0.1,0.86,0.8]) %[left bottom width height]
            title(strcat(emi, ' v NH3', space(1:45), space(1:10), season, ' (', num2str(yr_sta), '-', num2str(yr_end), ')'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    
        end
        axis normal;
        saveas(fig, ['C:\Users\Administrator\Desktop\output\', emi, '_', season, '.svg'])
        close
    end
end



    