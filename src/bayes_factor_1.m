function bayes1=bayes_factor_1(m,A,B,N_actual,rstate)
%BAYES_FACTOR_1 computes the Bayes factor using the draw-and-test method
%   BAYES1=bayes_factor_1(M,A,B,N,RSTATE)
%   
%   M is the data matrix, where each row gives the outcome of a binomial
%   test. For example, for a 3-dimensional case, with 20 observations per
%   dimensions, M could be [8,12; 7,13; 11,9]
%
%   A and B are the inequalities that define the polytope, i.e. Ax<=B. Note
%   that this method assumes full-dimensional polytopes so no equalities
%   are allowed.
%
%   N is the number of samples used to perform the Bayesian test.
%
%   RSTATE is optional. If specified, the random number generators will
%   be set to the given value (a scalar non-negative integer). This can
%   be used to create repeatable results.
%
% Outputs:
%
%   BAYES1 is the Bayes factor computed with volume method.
%   Caution: must not be used for non-full-rank models!
%

if nargin>=5
    rng(rstate);
end
num_dim = size(m,1);

CHUNK_SIZE=1e6;
n_chunks=max(1,floor(N_actual/CHUNK_SIZE));
prior_vol=0;
post_vol=0;
for iter=1:n_chunks
    if iter==n_chunks
        N=N_actual-(iter-1)*CHUNK_SIZE;
    else
        N=CHUNK_SIZE;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Bayes factor (volume method)
    % Caution: must not be used for non-full-rank models!!
    %
    prior_sample = rand(N,num_dim)';
    post_sample = betainv(rand(N,num_dim),ones(N,1)*(m(:,1)'+1),ones(N,1)*(m(:,2)'+1))';
    prior_vol = prior_vol + sum( sum(A*prior_sample > B*ones(1,N),1) ==0 );
    post_vol = post_vol + sum( sum(A*post_sample > B*ones(1,N),1) ==0 );
end
prior_vol = prior_vol/N_actual;
post_vol = post_vol/N_actual;
bayes1 = post_vol/prior_vol;
