function [ output ] = rand_viewer(inv_dist_func, N, n)
%RAND_VIEWER views the DISTRIBUTION function associated with the given data
    
    %generate a list of random numbers
    rand_numbers = rand(1, N+n);
    rand_numbers = inv_dist_func(rand_numbers);
    
    %calculating mean
    x_vals = 0:n;
    rand_mean = mean(rand_numbers(1:N));
    
    %calculating R(x)
    function [ value ] = R_x(x)
        value = 0;
        for i = 1:N
            value = value + (rand_numbers(i+x)-rand_mean)*(rand_numbers(i)-rand_mean);
        end
        value = value/N;
    end

    %calculating a SERIES of 'R' values
    R_array = zeros(1, n+1);
    for k = 0:n
        R_array(k+1) = R_x(k);
    end
    
    %taking FFT of the 'R' array
    R_fft = fft(R_array);
    
    %plotting data
    subplot(2, 1, 1);

    hold on
    
    cla
    grid on
    title('Spectrum Analysis for Uniform Distribution');
    xlim([-n/2, n]);
    xticks(-n/2:1.5*n/20:n)
    ylim([-0.5*max(R_array), 1.5*max(R_array)]);
    yticks(-0.5*max(R_array):2*max(R_array)/7:1.5*max(R_array));
    xlabel('Values of "n"');
    ylabel('Output for "n"');
    plot(x_vals, R_array, 'r-');
    plot(0, max(R_array), 'rO');
    legend('Noise', 'Dirac Delta Impulse', 'Inversed');
    
    txt_max = '\leftarrow Maximum';
    [max_val, max_idx] = max(R_array);
    text( max_idx, max_val, txt_max);
    
    subplot(2, 1, 2);

    hold on
     
    cla
    grid on
    title('Spectrum Analysis for Uniform Distribution');
    xlim([0, n]);
    
    max_mag = max(abs(R_fft)) - min(abs(R_fft));
    avg_mag = abs(mean(R_fft));
    ylim([avg_mag-max_mag, avg_mag+max_mag]);
    yticks(avg_mag-max_mag:(2*max_mag)/7:avg_mag+max_mag)
    xlabel('Values of "n"');
    ylabel('FFT of output');
    plot(x_vals, abs(R_fft), 'r-');
    plot(x_vals, smooth(x_vals, abs(R_fft), 0.1, 'loess'), 'b-');
    legend('FFT Magnitude of Signal', 'Filtered FFT Magnitude of Signal');
    
end

