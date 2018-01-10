function [ output ] = exp_inv_dist_func( x )
    output = -log(1-x).*(x>=0);
end

