function merge_results(job_name,worker_ids)
load(sprintf('%s_%d.mat',job_name,worker_ids(1)));
for i=2:length(worker_ids)
    z=load(sprintf('%s_%d.mat',job_name,worker_ids(i)));
    for j=1:length(z.res)
        if ~isempty(z.res{j})
            res{j}=z.res{j};
            job_strs{j}=z.job_strs{j};
            job_time(j)=z.job_time(j);
        end
    end
end
save(sprintf('%s_all.mat',job_name),'res','job_strs','job_time');
