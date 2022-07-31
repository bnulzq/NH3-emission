% filter the IASI daily data
clear all

path_in = '/pdiskdata/zhangyuzhonggroup/luozhenqi/nh3/IASI_daily/daily/';
path_ou = '/pdiskdata/zhangyuzhonggroup/luozhenqi/nh3/IASI_filter/IASI_filter_';
yr_sta = 2014;
yr_end = 2018;
missing_value = -999;
cloud_thre = 10;

% GEOS-Chem lat and lon
lon_geo = ncread(['/pdiskdata/zhangyuzhonggroup/luozhenqi/nh3/GEOS-Chem/concentration_month/GEOS-Chem_200801.nc'], 'lon');
lat_geo = ncread(['/pdiskdata/zhangyuzhonggroup/luozhenqi/nh3/GEOS-Chem/concentration_month/GEOS-Chem_200801.nc'], 'lat');
%[x,y] = meshgrid((lon) , (lat));
for yr = yr_sta:yr_end

    year = num2str(yr);
    disp(['Year: ', year])
    % skin temperature
    st = ncread(['/pdiskdata/zhangyuzhonggroup/luozhenqi/skin temperature/ERA5/ERA5_skin_temperature_', year, '_daily.nc'], 'skt'); % K

    for mon = 1:12

        month = num2str(mon, '%02d');
        disp(['Month: ', month])
        namelist = dir([path_in, 'IASI_METOPA_L2_NH3_', year, month, '*.nc']);
        
        nh3_fi_mon = NaN([46, 72, length(namelist)], 'double');
        nh3_unf_mon = NaN([46, 72, length(namelist)], 'double');
        re_err_mon = NaN([46, 72, length(namelist)], 'double');
        ret_n_mon = NaN([46, 72, length(namelist)], 'double');
        err_mon = NaN([46, 72, length(namelist)], 'double');
        day_mon = NaN([length(namelist), 1], 'single');

        for i = 1:length(namelist)
            

            nh3_fi = NaN([46, 72], 'double');
            nh3_unf = NaN([46, 72], 'double');
            re_err = NaN([46, 72], 'double');
            ret_n = NaN([46, 72], 'double');
            err = NaN([46, 72], 'double');

            namei = namelist(i).name;
            day = str2num(namei(26:27));
            disp(['Day: ', namei(26:27)])

            % date index 
            day_yr = days(datetime(yr, mon, day) - datetime(yr, 1, 1) +1)*2 - 1;

            day_mon(i) = day;
            am = ncread([path_in, namei], 'AMPM');
            clo = ncread([path_in, namei], 'cloud_coverage');
            unc = ncread([path_in, namei], 'nh3_total_column_uncertainty');
            lat = ncread([path_in, namei], 'latitude');
            lon = ncread([path_in, namei], 'longitude');
            col = ncread([path_in, namei], 'nh3_total_column');
            
            % filter: AM = 0, -1% < cloud coverage < cloud_thre%
            filter = find((am == 0) & (clo > -1) & (clo < cloud_thre) & (col ~= missing_value));
            
            % unfilter
            unfilter = find((am == 0) & (col ~= missing_value));

            % global processing
            for j = 1:46
                %disp(j)
                lat_j = lat_geo(j);
                for k = 2:72

                    lon_k = lon_geo(k);
                    f_geo_lon = find((lon < (lon_k +2.5)) & (lon > (lon_k -2.5)));
                    f_geo_lat = find((lat < (lat_j +2)) & (lat > (lat_j -2)));
                    f_geo = intersect(f_geo_lon, f_geo_lat);
                    
                    fi_geo = intersect(filter, f_geo); % get the intersection
                    unf_geo = intersect(unfilter, f_geo); 

                    if ~isempty(unf_geo) 

                        nh3_unfjk = col(unf_geo);
                        nh3_unf(j, k) = nanmean(nh3_unfjk);

                        if ~isempty(fi_geo)

                            % adjust the lon of skin temperature
                            stjk(1:720, :) = mean(st(721:1440, :, day_yr:day_yr +1), 3);
                            stjk(721:1440, :) = mean(st(1:720, :, day_yr:day_yr +1), 3);

                            % filter the skin temperature
                            fi_geo_skt = [];
                            for l = 1:length(fi_geo)

                                lonjkl = round((180 + lon(fi_geo(l)))/0.25);
                                latjkl = round((90 - lat(fi_geo(l)))/0.25);
                                
                                stjkl = stjk(lonjkl, latjkl);

                                if stjkl > 263.15

                                    fi_geo_skt = [fi_geo_skt fi_geo(l)];

                                end

                            end

                            nh3_fjk = col(fi_geo_skt);
                            nh3_fi(j, k) = nanmean(nh3_fjk);

                            rejk = abs(unc(fi_geo_skt));
                            errjk = (unc(fi_geo_skt)/100 .* nh3_fjk).^2; % relative_error% * column 
                            rejk(rejk == missing_value) = nan;
                            re_err(j, k) = nanmean(rejk);

                            ret_n(j, k) = nansum(~isnan(nh3_fjk));
                            err(j, k) = nansum(errjk);
                        
                        end      
                    end
                end
            end
            
            % lon center = -180
            for j = 1:46

                lat_j = lat_geo(j);

                f_geo_lon = find((lon < -177.5) | (lon > 177.5));
                f_geo_lat = find((lat < (lat_j +2)) & (lat > (lat_j -2)));
                f_geo = intersect(f_geo_lon, f_geo_lat);

                fi_geo = intersect(filter, f_geo); % get the intersection
                unf_geo = intersect(unfilter, f_geo); 

                if ~isempty(unf_geo) 

                    nh3_unfjk = col(unf_geo);
                    nh3_unf(j, 1) = nanmean(nh3_unfjk);

                    if ~isempty(fi_geo)

                        % adjust the lon of skin temperature
                        stjk(1:720, :) = mean(st(721:1440, :, day_yr:day_yr +1), 3);
                        stjk(721:1440, :) = mean(st(1:720, :, day_yr:day_yr +1), 3);

                        % filter the skin temperature
                        fi_geo_skt = [];
                        for l = 1:length(fi_geo)

                            lonjkl = round((180 + lon(fi_geo(l)))/0.25);
                            latjkl = round((90 - lat(fi_geo(l)))/0.25);
                            
                            if lonjkl == 0
                                lonjkl = 1;
                            end
                            
                            stjkl = stjk(lonjkl, latjkl);

                            if stjkl > 263.15

                                fi_geo_skt = [fi_geo_skt fi_geo(l)];
                            end

                        end

                        nh3_fjk = col(fi_geo_skt);
                        nh3_fi(j, k) = nanmean(nh3_fjk);

                        errjk = (unc(fi_geo_skt)/100 .* nh3_fjk).^2;

                        rejk = abs(unc(fi_geo_skt));
                        rejk(rejk == missing_value) = nan;
                        re_err(j, k) = nanmean(rejk);

                        ret_n(j, k) = nansum(~isnan(nh3_fjk));
                        err(j, k) = nansum(errjk);

                    end      
                end
            end

            nh3_fi(nh3_fi == 0) = nan;
            nh3_unf(nh3_unf == 0) = nan;
            re_err(re_err == 0) = nan;
            ret_n(ret_n == 0) = nan;
            
            
            nh3_fi_mon(:, :, i) = nh3_fi;
            nh3_unf_mon(:, :, i) = nh3_unf;
            re_err_mon(:, :, i) = re_err;
            ret_n_mon(:, :, i) = ret_n;
            err_mon(:, :, i) = err;

        end

        fi_mon = nanmean(nh3_fi_mon, 3);
        re_mon = nanmean(re_err_mon, 3);
        unf_mon = nanmean(nh3_unf_mon, 3);
        rn_mon = nansum(ret_n_mon, 3);
        uncertainty_mon = sqrt(nansum(err_mon, 3)./(rn_mon -1));
        
        % write to nc file
        ncid = netcdf.create([path_ou, 'AM_Cloud<', num2str(cloud_thre), '_', year, month,  '.nc'], 'CLOBBER');
        
        dimidx = netcdf.defDim(ncid, 'lon', 72);   
        dimidy = netcdf.defDim(ncid, 'lat', 46);
        dimidz = netcdf.defDim(ncid, 'day', length(namelist));

        var_lon = netcdf.defVar(ncid, 'lon', 'double', [dimidx]);
        var_lat = netcdf.defVar(ncid, 'lat', 'double', [dimidy]);
        var_day = netcdf.defVar(ncid, 'day', 'int', [dimidz]);

        var_nh3_f = netcdf.defVar(ncid, 'nh3 filter', 'double', [dimidy dimidx dimidz]);
        var_nh3_u = netcdf.defVar(ncid, 'nh3 unfilter', 'double', [dimidy dimidx dimidz]);
        var_re = netcdf.defVar(ncid, 'relative error', 'double', [dimidy dimidx dimidz]);
        var_nr = netcdf.defVar(ncid, 'Number of retrievals', 'double', [dimidy dimidx dimidz]);
        var_err = netcdf.defVar(ncid, 'err', 'double', [dimidy dimidx dimidz]);

        var_nh3_f_m = netcdf.defVar(ncid, 'averaging nh3 filter', 'double', [dimidy dimidx]);
        var_nh3_u_m = netcdf.defVar(ncid, 'averaging nh3 unfilter', 'double', [dimidy dimidx]);
        var_re_m = netcdf.defVar(ncid, 'averaging relative error', 'double', [dimidy dimidx]);
        var_nr_m = netcdf.defVar(ncid, 'Monthly number of retrievals', 'double', [dimidy dimidx]);
        var_err_m = netcdf.defVar(ncid, 'averaging err', 'double', [dimidy dimidx]);
        
        netcdf.putAtt(ncid, var_nh3_f, 'units', 'mol m-2');                                                    
        netcdf.putAtt(ncid, var_nh3_u, 'units', 'mol m-2');                                                    
        netcdf.putAtt(ncid, var_re, 'units', '%');                 
        netcdf.putAtt(ncid, var_nr, 'units', 'number');
        netcdf.putAtt(ncid, var_err, 'units', 'mol m-2');

        netcdf.putAtt(ncid, var_nh3_f_m, 'units', 'mol m-2');                                                    
        netcdf.putAtt(ncid, var_nh3_u_m, 'units', 'mol m-2');                                                    
        netcdf.putAtt(ncid, var_re_m, 'units', '%');                 
        netcdf.putAtt(ncid, var_nr_m, 'units', 'number');
        netcdf.putAtt(ncid, var_err_m, 'units', 'mol m-2');

        netcdf.endDef(ncid);

        netcdf.putVar(ncid, var_day, day_mon);
        netcdf.putVar(ncid, var_lon, lon_geo);
        netcdf.putVar(ncid, var_lat, lat_geo);

        netcdf.putVar(ncid, var_nh3_f, nh3_fi_mon);
        netcdf.putVar(ncid, var_nh3_u, nh3_unf_mon);
        netcdf.putVar(ncid, var_re, re_err_mon);
        netcdf.putVar(ncid, var_nr, ret_n_mon);
        netcdf.putVar(ncid, var_err, err_mon);

        netcdf.putVar(ncid, var_nh3_f_m, fi_mon);
        netcdf.putVar(ncid, var_nh3_u_m, unf_mon);
        netcdf.putVar(ncid, var_re_m, re_mon);
        netcdf.putVar(ncid, var_nr_m, rn_mon);
        netcdf.putVar(ncid, var_err_m, uncertainty_mon);
                
        netcdf.close(ncid);
    end
end
