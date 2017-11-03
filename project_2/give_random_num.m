function [ output ] = give_random_num(amount, inv_dens_func)
    output = rand(1, amount);
    output = inv_dens_func(output);
end

