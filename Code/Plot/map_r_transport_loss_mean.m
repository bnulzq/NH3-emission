 %mean spatial distribution of ratio of transport(-) to loss
clear all

path = 'D:\data\GEOS-Chem\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);

% ocean
map_land = ncread(['C:\Users\Administrator\Desktop\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

r = NaN([46, 72, yr_len*12], 'double');

for y = yr

    year = num2str(y);

    for m = 1:12

        mon = num2str(m, '%02d');

        grid_area = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.', year, mon, '01_0000z.nc4'], 'AREA')'; % m2
        nh3_wet = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'BudgetWetDepFull_NH3')'; % kg s-1, positive value
        nh3_dry = ncread([path, 'OutputDir', year, '\GEOSChem.DryDep.' year, mon, '01_0000z.nc4'], 'DryDep_NH4')'; % molec cm-2 s-1
        nh4_wet = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'BudgetWetDepFull_NH4')'; % kg s-1, positive value
        nh4_dry = ncread([path, 'OutputDir', year, '\GEOSChem.DryDep.' year, mon, '01_0000z.nc4'], 'DryDep_NH3')'; % molec cm-2 s-1
        dry = -(nh3_dry + nh4_dry)/6.02214179E19*17/1000; % kg m-2 s-1
        wet = (nh3_wet + nh4_wet)./grid_area;


        trans_nh3 = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.', year, mon, '01_0000z.nc4'], 'BudgetTransportFull_NH3')'; % kg s-1
        trans_nh4 = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.', year, mon, '01_0000z.nc4'], 'BudgetTransportFull_NH4')'; % kg s-1
        trans = (trans_nh3 + trans_nh4)./grid_area;
        trans_n = trans < 0;

        r(:, :, (y - yr_sta)*12 + m) = trans .* trans_n ./ (wet + dry);

    end
end

save([path, 'transport_to_deposition', '_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'r');

r = nanmean(r, 3) .* (map_land > 0);
r(r == 0) = nan;
% regridded lon and lat grid
lon = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lon');
lon = lon;
lat = ncread(['D:\data\GEOS-Chem\concentration_month\GEOS-Chem_200801.nc'], 'lat');
[x,y] = meshgrid((lon) , (lat));

mul = 1;
max = 2; 

% draw
fig = figure();
set (gcf,'Position', [232,400,623.5,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0)
hold on

sp = 40;
[C,h] = m_contourf(x, y, r*mul, 500);
set(h,'LineColor','none');
shp = shaperead('C:\Users\Administrator\Desktop\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
cmp = importdata('D:\data\\colormap\PiYG.txt');
colormap(flipud(cmp(:,1:3)));

cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', 0:1:max);
set (gca,'Position',[0.09,0.1,0.80,0.85])

space(1 : 150) = 32; 
%title(strcat('transport/deposition', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
text(-3, -1, '(b)', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')

axis normal;
%saveas(fig, ['C:\Users\Administrator\Desktop\output\transport_depositon.png']);
f = gcf;
exportgraphics(f,['C:\Users\Administrator\Desktop\output\transport_depositon.png'],'Resolution',300)
