function generate_example_job
%This example generates a job for computing Bayes factor 2
% on all 49 CPT theories and all 40 subjects, each repeated 10 times (for
% benchmarking purpose).
%
% It refers to data files under the 'BlacklightGUI' folder so you should
% change this if your data is in a different path


%%% some basic parameters

job_name = 'CPT_bf2';
CPT_level = 0.75;
N = 10000; %sample size
repetition = 10; %how many independent run for each analysis
options = {'b2'}; %this is the option to bayesian_test_super indicating
                    %that we want Bayes factor 2
theory_path = 'BlacklightGUI/CPT/PredictedPatterns';
subject_path = 'BlacklightGUI/CPT/Subjects';
                    
%%%%% load from data files and store into a cell array

all_ranks = cell(7,7);
for v_i=1:7
    for w_i=1:7
        t_data=load(sprintf('%s/2009_CPT_V%d_W%d_vertices.mat', ...
            theory_path, v_i, w_i));
        all_ranks{v_i,w_i} = t_data.rank;
    end
end

%%% load all subjects and store into a cell array

s_data=load(sprintf('%s/2009_data.mat',subject_path));
M = cell(40,1);
for i=1:40
    M{i} = s_data.data((i-1)*20+(1:20),:);
end

%%%%%%%% the most important variable: 'jobs', which should be a cell array
% we will add to this cell one command at a time
% Note the order: we cycle through all workers for the same theory, then
% move on to the next theory. This will maximize the use of the cache.
%
% Note also that 'cache' is specified. This is the default cache used by
% qtest_worker.

jobs={}; 
idx=0;

for seed=1:repetition
    for v_i=1:7
        for w_i=1:7
            for i=1:40
                idx = idx + 1;
                jobs{idx} = sprintf( ...
                ['bayesian_test_super(M{%d},all_ranks{%d,%d},', ...
                    '[],%g,options,%d,0,%d,cache)'],i,v_i,w_i,CPT_level,N,seed);
            end
        end
    end
end

%%%%%% Important: save all the necessary variables (but not more)
%%%%% In particular, only 'jobs' plus those referred *within* the command
%%%%% string. In this example, only M, all_ranks and options occur in the
%%%%% command string.

save([job_name,'.mat'],'jobs','M','all_ranks','options');

% The following variable names should never be saved:
%   cache, log, word_id, res, res_file, job_strs, job_time
%   idx, t_all, t_job

%%%% Finally, create the log file. This should remain unchanged for all
%%%% jobs.
fid=fopen([job_name,'.log'],'w');
fwrite(fid,zeros(length(jobs),1));
fclose(fid);
