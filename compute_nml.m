function [NML,msg]=compute_nml(m,A,b,Aeq,Beq,N,rstate,opt_tolerance)
%COMPUTE_NML computes the normalized maximum likelihood for multinomial,
%linearly constrained model.
%   [NML,MSG] = compute_nml(M,A,B,AEQ,BEQ,N,RSTATE,OPT_TOL)
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
%   N specifies the number of samples used to approximate the denominator.
%   If N is 0 then ALL possible datapoints will be used and the resulting
%   NML will be exact. The default value is 0.
%
%   RSTATE is optional. If specified, the random number generators will
%   be set to the given value (a scalar non-negative integer). This can
%   be used to create repeatable results.
%   
%   OPT_TOL (optional) is a (positive scalar) upper bound for first-order
%   optimality measure when finding the maximum likelihood estimator. 
%   Smaller OPT_TOL ensures more accurate estimator but may not be
%   attained. The default value of 1e-10 should work fine.
%
% Outputs:
%   
%   NML is the normalized maximum likelihood.
%   MSG contains warning messages (if any) that have been generated. It is
%   a cell array of strings:
%       'conv'  - maximum-likelihood estimator failed to converge for the
%                 numerator
%       'conv_d'- maximum-likelihood estimator failed to converge for some
%                 datapoints for the denominator
%       
% Example (2 binomials):
%
%       M={ [5,5]; [6,4] }; 
%       A=[1,-1; 1,1; -1,0];
%       B=[0; 1; 0];
%       NML=compute_nml(M,A,B);
%

msg=[];

if nargin>=8
    opt_tol=opt_tolerance;
else
    opt_tol=1e-10;
end
if nargin>=7
    rng(rstate);
end
if nargin<6
    N=0;
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

[nume,flag]=compute_L(length(q),m,A,b,eA,eB,opt_tol);
if flag>0
    msg{1+length(msg)}='conv';
end

%prepare combinations
[m_list,m_sum]=get_m_list(m);
if N==0
    m_idx=ones(1,length(m_sum));
else
    m_idx=ceil(rand(1,length(m_sum)).*m_sum);
end
flag=0;
count=0;
sum_L=0;
while 1
    [L,f]=compute_L(length(q),get_m(m_list,m_idx),A,b,eA,eB,opt_tol);
    sum_L=sum_L+L;
    flag=flag+f;
    count=count+1;
    if N>0
        if count>=N
            break;
        end
        m_idx=ceil(rand(1,length(m_sum)).*m_sum);
    else
        m_idx=inc_m_idx(m_sum,m_idx);
        if isempty(m_idx)
            break;
        end
    end
end
if flag>0
    msg{1+length(msg)}='conv_d';
end
NML=nume*(count/sum_L);

function [m_list,m_sum]=get_m_list(m)
n=length(m);
m_list=cell(n,1);
m_sum=zeros(1,n);
for i=1:n
    s=sum(m{i});
    len=length(m{i});
    z=nchoosek(1:(s+len-1),len-1);
    z=[zeros(size(z,1),1),z,(s+len)*ones(size(z,1),1)];
    m_list{i}=diff(z')'-1;
    m_sum(i)=size(m_list{i},1);
end

function m_idx=inc_m_idx(m_sum,m_idx)
n=length(m_idx);
for i=n:(-1):1
    if m_idx(i)<m_sum(i)
        m_idx(i)=m_idx(i)+1;
        return;
    end
    m_idx(i)=1;
end
m_idx=[];

function m=get_m(m_list,m_idx)
n=length(m_idx);
m=cell(n,1);
for i=1:n
    m{i}=m_list{i}(m_idx(i),:);
end

function [L,flag]=compute_L(len_q,m,A,b,eA,eB,opt_tol)
flag=0;
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
    flag=1;
end

x=x(1:len_q);
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
