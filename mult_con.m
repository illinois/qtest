function [x,L,w,p,msg,n_done]=mult_con(m,A,b,N,rstate,opt_tolerance,progress)
%MULT_CON multinomial model with linear inequality constraints
%   [X,L,W,P,MSG] = mult_con(M,A,B,N,RSTATE,OPT_TOL)
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
%   N (optional) is the number of iterations for the Silvapulle algorithm.
%   The default value is 10,000.
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
%   PROGRESS is optional. It should be a non-empty text string for progress bar.
%
% Outputs:
%   
%   X is the maximum likelihood solution (within the feasible region).
%   
%   L is the log-likelihood ratio (i.e. the test statistic).
%
%   W is a vector containing the Chi-bar squared weights.
%   
%   P is the p value for the hypothesis test.
%
%   MSG contains warning messages (if any) that have been generated. It is
%   a cell array of strings:
%       'conv' - maximum-likelihood estimator failed to converge
%       'dim'  - non-full rank polytope warning
%       
%
% Example (2 binomials):
%
%       M={ [5,5]; [6,4] }; 
%       A=[1,-1; 1,1; -1,0];
%       B=[0; 1; 0];
%       [X,L,W,P]=mult_con(M,A,B);
%

PRINT_MESSAGE=0;
msg=[];
n_done=[0,0];

if nargin>=6
    opt_tol=opt_tolerance;
else
    opt_tol=1e-10;
end
if nargin>=5
    rng(rstate,'twister');
end
if nargin<4
    N=10000;
end
if nargin<7
    progress=[];
end

