function [ output ] = exp_dist_func( x )
    output = (1-exp(-x)).*(x>=0);
end

