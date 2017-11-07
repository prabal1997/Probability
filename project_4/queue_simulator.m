function [ output_args ] = queue_simulator( service_distr, arrival_distr, sim_points, sim_time, sample_count )
%SERVER_SIMULATOR simulates a server with infinite processors receving
%requests one by one...
    
    %SIMULATION INPUT VARIABLES
    arrival_rate = 52; %rate at which requests arrive per second
    arrival_mean = 1/(arrival_rate);
    service_mean = 0.032; %mean service time of a request
%    service_distr = @rt_exp_inv_dist_func; %inverse probabilit distr. of service times
%    arrival_distr = @rt_periodic_inv_distr;
    queue_limit = Inf; %pending request(s) limit; extra requests are simply truncated
    core_count = Inf; %refers to number of cores available for processing
    sim_length = Inf; %number of seconds to simulate
    error_thresh = 0.01; %refers to how much close the output needs to be close to the ideal scenario (in %)
    ignorace_thresh = 10^-5; %refers to the scale at which 'e^-rho*t' gets replaced by '0'
    ideal_avg = arrival_rate * service_mean; %this is the 'rho' value
    
    sim_length_points = 0; %refers to how long the simulation needs to be
    if (sim_points == 0)
       sim_length_points = ceil(sim_time*arrival_rate);
    else
       sim_length_points = sim_points;
    end

    %these are requests right before the entry of which we sample the
    %number of busy servers
    %sample_count = floor(linspace(1, sample_count, sample_count)*(sim_length_points/sample_count))  %refers to the numbr of time samples we take EVERY second
    sample_dist_mean = sim_length_points/sample_count;
    sample_count_num = sample_count;
    sample_count = zeros(1, sample_count_num);
    sample_total_sum  = 0;
    for idx = 1:sample_count_num
        sample_count = linspace((1/3)*sample_count_num, (2/3)*sample_count_num, sample_count_num);
    end
    sample_count = ceil(sample_count);
    
    %create a matrix to store all the data
    test_count = 10000;
    test_output = zeros(test_count, length(sample_count));
    
    exp_mu_sum = 0;
    for test_idx = 1:test_count
        %simulate arrival delays
        arrival_delay = arrival_distr(rand(1, sim_length_points-1), arrival_mean);
        
        %calculate actual arrival timeline
        arrival_timeline = zeros(1, sim_length_points);
        for idx = 2:sim_length_points
            arrival_timeline(idx) = arrival_timeline(idx-1) + arrival_delay(idx-1);
        end
        
        %calculate service times, completion timelines
        service_duration = service_distr(rand(1, sim_length_points), service_mean);
        completion_timeline = arrival_timeline + service_duration;
        
        %calculate busy servers at each arrival
        busy_servers = zeros(1, length(sample_count));
        for idx = 1:length(sample_count)
            arrival_time = arrival_timeline(sample_count(idx));
            busy_servers(idx) = sum(1.0 * (arrival_time >= arrival_timeline(1:sample_count(idx)-1)) .* (arrival_time <= completion_timeline(1:sample_count(idx)-1)));;
        end
        
        %only store the required outputs
        test_output(test_idx, 1:end) = busy_servers;
    end
    
    %find the running average across all sampled time-points
    averaged_test_output = test_output;
    for idx = 1:length(sample_count)
        for idx_2 = 2:test_count
            averaged_test_output(idx_2, idx) = mean(test_output(1:idx_2-1, idx));
        end
    end
    
    %plot all these lines
    x_axis = linspace(1, test_count, test_count);
    for idx = 1:length(sample_count)
        hold on
        plot(x_axis, averaged_test_output(1:end, idx));
    end
    ideal_limit = exp(-1/ideal_avg)/(1-exp(-1/ideal_avg));
    plot(x_axis, ideal_limit*ones(1, test_count), 'rO-')
    
    %observed data
    observed_data = 
end

