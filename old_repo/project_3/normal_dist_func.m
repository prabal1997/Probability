function [ output ] = normal_dist_func( x )
    output = (1/2)*(1+erf(x./sqrt(2)));
end