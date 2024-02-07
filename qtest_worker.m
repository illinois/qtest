function qtest_worker(job_name,work_id)
%#function bayesian_test_super
%#function freq_test_super
%#function binom_test
%#function CPT_compute_ranks
%#function nml_super

% Restricted names:
%   cache, log, word_id, res, res_file, job_strs, job_time
%   idx, t_all, t_job
% <job_name>.mat must contain:
%   jobs: cell array of command strings
%   any data variables referred by command strings

if nargin~=2
    error('Invalid input!');
end
if ischar(work_id)
    work_id=str2num(work_id);
end
if ~isscalar(work_id)
    error('Invalid worker id!');
end
load([job_name,'.mat'],'-mat');
if ~exist('QtestLog','class')
    javaaddpath('.');
end
cache=create_cache([job_name,'.cac']);
log=javaObject('QtestLog',[job_name,'.log']);
res=cell(length(jobs),1);
job_strs=cell(length(jobs),1);
job_time=zeros(length(jobs),1);
res_file=sprintf('%s_%d.mat',job_name,work_id);
if exist(res_file,'file')
    error('Worker %d for job %s already exists!',work_id,job_name);
end
save(res_file,'res','job_strs','job_time');
idx=0;
t_all=tic;
while 1
    idx=log.getNewIndex(idx);
    if idx<=0
        break;
    end
    job_strs{idx}=jobs{idx};
    t_job=tic;
    res{idx}=eval(jobs{idx});
    job_time(idx)=toc(t_job);
    if toc(t_all)>30
        save(res_file,'res','job_strs','job_time');
        t_all=tic;
    end
end
save(res_file,'res','job_strs','job_time');
