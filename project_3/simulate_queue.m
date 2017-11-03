function [ output_args ] = simulate_queue(inv_time_distr, inv_wait_distr, inv_sam_distr, queue_param )
%SIMULATE_QUEUE simulates a queue

    %designated constants
    DEL_MEAN = 1;
    SERVICE_MEAN = 2;
    Q_LENGTH = 3;
    Q_START = 4;
    SAMPLING = 5;
    
    %generate a list of random numbers for arrival, service times
    delay_array = rand(1, queue_param(Q_LENGTH)-1);
    delay_array = inv_time_distr(delay_array, queue_param(DEL_MEAN) );
    
    arrival_array = zeros(1, queue_param(Q_LENGTH));
    arrival_array(1) = queue_param(Q_START);
    for i = 2:queue_param(Q_LENGTH)
        arrival_array(i) = arrival_array(i-1) + delay_array(i-1);
    end
    
    service_array = rand(1, queue_param(Q_LENGTH));
    service_array = inv_wait_distr(service_array, queue_param(SERVICE_MEAN) );
    
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
    subplot(2, 3, 1);
    
    title('M/M/1 Queue Simulation');
   
    hold on
    cla
    grid on
    xlim([1, queue_param(Q_LENGTH)]);
    xlabel('Element ''p''');
        
    ylabel('Time');
    ylim([0, ceil(max(completion_array))+2]);
    plot(1:queue_param(Q_LENGTH), arrival_array, 'bO-');
    plot(1:queue_param(Q_LENGTH), completion_array, 'rO-');
    
    legend('Arrival Time', 'Completion Time');
    
    subplot(2, 3, 2);
    
    X_of_t_array = X_of_t(arrival_array);
    
    hold on
    cla
    grid on
        
    title('Wait Duration and Service Time');
    xlabel('Element ''p''');
    ylabel('Duration');

    wait_array = completion_array - arrival_array - service_array;
    plot(1:queue_param(Q_LENGTH), service_array, 'r-');
    plot(1:queue_param(Q_LENGTH), wait_array, 'bO');
    xlim([1, queue_param(Q_LENGTH)]);
    ylim([0, max(max(wait_array), max(service_array))+1]);
    
    legend('Service Time','Wait Time');
    
    subplot(2, 3, 3);
    
    hold on
    cla
    grid on
        
    title('Queue Length at Element Arrival');
    xlabel('Element ''p''');
    ylabel('Queue Length');
    xlim([1, queue_param(Q_LENGTH)]);
    ylim([0, max(X_of_t_array)+1]);
    
    plot(1:queue_param(Q_LENGTH), X_of_t_array, 'b.');
    'AVG'
    mean(X_of_t_array)
    
    legend('Queue length after element ''p'' arrival');
    
    subplot(2, 3, 4);
    
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
    
    subplot(2, 3, 5);
    
    hold on
    cla
    grid on
        
    title('Queue Length with Periodic and Exponential Time Sampling');
    xlabel('Time');
    ylabel('Queue Length');
    
    %finding sampling times
    ideal_sampling_times = linspace(0, max(completion_array), queue_param(SAMPLING));  
    ideal_samples = zeros(1, queue_param(SAMPLING));
    
    non_ideal_sampling_times = rand(1, queue_param(SAMPLING));
    non_ideal_sampling_times = inv_sam_distr(non_ideal_sampling_times, 1);
    non_ideal_sampling_times = (non_ideal_sampling_times-min(non_ideal_sampling_times) );
    non_ideal_sampling_times = non_ideal_sampling_times/max(non_ideal_sampling_times);
    non_ideal_samples = zeros(1, queue_param(SAMPLING));
    non_ideal_sampling_times = completion_array(end)*sort(non_ideal_sampling_times);
    
    ratio_constant = queue_param(SAMPLING)/completion_array(end);
    
    %calculating the average values
    for i = 1:queue_param(SAMPLING)
        ideal_samples(i) = X_of_t(ideal_sampling_times(i));
        non_ideal_samples(i) = X_of_t(non_ideal_sampling_times(i));
    end
    
    %plot(1:queue_param(Q_LENGTH), completion_array, 'bO');
    xlim([0, max(completion_array)]);
    ylim([0, max(max(ideal_samples), max(non_ideal_samples)+1)]);
    plot(ideal_sampling_times, ideal_samples , 'rO');
    'SAMPLE AVG'
    mean(non_ideal_samples)
    plot(non_ideal_sampling_times, non_ideal_samples , 'bO');
    
    legend('Periodic Sampling', 'Exponential Sampling');
    
    subplot(2, 3, 6);
    
    hold on
    cla
    grid on
        
    title('Average Queue Length with Periodic and Exponential Time Sampling');
    xlabel('Time');
    ylabel('Average Queue Length');
    xlim([0, max(completion_array)]);
    ylim([0, max(max(ideal_samples), max(non_ideal_samples)+1)]);
    
    for i = 2:queue_param(SAMPLING)
        ideal_samples(i) = ((i-1)*ideal_samples(i-1) + ideal_samples(i))/i;
        non_ideal_samples(i) = ((i-1)*non_ideal_samples(i-1) + non_ideal_samples(i))/i;
    end 
    
    plot(ideal_sampling_times, ideal_samples , 'rs-');
    plot(non_ideal_sampling_times, non_ideal_samples, 'bs-');
    
    legend('Periodic Sampling', 'Exponential Sampling');
    
    %print values
    lambda_a
    W_Q
    L_Q
    
end

