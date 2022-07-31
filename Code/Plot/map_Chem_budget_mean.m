% mean spatial distribution of GEOS-Chem Budget
clear all

path = 'D:\data\GEOS-Chem\OutputDir';

yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
bud = 'WetDep';
%bud = 'Transport';
file = 'Budget.';

name = {'NH3', 'NH4'};



for i = 1:length(name)

    data = NaN([46, 72, yr_len*12], 'double');
    namei = char(name(i));

    for j = yr

        year = num2str(j);

        for k = 1:12

            mon = num2str(k, '%02d');
            data(:, :, (j-yr_sta)*12 + k) = ncread([path, year, '\GEOSChem.', file, year, mon, '01_0000z.nc4'], ['Budget', bud, 'Full_', namei])';

        end
    end

    data = nanmean(data, 3);

    % area
    area = ncread([path, year, '\GEOSChem.',file, year, mon, '01_0000z.nc4'], 'AREA')';
    data = data./area;

    % regridded lon and lat grid
    lon = ncread([path, year, '\GEOSChem.',file, year, mon, '01_0000z.nc4'], 'lon');
    lon = lon + 2.5;
    lat = ncread([path, year, '\GEOSChem.',file, year, mon, '01_0000z.nc4'], 'lat');
    [x,y] = meshgrid((lon) , (lat));

    mul = 1E+11;
    

    % draw map
    fig = figure();
    set (gcf,'Position',[232,400,580,300]); %[left bottom width height]

    m_proj('Equidistant Cylindrical','lat',[-90,90],'lon',[-180,180]);
    m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
    m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
    alpha(0)
    hold on
    
    
    % colorbar
    if  strcmp(bud, 'Transport')
        max = 20;
        caxis([-max max]);
        colormap(jet);
        if i == 2
            cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
            set(cb, 'YTick', -max:10:max);
            set (gca,'Position',[0.09,0.1,0.78,0.8])
        else
            set (gca,'Position',[0.09,0.1,0.86,0.8])
        end
    else
        max = 5;
        set (gca,'Position',[0.09,0.1,0.86,0.8])
        caxis([0 max]);
        colormap(cool);
    end
    sp = 30;

    [C,h] = m_contourf(x, y, data*mul, 500);
    set(h,'LineColor','none');
    shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
    boundary_x=[shp(:).X];
    boundry_y=[shp(:).Y];
    m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
    

    space(1 : 150) = 32; 
    title(strcat(bud, space(1), namei, ' (10^{-12} kg/m^{2}/s)', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
    axis normal;
    saveas(fig, ['C:\Users\Administrator\Desktop\output\GEOS-Chem_', namei, '_', bud ,'.png']);

end
