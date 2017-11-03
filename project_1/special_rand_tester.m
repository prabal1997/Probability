function [ output ] = special_rand_tester( den_func, dist_func, inv_dist_func, test_length, interval_width, display_length)
%SPECIAL_RAND_TESTER tests the density random number generator in
%matlab and returns 'percentage correctness/certainity'

    %set display width of output graph
    min_disp = 5;
    if (display_length < min_disp+1)
        display_length = min_disp+1;
    end
    
    %generate a list of random numbers
    rand_numbers = rand(1, test_length);
    rand_numbers = inv_dist_func(rand_numbers);
    
    %determine the length of arrays used for computation
    max_rand = max(rand_numbers);
    compute_length = max(display_length, ceil(max_rand/interval_width));
    
    index_array = linspace(0, max_rand, compute_length+1);
    bucket_array = zeros(1, compute_length);
    ideal_bucket_array = zeros(1, compute_length);
    
    %fill the ideal buckets with ideal values
    for i = 1:compute_length
        ideal_bucket_array(i) = test_length * ( dist_func(index_array(i+1)) - dist_func(index_array(i)) );
    end
  
    %fill the bucket array with the frequency of observed data
    for i = 1:test_length
        bucket_number = ceil(rand_numbers(i)/interval_width);
        bucket_array(bucket_number) = 1 + bucket_array(bucket_number);
    end
    
    %calculate the error/difference in the ideal/observed phenomenon
    error_array = ideal_bucket_array - bucket_array;
    error = norm(error_array, 2)/norm(ideal_bucket_array, 2);
    
    %calculate the 'certainity' of the identification of the observed
    %distribution
    output = abs(100 * (1 - error));
        
    %finally printing the results
    'Graphical Certainity (in %): '
    
    %graph the results
    cla
    hold on
    grid on
    title('Testing Results');
    xlim([-(1/display_length), display_length + (1/display_length)]);
    xlabel('Bucket Range(s)');
    ylabel('Frequency');
    
    bar(index_array(1:length(index_array)-1), bucket_array);
    bar(index_array(1:length(index_array)-1), error_array, 0.5, 'red');
    
    legend('Tested Values', 'Error');
    
end

