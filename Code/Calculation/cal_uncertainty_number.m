% calculate uncertainty of number of retrievals to emissions
clear all

path = 'E:\AEE\data\';
yr_sta = 2008;
yr_end = 2018;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
lat_sta = 6;
lat_end = 41;

ns = [400, 800, 1200];
thre_r = 1;

% import data
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

E_yr = NaN([46, 72, yr_len], 'double');
un = NaN([46, 72, yr_len*12], 'double');
load([path, 'GEOS-Chem\transport_to_emission_2008-2018.mat']); % transport/emission
r = r(:,:,(yr_sta-2008)*12+1:(yr_end-2008+1)*12);

for i = 1:length(ns)
    
    n = ns(i);
    disp(['Number: ', num2str(n)])
    for y = yr

        year = num2str(y);
        E_mon = NaN([46, 72, 12], 'double');
    
        for m = 1:12
    
            mon = num2str(m, '%02d');
            grid_area = ncread([path, 'GEOS-Chem\OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'AREA')'; % m-2
            geo = ncread([path, 'GEOS-Chem\concentration\GEOS-Chem_Total column_' year, mon, '.nc'], ['GEOS-Chem monthly mean NH3'])'; % mol m-2
            iasi = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'averaging nh3 filter'); % mol m-2
            t = ncread([path, 'GEOS-Chem\Budget\GEOS-Chem_lifetime_', year, mon, '.nc'], 'NHx lifetime')*3600; % s
            e0 = ncread([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.', year, mon, '.nc'], 'Total')'; % GEIS-Chem emission 
            N = ncread([path, 'IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'Monthly number of retrievals'); 
            %       e = iasi*17/1000./t;
            e = (iasi-geo)*17/1000./t + e0;
            e = e .* (r(:,:,(y-yr_sta)*12 + m) < thre_r);
            e = e .* (N > n);
            e0(e ~= 0) = 0;
            e = e + e0;
            E_mon(:, :, m) = e;
            un(:,:,(y-yr_sta)*12+m) = e .* (map_land > 0) .* grid_area * 3600*24*365/12; % kg month-1

        end

        E_mon(E_mon == 0) = nan;
        E_yr(:,:, y-yr_sta+1) = nanmean(E_mon, 3) .* (map_land > 0) .* grid_area * 3600*24*365/1E+9;

    end
    save([path, 'uncertainty_number_n_', num2str(n), '_', num2str(yr_sta) '-', num2str(yr_end), '.mat'], 'un')
    E_yr(E_yr == 0) = NaN;
    
    emi = squeeze(nansum(nansum(E_yr, 1), 2));
    emi_ave(i) = mean(emi);
    emi_std(i) = std(emi);

end