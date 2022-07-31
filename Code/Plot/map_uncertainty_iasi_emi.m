% draw mean uncertainty spatial distribution of emission based on IASI relative error
clear all

path = 'E:\AEE\data\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
thre_n = 30;
thre_r = 1;

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

iasi_un = load([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_Uncertainty_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).uncer;
grid_area = ncread([path, 'GEOS-Chem\OutputDir2008\GEOSChem.Budget.20080101_0000z.nc4'], 'AREA')'; % m-2

load([path, 'GEOS-Chem\transport_to_emission_2008-2018.mat']); % transport/emission
r = r(:,:,(yr_sta-2008)*12+1:(yr_end-2008+1)*12);

% regridded lon and lat grid
lon = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon;
lat = ncread(['E:\AEE\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
[x,yy] = meshgrid((lon) , (lat));

max = 20;
sp = 20;
mul = 1E12;
% draw
for y = yr
    
    un_mon = NaN([46, 72, 12], 'double');
    year = num2str(y);
    
    for m = 1:12
       
        mon = num2str(m, '%02d');
        geo = ncread([path, 'GEOS-Chem\concentration\GEOS-Chem_Total column_' year, mon, '.nc'], ['GEOS-Chem monthly mean NH3'])'; % mol m-2
        iasi = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'averaging nh3 filter'); % mol m-2
        t = ncread([path, 'GEOS-Chem\Budget\GEOS-Chem_lifetime_', year, mon, '.nc'], 'NHx lifetime')*3600; % s
        e0 = ncread([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.', year, mon, '.nc'], 'Total')'; % GEIS-Chem emission 
        N = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'Monthly number of retrievals'); 
        
        uncer = abs(iasi .* iasi_un(:, :, (y-yr_sta)*12 + m)/100);

        e1 = (iasi-geo)*17/1000./t + e0;
        e1 = e1 .* (r(:,:,(y-yr_sta)*12 + m) < thre_r);
        e1 = e1 .* (N > thre_n);

        e2 = (iasi+uncer-geo)*17/1000./t + e0;
        e2 = e2 .* (r(:,:,(y-yr_sta)*12 + m) < thre_r);
        e2 = e2 .* (N > thre_n);
        
        un_mon(:,:,m) = e2-e1;
        
    end
    
    save([path, 'uncertainty_IASI_emi_', num2str(yr_sta) '-', num2str(yr_end), '.mat'], 'un')
    
    fig = figure(y-yr_sta+1);
    set (gcf,'Position',[232,400,580,300]); %[left bottom width height]

    m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0)
    hold on
    
    uncertain = nanmean(un_mon, 3)*mul.*(map_land > 0);
    uncertain(uncertain == 0) = NaN;
    [C,h] = m_contourf(x, yy, uncertain, 100);
    set(h,'LineColor','none');
    shp = shaperead('E:\AEE\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    caxis([0 max]);
    colormap(jet);

    if y == yr_end

        %set (gcf,'Position',[232,400,623,300]);
        cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
        set(cb, 'YTick', 0:5:max);
        set (gca,'Position',[0.09,0.1,0.80,0.80])
    end

    space(1 : 150) = 32; 
    title(strcat('Uncertainty of emission (10^{-12} Kg m^{-2} s^{-1})', space(1:sp), num2str(y)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    axis normal;
%     f = gcf;
%     exportgraphics(f,['C:\Users\Administrator\Desktop\output\IASI_uncertainty_emi', num2str(y) ,'.png'],'Resolution',300)
    
end