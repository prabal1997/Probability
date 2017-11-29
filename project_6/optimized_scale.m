tic;

people = 4;
money_range = 1:200;

sim_count = 2000;
sim_chunk = 1000;

mean_storage_array = zeros(1, length(money_range));
counter = 1;

for money_amount = money_range
    mean_storage_array(counter) = optimized_gen_2(people, money_amount, money_amount, 1, 100, 100);
    counter = counter + 1;
    money_amount
end
toc
hold on
cla
%plot(money_range, log(mean_storage_array), 'r.');
x_arr = money_range;
y_arr = log(mean_storage_array);

plot(x_arr, y_arr, 'r.');
plot(x_arr, log(x_arr.^2), 'b-');
plot(x_arr, y_arr-log(x_arr.^2), 'k.');
mean(y_arr)
mean(y_arr-log(x_arr.^2))
toc
%csv_write('test_data.dat', mean_storage_array);

