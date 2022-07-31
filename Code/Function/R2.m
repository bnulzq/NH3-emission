function [r2] = R2(data1, data2, n_lat, n_lon, n_yr)
    %UNTITLED4 计算data的trend和Significance coefficient
    %   trend
        r2 = zeros([46, 72], 'double');
        for i = 1:n_lat
            for j = 1:n_lon
        
                data1ij = squeeze(data1(i, j, :));
                data2ij = squeeze(data2(i, j, :));
                %%judge 0
                a = squeeze(data1ij ~= 0);
                b = squeeze(data2ij ~= 0);
                if sum(a) == n_yr && sum(b) == n_yr
                    
                    [b, bint, r, rint, stats] = regress(data1ij, data2ij, 0.05);
                    r2(i, j) = stats(1);
                end
            end
        end
        
        r2(r2 == 0) = nan;
        
    end