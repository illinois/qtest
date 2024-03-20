function [p,D,bayes1,bayes2,sample]=bayesian_test(m,A,B,Aeq,Beq,ineq_idx,N_actual,N_burn,rstate,epsilon)
%BAYESIAN_TEST performs various Bayesian tests
%   [P,D,BAYES1,BAYES2,SAMPLE]=bayesian_test(M,A,B,AEQ,BEQ,INEQ_IDX,N_ACTUAL,N_BURN,RSTATE,EPSILON)
%   
%   M is the data matrix, where each row gives the outcome of a binomial
%   test. For example, for a 3-dimensional case, with 20 observations per
%   dimensions, M could be [8,12; 7,13; 11,9]
%
%   A, B, AEQ, BEQ, INEQ_IDX should be the corresponding output obtained
%   from porta_hull. In particular, A and B are the inequalities, while AEQ
%   and BEQ are the equalities. INEQ_IDX is the list of variables in the
%   inequalities.
%
%   N_ACTUAL is the actual number of samples used to perform the Bayesian
%   test.
%
%   N_BURN is an optional number of extra initial burn-in samples (default: 0).
%
%   RSTATE is optional. If specified, the random number generators will
%   be set to the given value (a scalar non-negative integer). This can
%   be used to create repeatable results.
%
%   EPSILON is optional. This is a value in the interval [0,0.5) such that
%   all likelihood for computing BAYES2 will be constrained to within
%   the interval [EPSILON,(1-EPSILON)]. Default is 0.
%
% Outputs:
%
%   P is the Bayes p-value.
%
%   D is a structure with 3 fields:
%     D.GOF  -  gives the goodness of fit (lack of) value
%     D.complexity  -  gives the complexity penalty
%     D.DIC  -  gives the DIC value
%
%   BAYES1 is the (unnormalized) Bayes factor computed with volume method.
%   Caution: must not be used for non-full-rank models!
%
%   BAYES2 is the (unnormalized) Bayes factor computed with direct method.
%   Caution: low-magnitude numbers -- use with care!
%
%   SAMPLE is a matrix containing the Gibbs samples for the posterior, one
%   sample per row.
%

if nargin<8
    N_burn=0;
end
if nargin>=9
    rng(rstate);
end
if nargin>=10
    if epsilon<0 || epsilon>=0.5
        epsilon=0;
    end
else
    epsilon = 0;
end

N=N_actual+N_burn;
p=[];
D=[];
bayes1=[];
bayes2=[];
sample=[];
%find valid starting point
%options_lin=optimset('LargeScale','off','Simplex','off','Display','off');
options_lin=optimset('LargeScale','on','Display','off');
[valid,lambda,exitflag,output]=linprog(ones(1,size(A,2)),A,B,Aeq,Beq, ...
    [],[],options_lin);
if exitflag<=0
    %error('Cannot find a feasible point!');
    return;
end
x=valid';
num_dim=length(x);
sample=zeros(N,num_dim);

if size(ineq_idx,1)>1
    ineq_idx=ineq_idx';
end
%prepare the square matrix for equalities
eq_idx=sort(setdiff(1:num_dim,ineq_idx));
if isempty(Aeq)
    Aeq=zeros(0,num_dim);
    Beq=zeros(0,1);
end
Aeq_square=Aeq(:,eq_idx);
Aeq_ineq=Aeq(:,ineq_idx);
%prepare individual inequalities matrices
pos_A=cell(num_dim,1); pos_A_j=cell(num_dim,1);
pos_B=cell(num_dim,1);
neg_A=cell(num_dim,1); neg_A_j=cell(num_dim,1);
neg_B=cell(num_dim,1);
for j=ineq_idx
    pos_ineq=find(A(:,j)>0);
    pos_A{j}=A(pos_ineq,[(1:(j-1)),((j+1):num_dim)]);
    pos_A_j{j}=A(pos_ineq,j);
    pos_B{j}=B(pos_ineq);
    neg_ineq=find(A(:,j)<0);
    neg_A{j}=A(neg_ineq,[(1:(j-1)),((j+1):num_dim)]);
    neg_A_j{j}=A(neg_ineq,j);
    neg_B{j}=B(neg_ineq);
