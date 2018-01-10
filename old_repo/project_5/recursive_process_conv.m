function [ output_args ] = recursive_process_conv(sim_length, test_count)
%STOCHASTIC PROCESS recursive (mini-project)
loop_result = zeros(1, test_count);
for looper = 1:test_count    
    %generate 'y' values
    y_val = randn(1, sim_length) + abs(rand(1, 1));
    
    %generate 'P' values
    p_val = ones(1, sim_length);
    std_dev = 1;
    for idx = 1:sim_length-1
        k_idx = p_val(idx)/(p_val(idx)+(std_dev^2));
        p_val(idx+1) = ((1-k_idx)^2)*p_val(idx)+(k_idx*std_dev)^2;
    end
    
    %generate 'x' values
    x_val = zeros(1, sim_length);
    for idx = 1:sim_length-1
        k_idx = p_val(idx)/(p_val(idx)+(std_dev^2));
        x_val(idx+1) = x_val(idx) + k_idx*(y_val(idx+1)-x_val(idx));
    end
    
    %convergent value
    loop_result(looper) = x_val(end);
end
    
    %find the distribution of input data
    bucket_count = 100;
    bucket_data = zeros(1, bucket_count);
    bucket_width = max(loop_result)/bucket_count;
    for idx = 1:bucket_data
        lower_limit = (idx-1)*bucket_width;
        upper_limit = idx*bucket_width;
        
        bucket_data(idx) = sum( 1.0 * (loop_result(1:idx-1) >= lower_limit) .* (loop_result(1:idx-1) < upper_limit) );
    end
    
    %print graphs
    hold on
    cla
    stem((1:100)*bucket_width, bucket_data, 'bO'); 
    ylabel('X_t Values');
    xlabel('''t'' - axis');
    title('Simulation');
    grid on
    
end

