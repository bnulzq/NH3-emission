% mean spatial distribution of GEOS-Chem lifetime (NH3)
% original and adjustment 
clear all

path = 'E:\AEE\data\GEOS-Chem\';
yr_sta = 2008;
yr_end = 2018;
yrs = yr_end - yr_sta +1;
thre_r = 1;
thre_n = 800;

% GEOS-Chem lat and lon
lon = ncread([path, 'OutputDir2008\GEOSChem.DryDep.20080101_0000z.nc4'], 'lon');
lat = ncread([path, 'OutputDir2008\GEOSChem.DryDep.20080101_0000z.nc4'], 'lat');

% land
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;

% ratio 
r = load(['E:\AEE\data\GEOS-Chem\transport_to_emission_2008-2018.mat']); % transport/emission
r = r.r;

t_nh3_ori = NaN([46, 72, yrs, 12], 'double');
for yr = yr_sta:1:yr_end

    year = num2str(yr);
    disp(['Year: ', year])

    for m = 1:12

        mon = num2str(m,'%02d');
        % import data
        grid_area = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'AREA')'; % m-2
        nh3 = ncread([path, 'concentration\GEOS-Chem_Total column_' year, mon, '.nc'], ['GEOS-Chem monthly mean NH3'])'; % mol m-2
        M = (nh3*17)/1000.*grid_area; % kg

        chem = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'BudgetChemistryFull_NH3')'; % kg s-1, neg
        nh3_wet = ncread([path, 'OutputDir', year, '\GEOSChem.Budget.' year, mon, '01_0000z.nc4'], 'BudgetWetDepFull_NH3')'; % kg s-1, positive value
        nh3_dry = ncread([path, 'OutputDir', year, '\GEOSChem.DryDep.' year, mon, '01_0000z.nc4'], 'DryDep_NH4')'; % molec cm-2 s-1, neg
        nh3_dry = -nh3_dry/6.02214179E19*17/1000.*grid_area; % kg s-1

        L = nh3_wet + nh3_dry + chem;
        N = ncread(['E:\AEE\data\IASI\IASI_filter\IASI_filter_AM_Cloud_10_', year, mon, '.nc'], 'Monthly number of retrievals'); 
        
        t_nh3_ori(:,:, yr-yr_sta +1, m) = -M./L/3600 .* (rm<thre_r) .* (N>thre_n); % original


    end

end

t(t == 0) = NaN;
save([path, num2str(yr_sta), '-', num2str(yr_end), '.mat'])