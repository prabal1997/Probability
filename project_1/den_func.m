function [ output ] = den_func( x )
    output = exp(-x).*heaviside(x);
    if ( (heaviside(x) < 1) .* (heaviside(x) > 0) )
        output = 2*output;
    end
end

