function [ output ] = rand_tester(test_length, interval_width)
%RAND_TESTER tests the uniform density random number generator in
%matlab and returns 'percentage correctness/certainity'
    interval_count = 1/interval_width;

    %ensuring that input is an integer
    interval_count = ceil(interval_count);

    %generate a list of random numbers
    rand_numbers = rand(1, test_length);
    
    %create buckets for each sub-interval
    bucket_range = linspace(0,1,interval_count);
    buckets = zeros(1, interval_count);
    
    %increment bucket count based on frequency
    for i = 1:test_length;
        bucket_number = ceil(interval_count*rand_numbers(i));
        buckets(bucket_number) = 1 + buckets(bucket_number);
    end
    
    %calculate error (Graphical Method)
    error = test_length/interval_count - buckets;
    ideal_vector = (test_length/interval_count)*ones(1, interval_count);
    
        
    %measure percentage 'certainity' in correctness
    output = abs(100 * (1-(norm(error, 2)/norm(ideal_vector, 2))));
    
    
    %graph the results
    cla
    hold on
    grid on
    title('Testing Results');
    xlim([-(1/interval_count), 1 + (1/interval_count)]);
    xlabel('Bucket Range(s)');
    ylabel('Frequency');
    
    bar(bucket_range, buckets);
    bar(bucket_range, error, 0.5, 'red');
    
    legend('Tested Values', 'Error');
    
end

