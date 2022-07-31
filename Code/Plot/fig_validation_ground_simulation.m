%joint the figure of modelled NH3 concentrations comparison with IASI observation (validation)
clear

path = 'E:\AEE\data\GEOS-Chem\validation2\';

yrs = [2008, 2013, 2018];
yr_len = length(yrs);
names = 'abcdefghi';

% % regridded lon and lat grid
% lon = ncread(['E:\AEE\data\IASI\IASI_filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lon');
% lat = ncread(['E:\AEE\data\IASI\IASI_filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lat');
% [x,y] = meshgrid((lon) , (lat));
data = readmatrix([path, 'Annual_surface.csv']);

figure();
set (gcf,'Position',[0,0,800*2+40,300*3], 'Units', 'normalized', 'OuterPosition', [0 0 1 1]); %[left bottom width height]
t = tiledlayout(3,2,'TileSpacing', 'tight', 'Position', [0.08,0.1,0.775,0.8]);

max = 100;
for i = 1:yr_len
    
    year = yrs(i);
    datai = data((data(:,6) == year),:);    
    fb1 = (datai(:, 4) - datai(:, 3))./(datai(:, 4) + datai(:, 3)) * 200;
    fb2 = (datai(:, 5) - datai(:, 3))./(datai(:, 5) + datai(:, 3)) * 200;
    

    % BUE1
    nexttile;
    m_proj('Equidistant Cylindrical','lat',[-10,70],'lon',[-150,150]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial',...
    'fontsize', 12, 'LineWidth', 2, 'xtick', [], 'ytick', []);
    alpha(0.1)
    hold on

    shp = shaperead('E:\AEE\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);

    m_scatter(datai(:, 8), datai(:, 9), [], fb1, 'filled', 's');
    caxis([-max max]);
    cmp = importdata('E:\AEE\data\colormap\PiYG.txt');
    colormap(flipud(cmp(:,1:3)));

    % title
    if i == 1
        title('BUE1', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');
    end

    % grid
    if i == 3
        m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName',...
        'Arial','fontsize', 12, 'LineWidth', 2, 'xtick',[-120, -60, 0, 60, 120]);
    else
        m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName',...
            'Arial','fontsize', 12, 'LineWidth', 2, 'xtick', []);
    end
    
    text(-11.5, -0.5, num2str(year), 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold','rotation', 90)
    text(-2, 0.2, ['(', names((i-1)*2+1) ,')'], 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')
    FB = round(mean(fb1));
    text(-2, -0, ['FB=', num2str(FB) ,'%'], 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold')
    text(-2.8, 0.2, num2str(year), 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold','rotation', 90)

    % TDE
    nexttile;
    m_proj('Equidistant Cylindrical','lat',[-10,70],'lon',[-150,150]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Arial',...
    'fontsize', 12, 'LineWidth', 2, 'xtick', [], 'ytick', []);
    alpha(0.1)
    hold on

    shp = shaperead('E:\AEE\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);

    m_scatter(datai(:, 8), datai(:, 9), [], fb2, 'filled', 's');
    caxis([-max max]);
    cmp = importdata('E:\AEE\data\colormap\PiYG.txt');
    colormap(flipud(cmp(:,1:3)));

    % title
    if i == 1
        title('TDE', 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');
    end

    % grid
    if i == 3
        m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName',...
            'Arial','fontsize', 12, 'LineWidth', 2, 'ytick', [], 'xtick',[-120, -60, 0, 60, 120]);
    end
    FB = round(mean(fb2));
    text(-2, 0.2, ['(', names((i-1)*2+2) ,')'], 'FontSize' , 20 , 'FontName' ,'Arial', 'FontWeight', 'bold')
    text(-2, -0, ['FB=', num2str(mean(FB)) ,'%'], 'FontSize' , 15 , 'FontName' ,'Arial', 'FontWeight', 'bold')

end

cb = colorbar('eastoutside','fontsize',15,'FontName','Arial' , 'FontWeight' ,'normal' ,'LineWidth' , 2);
set(cb, 'YTick', -max:50:max, 'Position', [0.87 0.1 0.02 0.8]);%, 'Position', [0.87 0.2 0.2 0.8]

text(2.6, 4.6, 'FB (%)', 'FontSize', 20 , 'FontName' ,'Arial', 'FontWeight', 'bold');
f = gcf;
exportgraphics(f,['E:\AEE\Pap\ACP\figure\fig7.png'],'Resolution',300)