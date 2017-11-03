function [ output_args ] = ezdraw(input, output, show_mean, show_smooth, label_names, legend_names, style, stem_enabled, xlim_array, ylim_array, buffer, smooth_config, line_width, grid_count)
    %SAMPLE function call
    %ezdraw(x_axis_input, output_distr_func, false, true, {'Inter-Arrival Time Distribution', 'Time Range', 'Frequency'},{'Distribution Function', 'Filtered Output'}, {'b.-','k-','r-'}, false, 0, 0, 0.1, [0.01, 'loess'], 1.5, [10,10]);
    
    %TYPE parameter
    %'histogram' = histogram
    %'normal'= typical graph
    %LEGEND_names parameter
    % 'graph_name' as input for each graph
    %STYLE parameter
    %'--', '-', '|', ':', '': dotted line, solid line, stem, dotted lines, no connection
    %'r', 'b', 'g', 'y', 'k', 'w', 'c', 'm': red, blue, green, yellow,
    %white, cyan, magenta
    %'s', 'x', 'O' or 'o' or '0', '.', 'd', '*', '+', '^', 'v', '<', '>',
    %'pentagram' or 'p', 'hexagram' or 'h'
    %X/Y LIM parameters: 'xlim_array', 'ylim_array' arrays  - if their size is '1', they can be ignored.
    %SMOOTH_CONFIG = [decimal value, 'rloess' or 'loess']
    %LABEL_NAMES parameter = [title, x-label, y-label];
    %STEM: asks whehter stems will be displayed
    %GRID_COUNT: array that gives grid dimension in x, y directions
    
    %set the plot boundaries for each graph
    if (length(xlim_array) == 1)
        xlim_array = [min(input), max(input)];
    end
    if (length(ylim_array) == 1)
        ylim_array = [min(output), max(output)];
    end
    
    mean_x = sum(xlim_array)/2;
    mean_y = sum(ylim_array)/2;
    xlim_array = (xlim_array-mean_x)*(1+buffer)+mean_x;
    ylim_array = (ylim_array-mean_y)*(1+buffer)+mean_y;
    if (diff(ylim_array) == 0)
        if (ylim_array(1) ~= 0)
            ylim_array(1) = ylim_array(1)*(1-buffer);
            ylim_array(2) = ylim_array(1)*(1+buffer);
        else
            ylim_array(1) = (-buffer);
            ylim_array(2) = buffer;
        end
    end
    
    %fixing the 'style' options
    use_stem = zeros(1, length(style));
    for idx = 1:length(stem_enabled)
        if (stem_enabled == true)
            use_stem(idx) = true;
        end            
    end
    
    %setting up the graph
    hold on
    
    title(label_names(1));
    xlim(xlim_array);
    if (diff(ylim_array) == 0)
        ylim_array(2) = ylim_array(1) + 1;
    end
    ylim(ylim_array);
    xlabel(label_names(2));
    ylabel(label_names(3));    

    %plotting the variables
    if (use_stem(1) ~= 1)
        plot(input, output, char(style(1)));
    else
        stem(input, output, char(style(1)));
    end
    
    mean_val = mean(output);
    if (show_mean == true)
        plot_1 = plot(linspace(xlim_array(1)/(1+buffer), xlim_array(2)/(1+buffer), 2), mean_val*ones(1, 2), char(style(2)));
        set(plot_1,'LineWidth', line_width);
    end
    
    if(show_smooth == true)
        plot_2 = 0;
        if (use_stem(2) ~= 1)
            plot_2 = plot(input, smooth(input, output, cell2mat(smooth_config(1)), char(smooth_config(2)) ), char(style(3)));
        else
            plot_2 = stem(input, smooth(input, output, cell2mat(smooth_config(1)), char(smooth_config(2)) ), char(style(3)));
        end
        
        set(plot_2,'LineWidth', line_width);    
    end

    %setting legend names
    if (show_mean == true && show_smooth ~= true)
        legend(char(legend_names(1)), [char(legend_names(2)), ' ' ,num2str(mean_val)]);
    elseif (show_mean ~= true && show_smooth == true)
        legend(char(legend_names(1)), char(legend_names(2)));
    elseif (show_mean ~= true && show_smooth ~= true)
        legend(char(legend_names(1)));
    elseif (show_mean == true && show_smooth == true)
        legend(char(legend_names(1)), [char(legend_names(2)), ' ~ ' ,num2str(mean_val)], char(legend_names(3)));
    end
    
    %enable the grid
    grid on
    set(gca, 'xtick', linspace(xlim_array(1), xlim_array(2),1+grid_count(1)));
    set(gca, 'ytick', linspace(ylim_array(1), ylim_array(2),1+grid_count(2)));

    %plot the origin
    origin_1 = plot(0, 0, 'kX');
    origin_2 = plot(0, 0, 'kO');
    set([origin_1, origin_2],'LineWidth', 2);    
    
    %setting output value
    output_args = 'Done!';
end