end
%Gibbs sampling
warning off 'stats:betainv:NoConvergence' %turn off betainv warning
for i=1:N
    for j=ineq_idx
        x_j=x([(1:(j-1)),((j+1):num_dim)])';
        LUB = min((pos_B{j}-pos_A{j}*x_j)./pos_A_j{j});
        GLB = max((neg_A{j}*x_j-neg_B{j})./(-neg_A_j{j}));
        a=m(j,1)+1;
        b=m(j,2)+1;
        try
            x(j)=betainv(betacdf(GLB,a,b)+rand*(betacdf(LUB,a,b)-betacdf(GLB,a,b)),a,b);
        catch
            x(j)=betainv(betacdf(GLB,a,b),a,b); %boundary case, just use the lower bound
        end
            
        if ~isempty(Aeq)
            x_ineq=x(ineq_idx)';
            x_eq = Aeq_square \ (Beq - Aeq_ineq*x_ineq);
            x(eq_idx) = x_eq';
        end
    end
    sample(i,:)=x;
end
sample = sample((N_burn+1):end,:); %remove burn-ins
N=N_actual;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% p-value

m_total=ones(N,1)*(sum(m,2)');
n_prd = sample.*m_total + 0.5; % .5 a continuity correction
n_sim = binornd(m_total,sample) + 0.5;
n_obs = ones(N,1)*(m(:,1)') + 0.5;
chisqr_sim = sum((n_sim-n_prd).^2./n_prd,2);
chisqr_obs = sum((n_obs-n_prd).^2./n_prd,2);
p = sum(chisqr_sim>=chisqr_obs)/N;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIC

%compute thetabar: the average value of theta across iterations of Gibbs
thetabar=mean(sample,1);
%compute deviance discrepancy functionv(DDF) of thetabar := "DThetaBar"
m_total=sum(m,2)';
n = m(:,1)';
DThetaBar = 2*sum( n.*log( (n+0.5)./(m_total.*thetabar+0.5) ) + ...
    (m_total-n).*log( (m_total-n+0.5)./(m_total-m_total.*thetabar+0.5) ));
%compute the DDF of each iteration of Gibbs, and then average them
m_total=ones(N,1)*m_total;
n = ones(N,1)*n;
DBarTheta = mean(2*sum( n.*log( (n+0.5)./(m_total.*sample+0.5) ) + ...
    (m_total-n).*log( (m_total-n+0.5)./(m_total-m_total.*sample+0.5) ), 2));

D.GOF=DThetaBar; % (lack of) Goodness of Fit
D.complexity = 2*(DBarTheta-DThetaBar); %Penalty assessed for less complex models
D.DIC= D.GOF + D.complexity; %DIC

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bayes factor (volume method)
% Caution: must not be used for non-full-rank models!!
%
prior_sample = rand(N,num_dim)';
post_sample = betainv(rand(N,num_dim),ones(N,1)*(m(:,1)'+1),ones(N,1)*(m(:,2)'+1))';
prior_vol = sum( (sum(A*prior_sample > B*ones(1,N),1) + sum(Aeq*prior_sample ~= Beq*ones(1,N),1))==0 )/N;
post_vol = sum( (sum(A*post_sample > B*ones(1,N),1) + sum(Aeq*post_sample ~= Beq*ones(1,N),1))==0 )/N;
bayes1 = post_vol/prior_vol;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bayes factor (direct method)
% Caution: small magnitudes!
%
x=valid';
%Gibbs sampling (no need for burning in)
prior_sample = zeros(N,num_dim);
for i=1:N
    for j=ineq_idx
        x_j=x([(1:(j-1)),((j+1):num_dim)])';
        LUB = min((pos_B{j}-pos_A{j}*x_j)./pos_A_j{j});
        GLB = max((neg_A{j}*x_j-neg_B{j})./(-neg_A_j{j}));
        x(j)=GLB + rand*(LUB-GLB);
            
        if ~isempty(Aeq)
            x_ineq=x(ineq_idx)';
            x_eq = Aeq_square \ (Beq - Aeq_ineq*x_ineq);
            x(eq_idx) = x_eq';
        end
    end
    prior_sample(i,:)=x;
end
prior_sample=max(min(prior_sample,1-epsilon),epsilon);
bayes2 = mean(prod(prior_sample.^(ones(N,1)*(m(:,1)')),2).* ...
    prod((1-prior_sample).^(ones(N,1)*(m(:,2)')),2));
