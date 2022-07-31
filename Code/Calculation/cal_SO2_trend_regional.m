% simulated SO2 concentration trend 
clear

path = 'E:\AEE\data\GEOS-Chem\';
yr_sta = 2012;
yr_end = 2018;
% Aus: 16 20 59 68; IP: 25 31 51 55; EU: 33 37 35 43; US: 30 35 12 23; EC:29 35 57 62; CA: 19 28 33 42
% NCP: 33 34 59 61; EI: 28 29 52 54
lat1 = 29;
lat2 = 35;
lon1 = 57;
lon2 = 62;

SO2 = load([path, 'SO2_concentration_2008-2018.mat']).SO2;
data = squeeze(nanmean(nanmean(SO2(lat1:lat2, lon1:lon2,:), 2), 1));
data = data(yr_sta -2008 +1: yr_end-2008+1);
n_yr = length(data);
x = single([ones(n_yr,1) , (0 : n_yr-1)']);
[b, bint, r, rint, stats] = regress(data, x, 0.05);
tre = b(2);
test = stats(3);
re_tre = tre/mean(data);


