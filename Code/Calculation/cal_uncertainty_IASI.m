% calculate uncertainty of IASI concentration to emissions
clear all

path = 'E:\AEE\data\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
thre_n = 800;
thre_r = 1;

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

% iasi_un = load([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_Uncertainty_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).uncer;
E_yr1 = NaN([46, 72, yr_len], 'double');
E_yr2 = NaN([46, 72, yr_len], 'double');
un = NaN([46, 72, yr_len*12], 'double');

load([path, 'GEOS-Chem\transport_to_emission_2008-2018.mat']); % transport/emission
r = r(:,:,(yr_sta-2008)*12+1:(yr_end-2008+1)*12);

for y = yr

    year = num2str(y);
    E_mon1 = NaN([46, 72, 12], 'double');
    E_mon2 = NaN([46, 72, 12], 'double');

    for m = 1:12

        mon = num2str(m, '%02d');
        grid_area = ncread([path, 'GEOS-Chem\OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'AREA')'; % m-2
        geo = ncread([path, 'GEOS-Chem\concentration\GEOS-Chem_Total column_' year, mon, '.nc'], ['GEOS-Chem monthly mean NH3'])'; % mol m-2
        iasi = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'averaging nh3 filter'); % mol m-2
        iasi_un = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'averaging err'); % mol m-2
        t = ncread([path, 'GEOS-Chem\Budget\GEOS-Chem_lifetime_', year, mon, '.nc'], 'NHx lifetime')*3600; % s
        e0 = ncread([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.', year, mon, '.nc'], 'Total')'; % GEIS-Chem emission 
        N = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'Monthly number of retrievals'); 
        
        e1 = (iasi-geo)*17/1000./t + e0;
        e1 = e1 .* (r(:,:,(y-yr_sta)*12 + m) < thre_r);
        e1 = e1 .* (N > thre_n);
        E_mon1(:, :, m) = e1;

        e2 = (iasi_un)*17/1000./t;
        e2 = e2 .* (r(:,:,(y-yr_sta)*12 + m) < thre_r);
        e2 = e2 .* (N > thre_n);
        E_mon2(:, :, m) = e2; % delta
        
        un(:,:,(y-yr_sta)*12+m) = (e2) .* (map_land > 0); % kg s-1 m-2
        
    end

    E_mon1(E_mon1 == 0) = nan;
    E_mon2(E_mon2 == 0) = nan;

    E_yr1(:,:, y-yr_sta+1) = nanmean(E_mon1, 3) .* (map_land > 0) .* grid_area * 3600*24*365/1E+9; 
    E_yr2(:,:, y-yr_sta+1) = nanmean(E_mon2, 3) .* (map_land > 0) .* grid_area * 3600*24*365/1E+9;

end

un(un == 0) = NaN;
save([path, 'uncertainty\Uncertainty_IASI_emi_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'un')

E_yr1(E_yr1 == 0) = NaN;
E_yr2(E_yr2 == 0) = NaN;
emi1 = squeeze(nansum(nansum(E_yr1, 1), 2));
emi2 = squeeze(nansum(nansum(E_yr2 .^ 2, 1), 2));

emi_ave(1) = mean(emi1);
emi_ave(2) = mean(sqrt(emi2));
emi_std(1) = std(emi1);
emi_std(2) = std(emi2 .^ 0.5);
