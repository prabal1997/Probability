function [ output ] = dist_func( x )
    output = (1-exp(-x)).*heaviside(x);
end

