function [ output ] = normal_inv_dist_func( x )
    output = sqrt(2)*erfinv(2*x-1);
end

