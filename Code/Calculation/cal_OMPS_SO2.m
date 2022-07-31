% calculate the OMPS (1°×1°) SO2 concentrations
clear

path = 'E:\AEE\data\OMPS\OMPS_SO2\OMPS_SO2_';

yr_sta = 2012;
yr_end = 2018;
yr_len = yr_end - yr_sta +1;

mul = 2.69E16/6.02214076E19;

SO2 = NaN([180, 360, yr_len*12], 'double');

for yr = yr_sta:yr_end

    year = num2str(yr);

    for m = 1:12

        if yr == 2018 && m >= 8
            mon = num2str(13-m, '%02d');
        else 
            mon = num2str(m, '%02d'); 
        end
        
        data = ncread([path, year, '-', mon, '_monthly.nc'], 'SO2_grid');
        
        SO2(:, :, (yr-yr_sta)*12+m) = data';

    end
end

so2 = Regrid4x5(SO2, 1, 3) * mul;
save([path, '_4x5_monthly_', num2str(yr_sta), '-', num2str(yr_end), '.mat'], 'so2'); % mol/m2
