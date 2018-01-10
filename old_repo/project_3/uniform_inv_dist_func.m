function [ output ] = uniform_inv_dist_func( x, mean )
    output = x.*(x>=0);
    output( output > 1 ) = 1;
end