%test trivial condition
q=get_q(m);
if isempty(find(A*q'>b,1))
    if PRINT_MESSAGE
        fprintf('\nFinding maximum likelihood parameter...\n');
        fprintf('All inequalities satisfied!\n');
        fprintf('ML parameter:\n');
        disp(q)
    end
    x=q; L=0; w=[]; p=1; 
    return;
end

[eA,eB]=get_equality_constraints(m,q);

if PRINT_MESSAGE
    fprintf('\nFinding maximum likelihood parameter...\n'); tic;
end

tol=1e-10; 
tolfun=opt_tol;
x=get_ext_q(m);

options=optimset('GradObj','on','LargeScale','off','Display','off', ...
    'Algorithm','interior-point', ...
    'tolfun',tolfun,'tolX',tol,'tolcon',tol);
[x,fval,exitflag,output,lambda]=fmincon(@(x) neglog_L_fast(x,m),x, ...
    [A,zeros(size(A,1),length(m))],b,...
    eA,eB,ones(size(x))*1e-6,ones(size(x))*(1-1e-6),[],options);
if exitflag<=0
    if PRINT_MESSAGE
        disp(output.message);
    end
    x=[]; L=[]; w=[]; p=[];
    msg{1+length(msg)}='conv';
    return;
end

x=x(1:length(q));

if PRINT_MESSAGE
    fprintf('...done. (%.2f secs)\n',toc);
    fprintf('ML parameter:\n');
    disp(x)
end

%A=A(abs(b-A*x')<1e-6,:)';
A=A(abs(lambda.ineqlin)>1e-6,:)';
if PRINT_MESSAGE
    fprintf('Number of facet-defining inequalities: %i\n',size(A,2));
end
if size(A,2)~=rank(A)
    %fprintf('\nWARNING: non-full rank polyhedral cone!\n\n');
    msg{1+length(msg)}='dim';
end
A_lambda = abs(lambda.ineqlin(abs(lambda.ineqlin)>1e-6));
while size(A,2)>rank(A)
    %eliminate smallest lambda
    [~,a_idx]=min(A_lambda);
    A(:,a_idx)=[];
    A_lambda(a_idx)=[];
end
fi=get_fi(x,m);
ifi=inv(fi);
[pA,pB]=get_polar_cone(A,ifi);

if PRINT_MESSAGE
    fprintf('Neg Log Likelihood: %g\n',neglog_L(x,m));
end

q=get_q(m);
[L2,G]=neglog_L(q,m);
[L3,G]=neglog_L(x,m);
L=2*(-L2)-2*(-L3);
if PRINT_MESSAGE
    fprintf('(Neg Log Likelihood: %g <> %g)\n',L2,L3);
    fprintf('Log-likelihood ratio: %g\n\n',L);
end

if PRINT_MESSAGE
    fprintf('Finding Chi-bar squared weights...\n'); tic;
end
[w,n_done]=do_silva(pA,pB,fi,ifi,N,progress);
w=w';
if PRINT_MESSAGE
    fprintf('...done. (%.2f secs)\n',toc);
    fprintf('Weights: \n');
    disp(w)
end

chisum=w(1)+w(2:end)*chi2cdf(L,1:(length(w)-1))';
p=1-chisum;
if PRINT_MESSAGE
    fprintf('p = %g\n',p);
end


function [w,n_done]=do_silva(A,B,fi,ifi,N_actual,progress)
k=size(A,2);
m1=size(A,1); m2=size(B,1);
%s_count=zeros(k+1,1); %s_count=zeros(k,1);
s_count=cell(1,N_actual);
% for i=1:N
%     s_count{i}=zeros(k+1,1);
% end

%silence the rank deficient warning
wmode = warning('off', 'MATLAB:rankDeficientMatrix');

%options=optimset('LargeScale','off','Algorithm','active-set','Display','off');
options=optimset('Algorithm','interior-point-convex','Display','off');
tic
if ~isempty(progress)
    h_wait=waitbar(0,sprintf('Sampling %d/%d',0,N_actual),'WindowStyle','modal','Name', ...
        progress,'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(h_wait,'canceling',0);
end
CHUNK_SIZE=200;
n_chunks=max(1,floor(N_actual/CHUNK_SIZE));
n_done=[0,0];
for iter=1:n_chunks
    if iter==n_chunks
        N=N_actual-(iter-1)*CHUNK_SIZE;
    else
        N=CHUNK_SIZE;
    end
    for i=1:N %parfor is possible
        z=mvnrnd(zeros(1,k),ifi)';
        [x,fval,exitflag,output,lambda]=quadprog(fi,-fi'*z,A,zeros(m1,1),B,zeros(m2,1),[],[],[],options);
        %     face=[];
        %     for j=1:m1
        %         if abs(A(j,:)*x)<1e-6
        %             face=[face; A(j,:)];
        %         end
        %     end
        %     s=size(null([face;B]),2);
        
        face=[A(abs(lambda.ineqlin)>1e-6,:); B];
        %s=size(null(face),2);
        s=size(face,2)-rank(face,1e-12);
        
        %s_count(s+1)=s_count(s+1)+1;
        s_count{n_done(1)+i}=zeros(k+1,1);
        s_count{n_done(1)+i}(s+1)=1;
        
        
        %     %%%DEBUG
        %     x1=x+[0.45;0.55];
        %     z1=z+[0.45;0.55];
        %     switch s
        %         case 1
        %             plot(x1(1),x1(2),'c*');
        %             plot(z1(1),z1(2),'co');
        %         case 2
        %             plot(x1(1),x1(2),'g*');
        %             plot(z1(1),z1(2),'go');
        %         case 0
        %             plot(z1(1),z1(2),'ko');
        %             plot(x1(1),x1(2),'k*');
        %     end
        %     %%%END DEBUG
        
        %     %%%DEBUG
        %     x1=x+[0.5;0.4;0.4];
        %     z1=z+[0.5;0.4;0.4];
        %     switch s
        %         case 1
        %             %plot3(x1(1),x1(2),x1(3),'c*');
        %             plot3(z1(1),z1(2),z1(3),'co');
        %             %plot3([x1(1),z1(1)],[x1(2),z1(2)],[x1(3),z1(3)],'c-');
        %         case 2
        %             %plot3(x1(1),x1(2),x1(3),'g*');
        %             plot3(z1(1),z1(2),z1(3),'go');
        %             %plot3([x1(1),z1(1)],[x1(2),z1(2)],[x1(3),z1(3)],'g-');
        %         case 3
        %             %plot3(x1(1),x1(2),x1(3),'m*');
        %             plot3(z1(1),z1(2),z1(3),'mo');
        %             %plot3([x1(1),z1(1)],[x1(2),z1(2)],[x1(3),z1(3)],'m-');
        %         case 0
        %             %plot3(x1(1),x1(2),x1(3),'k*');
        %             plot3(z1(1),z1(2),z1(3),'ko');
        %             %plot3([x1(1),z1(1)],[x1(2),z1(2)],[x1(3),z1(3)],'k-');
        %     end
        %     %%%END DEBUG
    end
    n_done=[(iter-1)*CHUNK_SIZE+N, 0];
    if ~isempty(progress)
        waitbar(n_done(1)/N_actual,h_wait,sprintf('Sampling %d/%d (Elapsed: %.0f secs)',n_done(1),N_actual,toc));
        if getappdata(h_wait,'canceling')
            n_done(2)=1;
            break;
        end
    end
end
if ~isempty(progress)
    delete(h_wait);
end
%fprintf('quad_prog: %g secs\n',toc);
s_count=sum(cell2mat(s_count),2);
w=s_count/sum(s_count);
%reset warning
warning(wmode);

function [pA,pB]=get_polar_cone(A,W)
%note: assume A non-redundant full rank (=>must be more rows than cols)
Ga=pinv(A);
pA=-Ga*W;
pB_0=eye(size(A,1))-A*Ga;
if norm(pB_0)<1e-14 && size(A,2)==size(A,1)
    pB=[];
else
    pB=pB_0*W;
end

% pB_0=(eye(size(A,1))-A*Ga)*W;
% n=null(pB_0);
% if isempty(n)
%     pB=eye(size(pB_0,2));
% else
%     pB=null(n')';
% end

function fi=get_fi(param_vec,m_0)
n=length(m_0);
fi=zeros(length(param_vec));
st_idx=1;
for i=1:n
    ed_idx=st_idx+length(m_0{i})-2;
    theta=param_vec(st_idx:ed_idx);
    fi_i=zeros(length(theta));
    N=sum(m_0{i});
    %s_theta=sum(theta);
    theta_end=1-sum(theta);
    for j=1:length(theta)
        %same
        ex_i=N/theta(j)+N/theta_end;
        fi_i(j,j)=ex_i;
        for k=(j+1):length(theta)
            %diff
            ex_i=N/theta_end;
            fi_i(j,k)=ex_i;
            fi_i(k,j)=ex_i;
        end
    end
    fi(st_idx:ed_idx,st_idx:ed_idx)=fi_i;
    st_idx=ed_idx+1;
end


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
