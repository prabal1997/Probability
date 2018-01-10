function [ output ] = rt_periodic_inv_distr( x, mean )
    output = mean.*ones(1, length(x)).*(x>=0).*(x<=1);
end

