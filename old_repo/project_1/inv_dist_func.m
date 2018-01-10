function [ output ] = inv_dist_func( x )
    function [ output ] = unit_step( x )
        output = (x >= 0);
    end
    output = -log(1-x).*unit_step(x);
end

