%%%%%%%%%%%%%%%%%%%
%PROBLEM PARAMETERS
%%%%%%%%%%%%%%%%%%%
tic

for test_val_size = 20:10:20

    people = 3;
    simulation_count = 20;
    money_amount = [20, 20, 20];
    expected_time = 3*prod(money_amount(1:3))/sum(money_amount(1:3));

    sim_set_size = 10;
    simulation_count = ceil(simulation_count/sim_set_size)*sim_set_size;
    sim_times = simulation_count/sim_set_size;
    
    sim_array = zeros(simulation_count, 1);

    %%%%%%%%%%%%%%%%%%%%%%
    %REPEATING SIMULATIONS
    %%%%%%%%%%%%%%%%%%%%%%
    for sim_time = 0:sim_times-1
        for sim_count = 1:sim_set_size
            %%%%%%%%%%%%%%%%%%%%%%
            %INITIALIZING SIMULATION
            %%%%%%%%%%%%%%%%%%%%%%

            local_money_amount = money_amount;
            global_time = 0;

            while(all(local_money_amount))
                random_pair_select = datasample(1:people, 2);
                
                winner = round(rand())+1;
                loser =  mod(winner,2)+1;
                winner = random_pair_select(winner);
                loser = random_pair_select(loser);

                local_money_amount(winner) = local_money_amount(winner) + 1;
                local_money_amount(loser) = local_money_amount(loser) - 1;

                global_time = global_time + 1;
            end

            %%%%%%%%%%%%%%%%%%%%%%
            %RECORDING TIMING DATA
            %%%%%%%%%%%%%%%%%%%%%%
            sim_array(sim_time*sim_set_size + sim_count) = global_time;
        end
    end


    %%%%%%%%%%%%%%%%%%%%%%
    %RECORD DATA ON DISK
    %%%%%%%%%%%%%%%%%%%%%%
    mean(sim_array)
    %csvwrite( strcat(int2str(simulation_count),'-',int2str(money_amount(end)), int2str(people),'.dat'), sim_array );

    toc
end