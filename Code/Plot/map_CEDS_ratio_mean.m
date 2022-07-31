% mean spatial distribution of CEDS emissions ratios
clear all

path = 'D:\data\CEDS\grid\';
yr_sta = 2008;
yr_end = 2014;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
lat_sta = 6;
lat_end = 41;
secs_name = {'Energy', 'Industry', 'Traffic', 'Residential and Commercial', 'Manure management', 'Soil emissions', 'Waste'};

% import data
% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

tot = load([path, 'CEDS_total_2008-2018.mat']).emi;
max = 0.5;
tot = tot(yr_sta - 2007:yr_end-2007,:,:);
% regridded lon and lat grid
lon = ncread(['D:\data\IASI\filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lon');
lon = lon;
lat = ncread(['D:\data\IASI\filter\IASI_filter_AM_Cloud_10_200801.nc'], 'lat');
lat = lat;
[x,y] = meshgrid((lon) , (lat));

for i = 1:length(secs_name)

    sec_name = char(secs_name(i));
    sec = ncread([path, 'CEDS_' sec_name, '_', num2str(yr_sta), '-', num2str(yr_end), '.nc'], sec_name);
    r = sec./tot;
    r = squeeze(nanmean(r, 1))' .* (map_land > 0);
    r(r == 0) = nan;
    
    % draw
    fig = figure(i);
    % set (gcf,'Position',[232,400,623.5,300]); %[left bottom width height]

    m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0)
    hold on

    sp = 10;
    [C,h] = m_contourf(x, y, r, 500);
    set(h,'LineColor','none');
    shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    caxis([0 max]);
    colormap(parula);

    if i == length(secs_name)
        cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
        set(cb, 'YTick', 0:.1:max);
        set (gcf,'Position',[232,400,623.5,300]);
        set (gca,'Position',[0.09,0.1,0.78,0.80])
    else
        set (gcf,'Position',[232,400,580,300]);
        set (gca,'Position',[0.09,0.1,0.86,0.80])
    end

    %set (gca,'Position',[0.09,0.1,0.86,0.8])
    space(1 : 150) = 32; 
    title(strcat('CEDS Proportion (', sec_name, ')', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    %text(-3, -1, '(b)', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')
    axis normal;
    % saveas(fig, ['C:\Users\Administrator\Desktop\output\IASI_E=M_τ_n=', num2str(thre), '.png']);
    f = gcf;
    exportgraphics(f,['C:\Users\Administrator\Desktop\output\CEDS_r_', sec_name,'.png'],'Resolution',300)

end

