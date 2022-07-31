% mean spatial distribution of IASI emissions filtered by the number of retrievals and transport/emission ratio (order estimation)
% nh3 and nhx lifetime
% original and adjustment
% adjustment for EC and IP E_nh3 = (C_NH3_o - C_NH3_m + 2*C_SO2_m*SO2_trend)/t + E_NH3_m
% uncertainty for lifetime and so2 emission

clear

path = 'E:\AEE\data\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
lat_sta = 6;
lat_end = 41;
thre_n = 800;
thre_r = 5;
mode = 1; % 1: with adjustment
lifetime = 4; % 3:nh3; 4:nhx; 12:12h
tre_EC = -5/100;% -7.8/100 + 1.04/100;
tre_IP = 5/100;
yr_baseline = 2012;
EC_geo = Domain([31, 57, 35, 62], 46, 72); % grid index: bottom, left, top, right
IP_geo = Domain([26, 50, 31, 55], 46, 72);
t_ratios = [1];

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

E = NaN([46, 72, yr_len*12], 'double');
E_EC = NaN([46, 72, yr_len], 'double');
E_IP = NaN([46, 72, yr_len], 'double');
SO2 = NaN([46, 72, yr_len], 'double');
SO4 = NaN([46, 72, yr_len], 'double');
%SO4s = NaN([46, 72, yr_len], 'double');
% E_adj = NaN([46, 72, yr_len], 'double');
SO2_O = NaN([46, 72, yr_len], 'double');

