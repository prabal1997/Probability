function [ output_args ] = recursive_process(sim_length)
%STOCHASTIC PROCESS recursive (mini-project)
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
    
    %print graphs
    plot(1:sim_length, x_val, 'b.'); 
    
end

