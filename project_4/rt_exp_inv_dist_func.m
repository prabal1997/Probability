function [ output ] = rt_exp_inv_dist_func(x, mean)
    output = -mean*log(1-x).*(x>=0);
end

