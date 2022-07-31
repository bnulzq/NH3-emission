% seasonal mean ratio spatial distribution of GEOS-Chem and IASI adjusted emissions
clear all

path =  'D:\data\';

yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
season = [[1, 2, 3]; [4, 5, 6]; [7, 8, 9]; [10, 11, 12]]; 
season_name = ['JFM'; 'AMJ'; 'JAS'; 'OND'];
thre_n = 20;
thre_r = 1;

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;
geo = load([path, 'GEOS-Chem\Emissions\HEMCO_diagnostics_NH3.Total_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).data;
iasi = load([path, 'IASI\IASI_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).E; % adjusted emissions
iasi = reshape(iasi, [46, 72, 12, yr_len]);
geo = reshape(geo, [46, 72, 12, yr_len]);

for sea = 1:4

    disp(['Season: ', season_name(sea, :)])
    mons = season(sea, :);   

    % regridded lon and lat grid
    lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
    lon = lon;
    lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
    [x,y] = meshgrid((lon) , (lat));

    r = nanmean(nanmean(geo(:,:,mons,:)./iasi(:,:,mons,:), 4),3).*map_land;

    max = 2;  
    
    % draw
    fig = figure();
    set (gcf,'Position',[232,400,580,300]); %[left bottom width height]

    m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0)
    hold on

    sp = 20;
    [C,h] = m_contourf(x, y, r, 2000);
    set(h,'LineColor','none');
    shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    caxis([0 max]);
    colormap(jet);

    %set (gca,'Position',[0.09,0.1,0.86,0.8])
    space(1 : 150) = 32; 
    title(strcat('GEOS-Chem/adjusted emissions (10^{-11} kg/m^{2}/s)', space(1:sp), season_name(sea,:)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    %text(-3, -1, season_name(sea,:), 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')
    if sea == 4
        
        cb = colorbar('eastoutside','fontsize', 15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
        set(cb, 'YTick', 0:.5:max);
        set (gca,'Position',[0.09,0.1,0.80,0.80])
        set (gcf,'Position',[232,400,623.5,300]);

    else
        
        set (gca,'Position',[0.09,0.1,0.86,0.80]) %[left bottom width height]
    
    end
    axis normal;
    % saveas(fig, ['C:\Users\Administrator\Desktop\output\IASI_E=M_τ_n=', num2str(thre), '.png']);
    f = gcf;
    exportgraphics(f,['C:\Users\Administrator\Desktop\output\IASI_Chem_emi_diff_', season_name(sea,:), '.png'],'Resolution',300)


end