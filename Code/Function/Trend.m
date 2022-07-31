function [tre, test] = Trend(data, n_lat, n_lon, n_yr)
    %UNTITLED4 计算data的trend和Significance coefficient
    %   trend
        tre = zeros([n_lat, n_lon], 'double');
        test = ones([n_lat, n_lon], 'double');
        for i = 1:n_lat
            for j = 1:n_lon
        
                dataij = squeeze(data(i,j,:));
                %%judge 0
                a = squeeze(dataij ~= 0);
                if sum(a) >= n_yr-1
                    x = single([ones(n_yr,1) , (0 : n_yr-1)']);
                    [b, bint, r, rint, stats] = regress(dataij, x, 0.05);
                    tre(i, j) = b(2);
                    test(i, j) = stats(3);
                end
            end
        end
        
        tre(tre==0) = nan;
        
    end