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
    ideal_arr1 = zeros(1, sim_length_points);
    ideal_arr2 = zeros(1, sim_length_points);
    for idx = 2:sim_length_points
        busy_servers(idx) = sum( 1.0 * (arrival_array(idx) >= arrival_array(1:idx-1)) .* ( arrival_array(idx) < completion_array(1:idx-1) ));
        ideal_arr1 = ideal_avg*(1-exp(-arrival_array(idx)/service_mean));
        ideal_arr2 = exp(-1/ideal_avg)/(1-exp(-1/ideal_avg))*(1-exp(-arrival_array(idx)/service_mean));
    end
    new_busy_servers = cumsum(busy_servers);
    %ideal_arr1 = cumsum(ideal_arr1);
    %ideal_arr2 = cumsum(ideal_arr2);
    for idx = 1:sim_length_points
        new_busy_servers(idx) = new_busy_servers(idx)/idx;
    end
    %for idx = 1:length(ideal_arr1)
    %    ideal_arr1(idx) = ideal_arr1(idx)/idx;
    %    ideal_arr2(idx) = ideal_arr2(idx)/idx;
    %end
    %plot(arrival_array, busy_servers, 'b.');
    
    %calculate e values
    e_array = exp((-log(1-busy_servers(2:end)/ideal_avg)*service_mean)./arrival_array(2:end));
    hold on
    cla
    grid on
    plot(arrival_array, new_busy_servers, 'b.');
    plot(arrival_array(2:end), real(e_array), 'g-');
    plot(arrival_array, exp(1)*ones(1, sim_length_points), 'r-');
    plot(arrival_array, ideal_avg*ones(1, sim_length_points), 'r--');
    plot(arrival_array, ideal_avg2*ones(1, sim_length_points), 'b--')
    %plot(arrival_array, ideal_arr1, 'b.');
    %plot(arrival_array, ideal_arr2, 'r.');
    grid_count = [40 24];
    xlim_arr = [arrival_array(1), arrival_array(end)];
    ylim_arr = [0, 4*ideal_avg];
    xlim(xlim_arr);
    ylim(ylim_arr);
    set(gca, 'xtick', floor(linspace(arrival_array(1), arrival_array(end),1+grid_count(1))) );
    set(gca, 'ytick', linspace(0, 4*ideal_avg,1+grid_count(2)));
    legend('Measured B(t) Running Average', '''e'' Estimate', '''e'' Constant', 'Rho Constant', 'Expected B(t) for large ''t''', 'Rho running average', 'E[B(t)] running average');
    title('Estimating ''e''');
    xlabel('Arrival Time of a new Request');
    ylabel('Busy Servers');
end
