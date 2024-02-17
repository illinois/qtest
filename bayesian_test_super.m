function res=bayesian_test_super(m,V,W,lambda,options,N_actual,N_burn,rstate,cache)
%BAYESIAN_TEST_SUPER performs theory-level Bayesian test for the
%supermajority probability specification.
%   RES=bayesian_test_super(M,V,W,LAMBDA,OPTIONS,N_ACTUAL,N_BURN,RSTATE)
%   
%   M is the data matrix, where each row gives the outcome of a binomial
%   test. For example, for a 3-dimensional case, with 20 observations per
%   dimensions, M could be [8,12; 7,13; 11,9]
%
%   V is a vertex matrix, where each row corresponds to one vertex. The
%   vertex coordinates can be anywhere from 0 to 1. An example set of
%   vertices in 3-dimensional space: [1,0,1; 1,1,0.5; 0.1,0.1,0.1]
%
%   W is a prior weight vector. It should be empty if the "natural"
%   volume-based prior is to be used. If it is non-empty, its length must
%   equal the number of vertices, where each component specifies the weight
%   given to the corresponding vertex.
%
%   LAMBDA is the supermajority level. It should be from 0.5 to 1. If
%   LAMBDA is a scalar then all vertices use this same level. Otherwise,
%   LAMBDA can be a vector whose length equals the number of vertices,
%   and each component specifies the level for the corresponding vertex.
%
%   OPTIONS is a cell array specifying the tests to be run. Each array
%   element should be one of the following strings:
%       'b1' - indicates that Bayes factor 1 should be computed
%       'b2' - indicates that Bayes factor 2 should be computed
%       'p'  - indicates that Bayesian p-value and DIC should be computed
%   Example: to compute Bayesian p and Bayes factor 2, OPTIONS should be
%       { 'p', 'b2' }
%   Note: the exact Bayes factor will always be computed so OPTIONS can be
%   left empty {}.
%
%   N_ACTUAL is the actual number of samples used to perform the Bayesian
%   test for each vertex and each test that requires sampling.
%
%   N_BURN is an optional number of extra initial burn-in samples (default:
%   0). This is only used if 'p' is included in OPTIONS.
%
%   RSTATE is optional. If specified, the random number generators will
%   be set to the given value (a scalar non-negative integer). This can
%   be used to create repeatable results. Default: 0.
%
%   CACHE is optional. It can either be a path name for the cache file, or
%   an existing cache object. If a path name is specified and the file does
%   not exist it will be created as a new cache file.
%
% Outputs:
%
%   RES is a structure containing various test results, including results
%   for individual vertices and theory-level results.
%   Vertex-level results:
%       bayes: exact Bayes factor of each vertex
%       bayes1: Bayes factor 1 of each vertex
%       bayes2: Bayes factor 2 of each vertex
%       p: Bayesian p-value of each vertex
%       DIC: DIC of each vertex
%       vol: prior volume of each vertex
%       post_vol: posterior "volume" of each vertex
%       b1_cached: 1 if cached result is used for 'b1'
%       b2_cached: 1 if cached result is used for 'b2'
%       p_cached: 1 if cached result is used for 'p'
%       b1_time: 'b1' computation time (in seconds)
%       b2_time: 'b2' computation time (in seconds)
%       p_time: 'p' computation time (in seconds)
%   Theory-level results:
%       W_bayes: exact Bayes factor, weighted using either the prior volume
%       (when W is empty) or the given weights in W
%       simple_avg_bayes: exact Bayes factor using simple average
%       W_bayes1, W_bayes2, simple_avg_bayes1, simple_avg_bayes2:
%           these are the respective results for Bayes factor 1 and 2
%       avg_p: Bayesian p-value, combined using the posterior volume
%       avg_DIC: DIC, combined using the posterior volume
%       time: overall time (in seconds)
%       params: input parameters for this analysis
%
t_all=tic;
if nargin<7
    N_burn = 0;
end
if nargin<8
    rstate = 0;
end
if nargin<9
    cache=[];
end
if ~isempty(cache)
    if ~isa(cache,'QtestCache')
        cache=create_cache(cache);
    end
end

res=[];
res.params.name='bayesian_test_super';
res.params.m=m;
res.params.V=V;
res.params.W=W;
res.params.lambda=lambda;
res.params.options=options;
res.params.N_actual=N_actual;
res.params.N_burn=N_burn;
res.params.rstate=rstate;

n=size(m,1); %dimension
n_vert=size(V,1);
A=[eye(n); -eye(n)];
Aeq=zeros(0,n);
Beq=zeros(0,1);
ineq_idx=1:n;
%per vertex analysis
res.bayes=zeros(n_vert,1);
if ismember('b1',options) || ismember('B1',options)
    res.bayes1=zeros(n_vert,1);
    res.b1_cached=zeros(n_vert,1,'uint8');
    res.b1_time=zeros(n_vert,1);
else
    res.bayes1=[];
