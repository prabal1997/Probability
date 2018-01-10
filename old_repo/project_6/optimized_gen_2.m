%commit again
function [output_args] = optimized_gen_2(people, start_money, exception_start_money, exceptional_people, sim_length, sim_chunk)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %This function receives certain parameters, and repeatedly gambles...
    %...using the SAME parameters to find a mean completion time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %tic
    
    %%%%%%%%%%%%%%%%%%%
    %PARAMETER 'FIXING'
    %%%%%%%%%%%%%%%%%%%
    if (mod(sim_length, sim_chunk))
        sim_length = ceil(sim_length/sim_chunk)*sim_chunk;
    end
    sim_chunk_count = sim_length/sim_chunk;

    %%%%%%%%%%%%%%%%%%%
    %GLOBAL VECTOR INITIALIZATION
    %%%%%%%%%%%%%%%%%%%
    CONST_PERM_COUNT = people*(people-1); %this is the
    
    money_array = ones(1, people)*start_money;
    money_array(end-(exceptional_people-1): end) = exception_start_money;
    
    sample_player_choice = zeros(1, people);
    sample_player_choice(1) = -1; sample_player_choice(2) = 1;
    player_choices = unique(perms(sample_player_choice), 'rows');
    
    sim_completion_time = zeros(1, sim_length);
    
    %%%%%%%%%%%%%%%%%%%
    %LOCAL VECTOR INITIALIZATION, UPDATION
    %%%%%%%%%%%%%%%%%%%
    buffer_constant = 1.5;
    exponential_avg_weight = 0.90; %this means that that 90% of original value is maintained, and 10% is accounted for by the updated value
    expected_game_len = ceil(3*prod(money_array(1:3))/sum(money_array(1:3)) * buffer_constant);
    
    cum_diff_sum_matrix = [];   %use this for keeping track of when we hit '0'
    
    %this function essentially creates a batch of random gambling events
    function [] = reset_init_vectors(input_size)
        cum_diff_sum_matrix = player_choices(ceil(rand(1, input_size)*CONST_PERM_COUNT), :);
        cum_diff_sum_matrix = cumsum(cum_diff_sum_matrix);
    end

    %%%%%%%%%%%%%%%%%%%
    %SIMULATION
    %%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %sim_counter = 0;
    %fault_counter = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for sim_chunk_idx = 0:sim_chunk_count-1
        for local_sim_idx = 1:sim_chunk
            %'resetting' the money array for EACH simulation
            local_money_array = money_array;
            time_counter = 0;           
            
            %we keep simulating till someone gets ruined
            exit_loop = false;
            while(~exit_loop)
                %create random gambling plays
                reset_init_vectors(expected_game_len);
               
                zero_loc_arr = find(cum_diff_sum_matrix == -local_money_array);
                if (~isempty(zero_loc_arr))
                    first_zero_pos = zero_loc_arr(1);
                    row_idx = mod(first_zero_pos-1, expected_game_len);
                    
                    time_counter = time_counter + row_idx;
                    exit_loop = true;
                else
                    time_counter = time_counter + expected_game_len;
                end                    
                
                %update the money counters
                local_money_array = local_money_array + cum_diff_sum_matrix(end, :);
            end
             
            %storing data, exponentially averaging the...
            %...'expected_sim_length' for optimization purposees
            sim_completion_time(sim_chunk_idx*sim_chunk+local_sim_idx) = time_counter;
            
            expected_game_len = ceil(expected_game_len * exponential_avg_weight + time_counter*(1-exponential_avg_weight));
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %sim_counter = sim_counter + 1;
            %fault_counter = fault_counter + (expected_game_len < time_counter);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    
    %RETURN THE MEAN
    output_args = mean(sim_completion_time);
    
    %Display time taken for completion
    %toc;
    
    %sim_counter
    %fault_counter
    %strcat(num2str(100*fault_counter/sim_counter), '%')
end