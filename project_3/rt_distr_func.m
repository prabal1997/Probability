function [ output ] = rt_distr_func( x, mean )
    
    if (x <= 0)
        output = zeros(1, length(x));
    elseif (x > 0 && x <= 1)
        output = x;
    else
        output = ones(1, length(x));
    end
    
end

