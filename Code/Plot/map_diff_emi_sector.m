% draw distribution of NH3 emissions difference of GEOS-Chem and optimized over different sectors
clear all

path = 'D:\data\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
thre_n = 30;
thre_r = 1;
sectors = {'Anthropogenic', 'Biomass burning', 'Others'};

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

% regridded lon and lat grid
lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon;
lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

% emission
opt = load([path, 'IASI\IASI_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).E; % adjusted emissions
geo_total = load([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.Total_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).data;
geo_anth = load([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.Anthro_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).data;
geo_bb = load([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.BioBurn_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).data;
geo_oth = geo_total - geo_anth - geo_bb;

% ratio
r_anth = geo_anth ./ geo_total;
r_bb = geo_bb ./ geo_total;
r_oth = geo_oth ./ geo_total;

% sectors
opt_bb = r_bb .* opt;
opt_anth = r_anth .* opt;
opt_oth = r_oth .* opt;

opt = {opt_anth, opt_bb, opt_oth};
geo = {geo_anth, geo_bb, geo_oth};

mul = 1E+11;
max = 5;

% draw
for i = 1:length(sectors)

    sec = char(sectors(i));
    opti = cell2mat(opt(i));
    geoi = cell2mat(geo(i));

    d = nanmean((opti - geoi), 3) .* map_land;
    d(d == 0) = nan;

    fig = figure(i);
    set (gcf,'Position',[232,400,580,300]); %[left bottom width height]

    m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0)
    hold on

    sp = 10;
    [C,h] = m_contourf(x, y, d*mul, 500);
    set(h,'LineColor','none');
    shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    caxis([-max max]);
    cmp = importdata([path, '\colormap\seismic.txt']);
    colormap(cmp(:,1:3));

    %set (gca,'Position',[0.09,0.1,0.86,0.8])
    space(1 : 150) = 32; 
    title(strcat('Opt - Mod emissions (10^{-11} kg/m^{2}/s)', space(1:sp), sec), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 

    axis normal;
    % saveas(fig, ['C:\Users\Administrator\Desktop\output\IASI_E=M_τ_n=', num2str(thre), '.png']);
    f = gcf;
    exportgraphics(f,['C:\Users\Administrator\Desktop\output\Opt_Chem_emi_diff_', sec, '.png'],'Resolution',300)

end