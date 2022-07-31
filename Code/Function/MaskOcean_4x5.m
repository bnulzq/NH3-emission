function [data_mask] = MaskOcean(data)
    %UNTITLED3 掩膜
    %   Mask the Ocean (4x5)
        % map
        map = ncread('C:\Users\Administrator\Desktop\code\fun\map.nc', 'map');
       % map_lon = ncread('C:\Users\Administrator\Desktop\code\fun\map.nc', 'lon');
        map = map';
        m = map(:,1:180);
        map(:,1:180) = map(:,181:360);
        map(:,181:360) = m;
        map_land = (map ~= 0 & map ~= 2);
        map_land = MapReclass(map_land, 72, 46);

        data_mask = data .* map_land;
        data_mask(data_mask == 0) = nan;
    
    end

