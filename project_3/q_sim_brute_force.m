function [ output_args ] = q_sim_brute_force(actual_points, sample_count, detail_range)
    
    function [ output_args ] = simulate_queue_conditional_local(inv_time_distr, time_param, inv_wait_distr, wait_param, inv_sam_distr, sample_param, queue_param, k_factor )
    %SIMULATE_QUEUE simulates a queue

        %designated constants
        Q_LENGTH = 1;
        Q_START = 2;
        SAMPLING = 3;

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

        service_array = rand(1, queue_param(Q_LENGTH));
        service_array = inv_wait_distr(service_array, wait_param);

        %calculate completion time for each customer
        completion_array = zeros(1, queue_param(Q_LENGTH));
        completion_array(1) = arrival_array(1) + service_array(1);
        for i = 2:queue_param(Q_LENGTH)
            completion_array(i) = max(arrival_array(i), completion_array(i-1)) + service_array(i);
        end

        %completion_array = arrival_array + service_array;

        %calculating constants
        function [ output ] = X_of_t(time)
            %X_OF_T: calculates the number of people in the queue during some
            %time
            output = zeros(1, length(time));
            for j = 1:length(time)
                output(j) = sum( (arrival_array < time(j)) .* (time(j) < completion_array) );
            end
        end

        lambda_a = queue_param(Q_LENGTH)/arrival_array(end);
        W_Q = mean(service_array);
        L_Q = lambda_a*W_Q;

        %sampling Queue length at different times


        %plotting data
%        close all
%        subplot(2, 1, 1);

%        title('M/M/1 Queue Simulation');

%        hold on
     %   cla
%        grid on
%        xlim([1, queue_param(Q_LENGTH)]);
%        xlabel('Element ''p''');

%        ylabel('Time');
%        ylim([0, ceil(max(completion_array))+2]);
%        plot(1:queue_param(Q_LENGTH), arrival_array, 'b.');
%        plot(1:queue_param(Q_LENGTH), completion_array, 'r.-');

%        legend('Arrival Time', 'Completion Time');

%        subplot(2, 1, 2);

        X_of_t_array = X_of_t(arrival_array);

%        hold on
    %    cla
%        grid on

%        title('Wait Duration');
%        xlabel('Element ''p''');
%        ylabel('Duration');

        wait_array = completion_array - arrival_array - service_array;
        wd_mean_1 = mean(wait_array);

%        plot(1:queue_param(Q_LENGTH), wait_array, 'b.');
%        plot(1:queue_param(Q_LENGTH), wd_mean_1*ones(1, queue_param(Q_LENGTH)), 'b-');
%        xlim([1, queue_param(Q_LENGTH)]);
%        ylim([0, max(wait_array)+1]);
%        legend('Wait Duration', 'Average Wait Duration');
%        str_mean = ['Average = ', num2str(wd_mean_1)];
%        text(queue_param(Q_LENGTH)/2, wd_mean_1*1.25, str_mean);

%        figure
     %{   
        hold on
        cla
        grid on
        title('Service Duration');
        xlabel('Element ''p''');
        ylabel('Duration');
        plot(1:queue_param(Q_LENGTH), service_array, 'b.');    
        xlim([1, queue_param(Q_LENGTH)]);
        ylim([0, max(service_array)+1]);
        legend('Service Duration');  
        figure
    %}  
%        subplot(2, 1, 1);

%        hold on
    %    cla
%        grid on

%        title('Queue Length at Element Arrival');
%        xlabel('Element ''p''');
%        ylabel('Queue Length');
%        xlim([1, queue_param(Q_LENGTH)]);
%        ylim([0, max(X_of_t_array)+1]);

        a_mean_1 = mean(X_of_t_array);
%        plot(1:queue_param(Q_LENGTH), X_of_t_array, 'b.');
%        plot(1:queue_param(Q_LENGTH), a_mean_1 * ones(1, queue_param(Q_LENGTH)), 'b-');

%        str_mean = ['Average = ', num2str(a_mean_1)];
%        text(queue_param(Q_LENGTH)/2, a_mean_1*1.25, str_mean);

%        legend('Queue length before ''p'' arrival', 'Average queue length before ''p'' arrival');

%        subplot(2, 1, 2);

%        hold on
    %    cla
%        grid on

%        title('Number of times { S }_{ n+1 }-{ \sigma  }_{ n } >= 0');
%        xlabel('Element ''p'' arrival');
%        ylabel('Total Occurence');

        delay_service_diff_array = completion_array - arrival_array;
        delay_service_diff_array = delay_array - delay_service_diff_array(1:end-1); 
        delay_service_diff_array = (delay_service_diff_array >= 0)*1.0; %NOTE; we added '1.0' to convert boolean to floating point
        for i = 2:queue_param(Q_LENGTH)-1
            delay_service_diff_array(i) = delay_service_diff_array(i) + delay_service_diff_array(i-1);
        end

