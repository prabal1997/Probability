function [output_vars] = test(required_elements, rv_count, inv_dist_type, mean)
        %MULTI_RV: gives an array of SUMMED random numbers belonging to a
        %given distribution
        %'required_elements': the number of random values required
        %'rv_count': number of random variables that need to be added to
        %obtain a single random value
        %'inv_dist_type': receives the type of input distribution to
        %which each of the random variables (that get summed) belongs
        
        output_vars = zeros(1, required_elements);
        for idx = 1:required_elements
            output_vars(idx) = sum(inv_dist_type(rand(1, rv_count), mean/rv_count));
        end
    end