function [ output_args ] = simulate_queue_updated(inv_time_distr, time_param, inv_wait_distr, wait_param, inv_sam_distr, sample_param, queue_param )
%SIMULATE_QUEUE simulates a queue

    %designated constants
%    DEL_MEAN = 1;
%    SERVICE_MEAN = 2;
    Q_LENGTH = 1;
    Q_START = 2;
    SAMPLING = 3;
    
    %generate a list of random numbers for arrival, service times
    delay_array = rand(1, queue_param(Q_LENGTH)-1);
    delay_array = inv_time_distr(delay_array, time_param);
    
    arrival_array = zeros(1, queue_param(Q_LENGTH));
    arrival_array(1) = queue_param(Q_START);
    for i = 2:queue_param(Q_LENGTH)
        arrival_array(i) = arrival_array(i-1) + delay_array(i-1);
    end
    
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
    close all
    subplot(2, 1, 1);
    
    title('M/M/1 Queue Simulation');
   
    hold on
    cla
    grid on
    xlim([1, queue_param(Q_LENGTH)]);
    xlabel('Element ''p''');
        
    ylabel('Time');
    ylim([0, ceil(max(completion_array))+2]);
    plot(1:queue_param(Q_LENGTH), arrival_array, 'b.-');
    plot(1:queue_param(Q_LENGTH), completion_array, 'r.--');
    
    legend('Arrival Time', 'Completion Time');
    
    subplot(2, 1, 2);
    
    X_of_t_array = X_of_t(arrival_array);
    
    hold on
    cla
    grid on
        
    title('Wait Duration');
    xlabel('Element ''p''');
    ylabel('Duration');

    wait_array = completion_array - arrival_array - service_array;
    mean_1 = mean(wait_array);
    
    plot(1:queue_param(Q_LENGTH), wait_array, 'b.');
    plot(1:queue_param(Q_LENGTH), mean_1*ones(1, queue_param(Q_LENGTH)), 'b-');
    xlim([1, queue_param(Q_LENGTH)]);
    ylim([0, max(wait_array)+1]);
    legend('Wait Duration', 'Average Wait Duration');
    str_mean = ['Average = ', num2str(mean_1)];
    text(queue_param(Q_LENGTH)/2, mean_1*1.25, str_mean);
    
    figure
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
    subplot(2, 1, 1);
    
    hold on
    cla
    grid on
        
    title('Queue Length at Element Arrival');
    xlabel('Element ''p''');
    ylabel('Queue Length');
    xlim([1, queue_param(Q_LENGTH)]);
    ylim([0, max(X_of_t_array)+1]);
    
    mean_1 = mean(X_of_t_array);
    plot(1:queue_param(Q_LENGTH), X_of_t_array, 'b.');
    plot(1:queue_param(Q_LENGTH), mean_1 * ones(1, queue_param(Q_LENGTH)), 'b-');

    str_mean = ['Average = ', num2str(mean_1)];
    text(queue_param(Q_LENGTH)/2, mean_1*1.25, str_mean);

    legend('Queue length before ''p'' arrival', 'Average queue length before ''p'' arrival');
    
    subplot(2, 1, 2);
    
    hold on
    cla
    grid on
        
    title('Number of times { S }_{ n+1 }-{ \sigma  }_{ n } >= 0');
    xlabel('Element ''p'' arrival');
    ylabel('Total Occurence');
    
    delay_service_diff_array = completion_array - arrival_array;
    delay_service_diff_array = delay_array - delay_service_diff_array(1:end-1); 
    delay_service_diff_array = (delay_service_diff_array >= 0)*1.0; %NOTE; we added '1.0' to convert boolean to floating point
    for i = 2:queue_param(Q_LENGTH)-1
        delay_service_diff_array(i) = delay_service_diff_array(i) + delay_service_diff_array(i-1);
    end

    xlim([1, queue_param(Q_LENGTH)-1]);
    ylim([0, abs(max(delay_service_diff_array)+1) ] );
    plot(1:queue_param(Q_LENGTH)-1, delay_service_diff_array, 'r-');
    
    legend('{ S }_{ n+1 }-{ \sigma  }_{ n } >= 0');
    
    figure
    subplot(2, 1, 1);
    
    hold on
    cla
    grid on
        
    title('Queue Length with Periodic and Exponential Time Sampling');
    xlabel('Time');
    ylabel('Queue Length');
    
    %finding sampling times
    ideal_sampling_times = linspace(0, max(completion_array), queue_param(SAMPLING)); 
    
    non_ideal_sampling_delay = rand(1, queue_param(SAMPLING)-1);
    non_ideal_sampling_delay = inv_sam_distr(non_ideal_sampling_delay, max(completion_array)/queue_param(SAMPLING));
    non_ideal_sampling_times = zeros(1, queue_param(SAMPLING));
    for i  = 2:queue_param(SAMPLING)
        non_ideal_sampling_times(i) = non_ideal_sampling_times(i-1) + non_ideal_sampling_delay(i-1);
    end
    
    %calculating the queue lengths at different sampling times
    ideal_samples = X_of_t(ideal_sampling_times);
    non_ideal_samples = X_of_t(non_ideal_sampling_times);
    
    mean_1 = mean(ideal_samples);
    mean_2 = mean(non_ideal_samples);
    
    xlim([0, max(completion_array)]);
    ylim([0, max(max(ideal_samples), max(non_ideal_samples)+1)]);
    plot(ideal_sampling_times, ideal_samples , 'r.');
    plot(ideal_sampling_times, mean_1 * ones(1, length(ideal_sampling_times)), 'r-');
    plot(non_ideal_sampling_times, non_ideal_samples , 'b.');
    plot(ideal_sampling_times, mean_2 * ones(1, length(ideal_sampling_times)), 'b-');
    
    str_mean_ideal = ['Ideal sampling mean = ', num2str(mean_1)];
    str_mean_non_ideal = ['Non-ideal sampling mean = ', num2str(mean_2)];
    text(0.75*ideal_sampling_times(end), mean_1*1.25, str_mean_ideal);
    text(0.25*ideal_sampling_times(end), mean_2*1.25, str_mean_non_ideal);
    
    %plot(non_ideal_sampling_times, smooth(non_ideal_sampling_times, non_ideal_samples, 0.09, 'loess') , 'g-');
    %plot(ideal_sampling_times, smooth(ideal_sampling_times, ideal_samples, 0.09, 'loess') , 'y-');

    
    legend('Periodic Sampling', 'Average with Periodic Sampling', 'Exponential Inter-arrival Sampling', 'Average with Exponential Inter-arrival Sampling');
    
    subplot(2, 1, 2);
    
    hold on
    cla
    grid on
    
    title('Average Queue Length with Periodic and Exponential Inter-arrival Sampling');
    xlabel('Time');
    ylabel('Average Queue Length');
    xlim([0, max(completion_array)]);
    ylim([0, max(max(ideal_samples), max(non_ideal_samples)+1)]);
    
    for i = 2:queue_param(SAMPLING)
        ideal_samples(i) = ((i-1)*ideal_samples(i-1) + ideal_samples(i))/i;
        non_ideal_samples(i) = ((i-1)*non_ideal_samples(i-1) + non_ideal_samples(i))/i;
    end 
    
    plot(ideal_sampling_times, ideal_samples , 'r.-');
    plot(non_ideal_sampling_times, non_ideal_samples, 'b.-');
    
    str_mean_1 = ['Ideal Sampling Average = ', num2str(ideal_samples(end))];
    text(0.75*max(completion_array), ideal_samples(end)*1.25, str_mean_1);
    str_mean_2 = ['Non-ideal Sampling Average = ', num2str(non_ideal_samples(end))];
    text(0.25*max(completion_array), non_ideal_samples(end)*1.25, str_mean_2);
    
    legend('Periodic Sampling', 'Exponential Inter-arrival Sampling');
    
    %print values
    lambda_a
    W_Q
    L_Q
    
end