%        xlim([1, queue_param(Q_LENGTH)-1]);
%        ylim([0, abs(max(delay_service_diff_array)+1) ] );
%        plot(1:queue_param(Q_LENGTH)-1, delay_service_diff_array, 'r-');

%        legend('{ S }_{ n+1 }-{ \sigma  }_{ n } >= 0');

%        figure
%        subplot(2, 1, 1);

%        hold on
%        cla
%        grid on

%        title('Queue Length with Periodic and Exponential Time Sampling');
%        xlabel('Time');
%        ylabel('Queue Length');

        %finding sampling times
        ideal_sampling_times = linspace(0, max(completion_array), queue_param(SAMPLING)); 

        non_ideal_sampling_delay = rand(1, queue_param(SAMPLING)-1);
        non_ideal_sampling_delay = inv_sam_distr(non_ideal_sampling_delay, max(completion_array)/queue_param(SAMPLING));%
        non_ideal_sampling_times = zeros(1, queue_param(SAMPLING));
        for i  = 2:queue_param(SAMPLING)
            non_ideal_sampling_times(i) = non_ideal_sampling_times(i-1) + non_ideal_sampling_delay(i-1);
        end

        %calculating the queue lengths at different sampling times
        ideal_samples = X_of_t(ideal_sampling_times);
        non_ideal_samples = X_of_t(non_ideal_sampling_times);

        mean_1 = mean(ideal_samples);
        mean_2 = mean(non_ideal_samples);

%        xlim([0, max(completion_array)]);
%        ylim([0, max(max(ideal_samples), max(non_ideal_samples)+1)]);
%        plot(ideal_sampling_times, ideal_samples , 'r.');
%        plot(ideal_sampling_times, mean_1 * ones(1, length(ideal_sampling_times)), 'r-');
%        plot(non_ideal_sampling_times, non_ideal_samples , 'b.');
%        plot(ideal_sampling_times, mean_2 * ones(1, length(ideal_sampling_times)), 'b-');

%        str_mean_ideal = ['Ideal sampling mean = ', num2str(mean_1)];
%        str_mean_non_ideal = ['Non-ideal sampling mean = ', num2str(mean_2)];
%        text(0.75*ideal_sampling_times(end), mean_1*1.25, str_mean_ideal);
%        text(0.25*ideal_sampling_times(end), mean_2*1.25, str_mean_non_ideal);

        %plot(non_ideal_sampling_times, smooth(non_ideal_sampling_times, non_ideal_samples, 0.09, 'loess') , 'k-');
        %plot(ideal_sampling_times, smooth(ideal_sampling_times, ideal_samples, 0.09, 'loess') , 'y-');


%        legend('Periodic Sampling', 'Average with Periodic Sampling', 'Exponential Inter-arrival Sampling', 'Average with Exponential Inter-arrival Sampling');

%        subplot(2, 1, 2);

%        hold on
    %    cla
%        grid on

%        title('Average Queue Length with Periodic and Exponential Inter-arrival Sampling');
%        xlabel('Time');
%        ylabel('Average Queue Length');
%        xlim([0, max(completion_array)]);

        for i = 2:queue_param(SAMPLING)
            ideal_samples(i) = ((i-1)*ideal_samples(i-1) + ideal_samples(i))/i;
            non_ideal_samples(i) = ((i-1)*non_ideal_samples(i-1) + non_ideal_samples(i))/i;
        end 

%        ylim([0, 1.1*max(max(ideal_samples), max(non_ideal_samples))]);

%        plot(ideal_sampling_times, ideal_samples , 'r.');
%        plot(non_ideal_sampling_times, non_ideal_samples, 'b.');

%        str_mean_1 = ['Ideal Sampling Average = ', num2str(ideal_samples(end))];
%        text(0.75*max(completion_array), ideal_samples(end)*1.25, str_mean_1);
%        str_mean_2 = ['Non-ideal Sampling Average = ', num2str(non_ideal_samples(end))];
%        text(0.25*max(completion_array), non_ideal_samples(end)*1.25, str_mean_2);

