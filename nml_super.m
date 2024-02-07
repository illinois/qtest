function res=nml_super(m,V,lambda,N,rstate)
%NML_SUPER computes the Normalized Maximum Likelihood for the
%supermajority probability specification.
%   RES=nml_super(M,V,LAMBDA,N,RSTATE)
%   
%   M is the data matrix, where each row gives the outcome of a binomial
%   test. For example, for a 3-dimensional case, with 20 observations per
%   dimensions, M could be [8,12; 7,13; 11,9].
%   Note: it is possible for each dimension to have a different number of
%   observations, e.g. [8,12; 2,8; 5,10].
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
%   N specifies the number of samples used to approximate the denominator.
%   If N is 0 then ALL possible datapoints will be used and the resulting
%   NML will be exact. The default value is 0.
%
%   RSTATE is optional. If specified, the random number generators will
%   be set to the given value (a scalar non-negative integer). This can
%   be used to create repeatable results. Default: 0.
%   Note: for repeated tests, RSTATE should be explicitly set instead of
%   using the default (since otherwise all results would be the same, i.e.
%   from RSTATE=0).
%
% Outputs:
%
%   RES is a structure containing various test results, including results
%   for individual vertices and theory-level results.
%   Vertex-level results:
%       v_nml: nml of each vertex as an individual model
%   Theory-level results:
%       nml: nml of the union of all vertices
%       time: overall time (in seconds)
%       params: input parameters for this analysis
%
t_all=tic;
if nargin<4
    N=0;
end
if nargin<5
    rstate = 0;
end
rng(rstate);

res=[];
res.params.name='nml_super';
res.params.m=m;
res.params.V=V;
res.params.lambda=lambda;
res.params.N=N;
res.params.rstate=rstate;

n=size(m,1); %dimension
n_vert=size(V,1);
if length(lambda)==1
    lambda=ones(n_vert,1)*lambda;
end
v_nume=zeros(n_vert,1);
res.v_nml=zeros(n_vert,1);
res.nml=0;

m_sum=sum(m,2);

%numerator
q=m./(m_sum*ones(1,2));
ll_const=gammaln(1+m_sum) - gammaln(1+m(:,1)) - gammaln(m(:,2)+1);
for i=1:n_vert
    d=0.5*(1-lambda(i));
    ex_u=max(0,d-V(i,:));
    ex_l=max(0,V(i,:)+d-1);
    v_upper=min(1-1e-6,V(i,:)+d+ex_u)';
    v_lower=max(1e-6,V(i,:)-d-ex_l)';
    q_ml=max(v_lower,min(v_upper,q(:,1)));
    v_nume(i)=exp(sum(ll_const+ m(:,1).*log(q_ml) + m(:,2).*log(1-q_ml)));
end
nume=max(v_nume);
%denominator
if N==0
    m_idx=zeros(length(m_sum),1);
    N_all=0;
    while 1
        q=m_idx./m_sum;
        ll_const=gammaln(1+m_sum) - gammaln(1+m_idx) - gammaln(m_sum-m_idx+1);
        LL=zeros(n_vert,1);
        for i=1:n_vert
            d=0.5*(1-lambda(i));
            ex_u=max(0,d-V(i,:));
            ex_l=max(0,V(i,:)+d-1);
            v_upper=min(1-1e-6,V(i,:)+d+ex_u)';
            v_lower=max(1e-6,V(i,:)-d-ex_l)';
            q_ml=max(v_lower,min(v_upper,q));
            
            LL(i) = sum(ll_const + m_idx.*log(q_ml) + (m_sum-m_idx).*log(1-q_ml));
            res.v_nml(i)=res.v_nml(i) + exp(LL(i));
        end
        res.nml=res.nml + exp(max(LL));
        N_all=N_all+1;
        m_idx=inc_m_idx(m_sum,m_idx);
        if isempty(m_idx)
            break;
        end
    end
    res.v_nml=N_all*v_nume./res.v_nml;
    res.nml=N_all*nume/res.nml;
else
    CHUNK_SIZE=max(10,ceil(1e7/n/n_vert));
    N_all=N;
    n_chunks=max(1,floor(N_all/CHUNK_SIZE));
    for iter=1:n_chunks
        if iter==n_chunks
            N=N_all-(iter-1)*CHUNK_SIZE;
        else
            N=CHUNK_SIZE;
        end
        m_sum_N=m_sum*ones(1,N);
        m_N=floor(rand(n,N).*(1+m_sum_N));
        q=m_N./m_sum_N;
        ll_const=gammaln(1+m_sum_N) - gammaln(1+m_N) - gammaln(m_sum_N-m_N+1);

        LL=zeros(n_vert,N);
        for i=1:n_vert
            d=0.5*(1-lambda(i));
            ex_u=max(0,d-V(i,:));
            ex_l=max(0,V(i,:)+d-1);
            v_upper=(min(1-1e-6,V(i,:)+d+ex_u)')*ones(1,N);
            v_lower=(max(1e-6,V(i,:)-d-ex_l)')*ones(1,N);
            
            q_ml=max(v_lower,min(v_upper,q));
            LL(i,:) = sum(ll_const + m_N.*log(q_ml) + (m_sum_N-m_N).*log(1-q_ml),1);

            res.v_nml(i)=res.v_nml(i) + sum(exp(LL(i,:)));
        end
        res.nml=res.nml+ sum(exp(max(LL,[],1)));
    end
    res.v_nml=N_all*v_nume./res.v_nml;
    res.nml=N_all*nume/res.nml;
end

res.time=toc(t_all);



function m_idx=inc_m_idx(m_sum,m_idx)
n=length(m_idx);
for i=n:(-1):1
    if m_idx(i)<m_sum(i)
        m_idx(i)=m_idx(i)+1;
        return;
    end
    m_idx(i)=0;
end
m_idx=[];

