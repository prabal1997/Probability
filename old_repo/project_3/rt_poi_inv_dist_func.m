function [ output ] = rt_poi_inv_dist_func( x, mean )
    output = zeros(1, length(x));
    for i = 1:length(x)
        output(i) = exp(-mean)*(mean^x(i))/gamma(x(i)+1);
    end
end

