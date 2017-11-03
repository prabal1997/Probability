function [ output ] = pulse( x, window_length )
%PULSE generates a single pulse of length 'k' from x = 0 to 'k' 
    output = (x >= 0) .* (x < window_length);
end

