function [ trial_count ] = estimate_e( service_distr, arrival_distr, sim_length_points)
    %calculate the ratios
    arrival_rate = 100;
    arrival_mean = 1/arrival_rate;
    service_mean = 0.009;
    ideal_avg = arrival_rate * service_mean;
    ideal_avg2=  exp(-1/ideal_avg)/(1-exp(-1/ideal_avg));
    
    %calculate arrivals
    arrival_array = arrival_distr(rand(1, sim_length_points), arrival_mean);
    arrival_array(1) = 0;
    arrival_array = cumsum(arrival_array);
    
    %calculate service time
    service_array = service_distr(rand(1, sim_length_points), service_mean);
    
    %completion times array
    
    completion_array = service_array + arrival_array;
    
    %calculate busy servers
    busy_servers = zeros(1, sim_length_points);
    for idx = 2:sim_length_points
        busy_servers(idx) = sum( 1.0 * (arrival_array(idx) >= arrival_array(1:idx-1)) .* ( arrival_array(idx) < completion_array(1:idx-1) ));
    end
    new_busy_servers = cumsum(busy_servers);
    for idx = 1:sim_length_points
        new_busy_servers(idx) = new_busy_servers(idx)/idx;
    end
    %plot(arrival_array, busy_servers, 'b.');
    
    %calculate e values
    e_array = exp((-log(1-busy_servers/ideal_avg)*service_mean)./arrival_array);
    hold on
    plot(arrival_array, new_busy_servers, 'b.');
    plot(arrival_array, (e_array), 'g-');
    plot(arrival_array, exp(1)*ones(1, sim_length_points), 'r-');
    plot(arrival_array, ideal_avg*ones(1, sim_length_points), 'r.-');
    plot(arrival_array, ideal_avg2*ones(1, sim_length_points), 'r.-');
end
