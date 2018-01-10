function [ output ] = normal_inv_dist_func( x, param )
    dev = 1;
    mean = 0;
    if (length(param) == 1)
        mean = param;
    else
        dev = param(1);
        mean = param(2);
    end
    output = dev*sqrt(2)*erfinv(2*x-1)+mean;
end

