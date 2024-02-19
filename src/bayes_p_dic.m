function [p,D,pD_ext]=bayes_p_dic(m,A,B,Aeq,Beq,ineq_idx,N_actual,N_burn,rstate,progress)
%BAYES_P_DIC computes Bayesian p-value and DIC for a single vertex
%specification
%   [P,D]=bayes_p_dic(M,A,B,AEQ,BEQ,INEQ_IDX,N_ACTUAL,N_BURN,RSTATE)
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
%   PROGRESS is optional. It should be a non-empty text string for progress bar.
%
% Outputs:
%
%   P is the Bayesian p-value.
%
%   D is a structure with 3 fields:
%     D.thetabar - gives the averaged parameter according to posterior
%     D.GOF  -  gives the goodness of fit (lack of) value
%     D.complexity  -  gives the complexity penalty
%     D.DIC  -  gives the DIC value
%

if nargin<8
    N_burn=0;
end
if nargin>=9
    rng(rstate,'twister');
end
if nargin<10
    progress=[];
end

p=[];
D=[];
%find valid starting point
l_scale='on';
max_iter=85;
while 1
    options_lin=optimset('LargeScale',l_scale,'Display','off','MaxIter',max_iter);
    [valid,~,exitflag]=linprog(ones(1,size(A,2)),A,B,Aeq,Beq, ...
        [],[],options_lin);
    if exitflag==0
        max_iter=max_iter*2;
        continue;
    end
    if exitflag<0
        if isequal(l_scale,'on') && isfield(optimset,'Simplex')
            l_scale='off'; %rare case
            max_iter=85;
            continue;
        end
        %error('Cannot find a feasible point!');
        return;
    end
    break;
end
x=valid';
num_dim=length(x);

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

tic
if ~isempty(progress)
    h_wait=waitbar(0,sprintf('Sampling %d/%d',0,N_actual),'WindowStyle','modal','Name', ...
        progress,'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(h_wait,'canceling',0);
end

CHUNK_SIZE=1000; %1e6;
n_chunks=max(1,floor(N_actual/CHUNK_SIZE));
p_sum = 0;
dic_sum_sample = zeros(1,num_dim);
dic_sum_bartheta = 0;
pD_ext=zeros(n_chunks,4);
for iter=0:n_chunks
    if iter==0
        N=N_burn;
    else
        if iter==n_chunks
            N=N_actual-(iter-1)*CHUNK_SIZE;
        else
            N=CHUNK_SIZE;
        end
        sample=zeros(N,num_dim);
    end

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
        if iter>0 %not burn-in
            sample(i,:)=x;
        end
    end
    if iter==0
        continue;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % p-value

    m_total=ones(N,1)*(sum(m,2)');
    n_prd = sample.*m_total + 0.5; % .5 a continuity correction
    n_sim = binornd(m_total,sample) + 0.5;
    n_obs = ones(N,1)*(m(:,1)') + 0.5;
    chisqr_sim = sum((n_sim-n_prd).^2./n_prd,2);
    chisqr_obs = sum((n_obs-n_prd).^2./n_prd,2);
    %p = sum(chisqr_sim>=chisqr_obs)/N;
    p_sum = p_sum + sum(chisqr_sim>=chisqr_obs);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DIC
    
    dic_sum_sample = dic_sum_sample + sum(sample,1);
    %compute the DDF of each iteration of Gibbs
    n = ones(N,1)*(m(:,1)');
    dic_sum_bartheta = dic_sum_bartheta + ...
        sum(2*sum( n.*log( (n+0.5)./(m_total.*sample+0.5) ) + ...
        (m_total-n).*log( (m_total-n+0.5)./(m_total-m_total.*sample+0.5) ), 2));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n_done=(iter-1)*CHUNK_SIZE+N;
    cur_p = p_sum/n_done;
    cur_thetabar=dic_sum_sample/n_done;
    m_total=sum(m,2)';
    n = m(:,1)';
    DThetaBar = 2*sum( n.*log( (n+0.5)./(m_total.*cur_thetabar+0.5) ) + ...
        (m_total-n).*log( (m_total-n+0.5)./(m_total-m_total.*cur_thetabar+0.5) ));
    cur_DIC= DThetaBar + 2*(dic_sum_bartheta/n_done-DThetaBar); %DIC
    pD_ext(iter,:)=[n_done,cur_p,cur_DIC,0];
    
    if ~isempty(progress)
        waitbar(n_done/N_actual,h_wait,sprintf('Sampling %d/%d (Elapsed: %.0f secs)',n_done,N_actual,toc));
        if getappdata(h_wait,'canceling')
            pD_ext=pD_ext(1:iter,:);
            pD_ext(iter,4)=1;
            break;
        end
    end
end
if ~isempty(progress)
    delete(h_wait);
end
%fprintf('Bp time (%g secs)\n',toc);

p = p_sum/n_done;

%compute thetabar: the average value of theta across iterations of Gibbs
thetabar=dic_sum_sample/n_done;
%compute deviance discrepancy functionv(DDF) of thetabar := "DThetaBar"
m_total=sum(m,2)';
n = m(:,1)';
DThetaBar = 2*sum( n.*log( (n+0.5)./(m_total.*thetabar+0.5) ) + ...
    (m_total-n).*log( (m_total-n+0.5)./(m_total-m_total.*thetabar+0.5) ));
%compute the DDF of each iteration of Gibbs, and then average them
DBarTheta = dic_sum_bartheta/n_done;
D.thetabar=thetabar;
D.GOF=DThetaBar; % (lack of) Goodness of Fit
D.complexity = 2*(DBarTheta-DThetaBar); %Penalty assessed for less complex models
D.DIC= D.GOF + D.complexity; %DIC
