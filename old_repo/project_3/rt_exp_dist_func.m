function [ output ] = rt_exp_dist_func( x, mean )
    output = (1-exp(-x/mean))*(x>=0);
end

