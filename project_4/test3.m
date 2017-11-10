function [output_vars] = test3()
    
    %extract data
    point_count = 3000;
    storage_array = zeros(1, point_count);
    for idx = 1:point_count
        storage_array(idx) = queue_simulator(@rt_exp_inv_dist_func, @rt_periodic_inv_distr, 0, 8, 3000);
        if (rem(idx, 10))
            int2str(idx)
        end
    end
    
    %count stuff by distributing it among buckets
    bucket_count = 200;
    buckets = zeros(1, bucket_count);
    value_range = 1000;
    
    for idx = 1:bucket_count
        lower_bound = (idx-1)*value_range/bucket_count;
        upper_bound = idx*value_range/bucket_count;
 
        buckets(idx) = (sum( 1.0 * (lower_bound <= storage_array) .* (upper_bound > storage_array) ));
    end
    buckets = buckets/point_count;

    %plot data
    hold on
    xlim_arr = [0 value_range];
    ylim_arr = [0 0.2];
    xlim(xlim_arr);
    ylim(ylim_arr);
    stem(linspace(0, value_range, bucket_count),  buckets, 'bO-'); 
    title('Density of ''t_b''');
    grid on
    grid_count = [20, 12];
    set(gca, 'xtick', floor(linspace(xlim_arr(1), xlim_arr(2),1+grid_count(1))) );
    set(gca, 'ytick', linspace(ylim_arr(1), ylim_arr(2),1+grid_count(2)));
    xlabel('Time Taken to achieve Precision (Buckets)');
    ylabel('Probability Density');
end