%        legend('Periodic Sampling', 'Exponential Inter-arrival Sampling');

        %return output
        avg_ideal_sampling_queue_length = mean_1;
        avg_exp_sampling_queue_length = mean_2;
        avg_wait_duration = wd_mean_1;
        avg_arrival_queue_length = a_mean_1;

        output_args = [avg_ideal_sampling_queue_length, avg_exp_sampling_queue_length, avg_wait_duration, avg_arrival_queue_length];
    end

    %making the actual function call multiple times
    output_arg_size = 4;
    output_args = zeros(detail_range, output_arg_size);   
    for detail_val = 1:detail_range
        output_args(detail_val, :) = simulate_queue_conditional_local(@uni_inv_dist_func, [0 1], @rt_exp_inv_dist_func, 0.25, @rt_exp_inv_dist_func, 1, [actual_points 0 sample_count], detail_val);
    end
    
    %plotting features against the amount of 'detail' in graph
    vec_in = 1:detail_range;
    
    vec_avg_ideal_sampling_queue_length = output_args(:, 1); 
    vec_avg_exp_sampling_queue_length = output_args(:, 2);
    vec_avg_wait_duration = output_args(:, 3);
    vec_arrival_queue_length = output_args(:, 4);
    
    subplot(2,2,1);
    cla
    
    %Plotting average sampled values
    
    hold on
    grid on
    title('Average Sampled Queue Length');
    
    xlabel('Amount of Divisions');
    ylabel('Average Queue Length');
    
    xlim([0, detail_range]);
    min_ht =     min(min(vec_avg_ideal_sampling_queue_length), min(vec_avg_exp_sampling_queue_length))*0.9;
    max_ht =     max(max(vec_avg_ideal_sampling_queue_length), max(vec_avg_exp_sampling_queue_length))*1.1;
    ylim([min_ht, max_ht]);
    
    mean_1 = mean(vec_avg_ideal_sampling_queue_length);
    mean_2 = mean(vec_avg_exp_sampling_queue_length);
    
    plot(vec_in, vec_avg_ideal_sampling_queue_length, 'r.');
    h1 = plot(vec_in, mean_1*ones(1,detail_range) , 'k-');
    plot(vec_in, vec_avg_exp_sampling_queue_length, 'b.');
    h2 = plot(vec_in, mean_2*ones(1,detail_range) , 'k--');
    
    legend('Periodically Sampled (1)', strcat('Mean of (1) is :' ,num2str(mean_1)) ,'Exponential (inter-arrival) Sampling (2)', strcat('Mean of (2) is :',num2str(mean_2)) );
    
    subplot(2,2,2);
    cla  
    %Plotting queue length measure average error
    
%    q_len_error_array = 100*norm(vec_avg_ideal_sampling_queue_length - vec_avg_exp_sampling_queue_length, 2)/norm(vec_avg_ideal_sampling_queue_length, 2);
    q_len_error_array = 100*abs(vec_avg_ideal_sampling_queue_length - vec_avg_exp_sampling_queue_length)./(0.01+abs(vec_avg_ideal_sampling_queue_length));
    
    hold on
    grid on
    title('Queue Length - Ideal vs. Exponential Sampling Error');
    
    xlabel('Amount of Divisions');
    ylabel('Queue Length Error (%)');
    
    xlim([0, detail_range]);
    min_ht =     min(q_len_error_array)*0.9;
    max_ht =     max(q_len_error_array)*1.1;
    ylim([min_ht, max_ht]);

    plot(vec_in, q_len_error_array, 'b.');
    mean_1 = mean(q_len_error_array);
    h3 = plot(vec_in, mean_1*ones(1, detail_range), 'k-');

    legend('Percentage Error Measure', strcat('Mean is :' ,num2str(mean_1), '%'));
    
    %Average Wait Duration
    
    subplot(2,2,3);
    cla
    
    hold on
    grid on
    title('Average Queue Wait Duration');
    
    xlabel('Amount of Divisions');
    ylabel('Average Wait Duration');
    
    xlim([0, detail_range]);
    min_ht =     min(vec_avg_wait_duration)*0.9;
    max_ht =     max(vec_avg_wait_duration)*1.1;
    ylim([min_ht, max_ht]);

    mean_1 =  mean(vec_avg_wait_duration);
    plot(vec_in, vec_avg_wait_duration, 'b.');
    h4 = plot(vec_in, mean_1 *ones(1, detail_range), 'k-');

    legend('Average Wait Duration', strcat('Mean is :', num2str(mean_1)));
    %Average Arrival Queue Length
    
    subplot(2,2,4);
    cla
    
    hold on
    grid on
    title('Average Queue Length at Request Arrival');
    
    xlabel('Amount of Divisions');
    ylabel('Average Queue Length');
    
    xlim([0, detail_range]);
    min_ht =     min(vec_arrival_queue_length)*0.9;
    max_ht =     max(vec_arrival_queue_length)*1.1;
    ylim([min_ht, max_ht]);

    mean_1 = mean(vec_arrival_queue_length);
    plot(vec_in, vec_arrival_queue_length, 'b.');
    h5 = plot(vec_in, mean_1*ones(1, detail_range), 'k-');
    
    legend('Average Queue Length', strcat('Mean is :', num2str(mean_1)));
    
    %plot(vec_in, smooth(vec_in, vec_arrival_queue_length, smooth_val, 'rloess'), 'r-');
    
    set([h1 h2 h3 h4 h5],'LineWidth',1.5)
    
    %output_args = [avg_ideal_sampling_queue_length, avg_exp_sampling_queue_length, avg_wait_duration, avg_arrival_queue_length];
    output_args = 0;
end

