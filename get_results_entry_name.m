function entry_name=get_results_entry_name(res)
if isfield(res,'sets_M')
    data_str=res.sets_M.name;
else
    data_str=sprintf('%.4f',get_data_hash(res.M));
end
if ~isfield(res,'type') || isequal(res.type,'frequentist')
    N_str=sprintf('freq/%i',res.N);
elseif isequal(res.type,'bayes_factor')
    N_str=sprintf('bayes-f/%i',res.gibbs_size);
else
    N_str=sprintf('bayes-p/%i/%i',res.gibbs_size,res.gibbs_burn);
end
if isequal(res.spec,'file')
    entry_name=sprintf('%s (%s/%s/%i)',res.theory.name, ...
        data_str, N_str, res.rstate);
elseif res.use_ref>0 && ~isequal(res.spec,'borda')
    entry_name=sprintf('%s [R: %g] (%s/%s/%i)',res.theory.name, ...
        exp(res.log_ref_vol), data_str, N_str, res.rstate);
else
    entry_name=sprintf('%s (%s/%s/%i)',res.theory.name, ...
        data_str, N_str, res.rstate);
end
