function [ output ] = backup_rand_viewer2( dist_func, inv_dist_func, test_length, unity_interval_count, display_count_x, display_count_y)
%RAND_VIEWER views the DISTRIBUTION function associated with the given data
    
    %generate a list of random numbers
    rand_numbers = rand(1, test_length);
    rand_numbers = inv_dist_func(rand_numbers);
    
    %create multiple intervals
    bucket_count = ceil(diff(display_count_x)*unity_interval_count);
    x = linspace(display_count_x(1), display_count_x(2), bucket_count+1);
    
    F_n = zeros(1, bucket_count+1);
    ideal_F_n = dist_func(x);
    
    dens_bucket = zeros(1, bucket_count+1);
    dist_bucket = zeros(1, bucket_count+1);
    
    %iterate through EACH value of 'x' (except x = 1, since ALL points have a prob. of occurring LESS than x = 1)
    for i = 1:bucket_count+1
        F_n(i) = 0;
        comparison_value = display_count_x(1) + (i-1)/unity_interval_count;
        for k = 1:test_length
            F_n(i) = F_n(i) + (rand_numbers(k) <= comparison_value);
        end
        
        F_n(i) = F_n(i)/test_length; 
    end
    
    %calculating error, derivative now
    f_n = smooth(smooth(x(1:end-1), diff(F_n)*unity_interval_count, 0.02, 'loess'));
    ideal_f_n = (diff(ideal_F_n)*unity_interval_count);

    
    %printing the observed distribution and density functions
    subplot(2, 1, 1);
    
    cla
    hold on
    grid on
    title('Test Results for Cumulative Distributions');
    xlim(display_count_x);
    xlabel('Values');
    ylim(display_count_y);
    ylabel('Cumulative Probability');
    
    plot(x, F_n, 'r-');
    plot(x, ideal_F_n, 'b-');
    plot(x, abs(ideal_F_n - F_n), 'g-');

    legend('Observed Distribution Function', 'Ideal Distribution Function', 'Error Mangitude');
    
    subplot(2, 1, 2);
        
    cla
    hold on
    grid on
    title('Test Results for Density');
    xlim(display_count_x);
    xlabel('Values');
    ylim(display_count_y);
    ylabel('Probability');
    
    plot(x(1:end-1), f_n, 'r-');
    plot(x(1:end-1), ideal_f_n, 'b-');
    
    legend('Estimated Density Function (Filtered)', 'Ideal Density Function');
    
end

