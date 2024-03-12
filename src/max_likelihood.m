function [L,x,msg]=max_likelihood(m,A,b,Aeq,Beq,opt_tolerance)
%MAX_LIKELIHOOD computes the maximum likelihood for multinomial, linearly
%constrained model.
%   [L,X,MSG] = max_likelihood(M,A,B,AEQ,BEQ,OPT_TOL)
%
%   M contains the data. It has to be a cell array, where each cell 
%   corresponds to a multinomial random variable. Each cell is a row vector
%   containing the count for each category in the corresponding variable.
%   Example:
%      M = { [12,8]; [10,5,15] };
%   creates a binomial and a trinomial variable, with 20 and 30 observations
%   respectively.
%   Note that each vector of length k defines (k-1) parameters for the
%   corresponding distribution.
%
%   A is a matrix and B is a column vector, specifying the inequality
%   constraints in the form of AX <= B.
%   Note that X is formed by concatenating each parameter vector 
%   in the order specified in M.
%
%   AEQ and BEQ specify the optional equality constraints. By default they
%   are assumed empty.
%
%   OPT_TOL (optional) is a (positive scalar) upper bound for first-order
%   optimality measure when finding the maximum likelihood estimator. 
%   Smaller OPT_TOL ensures more accurate estimator but may not be
%   attained. The default value of 1e-10 should work fine.
%
% Outputs:
%   
%   L is the maximum likelihood.
%   X is the maximum likelihood solution (within the feasible region).
%   MSG contains warning messages (if any) that have been generated. It is
%   a cell array of strings:
%       'conv' - maximum-likelihood estimator failed to converge
%       
% Example (2 binomials):
%
%       M={ [5,5]; [6,4] }; 
%       A=[1,-1; 1,1; -1,0];
%       B=[0; 1; 0];
%       L=max_likelihood(M,A,B);
%

PRINT_MESSAGE=0;
msg=[];

if nargin>=6
    opt_tol=opt_tolerance;
else
    opt_tol=1e-10;
end
if nargin<5
    Aeq=[]; Beq=[];
end

q=get_q(m);

[eA,eB]=get_equality_constraints(m,q);
if ~isempty(Aeq)
    Aeq=[Aeq,zeros(size(Aeq,1),length(m))];
    eA=[eA; Aeq];
    eB=[eB; Beq];
end

if PRINT_MESSAGE
    fprintf('\nFinding maximum likelihood parameter...\n'); tic;
end

tol=1e-10; 
tolfun=opt_tol;
x=get_ext_q(m);

options=optimset('GradObj','on','LargeScale','off','Display','off', ...
    'Algorithm','interior-point', ...
    'tolfun',tolfun,'tolX',tol,'tolcon',tol);
[x,~,exitflag]=fmincon(@(x) neglog_L_fast(x,m),x, ...
    [A,zeros(size(A,1),length(m))],b,...
    eA,eB,ones(size(x))*1e-6,ones(size(x))*(1-1e-6),[],options);
if exitflag<=0
    if PRINT_MESSAGE
        disp(output.message);
    end
    L=[];
    x=[];
    msg{1+length(msg)}='conv';
    return;
end

x=x(1:length(q));

if PRINT_MESSAGE
    fprintf('...done. (%.2f secs)\n',toc);
    fprintf('ML parameter:\n');
    disp(x)
end

L=exp(-neglog_L(x,m));


function q=get_q(m)
tol=1e-6;
n=length(m);
q=[];
for i=1:n
    theta=m{i}/sum(m{i});
    if sum(theta<tol)>0 || sum(theta>1-tol)>0
        median=ones(1,length(theta))/length(theta);
        dir=median-theta;
        theta=theta+tol*dir/norm(dir);
    end
    q=[q, theta(1:(end-1))];
end

function q=get_ext_q(m)
tol=1e-6;
n=length(m);
q=[];
q2=zeros(1,n);
for i=1:n
    theta=m{i}/sum(m{i});
    if sum(theta<tol)>0 || sum(theta>1-tol)>0
        median=ones(1,length(theta))/length(theta);
        dir=median-theta;
        theta=theta+tol*dir/norm(dir);
    end
    q=[q, theta(1:(end-1))];
    q2(i)=theta(end);
end
q=[q,q2];

function [L,G]=neglog_L_fast(param_vec,m)
n=length(m);
param_len=length(param_vec)-n;
G=zeros(size(param_vec));
L=0;
st_idx=1;
for i=1:n
    ed_idx=st_idx+length(m{i})-2;
    param=param_vec([(st_idx:ed_idx),(param_len+i)]);
    
%     ll(i)=gammaln(sum(m{i})+1)-sum(gammaln(m{i}+1)) + ...
%         m{i}*log(param)';
    L=L - m{i}*log(param)';
    G([(st_idx:ed_idx),(param_len+i)])=-m{i}./param;
    st_idx=ed_idx+1;
end

function [L,G]=neglog_L(param_vec,m)
n=length(m);
G=zeros(size(param_vec));
ll=zeros(n,1);
st_idx=1;
for i=1:n
    ed_idx=st_idx+length(m{i})-2;
    theta=param_vec(st_idx:ed_idx);
    param=[theta,(1-sum(theta))];
    
    ll(i)=gammaln(sum(m{i})+1)-sum(gammaln(m{i}+1)) + ...
        m{i}*log(param)';
    G(st_idx:ed_idx)=-m{i}(1:(end-1))./param(1:(end-1)) + (m{i}(end)/param(end));
    st_idx=ed_idx+1;
end
L=-sum(ll);

function [A,B]=get_equality_constraints(m,q)
n=length(m);
param_len=length(q);
A=zeros(n,param_len+n);
B=ones(n,1);
s_idx=1;
for i=1:n
    e_idx=s_idx+length(m{i})-2;
    A(i,[(s_idx:e_idx),(param_len+i)])=1;
    s_idx=e_idx+1;
end
