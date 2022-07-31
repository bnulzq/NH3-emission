function [domain_matrix] = Domain(geo, n_lat, n_lon)
%UNTITLED assign values to specific domain
% geo: grid index: bottom, left, top, right
    domain_matrix = zeros([n_lat, n_lon], 'double');
    domain_matrix(geo(1):geo(3), geo(2):geo(4)) = 1;

end

