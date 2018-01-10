%commit again
function [output_args] = optimized_gen(people, start_money, exception_start_money, sim_length, sim_chunk)

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

    money_array = ones(1, people)*start_money;
    money_array(end) = exception_start_money;

    pair_combs_1 = nchoosek(1:people, 2);
    pair_combs_2 = pair_combs_1(:, [2, 1]);
    pair_possible = zeros(2*length(pair_combs_1), 2);
    pair_possible(1:length(pair_combs_1), [1, 2]) =  pair_combs_1;
    pair_possible(length(pair_combs_1)+1:2*length(pair_combs_1), [1, 2]) = pair_combs_2;

    pair_count = length(pair_possible);
    sim_completion_time = zeros(1, sim_length);
    
    %%%%%%%%%%%%%%%%%%%
    %LOCAL VECTOR INITIALIZATION, UPDATION
    %%%%%%%%%%%%%%%%%%%
    buffer_constant = 1.5;
    exponential_avg_weight = 0.9; %this means that that 90% of original value is maintained, and 10% is accounted for by the updated value
    expected_game_len = ceil(3*prod(money_array(1:3))/sum(money_array(1:3)) * buffer_constant);
    
    random_pair_choice = [];
    winner_idx = [];
    loser_idx = [];
    
    function [output_vals] = reset_init_vectors(input_size)
        random_pair_choice = ceil(pair_count * rand(1, input_size));
        winner_idx = pair_possible(random_pair_choice, 1);
        loser_idx = pair_possible(random_pair_choice, 2);     
    end
    
    %%%%%%%%%%%%%%%%%%%
    %SIMULATION
    %%%%%%%%%%%%%%%%%%%
    for sim_chunk_idx = 0:sim_chunk_count-1
        for local_sim_idx = 1:sim_chunk
            %'resetting' the money array for EACH simulation
            local_money_array = money_array;
            time_counter = 0;           
            
            %we keep simulating till someone gets ruined
            while(all(local_money_array))
                index_access = mod(time_counter, expected_game_len)+1;
                
                %whenever we 'run' out of values, we update them for
                %continual use
                if ( index_access == 1 )
                    reset_init_vectors(expected_game_len);
                end
                
                local_money_array(winner_idx(index_access)) = local_money_array(winner_idx(index_access)) + 1;
                local_money_array(loser_idx(index_access)) = local_money_array(loser_idx(index_access)) - 1;
                
                time_counter = time_counter + 1;
            end
             
            %storing data, exponentially averaging the...
            %...'expected_sim_length' for optimization purposees
            sim_completion_time(sim_chunk_idx*sim_chunk+local_sim_idx) = time_counter;
            expected_game_len = ceil(expected_game_len * exponential_avg_weight + time_counter*(1-exponential_avg_weight));
        end
    end
    
    %'Additional Stats:'
    output_args = mean(sim_completion_time);
    %toc
end