%%%%%%%%%%%%%%%%%%%
%PROBLEM PARAMETERS
%%%%%%%%%%%%%%%%%%%
tic

x_arr = 10;
y_arr = zeros(size(x_arr));
counter = 1;

simulation_count = 16000;
for test_val_size = x_arr
    people = 4;

    money_amount = ones(1, 4)*test_val_size;
    %money_amount(end) = 10000;
    %expected_time = 16*prod(money_amount(1:4).^2)/((sum(money_amount(1:4).^2))^2);
    
    sim_set_size = 4000;
    simulation_count = ceil(simulation_count/sim_set_size)*sim_set_size;
    sim_times = simulation_count/sim_set_size;
    
    sim_array = zeros(simulation_count, 1);
    choose_array = nchoosek(1:people, 2);    
    possible_choice = factorial(people)/(factorial(people-2)*2);
    random_pair_select = 0;
    
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
            
           %random_pair_select
            while(all(local_money_amount))

                random_pair_select = choose_array(floor(rand()*possible_choice+1), :);
                
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
    y_arr(counter) = global_time;
    counter = counter + 1
    mean(sim_array)
   
    %expected_time
    toc
end

plot(x_arr, y_arr, 'b.');
csvwrite( strcat('set-',int2str(simulation_count), '-' ,int2str(x_arr(end)),'.dat'), y_arr );