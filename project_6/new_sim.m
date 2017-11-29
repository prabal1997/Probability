sim_count = 10000;
start_money = [10, 10, 10, 1000];
people = 4;

sim_len = zeros(1, sim_count);
for sim_idx = 1:sim_count
    local_start_money = start_money;
    global_counter = 0;
    
    while( all(local_start_money) )
        random_pair_select = nchoosek(1:people, 2);
        choose_set = floor(rand()*6) + 1;
        random_pair_select = random_pair_select(choose_set, :);
        
        winner = round(rand()) + 1;
        loser = 1;
        if (winner == 1)
            loser = 2;
        else
            loser = 1;
        end
        
        local_start_money(random_pair_select(winner)) = 1 + local_start_money(random_pair_select(winner));
        local_start_money(random_pair_select(loser)) = local_start_money(random_pair_select(loser))-1;
        
        global_counter = global_counter + 1;
    end
    
    sim_len(sim_idx) = global_counter;
end

mean(sim_len)