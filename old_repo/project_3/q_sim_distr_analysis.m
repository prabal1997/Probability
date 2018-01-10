function [ output_args ] = q_sim_distr_analysis(actual_points, bucket_count, detail)
    
    function [ output_args ] = queue_sim_bucket_sort(inv_time_distr, time_param, inv_wait_distr, wait_param, queue_param, k_factor)
    %SIMULATE_QUEUE simulates a queue

        %designated constants
        Q_LENGTH = 1;
        Q_START = 2;
        BUCKET_COUNT = 3;

        %'fixing' the lambda value, and the number of simulated points
        time_param = time_param/k_factor;
        queue_param(Q_LENGTH) = queue_param(Q_LENGTH)*k_factor;

        %making a list of indices that are NOT to be discarded
        usable_indices = 1:k_factor:queue_param(Q_LENGTH);

        %generate a list of random numbers for arrival, service times
        delay_array = rand(1, queue_param(Q_LENGTH)-1);
        delay_array = inv_time_distr(delay_array, time_param);

        arrival_array = zeros(1, queue_param(Q_LENGTH));
        arrival_array(1) = queue_param(Q_START);
        for i = 2:queue_param(Q_LENGTH)
            arrival_array(i) = arrival_array(i-1) + delay_array(i-1);
        end

        %discarding the additional points
        arrival_array = arrival_array(usable_indices);
        delay_array = diff(arrival_array);
        queue_param(Q_LENGTH) = queue_param(Q_LENGTH)/k_factor;

        %sorting the delay into BUCKETS
        new_delay_array = sort(delay_array);
        bucket_count = zeros(1, queue_param(BUCKET_COUNT));

 %{       
        global_new_delay_array_counter = 1;
        for idx = 1:queue_param(BUCKET_COUNT)
            low_range = (idx-1)*new_delay_array(end)/queue_param(BUCKET_COUNT);
            high_range = idx*new_delay_array(end)/queue_param(BUCKET_COUNT);
            
            for i = global_new_delay_array_counter:queue_param(BUCKET_COUNT)
                if (new_delay_array(i) >= low_range && new_delay_array(i) < high_range)
                    bucket_count(idx) = bucket_count(idx) + 1;        
                else
                    global_new_delay_array = i;
                    break;
                end
            end
        end
  %}
          
        %alternative method of sorting into buckets
        for idx = 1:queue_param(BUCKET_COUNT)
            low_range = (idx-1)*1/queue_param(BUCKET_COUNT);
            high_range = idx*1/queue_param(BUCKET_COUNT);
            
            bucket_count(idx) = sum( ((new_delay_array >= low_range) .* (new_delay_array < high_range)) );
        end        
          
        %calculating the distr. func
        for idx = 2:queue_param(BUCKET_COUNT)
            bucket_count(idx) = bucket_count(idx) + bucket_count(idx-1);
        end
        
        %fixing the values in bucket_count array
        bucket_count = bucket_count/queue_param(Q_LENGTH);
        
        %calculating the dens. func
        dy = zeros(1, queue_param(BUCKET_COUNT));
        dy(1:end-1) = diff(bucket_count);
        dy(end) = dy(end-1);
        
        dx = new_delay_array(end)/queue_param(BUCKET_COUNT);
        
        dens_func = dy./dx;

        %returning the density function, distr. func as the output
        output_args = zeros(queue_param(BUCKET_COUNT), 3);
        
        output_args(1:end, 1) =  dens_func;
        output_args(1:end, 2) =  bucket_count;
        output_args(1:end, 3) = linspace(0, 1, queue_param(BUCKET_COUNT));
    end

    %calling the function with appropriate paramters
    output_matrix = queue_sim_bucket_sort(@rt_exp_inv_dist_func, 0.5, @rt_exp_inv_dist_func, 0.25, [actual_points 0 bucket_count], ceil(detail));
    
    %extracting dens, distr functions, and the x-axis values
    output_dens_func = output_matrix(1:end, 1);
    output_distr_func = output_matrix(1:end, 2);
    x_axis_input = output_matrix(1:end, 3);
    
    %plotting the data
    subplot(1, 2, 1);
    cla
    ezdraw(x_axis_input, output_distr_func, false, false, {'Inter-Arrival Time Distribution', 'Time Range', 'Frequency'},{'Distribution Function', 'Filtered Output'}, {'b.-','k-','r-'}, false, 0, [0, 1], 0, {0.01, 'loess'}, 1.5, [10,10]);
    subplot(1, 2, 2);
    cla
    ezdraw(x_axis_input, output_dens_func, false, true, {'Inter-Arrival Time Density', 'Time Range', 'Probability Density'},{'Density Function', 'Filtered Output'}, {'r.-','k-','b--'}, false, 0, 0, 0, {0.02, 'loess'}, 1.25, [10,10]);
end

