function [map_re] = MapReclass(map, lon, lat)
%UNTITLED2 对地图进行重分类
%   Get the mode
    map_re = zeros([lat, lon], 'single');
    lon_mul = 360/lon;
    lat_mul = 180/(lat-1);
    
    % start and end of the latitude is specific
    for j = 1:lon
        map1j = map(1:2, (j-1)*lon_mul+1:j*lon_mul);
        map_1j = map(end-1:end, (j-1)*lon_mul+1:j*lon_mul);
        
        map_re(1, j) = mode(map1j, 'all');
        map_re(end, j) = mode(map_1j, 'all');
    end
    
    % latitude 2:(n-1)
    for i = 2:lat-1
       for j = 1:lon
           mapij = map((i-1)*lat_mul+1:i*lat_mul, (j-1)*lon_mul+1:j*lon_mul);
           
           a = squeeze(mapij == 0);
           if sum(sum(a)) < 19           
              m = 1;
           else
              m = mode(mapij, 'all');
           end
           map_re(i, j) = m;
       end
    end
 
end