E_yr = NaN([46, 72, yr_len], 'double');
load([path, 'GEOS-Chem\transport_to_emission_2008-2018.mat']); % transport/emission
r = r(:,:,(yr_sta-2008)*12+1:(yr_end-2008+1)*12);
so2_omps = load([path, 'OMPS\OMPS_SO2\OMPS_SO2__4x5_monthly_2012-2018']).so2;
data_iasi = NaN([46, 72, yr_len, 12], 'double');
for i = 1:length(t_ratios)
    
    ratio = t_ratios(i);
    disp(['Ratio: ', num2str(ratio)])
    for y = yr

        disp(y);
        year = num2str(y);
        E_mon = NaN([46, 72, 12], 'double');
        E_mon_EC = NaN([46, 72, 12], 'double');
        E_mon_IP = NaN([46, 72, 12], 'double');
        SO2_mon = NaN([46, 72, 12], 'double');
        SO4_mon = NaN([46, 72, 12], 'double');
        SO2_O_mon = NaN([46, 72, 12], 'double');
    %     E_mon_adj = NaN([46, 72, 12], 'double');

        for m = 1:12

            mon = num2str(m, '%02d');
            grid_area = ncread([path, 'GEOS-Chem\OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'AREA')'; % m-2
            geo = ncread([path, 'GEOS-Chem\concentration\GEOS-Chem_Total column_' year, mon, '.nc'], ['GEOS-Chem monthly mean NH3'])'; % mol m-2
            iasi = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'averaging nh3 filter'); % mol m-2
            data_iasi(:,:, y-yr_sta+1,m) = iasi;
            if lifetime == 3
                tnames = 'NH3 lifetime';
                t = ncread([path, 'GEOS-Chem\Budget\GEOS-Chem_lifetime_', year, mon, '.nc'], tnames)*3600; % s
            elseif lifetime == 4
                tnames = 'NHx lifetime';
                t = ncread([path, 'GEOS-Chem\Budget\GEOS-Chem_lifetime_', year, mon, '.nc'], tnames)*3600; % s
            else
                tnames = '12h';
                t = 12*3600;
            end
            t(t<=0) = nan;
            e0 = ncread([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.', year, mon, '.nc'], 'Total')'; % GEIS-Chem emission 

            if mode == 0
                e = iasi*17/1000./t/ratio;
                mode_name = 'without adjustment';
            else
                e = (iasi-geo)*17/1000./t/ratio + e0;
                mode_name = 'with adjustment';
            end  

            so2 = ncread([path, 'GEOS-Chem\OutputDir', year, '\GEOSChem.SpeciesConc.' year, mon, '01_0000z.nc4'], 'SpeciesConc_SO2'); % mol mol-1 dry
            air_den = ncread([path, 'GEOS-Chem\OutputDir', year, '\GEOSChem.StateMet.' year, mon, '01_0000z.nc4'], 'Met_AIRDEN'); % kg m-3
            hi = ncread([path, 'GEOS-Chem\OutputDir', year, '\GEOSChem.StateMet.' year, mon, '01_0000z.nc4'], 'Met_BXHEIGHT'); % m

            so2 = sum(so2.*air_den.*hi/29*1000, 3)'; %mol/m-2
            SO2_mon(:,:,m) = so2;

            so4 = ncread([path, 'GEOS-Chem\OutputDir', year, '\GEOSChem.SpeciesConc.' year, mon, '01_0000z.nc4'], 'SpeciesConc_SO4'); % mol mol-1 dry
            %so4s = ncread([path, 'GEOS-Chem\OutputDir', year, '\GEOSChem.SpeciesConc.' year, mon, '01_0000z.nc4'], 'SpeciesConc_SO4'); % mol mol-1 dry

            so4 = sum((so4).*air_den.*hi/29*1000, 3)'; %mol/m-2
            %so4s = sum((so4s).*air_den.*hi/29*1000, 3)'; %mol/m-2

            SO4_mon(:,:,m) = so4;
            %SO4s_mon(:,:,m) = so4s;

            if y >= 2012 

                so2_o = so2_omps(:,:, (y-yr_baseline)*12 + m);
                SO2_O_mon(: ,:, m) = so2_o;
                e_EC = (iasi - geo + 2*so4*tre_EC*(y-yr_baseline))*17/1000./t/ratio + e0; % baseline year: 2012
                e_EC = e_EC .* (r(:,:,(y-yr_sta)*12 + m) < thre_r) .* (N > thre_n);
                e_EC = e_EC + e0.*(e_EC == 0);

                e_IP = (iasi - geo + 2*so4*tre_IP*(y-yr_baseline))*17/1000./t/ratio + e0; % baseline year: 2012
                e_IP = e_IP .* (r(:,:,(y-yr_sta)*12 + m) < thre_r) .* (N > thre_n);
                e_IP = e_IP + e0.*(e_IP == 0);

                e_IP_EC =  e_EC .* EC_geo + e_IP .* IP_geo;  
                e_adj = (iasi - geo + 2*so4.*(so2_o./so2 -1))*17/1000./t + e0; % baseline year: 2012
                e_adj = e_adj .* (r(:,:,(y-yr_sta)*12 + m) < thre_r) .* (N > thre_n);
                e_adj = e_adj + e0.*(e_adj == 0); 
                E_mon_adj(: ,:, m) = e_adj;
                e = e .* ~EC_geo .* ~IP_geo;
                e = e + e_IP_EC;
            end

            N = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'Monthly number of retrievals'); 
            % filter the emission
            e = e .* (r(:,:,(y-yr_sta)*12 + m) < thre_r);
            e = e .* (N > thre_n);
            e = e + e0.*(e==0);
            E(:, :, (y - yr_sta)*12 + m) = e;
            E_mon(:, :, m) = e;


        end
        E_mon(E_mon == 0) = nan;
        E_yr(:,:, y-yr_sta+1) = nanmean(E_mon, 3) .* (map_land > 0) .* grid_area * 3600*24*365/1E+9;

    %     E_EC(:,:, y-yr_sta+1) = mean(E_mon_EC, 3) .* (map_land > 0) .* grid_area * 3600*24*365; %kg
    %     E_IP(:,:, y-yr_sta+1) = mean(E_mon_IP, 3) .* (map_land > 0) .* grid_area * 3600*24*365; %kg
        SO2(:,:, y-yr_sta+1) = mean(SO2_mon, 3) .* (map_land > 0); %mol m-2
        SO4(:,:, y-yr_sta+1) = mean(SO4_mon, 3) .* (map_land > 0); %mol m-2
        SO2_O(:,:, y-yr_sta+1) = mean(SO2_O_mon, 3) .* (map_land > 0);

        %SO4s(:,:, y-yr_sta+1) = mean(SO4s_mon, 3) .* (map_land > 0); %mol m-2
    %     E_adj(:,:, y-yr_sta+1) = mean(E_mon_adj, 3) .* (map_land > 0) .* grid_area * 3600*24*365; % kg
    end
    E(E == 0) = NaN;

    save([path, '\IASI\Emission\SO2-correct-IP-EC_lifetime_', num2str(ratio*100), '%_', tnames, '_', mode_name, '_optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_w=', num2str(tre_IP), '_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'E'); % kg/m2/s
end

% E_EC(E_EC == 0) = NaN;
% E_IP(E_IP == 0) = NaN;
SO2(SO2 == 0) = NaN;
SO4(SO4 == 0) = NaN;
SO2_O(SO2_O == 0) = NaN;
%SO4s(SO4s == 0) = NaN;
% E_adj(E_adj == 0) = NaN;

data_iasi(data_iasi == 0) = NaN;
save([path, '\IASI\IASI_filter\IASI_filter_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'data_iasi'); % kg/m2/s
E_yr(E_yr == 0) = NaN;
% save([path, '\IASI\Emission\SO2-correct-IP-EC_', tnames, '_', mode_name, '_optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_w=', num2str(tre_IP) ,'_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'E'); % kg/m2/s
% save([path, '\IASI\Emission\Adjust_EC_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'E_EC'); % kg/
% save([path, '\IASI\Emission\Adjust_IP_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'E_IP'); % kg/
save([path, 'GEOS-Chem\SO2_concentration_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'SO2');
save([path, 'GEOS-Chem\SO4_concentration_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'SO4');
%save([path, 'GEOS-Chem\SO4s_concentration_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'SO4s');
% save([path, '\IASI\Emission\Adjust_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'E_adj'); % kg
save([path, '\OMPS\OMPS_SO2_annually_', num2str(yr_baseline), '-', num2str(yr_end), '.mat'], 'SO2_O'); % kg

E = nanmean(E, 3).* (map_land>0); % 
E(E == 0) = NaN;

emi_total = nansum(nansum(E .* grid_area * 3600*24*365/1E+9));
emi = squeeze(nansum(nansum(E_yr, 1), 2));
emi_ave = mean(emi);
emi_std = std(emi);

% regridded lon and lat grid
lon = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'lon');
lon = lon;
lat = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'lat');
lat = lat;
[x,y] = meshgrid((lon) , (lat));
mul = 1E+11;
max = 5; 

% draw
fig = figure();
set (gcf,'Position',[232,400,620,300]); %[left bottom width height]

m_proj('Equidistant Cylindrical','lat',[-70,70],'lon',[-180,180]);
m_coast('patch',[.6 .6 .6],'edgecolor',[.5,.5,.5]);
m_grid('box', 'on', 'linestyle', 'none', 'FontWeight', 'bold', 'FontName', 'Times New Roman','fontsize', 15, 'LineWidth', 2);
alpha(0)
hold on

sp = 10;
[C,h] = m_contourf(x, y, E*mul, 500);
set(h,'LineColor','none');
shp = shaperead('E:\AEE\code\fun\country\country.shp');
boundary_x=[shp(:).X];
boundry_y=[shp(:).Y];
m_plot(boundary_x , boundry_y , 'color' , 'k', 'LineWidth' , 1);
caxis([0 max]);
colormap(jet);

cb = colorbar('eastoutside','fontsize',15,'FontName','Times New Roman' , 'FontWeight' , 'normal' ,'LineWidth' , 2);
set(cb, 'YTick', 0:1:max);
set (gca,'Position',[0.09,0.1,0.80,0.80])
space(1 : 150) = 32; 

title(strcat('t=', tnames, space(1), mode_name, ' (10^{-11} kg/m^{2}/s)'), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
%title(strcat('IAIS n>', num2str(thre_n) ,' (10^{-11} kg/m^{2}/s) (Trans < Emi0)', space(1:sp), num2str(yr_sta), '-', num2str(yr_end)), 'FontSize' , 15 , 'FontName' ,'Times New Roman'); 
% text(-3, -1, '(b)', 'FontSize' , 15 , 'FontName' ,'Times New Roman', 'FontWeight', 'bold')
axis normal;

saveas(gcf,['C:\Users\bnulzq\Desktop\test\', tnames, '_', mode_name, '_IASI_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '.png'])

