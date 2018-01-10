function [ output ] = discrete_value(x, input_function, window_length )
%DISCRETE_VALUE divides a function into discrete chunks of size 'k', and
%returns a value

    right_shift = floor(x./window_length);
    output = pulse(x-right_shift.*window_length, window_length);
    
    for index = 1:length(x); 
        output(index) = output(index) * integral(input_function, window_length*right_shift(index), window_length*(right_shift(index)+1));
        output(index) = output(index) * (1/window_length);
    end
  
end


 
