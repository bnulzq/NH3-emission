function [data_4_5] = Regrid4x5(data,scale, n)
%UNTITLED2 regrid for the data to 4X5
    si = size(data);
    disp(['data size is: ', num2str(si)])
    len = si(n);
    
    if si(1) > si(2)
        disp('(lon, lat, :)')
        data_4_5 = NaN([72, 46, len]);
%    88-90/0-2
        for lon = 1:72

            data_4_5(lon, 1, :) = nanmean(nanmean(data((lon-1)*scale*5+1:lon*scale*5, 1:2*scale, :), 2), 1);
            data_4_5(lon, 46, :) = nanmean(nanmean(data((lon-1)*scale*5+1:lon*scale*5, 178*scale+1:180*scale, :), 2), 1);
            
        end
%   3S-87N
        for lat = 2:45
           for lon = 1:72
               
               data_4_5(lon, lat, :) = nanmean(nanmean(data((lon-1)*scale*5+1:lon*scale*5, (lat-1)*scale*4-2*scale+1:lat*scale*4-2*scale,:), 2), 1);
                              
           end
        end
        
    else
        disp('(lat, lon, :)')
        data_4_5 = NaN([46, 72, len]);
        %    88-90/0-2
        for lon = 1:72

            data_4_5(1, lon, :) = nanmean(nanmean(data(1:2*scale, (lon-1)*scale*5+1:lon*scale*5, :), 2), 1);
            data_4_5(46, lon, :) = nanmean(nanmean(data(178*scale+1:180*scale, (lon-1)*scale*5+1:lon*scale*5, :), 2), 1);
            
        end
%   3S-87N
        for lat = 2:45
           for lon = 1:72
               
               data_4_5(lat, lon, :) = nanmean(nanmean(data((lat-1)*scale*4-2*scale+1:lat*scale*4-2*scale, (lon-1)*scale*5+1:lon*scale*5,:), 2), 1);
                              
           end
        end
    end
    

end