end
if ismember('b2',options) || ismember('B2',options)
    res.bayes2=zeros(n_vert,1);
    res.b2_cached=zeros(n_vert,1,'uint8');
    res.b2_time=zeros(n_vert,1);
else
    res.bayes2=[];
end
if ismember('p',options) || ismember('P',options)
    res.p=zeros(n_vert,1);
    res.DIC=zeros(n_vert,1);
    res.p_cached=zeros(n_vert,1,'uint8');
    res.p_time=zeros(n_vert,1);
    thetabar=zeros(1,n);
    DBarTheta=0;
else
    res.p=[];
    res.DIC=[];
end
res.vol=zeros(n_vert,1);
res.post_vol=zeros(n_vert,1);
if length(lambda)==1
    lambda=ones(n_vert,1)*lambda;
end
for i=1:n_vert
    d=0.5*(1-lambda(i));
    ex_u=max(0,d-V(i,:));
    ex_l=max(0,V(i,:)+d-1);
    B=[min(1,V(i,:)+d+ex_u)'; -max(0,V(i,:)-d-ex_l)'];
    res.vol(i)=prod(B(1:n)+B((n+1):end));
    res.bayes(i)=bayes_factor_super(m,V(i,:),lambda(i));
    res.post_vol(i)=res.bayes(i)*res.vol(i);
    if ~isempty(res.bayes1)
        t_vert = tic;
        if isjava(cache)
            key=[cache.CID_B1_SUPER; n; V(i,:)'; lambda(i); m(:); N_actual; rstate];
            q=cache.query(key);
        else
            q=[];
        end
        if isempty(q)
            res.bayes1(i)=bayes_factor_1(m,A,B,N_actual,rstate);
            if isjava(cache)
                cache.update(key,res.bayes1(i));
            end
        else
            res.bayes1(i)=q;
            res.b1_cached(i)=1;
        end
        res.b1_time(i)=toc(t_vert);
    end
    if ~isempty(res.bayes2)
        t_vert = tic;
        if isjava(cache)
            key=[cache.CID_B2_SUPER; n; V(i,:)'; lambda(i); m(:); N_actual; rstate];
            q=cache.query(key);
        else
            q=[];
        end
        if isempty(q)
            res.bayes2(i)=bayes_factor_2_Dan_v2(m,A,B,Aeq,Beq,ineq_idx,N_actual,rstate);
            if isjava(cache)
                cache.update(key,res.bayes2(i));
            end
        else
            res.bayes2(i)=q;
            res.b2_cached(i)=1;
        end
        res.b2_time(i)=toc(t_vert);
    end
    if ~isempty(res.p)
        t_vert = tic;
        if isjava(cache)
            key=[cache.CID_B_P_SUPER; n; V(i,:)'; lambda(i); m(:); N_actual; N_burn; rstate];
            q=cache.query(key);
        else
            q=[];
        end
        if isempty(q)
            [p,D]=bayes_p_dic(m,A,B,Aeq,Beq,ineq_idx,N_actual,N_burn,rstate);
            res.p(i)=p;
            res.DIC(i)=D.DIC;
            thetabar=thetabar+res.post_vol(i)*D.thetabar;
            DBarTheta=DBarTheta+res.post_vol(i)*(D.GOF+0.5*D.complexity);
            if isjava(cache)
                cache.update(key,[p; D.DIC; D.GOF; D.complexity; D.thetabar']);
            end
        else
            res.p(i)=q(1);
            res.DIC(i)=q(2);
            res.p_cached(i)=1;
            thetabar=thetabar+res.post_vol(i)*(q(5:end)');
            DBarTheta=DBarTheta+res.post_vol(i)*(q(3)+0.5*q(4));
        end
        res.p_time(i)=toc(t_vert);
    end
end
if length(W)~=n_vert
    W=res.vol';
else
    if iscolumn(W)
        W=W';
    end
end
if isjava(cache)
    cache.sync_out();
end
vol_sum=sum(W);
res.W_bayes=(W*res.bayes)/vol_sum;
res.simple_avg_bayes=sum(res.bayes)/n_vert;
if ~isempty(res.bayes1)
    res.W_bayes1=(W*res.bayes1)/vol_sum;
    res.simple_avg_bayes1=sum(res.bayes1)/n_vert;
end
if ~isempty(res.bayes2)
    res.W_bayes2=(W*res.bayes2)/vol_sum;
    res.simple_avg_bayes2=sum(res.bayes2)/n_vert;
end
if ~isempty(res.p)
    vol_sum=sum(res.post_vol);
    res.avg_p=(res.post_vol'*res.p)/vol_sum;
    
    thetabar=thetabar/vol_sum;
    DBarTheta=DBarTheta/vol_sum;
    m_total=sum(m,2)';
    m1 = m(:,1)';
    DThetaBar = 2*sum( m1.*log( (m1+0.5)./(m_total.*thetabar+0.5) ) + ...
        (m_total-m1).*log( (m_total-m1+0.5)./(m_total-m_total.*thetabar+0.5) ));
    res.avg_DIC=2*DBarTheta-DThetaBar;
end
res.time=toc(t_all);
