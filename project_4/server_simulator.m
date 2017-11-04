function [ output ] = server_simulator(service_distr, arrival_distr)
%SERVER_SIMULATOR simulates a server with infinite processors receving
%requests one by one...
    
    %SIMULATION INPUT VARIABLES
    arrival_rate = 1000; %rate at which requests arrive per second
    arrival_mean = 1/(arrival_rate-1);
    service_mean = 0.0005; %mean service time of a request
%    service_distr = @rt_exp_inv_dist_func; %inverse probabilit distr. of service times
%    arrival_distr = @rt_periodic_inv_distr;
    queue_limit = Inf; %pending request(s) limit; extra requests are simply truncated
    core_count = Inf; %refers to number of cores available for processing
    sim_length = Inf; %number of seconds to simulate
    error_thresh = 0.01; %refers to how much close the output needs to be close to the ideal scenario (in %)
    ignorace_thresh = 10^-5; %refers to the scale at which 'e^-rho*t' gets replaced by '0'

    %SUPPORT FUNCTIONS
    function [output_vars] = multi_rv(required_elements, rv_count, inv_dist_type, mean)
        %MULTI_RV: gives an array of SUMMED random numbers belonging to a
        %given distribution
        %'required_elements': the number of random values required
        %'rv_count': number of random variables that need to be added to
        %obtain a single random value
        %'inv_dist_type': receives the type of input distribution to
        %which each of the random variables (that get summed) belongs
        output_vars = zeros(1, required_elements);
        for idx = 1:required_elements
            output_vars(idx) = sum( inv_dist_type(rand(1, rv_count), mean/rv_count) );
        end
    end
    
    function [running_avg] = simulate_requests(element_chunk_size, arrival_distr, input_arrival_mean, service_distr, input_service_mean)
        %SIMULATE_REQUESTS: simulates an 'element_chunk_size' number of
        %requests AND their completion
        
        %generate inter-arrival times
        inter_arrival_times = multi_rv(element_chunk_size-1, 1, arrival_distr, input_arrival_mean);
        
        %generate service times
        service_duration = multi_rv(element_chunk_size, 1, service_distr, input_service_mean);
        
        %calculate arrival, completion 'timelines'
        arrival_timeline = zeros(1, element_chunk_size);
        for idx = 2:element_chunk_size
            arrival_timeline(idx) = arrival_timeline(idx-1) + inter_arrival_times(idx-1);
        end
        
        completion_timeline = arrival_timeline + service_duration;
        
        %measure number of 'busy' server everytime for every new element
        %arrival
        ideal_busy_servers = (1/input_arrival_mean) * input_service_mean;
        busy_servers_count = zeros(1,element_chunk_size); %keeps track of busy servers EVERY element arrival
        running_avg = zeros(1, element_chunk_size);
        running_sum = 0;
        for idx = 2:element_chunk_size
            busy_servers_count(idx) = sum( 1.0 .* (arrival_timeline(idx) >  arrival_timeline(1:idx-1)) .* (arrival_timeline(idx) < completion_timeline(1:idx-1)) ) ;
            running_sum = running_sum + busy_servers_count(idx);
            if (rem(idx, 1000) == 0)
                running_sum = 0;
            end
            running_avg(idx) = running_sum/(rem((idx-1), 1000));
        end
    end

    %SIMULATE TEST
    %1.) we simulate a 'group of elements' at a time
    %2.) stop abruptly if precision requirements are met OR if time count
    %has been exceeded
    %3.) continue otherwise

    element_chunk_size = 10000;
    running_avg = simulate_requests(element_chunk_size, arrival_distr, arrival_mean, service_distr, service_mean);
    cla
    hold on
    plot(linspace(1, element_chunk_size+1, element_chunk_size), running_avg, 'r-');
    plot(linspace(1, element_chunk_size+1, element_chunk_size), ideal_busy_servers*ones(1, element_chunk_size), 'g-');
end

