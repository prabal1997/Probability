k = 1/5;
n = 1000;
m = 10; %defines NO OF INTERVALS we tested this on

test_count = n;

rand_array = give_random_num(n, @rt_inv_dens_func);
for i = 1:m    
    x_i_array(i) = (1/n) .* ( (rand_array >= (i-1)*k) .* (rand_array <= i*k) );
    
    for i = 1:n
        x_i_array = zeros(m, n);    
        %distribution function of density
        data = 0;
        for k = 1:n
            fft(x_i_array
        end
    end
end

