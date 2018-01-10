function [ output_args ] = request_simulator(service_distr, arrival_distr)

    %required parameters
    arrival_rate = 500;
    arrival_mean = 1/arrival_rate;
    service_mean = 0.002;
    population_rate = arrival_rate * service_mean;
    
    delta_time = min(arrival_mean, service_mean);

    init_size = 1000000;
    point_array = zeros(1, init_size);    %holds arrival times of points
    used_point_array = 0;
    death_array = zeros(1, init_size);    %holds death times of points
    used_death_array = 0;

    %create an array of birth, death
    function [ output_args ] = add_points(count)
        %if no elements exist
        if (used_point_array == 0)
            death_array(1) = service_distr(rand, service_mean);
            used_death_array = 1;
            used_point_array = used_death_array;
            
            count = count - 1;
            if (count == 0)
                return;
            end
        end
        
        %double array size if needed
        if (used_point_array + count > length(point_array))            
            old_point_array = point_array;
            old_death_array = death_array;

            new_size = 2^ceil(log(used_point_array + count)/log(2));
            point_array = zeros(1, new_size);
            death_array = point_array;

            point_array(1:length(old_point_array)) = old_point_array;
            death_array(1:length(old_death_array)) = old_death_array;
        end
        
        %add new points to the list
        for idx = used_point_array+1:used_point_array+count
            point_array(idx) = point_array(idx-1) + arrival_distr(rand, arrival_mean);
            death_array(idx) = point_array(idx)   + service_distr(rand, service_mean);
        end
        used_death_array = used_point_array+count;
        used_point_array = used_death_array;
    end

    %initialize data
    add_points(init_size);
    initial_pop = 0;
    
    diff_array = death_array - point_array;
    state = zeros(1, length(diff_array));
    count = 1;
    for idx = 1:init_size
        if (arrival_mean < diff_array(count))
            initial_pop = initial_pop + 1;
        else
            if (initial_pop > 0)
                initial_pop = initial_pop - 1;
            end
        end
        state(count) = initial_pop;
        
        count = count + 1;
    end
    
    mean(state)
    population_rate
end

