% mean spatial distribution of GEOS-Chem and optimized regional emissions over months
clear all

path = 'E:\AEE\data\GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.';

yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
emi_name = 'Total';
thre_n = 800;
thre_r = 1;
yr = 2016;
mons = [3, 4, 5, 6, 7, 8, 9];
mul = 1E+3*3600*24*30; % kg/m2/s to g/m2/month
max = 1.5;
lat1_i = 36;
lat2_i = 39;
lon1_i = 35;
lon2_i = 37;

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

iasi = load(['E:\AEE\data\IASI\NHx lifetime_with adjustment_optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_', num2str(yr_sta), '-', num2str(yr_end), '.mat']); % adjusted emissions
iasi = iasi.E;
% regridded lon and lat grid
lon = ncread([path, '200801.nc'], 'lon');
lon = lon;
lat = ncread([path, '200801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));
grid_area = ncread(['E:\AEE\data\GEOS-Chem\OutputDir2008\GEOSChem.Budget.20080101_0000z.nc4'], 'AREA')'; % m-2
lon1 = double(lon(lon1_i));
lon2 = double(lon(lon2_i));
lat1 = double(lat(lat1_i));
lat2 = double(lat(lat2_i));

emi = [];
% draw
for m = mons

    year = num2str(yr);
    month = num2str(m, '%02d');
    e = ncread([path, year, month, '.nc'], emi_name)';
    
    i_e = iasi(:,:, (yr-yr_sta)*12+m) .* (map_land>0);
    i_e(i_e == 0) = NaN;
    e = e .* ~isnan(i_e);
    e(e == 0) = NaN;
    
    i_e_total = i_e .* grid_area * mul;
    i_e_reg = nansum(nansum(i_e_total(lat1_i:lat2_i,lon1_i:lon2_i)))*1E-9;
    emi(end +1) = i_e_reg;
    
    % geos-chem
    fig = figure(1);
    
    m_proj('Equidistant Cylindrical','lat',[lat1, lat2],'lon',[lon1, lon2]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0)
    hold on

    if m == mons(end)

        set (gcf,'Position',[232,400,620,300]);
        cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
        set(cb, 'YTick', 0:.5:max);
        set (gca,'Position',[0.09,0.1,0.80,0.80])

    else
        set (gcf,'Position',[232,400,580,300]); %[left bottom width height]
        set (gca,'Position',[0.09,0.1,0.85,0.80])
    end

    [C,h] = m_contourf(x, y, e*mul, 500);
    set(h,'LineColor','none');
    shp = shaperead('E:\AEE\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    caxis([0 max]);
    cmp = importdata('E:\AEE\data\colormap\OrRd.txt');
    colormap(cmp(:,1:3));

    space(1 : 150) = 32; 
    title(strcat('GEOS-Chem Emission (g m^{-2} month^{-1})', space(1:30), num2str(yr), '.', num2str(m)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    axis normal;
    
    f = gcf;
    saveas(gcf,['C:\Users\bnulzq\Desktop\test\emi_geo', year, month, '.png'])
    %optimized
    fig = figure(2);
    
    m_proj('Equidistant Cylindrical','lat',[lat1, lat2],'lon',[lon1, lon2]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0)
    hold on
    set (gcf,'Position',[232,400,580,300]); %[left bottom width height]
    set (gca,'Position',[0.09,0.1,0.85,0.80])
    
    [C,h] = m_contourf(x, y, i_e*mul, 500);
    set(h,'LineColor','none');
    shp = shaperead('E:\AEE\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    caxis([0 max]);
    cmp = importdata('E:\AEE\data\colormap\OrRd.txt');
    colormap(cmp(:,1:3));

    space(1 : 150) = 32; 
    title(strcat('Optimized Emission (g m^{-2} month^{-1})', space(1:30), num2str(yr), '.', num2str(m)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    axis normal;
    
    f = gcf;
    saveas(gcf,['C:\Users\bnulzq\Desktop\test\emi_opt', year, month, '.png'])
end

