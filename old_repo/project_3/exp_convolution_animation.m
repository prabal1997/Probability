function [ output ] = exp_convolution_animation( n, lambda )
    %EXP_CONVOLUTION_ANIMATION creates an animation of an exponential
    %distribution function being convoluted with itself 'n' times

    lambda_k = n*lambda;
    function [val] = dens_func(n_value, lambda_k_value, x)
        val = (lambda_k_value^n_value)*(1/gamma(n_value)) * x.^(n_value-1) .* exp(x * (-1) * lambda_k_value) .* (x >= 0); 
    end
    cla;
    vec_in = linspace(0, 2*lambda, 1000);
    vec_out = dens_func(n, lambda_k, vec_in);
    hold on;
    plot(vec_in, vec_out);
    xlim([0, 2*lambda]);
    abs(max(vec_out))
    ylim([0, 6]);
    grid on
    grid_count = [15, 10];
    set(gca, 'xtick', linspace(0, 2*lambda,1+grid_count(1)));
    set(gca, 'ytick', linspace(0, 6,1+grid_count(2)));
    title('Convoluted Density Function');
    g = plot(vec_in, mean(vec_out)*ones(1, length(vec_in)), 'r-');
    legend('Density Function', 'Mean');
    
end

