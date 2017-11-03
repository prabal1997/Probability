function [ output ] = uni_inv_dist_func( x, arr )
    if (length(arr) == 2)
        a = arr(1);
        b = arr(2);
    else
        a = 0;
        b = 2*arr;
    end
    
    output = x*(b-a)+a;
end

