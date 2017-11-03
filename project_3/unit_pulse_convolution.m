function [ output ] = unit_pulse_convolution( x, conv_count )
%UNIT_PULSE_CONVOLUTION convolves the unit-step function 'n'-times, and
%returns the value at 'x'
    output = zeros(1, length(x));
    for index = 1:length(x);
        output(index) = 0;
        for i = 0:conv_count;
            output(index) = output(index) + ((-1)^i)*nchoosek(conv_count, i)*(1/factorial(conv_count-1))*((x(index)-i)^(conv_count-1))*heaviside(x(index)-i);
        end
    end

end

