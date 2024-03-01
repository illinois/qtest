function res=freq_test_super(m,V,lambda,N,rstate,cache)
%FREQ_TEST_SUPER performs theory-level frequentist test for the
%supermajority probability specification.
%   RES=freq_test_super(M,V,LAMBDA,N,RSTATE)
%   
%   M is the data matrix, where each row gives the outcome of a binomial
%   test. For example, for a 3-dimensional case, with 20 observations per
%   dimensions, M could be [8,12; 7,13; 11,9]
%
%   V is a vertex matrix, where each row corresponds to one vertex. The
%   vertex coordinates can be anywhere from 0 to 1. An example set of
%   vertices in 3-dimensional space: [1,0,1; 1,1,0.5; 0.1,0.1,0.1]
%
%   LAMBDA is the supermajority level. It should be from 0.5 to 1. If
%   LAMBDA is a scalar then all vertices use this same level. Otherwise,
%   LAMBDA can be a vector whose length equals the number of vertices,
%   and each component specifies the level for the corresponding vertex.
%
%   N (optional) is the number of iterations for the Silvapulle algorithm.
%   The default value is 10,000.
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
%       p: p-value of each vertex
%       p_cached: 1 if cached result is used
%       p_time: computation time (in seconds)
%   Theory-level results:
%       max_p: maximum p-value over all vertices
%       time: overall time (in seconds)
%       params: input parameters for this analysis
%
t_all=tic;
if nargin<4
    N=10000;
end
if nargin<5
    rstate = 0;
end
if nargin<6
    cache=[];
end
if ~isempty(cache)
    if ~isa(cache,'QtestCache')
        cache=create_cache(cache);
    end
end

res=[];
res.params.name='freq_test_super';
res.params.m=m;
res.params.V=V;
res.params.lambda=lambda;
res.params.N=N;
res.params.rstate=rstate;

n=size(m,1); %dimension
n_vert=size(V,1);
A=[eye(n); -eye(n)];
%per vertex analysis
res.p=zeros(n_vert,1);
res.p_cached=zeros(n_vert,1,'uint8');
res.p_time=zeros(n_vert,1);
if length(lambda)==1
    lambda=ones(n_vert,1)*lambda;
end
for i=1:n_vert
    t_vert=tic;
    d=0.5*(1-lambda(i));
    ex_u=max(0,d-V(i,:));
    ex_l=max(0,V(i,:)+d-1);
    B=[min(1,V(i,:)+d+ex_u)'; -max(0,V(i,:)-d-ex_l)'];

    if isjava(cache)
        key=[cache.CID_F_P_SUPER; n; V(i,:)'; lambda(i); m(:); N; rstate];
        q=cache.query(key);
    else
        q=[];
    end
    if isempty(q)
        [~,~,~,p]=mult_con(mat2cell(m,ones(n,1),2),A,B,N,rstate);
        res.p(i)=p;
        if isjava(cache)
            cache.update(key,res.p(i));
        end
    else
        res.p(i)=q;
        res.p_cached(i)=1;
    end
    res.p_time(i)=toc(t_vert);
end
if isjava(cache)
    cache.sync_out();
end
res.max_p=max(res.p);
res.time=toc(t_all);
