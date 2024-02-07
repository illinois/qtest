function generate_example_CPT_job
%This example generates a job for CPT_compute_ranks
%
% It is based on CPT_vertices_onlygain_2outcomes_par5b_java
% It also loads from file '2009gambles.mat'

%%% some basic parameters

job_name = 'CPT_vo2par5b';

%%%%%%%%%%% the followings are input data %%%%%%%%%%%%%%%%%%
load('2009gambles.mat');
B=gambles;
dim=20;

alpha=[0.001:.01:3,3:.05:10];
% alpha=0.001:.1:1;
beta=[0.001:.01:2 1.001:.05:10];
% beta=1;
gamma=.001:.01:1;
% gamma=1;
% s=1;
s=[0.001:.01:2 1.001:.05:10];

% ID1_rng = 1:7;
% ID2_rng = 1:7;
% [ID1,ID2]=meshgrid(ID1_rng,ID2_rng);
% ID1ID2 = [ID1(:), ID2(:)];
ID1ID2=[6,3;6,5;6,7;7,3;7,5;7,7;];

%preprocess gamble pairs
Xp=cell(1,dim);
for i=1:dim
    A=[B(i,[1 3]);B(i,[2 4]);B(i,[5 7]);B(i,[6 8])]';
    [~,IX] = sort(A,1,'ascend');
    Xp{i}=[A(IX(:,1),1), A(IX(:,1),2), A(IX(:,3),3), A(IX(:,3),4)];
end

Xp_mat = cell2mat(Xp');

%%%%%%%% the most important variable: 'jobs', which should be a cell array
% we will add to this cell one command at a time
% Note the order: we cycle through all alpha for each pair of (ID1,ID2)
% specified in ID1ID2. Each worker will work on one alpha at a time.

jobs={}; 
idx=0;

for ID_idx = 1:size(ID1ID2,1)
    ID1 = ID1ID2(ID_idx,1);
    ID2 = ID1ID2(ID_idx,2);

    for k=1:length(alpha)
        idx = idx + 1;
        jobs{idx} = sprintf( ...
            'CPT_compute_ranks(%d,alpha(%d),%d,%d,Xp_mat,beta,gamma,s)', ...
            dim,k,ID1,ID2);
    end
end

%%%%%% Important: save all the necessary variables (but not more)
%%%%% In particular, only 'jobs' plus those referred *within* the command
%%%%% string. In this example, only alpha, Xp_mat, beta, gamma and s occur
%%%%% in the command string.

save([job_name,'.mat'],'jobs','alpha','Xp_mat','beta','gamma','s');

% The following variable names should never be saved:
%   cache, log, word_id, res, res_file, job_strs, job_time
%   idx, t_all, t_job

%%%% Finally, create the log file. This should remain unchanged for all
%%%% jobs.
fid=fopen([job_name,'.log'],'w');
fwrite(fid,zeros(length(jobs),1));
fclose(fid);
