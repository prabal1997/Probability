function [ used_test_result_holder_idx ] = queue_simulator( service_distr, arrival_distr, sim_points, sim_time, sim_test_count)
%SERVER_SIMULATOR simulates a server with infinite processors receving
%requests one by one...
    
    %SIMULATION INPUT VARIABLES
    arrival_rate = 2^6; %rate at which requests arrive per second
    arrival_mean = 1/(arrival_rate);
    service_mean = 2^(-5); %mean service time of a request
    error_thresh = 0.001; %refers to how much close the output needs to be close to the ideal scenario (in %)
    ignorace_thresh = 10^-5; %refers to the scale at which 'e^-rho*t' gets replaced by '0'
    ideal_avg = arrival_rate * service_mean;
    ideal_limit = exp(-1/ideal_avg)/(1-exp(-1/ideal_avg));
    
    %check how long the simulation needs to be
    sim_length_points = 0;
    if (sim_points == 0)
        sim_length_points = sim_time*arrival_rate;
    end
    if (sim_time == 0)
        sim_length_points = sim_points;
    end
    
    %initialize storage
    start_test_count = 10;
    storage_width = 1;
    test_result_holder = zeros(start_test_count, storage_width);

    used_test_result_holder_idx = 0;
    function [test_size] = push_results(input_row)
        used_test_result_holder_idx = 1 + used_test_result_holder_idx;
        %if a user exceeds the pre-set limit, treat the array as a typical
        %'doubling' array
        if (used_test_result_holder_idx > sim_test_count)
            sim_test_count = Inf;
        end
        %check if the array requires size extension
        if (used_test_result_holder_idx > size(test_result_holder, 1))
            %calculate the new potential length
            new_test_result_holder = 0;
            if (sim_test_count ~= Inf)
                start_test_count = sim_test_count;
                new_test_result_holder = zeros(sim_test_count, storage_width);
            else
                start_test_count = 2*start_test_count;
                new_test_result_holder = zeros(start_test_count, storage_width); 
            end
            %copy old elements onto the new array, delete old array
            new_test_result_holder(1:size(test_result_holder, 1), 1:storage_width) =  test_result_holder;
            test_result_holder = new_test_result_holder;
        end
        
        %add the new line of data to the array
        test_result_holder(used_test_result_holder_idx, 1:end) = input_row; 
    end
    
    %starts a single test, produces and stores results
    function [test_size] = perform_single_test()
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
        busy_servers_count = sum(1.0 * (arrival_timeline(end) >= arrival_timeline(1:end-1)) .* (arrival_timeline(end) < completion_timeline(1:end-1)));
        push_results(busy_servers_count);
        
        %return appropriate data
        test_size = used_test_result_holder_idx;
        return;
    end
    

    %perform the actual test appropriate number of times
    cont_exec = true;
    total_array_sum = 0;
    while(cont_exec)
        %run a test
        perform_single_test();
        
        %calculate array average and error
        total_array_sum = total_array_sum + test_result_holder(used_test_result_holder_idx, 1);
        calc_mean = total_array_sum/used_test_result_holder_idx;
        
        %stop testing if the precision has been achieved
        prec_val = abs(calc_mean-ideal_limit)/ideal_limit;
        if (prec_val < error_thresh)
            cont_exec = false;
        end
    end 
   
    %calculate running avg
    running_avg =  test_result_holder(1:used_test_result_holder_idx);
    running_avg = cumsum(running_avg);
    for idx = 1:length(running_avg)
        running_avg(idx) = running_avg(idx)/idx;
    end
    
    %plot the entire recorded data
    hold on

    %set graph properties
    x_axis = linspace(1, used_test_result_holder_idx, used_test_result_holder_idx);
    grid_count = [20, 12];
    line_width = 1.75;
    xlim_array=[x_axis(1), x_axis(end)];
    ylim_array=[2*ideal_limit*(2/5), 2*ideal_limit*(3/5)];
    title('Busy Servers in a Multi-Server System at some time ''t'' over multiple tests');
    xlabel('Number of Tests');
    ylabel('Busy Servers');

    %plot all these lines
    hold on;
    calc_mean = running_avg(end);
    plot_1 = plot(x_axis, running_avg, 'b.');
    plot_2 = plot(x_axis, smooth(x_axis, running_avg, 0.1, 'loess'), 'b--');
    plot_3 = plot(x_axis, mean(test_result_holder(1:used_test_result_holder_idx))*ones(1, used_test_result_holder_idx), 'k--');
    plot_4 = plot(x_axis, ideal_limit*ones(1, used_test_result_holder_idx), 'r-');
    
    grid on;
    legend('Running Average', 'Filtered Running Average', 'Observed Running Average', 'Ideal Expected Value');
    xlim(xlim_array);
    ylim(ylim_array);

    set(plot_1,'LineWidth', 1/20);
    set([plot_2, plot_3, plot_4],'LineWidth', line_width);
    %set(plot_5,'LineWidth', 2*line_width);
    set(gca, 'xtick', floor(linspace(0, xlim_array(2),1+grid_count(1))) );
    set(gca, 'ytick', linspace(ylim_array(1), ylim_array(2),1+grid_count(2)));
    
end

