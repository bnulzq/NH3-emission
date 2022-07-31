% calculate the averaged emission of prior and optimization with uncertainty and sensitivity (without ocean)
clear

path = 'E:\AEE\data\';
yr_sta = 2008;
yr_end = 2018;
yr_sta1 = 2008;
yr_end1 = 2018;
yr_len1 = yr_end1 - yr_sta1 +1;
yr = yr_sta:1:yr_end;
yr_len = length(yr);
thre_n = 800;
num = [400, 1200];
thre_r = 1;
ratio = [0.2, 5];
mul = 3600*24*365/12*1E-9; % Tg/year
mul1 = 1E-9; % kg -> Tg
lt_un = [50, 200]; %
so2_un = [0.04, 0.06]; % yr-1
% ocean
map_land = ncread(['E:\AEE\code\fun\MERRA2.20150101.CN.4x5.nc4'], 'FRLAND')';
map_land(map_land < 0.2) = NaN;
land = reshape(repmat(map_land, 1, yr_len1), [46, 72, yr_len1]);

% import data
opt = load([path, 'IASI\Emission\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_w=0.05_', num2str(yr_sta), '-', num2str(yr_end), '.mat']);
opt = opt.E;
opt = reshape(opt, [46, 72, yr_len, 12]);
opt = opt(:,:, yr_sta1-yr_sta+1:yr_end1-yr_sta+1,:);
pri = load([path, 'GEOS-Chem\Emissions\Total\HEMCO_diagnostics_NH3.Total_', num2str(yr_sta), '-', num2str(yr_end), '.mat']);
pri = pri.data;
pri = reshape(pri, [46, 72, yr_len, 12]);
pri = pri(:,:, yr_sta1-yr_sta+1:yr_end1-yr_sta+1,:);
grid_area = ncread([path, 'GEOS-Chem\OutputDir2008\GEOSChem.Budget.20080101_0000z.nc4'], 'AREA')'; % m-2
grid_area = reshape(repmat(grid_area, yr_len1, 1), [46, 72, yr_len1]);

iasi_un = load([path, '\Uncertainty\Uncertainty_IASI_emi_', num2str(yr_sta), '-', num2str(yr_end), '.mat']);
iasi_un = iasi_un.un;
iasi_un = reshape(iasi_un, [46, 72, yr_len, 12]);
iasi_un = iasi_un(:,:, yr_sta1-yr_sta+1:yr_end1-yr_sta+1,:);
lt_un1 = load([path, 'IASI\Emission\SO2-correct-IP-EC_lifetime_', num2str(lt_un(1)),'%_NHx lifetime_with adjustment_optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_w=0.05_', num2str(yr_sta), '-', num2str(yr_end), '.mat']);
lt_un1 = lt_un1.E;
lt_un1 = reshape(lt_un1, [46, 72, yr_len, 12]);
lt_un1 = lt_un1(:,:, yr_sta1-yr_sta+1:yr_end1-yr_sta+1,:);
lt_un2 = load([path, 'IASI\Emission\SO2-correct-IP-EC_lifetime_', num2str(lt_un(2)), '%_NHx lifetime_with adjustment_optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_w=0.05_', num2str(yr_sta), '-', num2str(yr_end), '.mat']);
lt_un2 = lt_un2.E;
lt_un2 = reshape(lt_un2, [46, 72, yr_len, 12]);
lt_un2 = lt_un2(:,:, yr_sta1-yr_sta+1:yr_end1-yr_sta+1,:);
so2_un1 = load([path, 'IASI\Emission\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_w=', num2str(so2_un(1)),'_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).E;
so2_un2 = load([path, 'IASI\Emission\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=', num2str(thre_n), '_r=', num2str(thre_r), '_w=', num2str(so2_un(2)),'_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).E;
so2_un1 = reshape(so2_un1, [46, 72, yr_len, 12]);
so2_un2 = reshape(so2_un2, [46, 72, yr_len, 12]);

% fill the nan
% opt_nan = isnan(opt);
% opt(isnan(opt)) = 0;
% opt = opt + pri.*opt_nan;
% opt(opt == 0) = nan;
opt = nansum(opt, 4) .* grid_area * mul .* (land > 0);
pri = nansum(pri, 4) .* grid_area * mul .* (land > 0);
opt = squeeze(nansum(nansum(opt, 2), 1));
pri = squeeze(nansum(nansum(pri, 2), 1));
opt_mean = mean(opt);
pri_mean = mean(pri);

un(1,:) = squeeze(nansum(nansum((nansum(iasi_un.^2, 4)/(yr_len*12 -1)).^0.5.* grid_area .* (land > 0), 2), 1)*mul) + opt;
un(2,:) = squeeze(-nansum(nansum((nansum(iasi_un.^2, 4)/(yr_len*12 -1)).^0.5.* grid_area .* (land > 0), 2), 1)*mul) + opt;
un(3,:) = squeeze(nansum(nansum(nansum(lt_un1, 4).* grid_area .* (land > 0), 2), 1))*mul;
un(4,:) = squeeze(nansum(nansum(nansum(lt_un2, 4).* grid_area .* (land > 0), 2), 1))*mul;
un(5,:) = squeeze(nansum(nansum(nansum(so2_un1, 4).* grid_area .* (land > 0), 2), 1))*mul;
un(6,:) = squeeze(nansum(nansum(nansum(so2_un2, 4).* grid_area .* (land > 0), 2), 1))*mul;

un_mean = mean(un, 2);

un_top = max(un, [], 1);
un_bot = min(un, [], 1);
un_top_mean = mean(un_top);
un_bot_mean = mean(un_bot);

% sensitivity
se_n_bo = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=', num2str(num(1)), '_r=1_w=0.05_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).E;
se_n_bo = reshape(se_n_bo, [46, 72, yr_len, 12]);
se_n_up = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=', num2str(num(2)), '_r=1_w=0.05_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).E;
se_n_up = reshape(se_n_up, [46, 72, yr_len, 12]);
se_r_up = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=800_r=', num2str(ratio(1)), '_w=0.05_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).E;
se_r_up = reshape(se_r_up, [46, 72, yr_len, 12]);
se_r_bo = load([path, 'IASI\\Emission\\SO2-correct-IP-EC_lifetime_100%_NHx lifetime_with adjustment_optimized_emi_n=800_r=', num2str(ratio(2)), '_w=0.05_', num2str(yr_sta), '-', num2str(yr_end), '.mat']).E;
se_r_bo = reshape(se_r_bo, [46, 72, yr_len, 12]);

se(1,:) = squeeze(nansum(nansum(nansum(se_n_bo, 4).* grid_area .* (land > 0), 2), 1))*mul;
se(2,:) = squeeze(nansum(nansum(nansum(se_n_up, 4).* grid_area .* (land > 0), 2), 1))*mul;
se(3,:) = squeeze(nansum(nansum(nansum(se_r_bo, 4).* grid_area .* (land > 0), 2), 1))*mul;
se(4,:) = squeeze(nansum(nansum(nansum(se_r_up, 4).* grid_area .* (land > 0), 2), 1))*mul;

se_mean = mean(se, 2);

