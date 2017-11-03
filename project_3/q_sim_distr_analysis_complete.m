function [ final_output ] = q_sim_distr_analysis_complete(inv_delay_distr, delay_param, inv_serv_distr, serv_param, actual_points, bucket_count, delay_detail, service_detail)
    
    calculated_data = zeros(1, actual_points);

    function [ output_args ] = distr_sum_analysis(input_inv_distr, input_param, input_actual_points, input_bucket_count, input_detail, graph_output)
        
        function [output] = deter_random_var_sum(inv_distr, output_len, total_vars, param)
            %INV_DISTR: the inverse probability distribution of the type of
            %distribution you want to impelement
            %OUTPUT_LEN: the length of the output array i.e. the number of
            %random values generated
            %TOTAL_VARS: the number of random variables each value is a sum of
            %PARAM: input parameters required by the inverse probability
            %distribution

            random_vals = zeros(1, output_len);

            %creating an array of 'summed' random variables
            for idx = 1:output_len
                for internal_idx = 1:total_vars
                    random_vals(idx) = random_vals(idx) + inv_distr(rand(1,1), param/total_vars);
                end
            end

            output = random_vals;
        end

        function [output] = bucket_sorter(range, bucket_width, input_data)
            %RANGE: [min, max] array that tells use what range the buckets need
            %to exist in
            %BUCKET_WIDTH: tells us how many buckets we need to create
            %INPUT_DATA: array of input values as per which the buckets need to
            %be filled into buckets

            array_len = ceil(range(2)/bucket_width);
            buckets = zeros(1, array_len);

            for idx = 1:array_len
                low_range = (idx-1)*bucket_width;
                high_range = idx*bucket_width;

                buckets(idx) = sum( 1.0 .* (input_data >= low_range) .* (input_data < high_range) );
            end

            buckets = buckets./length(input_data);
            distr_func = buckets;
            for idx = 2:length(distr_func)
                distr_func(idx) = distr_func(idx-1) + distr_func(idx); 
            end

            %sending the x-axis, the distribution function, and the density
            %function as the output
            output = zeros(array_len, 3);

            output(1:end, 1) = range(1):bucket_width:ceil(range(2))-bucket_width;
            output(1:end, 2) = buckets;
            output(1:end, 3) = distr_func;
        end

        %calling the function with appropriate paramters
        input_data = deter_random_var_sum(input_inv_distr, input_actual_points,input_detail,input_param);
        output_args = bucket_sorter([0 1], 1/input_bucket_count, input_data);
        calculated_data = input_data;

        if (graph_output)
            %extracting dens, distr functions, and the x-axis values
            x_axis_input = output_args(1:end, 1);
            delay_output_distr_func = output_args(1:end, 3);
            delay_output_dens_func = output_args(1:end, 2);

            %plotting the data
            subplot(2, 1, 1);
            cla
            ezdraw(x_axis_input, delay_output_distr_func, false, false, {'Inter-Arrival Time Distribution', 'Time Range', 'Frequency'},{'Distribution Function'}, {'b.-','k-','r-'}, false, 0, [0, 1], 0, {0.01, 'loess'}, 1.5, [10,10]);
            subplot(2, 1, 2);
            cla
            ezdraw(x_axis_input, delay_output_dens_func, false, true, {'Inter-Arrival Time Density', 'Time Range', 'Probability Density'},{'Density Function', 'Filtered Output'}, {'r.-','k-','b--'}, false, 0, 0, 0, {0.02, 'loess'}, 1.25, [10,10]);
        end
        
    end

    %produce, analyze delay and service times
    delay_matrix = distr_sum_analysis(inv_delay_distr, delay_param, actual_points, bucket_count, delay_detail, false);
    delay_data = calculated_data;
    
    %figure;
    
    service_matrix = distr_sum_analysis(inv_serv_distr, serv_param, actual_points, bucket_count, service_detail, false);
    service_data = calculated_data;
    
    %calculating arrival times
    arrival_data = delay_data;
    for idx = 2:length(delay_data)
        arrival_data(idx) = arrival_data(idx-1)+arrival_data(idx);
    end
    
    %calculating completion times
    completion_data = zeros(1, length(arrival_data));
    completion_data(1) = arrival_data(1) + service_data(1);
    for idx = 2:length(arrival_data)
        completion_data(idx) = max(completion_data(idx-1), arrival_data(idx)) + service_data(idx);
    end
    
    %calculating queue wait times (NOTE: queue_wait_data holds time spent
    %by elements in queue before their service started)
    queue_wait_data = completion_data-(arrival_data + service_data);
    
    %calculating queue length times (i.e. number of elements just waiting in the
    %queue measured whenever a new point arrives)
    arrival_and_wait_data = arrival_data + queue_wait_data; 
    queue_length_data = zeros(1, actual_points);
    queue_length_with_serv_data = zeros(1, actual_points);
    for idx = 2:actual_points
        queue_length_data(idx) = sum ( 1.0 * (arrival_data(idx) > arrival_data(1:idx-1)) .* (arrival_data(idx) < arrival_and_wait_data(1:idx-1)) );
        queue_length_with_serv_data(idx) = sum ( 1.0 * (arrival_data(idx) > arrival_data(1:idx-1)) .* (arrival_data(idx) < completion_data(1:idx-1)) );
    end
    
%    queue_length_data
%    arrival_data
%    service_data
%    completion_data
%    queue_wait_data

%{
    hold on
    title('Element Timing');
    plot(linspace(0, actual_points, actual_points), arrival_data);
    plot(linspace(0, actual_points, actual_points), completion_data-service_data);
    plot(linspace(0, actual_points, actual_points), completion_data);*
    legend('Arrival Times', 'Wait Times', 'Completion Timese');
%}    
  
    %PLOTTING
    %figure;
    %arrival time, wait time, completion time
    
    grid_width = 10;
    subplot(2, 1, 1)
    cla
    ezdraw(linspace(0, actual_points, actual_points) , queue_length_with_serv_data, true, false, {'Queue Length at Element Arrival', 'Element Number', 'Queue Length'},{'Queue Length at Element Arrival', 'Mean Value ~ '}, {'b.','k-','r-'}, false, 0, [0 14], 0, {0.01, 'loess'}, 1.5, [grid_width,grid_width]);
    subplot(2, 1, 2)
    cla
    ezdraw(linspace(0, actual_points, actual_points) , queue_wait_data, true, false, {'Queue Wait at Element Arrival', 'Element Number', 'Queue Length'},{'Queue Length at Element Arrival', 'Mean Value ~ '}, {'b.','k-','r-'}, false, 0, [0 5], 0, {0.01, 'loess'}, 1.5, [grid_width,grid_width]);
end