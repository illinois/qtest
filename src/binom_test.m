function res=binom_test(m,A,B,Aeq,Beq,ineq_idx,options,N_actual,N_burn,rstate)
%BINOM_TEST performs Bayesian and frequentist tests for any binomial,
%linearly constrained models.
%   RES=binom_test(M,A,B,AEQ,BEQ,INEQ_IDX,OPTIONS,N_ACTUAL,N_BURN,RSTATE)
%   
%   M is the data matrix, where each row gives the outcome of a binomial
%   test. For example, for a 3-dimensional case, with 20 observations per
%   dimensions, M could be [8,12; 7,13; 11,9]
%
%   A, B, AEQ, BEQ, INEQ_IDX specify the inequalities as well as the
%   equalities that define the constraint polytope. These can be obtained 
%   from porta_hull if one starts with a set of vertices. In particular, 
%   A and B specify the inequalities, while AEQ and BEQ specify the 
%   equalities:
%     A.x<=B
%     AEQ.x==BEQ
%   In case there are no equalities, AEQ and BEQ should be left empty.
%   INEQ_IDX is the list of variables in the inequalities. For example, for
%   a 3-dimensional case with no equalities, INEQ_IDX would be [1,2,3],
%   indicating that all 3 variables are constrained by the inequalities.
%
%   OPTIONS is a cell array specifying the tests to be run. Each array
%   element should be one of the following strings:
%       'b1' - indicates that Bayes factor using Draw and Test should be computed
%       'b2' - indicates that Bayes factor using Gibbs Sampler should be computed
%       'p'  - indicates that Bayesian p-value and DIC should be computed
%       'f'  - indicates that frequentist p-value should be computed
%       'nml'- indicates that NML should be computed
%   Example: to compute Bayesian p and Bayes factor using Gibbs Sampler, OPTIONS should be
%       { 'p', 'b2' }
%   Note: Nothing will be computed if OPTIONS is left empty {}.
%   WARNING: AEQ and BEQ will be assumed empty for 'b1' and 'f' regardless
%   of their actual contents.
%
%   N_ACTUAL is the actual number of samples used to perform each test.
%   In the case of NML, this value can be 0, which means that the
%   exact denominator will be computed, using all possible data-points.
%   WARNING: When mixing several OPTIONS, the same sample size will be used
%   for each. This may not be desired, since the quality of the
%   approximation given the same sample size may vary greatly for each
%   option (say, between 'b2' and 'nml').
%
%   N_BURN is an optional number of extra initial burn-in samples (default:
%   0). This is only used if 'p' is included in OPTIONS.
%
%   RSTATE is optional. If specified, the random number generators will
%   be set to the given value (a scalar non-negative integer). This can
%   be used to create repeatable results. Default: 0.
%
% Outputs:
%
%   RES is a structure containing various test results:
%       bayes_dat: Bayes factor using Draw and Test
%       bayes_gibbs: Bayes factor using Gibbs Sampler
%       p: Bayesian p-value
%       DIC: DIC
%       f: frequentist p-value
%       nml: normalized maximum likelihood
%       nml_msg: nonempty if there is any warning messages for nml
%       b1_time: 'b1' computation time (in seconds)
%       b2_time: 'b2' computation time (in seconds)
%       p_time: 'p' computation time (in seconds)
%       f_time: 'f' computation time (in seconds)
%       nml_time: 'nml' computation time (in seconds)
%       time: overall time (in seconds)
%       params: input parameters for this analysis
%
t_all=tic;
if nargin<9
    N_burn = 0;
end
if nargin<10
    rstate = 0;
end

res=[];
res.params.name='binom_test';
res.params.m=m;
res.params.A=A;
res.params.B=B;
res.params.Aeq=Aeq;
res.params.Beq=Beq;
res.params.ineq_idx=ineq_idx;
res.params.options=options;
res.params.N_actual=N_actual;
res.params.N_burn=N_burn;
res.params.rstate=rstate;

n=size(m,1); %dimension

if ismember('b1',options) || ismember('B1',options)
    t_this=tic;
    res.bayes_dat=bayes_factor_draw_and_test(m,A,B,N_actual,rstate);
    res.b1_time=toc(t_this);
end
if ismember('b2',options) || ismember('B2',options)
    t_this=tic;
    res.bayes_gibbs=bayes_factor_gibbs(m,A,B,Aeq,Beq,ineq_idx,N_actual,rstate);
    res.b2_time=toc(t_this);
end
if ismember('p',options) || ismember('P',options)
    t_this=tic;
    [p,D]=bayes_p_dic(m,A,B,Aeq,Beq,ineq_idx,N_actual,N_burn,rstate);
    res.p=p;
    res.DIC=D.DIC;
    res.p_time=toc(t_this);
end
if ismember('f',options) || ismember('F',options)
    t_this=tic;
    [~,~,~,p]=mult_con(mat2cell(m,ones(n,1),2),A,B,N_actual,rstate);
    res.f=p;
    res.f_time=toc(t_this);
end
if ismember('nml',options) || ismember('NML',options)
    t_this=tic;
    [res.nml,res.nml_msg]=compute_nml(mat2cell(m,ones(n,1),2),A,B,Aeq,Beq,N_actual,rstate);
    res.nml_time=toc(t_this);
end

res.time=toc(t_all);
