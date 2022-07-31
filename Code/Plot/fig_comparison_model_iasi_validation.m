%joint the figure of modelled NH3 concentrations comparison with IASI observation (validation)
clear

path = 'E:\AEE\data\GEOS-Chem\validation2\';

yrs = [2008, 2013, 2018];
yr_len = length(yrs);
names = 'abcdefghi';

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

% regridded lon and lat grid
lon = ncread(['E:\AEE\data\IASI\IASI_filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lon');
lat = ncread(['E:\AEE\data\IASI\IASI_filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

figure();
set (gcf,'Position',[0,0,800*2+40,300*3], 'Units', 'normalized', 'OuterPosition', [0 0 1 1]); %[left bottom width height]
t = tiledlayout(3,2,'TileSpacing', 'tight', 'Position', [0.08,0.1,0.775,0.8]);

D_d = NaN([46, 72, 12, 3], 'double');
D_s = NaN([46, 72, 12, 3], 'double');
max = 100;
mul = 100;

for i = 1:yr_len

    year = num2str(yrs(i));
    
    D_d(:, :, :,1) = load([path, 'FB_IASI_GEOS-Chem_emission_D_d_', year, '.mat']).D_d;
    D_s(:, :, :,1) = load([path, 'FB_IASI_GEOS-Chem_emission_D_s_', year, '.mat']).D_s;

    D_d(:, :, :,2) = load([path, 'FB_IASI_GEOS-Chem_emission_nhx_D_d_', year, '.mat']).D_nhx_d;
    D_s(:, :, :,2) = load([path, 'FB_IASI_GEOS-Chem_emission_nhx_D_s_', year, '.mat']).D_nhx_s;
    
%     D_d(:, :, :,3) = load([path, 'FB_IASI_GEOS-Chem_emission_12h_D_d_', year, '.mat']).D_12_d;
%     D_s(:, :, :,3) = load([path, 'FB_IASI_GEOS-Chem_emission_12h_D_s_', year, '.mat']).D_12_s;
%     
    for j = 1:2

        nexttile;
        m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
        m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
        m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial',...
        'fontsize', 12, 'LineWidth', 2, 'xtick', [], 'ytick', []);
        alpha(0.5)
        hold on
        
        fb = 200 * nansum(D_d(:,:,:,j), 3)./nansum(D_s(:,:,:,j), 3).*map_land;
        fb(fb == 0) = nan;

        [C,h] = m_contourf(x, y, fb, 2000);
        set(h,'LineColor','none');
        shp = shaperead('E:\AEE\code\fun\country\country.shp');
        boundary_x=[shp(:).X];
        boundry_y=[shp(:).Y];
        m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
        caxis([-max max]);
        cmp = importdata('E:\AEE\data\colormap\PiYG.txt');
        colormap(flipud(cmp(:,1:3)));
        % colormap(jet);
        
        % color bar and title
        if  i == 1
            if j == 1
                title('BUE1', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');
            end

            if j == 2
                title('TDE', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');
            end

            if j == 3
                title('VD12h', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');
            end
        end
        
        % grid text
        if j == 1
            if i == 3
                m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName',...
                    'Arial','fontsize', 12, 'LineWidth', 2, 'xtick',[-120, -60, 0, 60, 120]);
            else
                m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName',...
                'Arial','fontsize', 12, 'LineWidth', 2, 'xtick', []);
            end
        else
            
        end
        
        if i == 3 && j > 1
            m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName',...
                'Arial','fontsize', 12, 'LineWidth', 2, 'ytick', [], 'xtick',[-120, -60, 0, 60, 120]);
        end
        
        FB = round(2 * nansum(nansum(nansum(D_d(:,:,:,j), 3)))./nansum(nansum(nansum(D_s(:,:,:,j), 3)))*100);

        % text
        text(-3, -0.5, ['FB=', num2str(FB) ,'%'], 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold')
        text(-3, -1, ['(', names((i-1)*2+j) ,')'], 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')

    end
    text(-11.5, -0.5, year, 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold','rotation', 90)

end
cb = colorbar('eastoutside','fontsize',15,'FontName','Arial' , 'FontWeight' ,'normal' ,'LineWidth' , 2);
set(cb, 'YTick', -max:50:max, 'Position', [0.87 0.1 0.02 0.8]);%, 'Position', [0.87 0.2 0.2 0.8]

text(3.7, 6.7, 'FB (%)', 'FontSize', 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');
f = gcf;
exportgraphics(f,['E:\AEE\Pap\ACP\figure\figS7.png'],'Resolution',300)
