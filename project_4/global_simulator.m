function [ output_args ] = global_simulator( service_distr, arrival_distr )
    arrival_rate = 1000;
    arrival_mean = 1/(arrival_rate);
    service_mean = 0.04;
    
    chunk_size = 10000;
    
    arrival_delay = arrival_distr(rand(1, chunk_size-1), arrival_mean);
    arrival_timeline = zeros(1, chunk_size);
    for idx = 2:chunk_size
        arrival_timeline(idx) = arrival_timeline(idx-1) + arrival_delay(idx-1); 
    end
    service_delay = service_distr(rand(1, chunk_size), service_mean);
   
    completion_timeline = arrival_timeline + service_delay;
    
    busy_servers = zeros(1, chunk_size);
    running_avg = zeros(1, chunk_size);
    
    running_sum = 0;
    for idx = 2:chunk_size
        busy_servers(idx) = sum( 1.0 * (arrival_timeline(idx) >= arrival_timeline(1:idx-1)) .* (arrival_timeline(idx) < completion_timeline(1:idx-1)) );
        running_sum = running_sum + busy_servers(idx);
        running_avg(idx) = running_sum/(idx-1);
    end
    
    x_axis = linspace(1, chunk_size + 1, chunk_size);
    ideal_vals = arrival_rate * service_mean * ones(1, chunk_size);
    ideal_vals_2 = mean(busy_servers) * ones(1, chunk_size);
    ideal_vals_3 = zeros(1, chunk_size);
    for idx = 1:chunk_size
        current_t_value = arrival_timeline(idx);
        n_value = floor(arrival_rate*current_t_value);
        k_th_sum = 0;
        for idx_2 = 1:n_value
            time_diff = 1.5*current_t_value - arrival_timeline(idx_2);
            k_th_sum  = k_th_sum + exp( (-1/service_mean)*time_diff );
        end
        
        ideal_vals_3(idx) = k_th_sum;
    end
    
    cla
    hold on
    plot(arrival_timeline, running_avg, 'r-');
    plot(arrival_timeline, ideal_vals, 'g-');
    plot(arrival_timeline, ideal_vals_2, 'b-');
    figure;
    plot(arrival_timeline, ideal_vals_3, 'r-');

    mean(ideal_vals_3)
    arrival_rate * service_mean
    
%GLOBAL_SIMULATOR Summary of this function goes here
%   Detailed explanation goes here


end

