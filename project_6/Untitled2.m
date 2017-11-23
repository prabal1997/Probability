for d = 20:10:100
    tic
    people = 3;
    fil_name = strcat("200000-", int2str(d), int2str(people),".dat")
    arr_y = csvread(fil_name);
    
    arr_y_2 = cumsum(arr_y.');
    length_arr2 = size(arr_y_2)
    
    for idx = 1:length_arr2(2)
        arr_y_2(idx) = arr_y_2(idx)/idx;
    end
    
    
    bin_count = 300;
    arr_x = 1:bin_count;
    bin_width = max(arr_y)/bin_count;

    bins = zeros(1, bin_count);
    for idx = 1:bin_count
        bins(idx) = sum(1.0 * (arr_y > bin_width*(idx-1)) .* (arr_y <= bin_width*(idx)));
    end

    %plot data
    figure
    hold on
    cla
    ezdraw(bin_width*arr_x, bins, false, true, {strcat('Empirical Density Function of Completion Times with d= ', int2str(d)) , 'Completion Time', 'Frequency'},{'Density Function', 'Filtered Output'}, {'b.','k-','r-'}, true, 0, 0, 0, {0.15*(30/d), 'loess'}, 1.5, [20,12], false);
    
    toc
    
    figure
    hold on
    cla
    ezdraw(1:length(arr_y_2), arr_y_2, true, true, {strcat('Running average of Completion Times with d= ', int2str(d)) , 'Test Number', 'Running Average'},{'Running Average', 'Mean', 'Filtered Output'}, {'b.','k-','r-'}, false, 0, 0, 0, {0.01, 'loess'}, 1.5, [20,12], true);

    toc
    
    %ylim_arr = [0, 9000];
    %ylim(ylim_arr);
    %stem(bin_width*arr_x, bins, 'b-');
    %legend('Empirical Density Function');
end