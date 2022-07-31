function [ nh3 ] = Extract_season_year(data)
%UNTITLED2 此处显示有关此函数的摘要
%   convert monthly data into seasonal data
    n_yr = size(data, 3);
    nh3 = zeros([180, 360, n_yr, 4], 'single');
    mon = [1, 2, 12;
        3, 4, 5;
        6, 7, 8;
        9, 10, 11];
    for i = 1:4
        for j = 1:3
            monij = mon(i, j);
            dataij = data(:,:,:,monij);
            %dataij(dataij == 0) = nan;
            nh3ij(:,:,:,j) = dataij;
        end
        nh3(:,:,:,i) = squeeze(nanmean(nh3ij, 4));
    end
    nh3(nh3==0)=nan;
end

