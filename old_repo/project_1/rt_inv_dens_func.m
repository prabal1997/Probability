function [ output ] = rt_inv_dens_func( x )
    output = x .* (x >= 0) .* (x <= 1);
end

