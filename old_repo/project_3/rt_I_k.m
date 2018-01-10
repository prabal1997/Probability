function [ output ] = rt_I_k(x, i, k, dist_func)
    if (x == 1)
        output = dist_func(i*k)-dist_func((i-1)*k);
    elseif (x == 0)
        output = 1-(dist_func(i*k)-dist_func((i-1)*k)); 
    else
        output = zeros(1, length(i));
    end   
end

