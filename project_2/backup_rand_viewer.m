function [ output ] = backup_rand_viewer( dist_func, inv_dist_func, test_length, interval_width, display_count_x, display_count_y)
%RAND_VIEWER views the DISTRIBUTION function associated with the given data
    
    %generate a list of random numbers
    rand_numbers = rand(1, test_length);
    rand_numbers = inv_dist_func(rand_numbers);
    
    %create multiple intervals
    bucket_count = ceil(display_count_x(2)/interval_width);
    x = linspace(0, display_count_x(2), bucket_count);
    
    F_n = zeros(1, bucket_count);
    ideal_F_n = discrete_value(x, dist_func, interval_width);
    
    %iterate through EACH value of 'x' (except x = 1, since ALL points have a prob. of occurring LESS than x = 1)
    for i = 1:bucket_count
        F_n(i) = 0;
        
        for k = 1:test_length
            F_n(i) = F_n(i) + (rand_numbers(k) <= i*interval_width);
        end
        
        F_n(i) = F_n(i)/test_length; 
    end
    
    %calculating error now
    error_array = abs(ideal_F_n - F_n);
    
    %printing the observed distribution function
    cla
    hold on
    grid on
    title('Test Results');
    xlim(display_count_x);
    xlabel('Values');
    ylim(display_count_y);
    ylabel('Cumulative Probability');
    plot(x, F_n);
    plot(x, ideal_F_n);
    plot(x, error_array, '-');
    
    legend('Observed Cumulative Distribution Function', 'Ideal Cumulative Distribution Function', 'Error Magnitude');
    
end

