function [x,L,w,p,msg,n_done]=mult_con_euclid(m,center,U,N,rstate,opt_tolerance,opt_iter,progress)
msg=[];
n_done=[0,0];

if nargin>=7
    opt_max_iter=opt_iter;
else
    opt_max_iter=100;
end
if nargin>=6
    opt_tol=opt_tolerance;
else
    opt_tol=1e-5;
end
if nargin>=5
    rng(rstate,'twister');
end
if nargin<4
    N=10000;
end
if nargin<8
    progress=[];
end

%test trivial condition
q=get_q(m);
if norm(q-center)<=U
    x=q; L=0; w=[]; p=1; 
    return;
end

[A,b]=get_boundary_constraints(m,q);
q_vec=q-center;
q_vec=q_vec/norm(q_vec);
%q=center+U/2*q_vec;
q=center+U*(0.25+0.5*rand)*q_vec;

tol=1e-10;
best_fval=inf;
iter=1;
x=q;
while 1
    try %use 'interior-point' if possible
        options=optimset('GradObj','on','LargeScale','off','Display','off', ...
            'GradConstr','on','Algorithm','interior-point', ...
            'tolfun',tol,'tolX',tol,'tolcon',tol);
    catch
        options=optimset('GradObj','on','LargeScale','off','Display','off', ...
            'tolfun',tol,'tolX',tol,'tolcon',tol);
    end
    [x,fval,exitflag,output,lambda]=fmincon(@(x) neglog_L_fast(x,m),x,A,b,...
        [],[],ones(size(q))*1e-6,ones(size(q))*(1-1e-6),...
        @(x) noneq(x,center,U),options);
    if exitflag==1 || (exitflag>0 && ~isempty(output.firstorderopt) ...
	    && output.firstorderopt<=opt_tol)
        break;
    end
    if fval<best_fval
        best_x=x;
        best_fval=fval;
    end
    iter=iter+1;
    if iter>opt_max_iter
        msgbox(sprintf('Maximum likelihood estimator did not converge after %i iterations',opt_max_iter), ...
            'Convergence Warning','modal');
        msg{1+length(msg)}='conv';
        x=best_x;
        fval=best_fval;
        break;
    end
    rand_dir=randn(size(x));
    rand_dir=rand_dir/norm(rand_dir);
    x=x+tol*rand_dir;
end
%fprintf('iter: %i\n',iter);

%normal=x-center;
A=(x-center)';

fi=get_fi(x,m);
ifi=inv(fi);
[pA,pB]=get_polar_cone(A,ifi);

q=get_q(m);
[L2,G]=neglog_L(q,m);
[L3,G]=neglog_L(x,m);
L=2*(-L2)-2*(-L3);

[w,n_done]=do_silva(pA,pB,fi,ifi,N,progress);
w=w';

chisum=w(1)+w(2:end)*chi2cdf(L,1:(length(w)-1))';
p=1-chisum;


function [c,ceq,Gc,Gceq]=noneq(x,center,U)
v=x-center;
c=v*v'-U*U;
ceq=[];
Gc=2*v';
Gceq=[];

function [w,n_done]=do_silva(A,B,fi,ifi,N_actual,progress)
k=size(A,2);
m1=size(A,1); m2=size(B,1);
%s_count=zeros(k+1,1); %s_count=zeros(k,1);
s_count=cell(1,N_actual);
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
        s=size(null(face),2);
        
        %s_count(s+1)=s_count(s+1)+1;
        s_count{n_done(1)+i}=zeros(k+1,1);
        s_count{n_done(1)+i}(s+1)=1;
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
    s_theta=sum(theta);
    theta_end=1-sum(theta);
    for j=1:length(theta)
        %same
        theta_rest=s_theta - theta(j);
        ex_i=0;
        for m=0:N
            for m_j=0:(N-m)
                ex_i=ex_i + exp(gammaln(N+1)-gammaln(m+1)-gammaln(m_j+1) ...
                    -gammaln(N-m-m_j+1)) * theta_rest^(N-m-m_j) * ...
                    theta(j)^m_j * theta_end^m * ...
                    (m_j/theta(j)^2 + m/theta_end^2);
            end
        end
        fi_i(j,j)=ex_i;
        for k=(j+1):length(theta)
            %diff
            m=1:N; %m=0 is 0
            ex_i=sum( exp(gammaln(N+1)-gammaln(m+1)-gammaln(N-m+1)) ...
                .* s_theta.^(N-m) .* ...
                theta_end.^(m-2) .* m );
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
    %theta=m{i}(1:(end-1));
    %q=[q, theta/sum(m{i})];
    theta=m{i}/sum(m{i});
    if sum(theta<tol)>0 || sum(theta>1-tol)>0
        median=ones(1,length(theta))/length(theta);
        dir=median-theta;
        theta=theta+tol*dir/norm(dir);
    end
    q=[q, theta(1:(end-1))];
end

function [L,G]=neglog_L_fast(param_vec,m)
n=length(m);
G=zeros(size(param_vec));
ll=zeros(n,1);
st_idx=1;
for i=1:n
    ed_idx=st_idx+length(m{i})-2;
    theta=param_vec(st_idx:ed_idx);
    param=[theta,(1-sum(theta))];
    
%     ll(i)=gammaln(sum(m{i})+1)-sum(gammaln(m{i}+1)) + ...
%         m{i}*log(param)';
    ll(i)=m{i}*log(param)';
    G(st_idx:ed_idx)=-m{i}(1:(end-1))./param(1:(end-1)) + (m{i}(end)/param(end));
    st_idx=ed_idx+1;
end
L=-sum(ll);

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


function [A,B]=get_boundary_constraints(m,q)
n=length(m);
A=[]; B=[];
s_idx=1;
for i=1:n
    e_idx=s_idx+length(m{i})-2;
    if length(m{i})>2
        vec=zeros(1,length(q));
        vec(s_idx:e_idx)=1;
        A=[A; vec]; 
        B=[B; 1-1e-6];
    end
    s_idx=e_idx+1;
end
