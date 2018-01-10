function [ sum ] = measure_average( anomaly_detector, iterations )
    sum = 0;
    for i = 1:iterations
        sum = sum + anomaly_detector(@den_func,@inv_dens_func ,@dist_func, @inv_dist_func, 100000, 1/4, 10);
    end
    sum = sum/iterations;
    
    'Average: '
    sum
end

