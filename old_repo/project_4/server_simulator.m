function [ trial_count ] = server_simulator( service_distr, arrival_distr, sim_length_points)
%server_simulator(@rt_exp_inv_dist_func, @rt_periodic_inv_distr, 1000);

%SERVER_SIMULATOR simulates a server with infinite processors receving
%requests one by one...
    
    set(0, 'DefaultFigureRenderer', 'painters');

    %SIMULATION INPUT VARIABLES
    arrival_rate = 52; %rate at which requests arrive per second
    arrival_mean = 1/(arrival_rate);
    service_mean = 0.0032; %mean service time of a request
    error_thresh = 0.001; %refers to how much close the output needs to be close to the ideal scenario (in %)
    ignorace_thresh = 10^-5; %refers to the scale at which 'e^-rho*t' gets replaced by '0'
    ideal_avg = arrival_rate * service_mean;
    ideal_limit = exp(-1/ideal_avg)/(1-exp(-1/ideal_avg));
    
    %check how long EACH simulation chunk needs to be
    sim_length_points;
    
    %initialize storage
    start_test_count = 2;
    test_result_holder = zeros(1, start_test_count);

    used_test_result_holder_idx = 0;
    function [test_size] = push_results(input_row)
        used_test_result_holder_idx = length(input_row) + used_test_result_holder_idx;
        new_test_result_holder = 0;
        %resize array if needed
        if (used_test_result_holder_idx > length(test_result_holder))
            start_test_count = max(start_test_count, 2^ceil(log(used_test_result_holder_idx)/log(2)));
            new_test_result_holder = zeros(1, start_test_count);
            
            %copy old array, replace with new array
            new_test_result_holder(1:length(test_result_holder)) =  test_result_holder;
            test_result_holder = new_test_result_holder;
        end
        
        %add element to the list
        test_result_holder(used_test_result_holder_idx-length(input_row)+1:used_test_result_holder_idx) = input_row;
    end
    
    %starts a single test, produces and stores results
    function [total_sum] = perform_test()
        %random number generator
        function [output_vars] = multi_rv(required_elements, rv_count, inv_dist_type, mean)
            %MULTI_RV: gives an array of SUMMED random numbers belonging to a
            %given distribution
            output_vars = zeros(1, required_elements);
            for idx = 1:required_elements
                output_vars(idx) = sum( inv_dist_type(rand(1, rv_count), mean/rv_count) );
            end
        end    
        
        %create arrival variables
        arrival_delays = zeros(1, sim_length_points);
        arrival_delays(2:end) = multi_rv(sim_length_points-1, 1, arrival_distr, arrival_mean);
        
        arrival_timeline = cumsum( arrival_delays );
        
        %create service delays, completion timeline
        service_delays = multi_rv(sim_length_points, 1, service_distr, service_mean);
        completion_timeline = arrival_timeline + service_delays;
        
        %count number of busy servers at the LAST arrival, push it onto the
        %storage array
        busy_servers_count = zeros(1, sim_length_points);
        total_sum = 0;
        for idx = 2:sim_length_points 

            busy_servers_count(idx) = sum(1.0 * (arrival_timeline(idx) >= arrival_timeline(1:idx-1)) .* (arrival_timeline(idx) < completion_timeline(1:idx-1)));
            total_sum = total_sum + busy_servers_count(idx);
        end
        push_results(busy_servers_count);
        
        %return appropriate data
        return;
    end
    
    %perform the actual test appropriate number of times
    cont_exec = true;
    total_array_sum = 0;
    
    total_avg = 0;
    trial_count = 0;
    
    cont_exec = true;
    abs_err = 0;
    while(cont_exec)
        %perform a test
        obs_sum = perform_test();
        trial_count = 1 + trial_count;
        
        %find the running average, terminate if target met
        total_avg = (total_avg*(trial_count-1)+obs_sum/sim_length_points)/(trial_count);
        abs_err = (total_avg-ideal_limit)/ideal_limit;
        
        if (abs(abs_err) <= error_thresh || trial_count > 300)
            cont_exec = false;
        end
        %abs_err
        %total_avg
        %ideal_limit
    end
    trial_count = trial_count*sim_length_points*arrival_mean;
    
    'Done'
    
    %calculate running avg
    running_avg =  test_result_holder(1:used_test_result_holder_idx);
    running_avg = cumsum(running_avg);
    for idx = 1:length(running_avg)
        running_avg(idx) = running_avg(idx)/idx;
    end
    
    %set graph properties
    used_test_result_holder_idx
    arrival_mean
    x_axis = linspace(1, used_test_result_holder_idx, used_test_result_holder_idx);
    grid_count = [20, 12];
    line_width = 1.75;
    xlim_array=[0, arrival_mean*used_test_result_holder_idx];
    ylim_array=[2*ideal_limit*(2/5), 2*ideal_limit*(3/5)];
    title('Average Busy Servers across Different Times');
    xlabel('Time');
    ylabel('Busy Servers');

    %plot all these lines
    hold on;
    cla
    plot_1 = plot(arrival_mean*x_axis, running_avg, 'b.');
    plot_2 = plot(arrival_mean*x_axis, smooth(arrival_mean*x_axis, running_avg, 0.1, 'rloess'), 'b--');
    plot_3 = plot(arrival_mean*x_axis, running_avg(end)*ones(1, used_test_result_holder_idx), 'k--');
    plot_4 = plot(arrival_mean*x_axis, ideal_limit*ones(1, used_test_result_holder_idx), 'r-');
    
    grid on;
    legend('Running Average', 'Filtered Running Average', 'Observed Running Average', 'Ideal Expected Value');
    xlim(xlim_array);
    ylim(ylim_array);
    
    set(plot_1,'LineWidth', 1/20);
    set([plot_2, plot_3, plot_4],'LineWidth', line_width);
    set(gca, 'xtick', (linspace(xlim_array(1), xlim_array(2),1+grid_count(1))) );
    set(gca, 'ytick', linspace(ylim_array(1), ylim_array(2),1+grid_count(2)));

end

