for i = 9
    figure;
    Copy_of_q_sim_distr_analysis_complete(@rt_exp_inv_dist_func, 0.5, @rt_exp_inv_dist_func, 0.25, 100000, 10000, 2^i, 2^i);
    'Done with 2^:'
    i
end