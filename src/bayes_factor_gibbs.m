function [bayes_gibbs,bayes_gibbs_ext]=bayes_factor_gibbs(m,A,B,Aeq,Beq,ineq_idx,N_actual,rstate,epsilon,progress)
%bayes_factor_gibbs computes the Bayes factor using the gibbs sampler method
%   BAYES_GIBBS=bayes_factor_gibbs(M,A,B,AEQ,BEQ,INEQ_IDX,N,RSTATE,EPSILON)
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
%   N is the number of samples used to perform the Bayesian test.
%
%   N_BURN is an optional number of extra initial burn-in samples (default: 0).
%
%   RSTATE is optional. If specified, the random number generators will
%   be set to the given value (a scalar non-negative integer). This can
%   be used to create repeatable results.
%
%   EPSILON is optional. This is a value in the interval [0,0.5) such that
%   all likelihood for computing BAYES_GIBBS will be constrained to within
%   the interval [EPSILON,(1-EPSILON)]. Default is 0.
%   
%   PROGRESS is optional. It should be a non-empty text string for progress bar.
%
% Outputs:
%
%   BAYES_GIBBS is the Bayes factor computed with the direct method.
%

if nargin>=8
    rng(rstate,'twister');
end
if nargin>=9
    if epsilon<0 || epsilon>=0.5
        epsilon=0;
    end
else
    epsilon = 0;
end
if nargin<10
    progress=[];
end

%bayes_gibbs=[];
% %find valid starting point
% l_scale='on';
% max_iter=85;
% while 1
%     options_lin=optimset('LargeScale',l_scale,'Display','off','MaxIter',max_iter);
%     [valid,~,exitflag]=linprog(ones(1,size(A,2)),A,B,Aeq,Beq, ...
%         [],[],[],options_lin);
%     if exitflag==0
%         max_iter=max_iter*2;
%         continue;
%     end
%     if exitflag<0
%         if isequal(l_scale,'on') && isfield(optimset,'Simplex')
%             l_scale='off'; %rare case
%             max_iter=85;
%             continue;
%         end
%         %error('Cannot find a feasible point!');
%         return;
%     end
%     break;
% end
% x=valid';


%% ADDED BY DAN TO GET A VALID STARTING POINT

%%%%%%%%%%% THIS VERSION USES TEH MPT3 TOOLBOX %%%%%%%%%%%%
% % display old starting point
% disp(x)
% %%%%%% use mpt to find an interior point of the polytope
% % construct a polyhedron object from A, B, AEQ, BEQ
% P = Polyhedron('A', A, 'b', B, 'Ae', Aeq, 'be', Beq);
% int = P.interiorPoint;
% x = int.x;
% x = x';
% disp(x)

%%%%%%%%% THIS VERSION DOES THE SAME THING WITHOUT THE MPT3 TOOLBOX
% Compute Chebyshev center from facet description by solving linear program
% minimize r such that aix + ||ai||r < bi 
%add last column for r variable, which is the L2 norm of each row of A
lastcol=zeros(size(A,1),1);
for iii=1:size(A,1)
    lastcol(iii,1)=norm(A(iii,:));
end
Ar=horzcat(A,lastcol);
%add last row to Ar for r>0 constraint
Ar2=vertcat(Ar,[zeros(1,size(A,2)),-1]);
%add last row to B for r>0 constraint
Br2=vertcat(B,0);
%if Aeq is empty then leave it alone, otherwise add column of zeros for the
%r variable
if isempty(Aeq)==0
    Aeqr=horzcat(Aeq,zeros(size(Aeq,1),1));
end
% maximize r by minimizing -r
f=horzcat(zeros(1,size(A,2)),-1);

if isempty(Aeq)==0
    xr = linprog(f,Ar2,Br2,Aeqr,Beq);
    else
    xr = linprog(f,Ar2,Br2,Aeq,Beq);
end
%x=linprog(f,Ar2,Br2,Aeq,Beq);

x = xr(1:size(A,2));
%r = xr(size(A,2)+1);
x = x';
%%

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

tic
if ~isempty(progress)
    h_wait=waitbar(0,sprintf('Sampling %d/%d',0,N_actual),'WindowStyle','modal','Name', ...
        progress,'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(h_wait,'canceling',0);
end

CHUNK_SIZE=1000; %1e6;
n_chunks=max(1,floor(N_actual/CHUNK_SIZE));
bayes_gibbs = 0;
bayes_gibbs_ext=zeros(n_chunks,3);

%% Marginal likelihood of null model (denominator in the Bayes factor) only depends on the data, not the particular sample, so we precompute it
logdenom=sum(betaln(m(:,1)+1,m(:,2)+1));

for iter=1:n_chunks
    if iter==n_chunks
        N=N_actual-(iter-1)*CHUNK_SIZE;
    else
        N=CHUNK_SIZE;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Bayes factor (direct method)
    % Caution: small magnitudes!
    %
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

    %% Revised Bayes factor calculation.  Normalize by marginal likelihood of the null model in each sample, instead of waiting until the end.  We precomputed it and called it logdenom.
%      bayes_gibbs = bayes_gibbs + ...
%          sum(prod(prior_sample.^(ones(N,1)*(m(:,1)')),2).* ...
%          prod((1-prior_sample).^(ones(N,1)*(m(:,2)')),2));
    bayes_gibbs=bayes_gibbs+sum( exp(sum(  (ones(N,1)*(m(:,1)')).*log(prior_sample) + (ones(N,1)*(m(:,2)')).*log(1-prior_sample) ,2) - logdenom )); 
    %%
    
    n_done=(iter-1)*CHUNK_SIZE+N;
    %% No need to divide by likelihood of null model because it was already done in each sample.
    %cur_bayes_gibbs =  exp(log(bayes_gibbs/n_done)-sum(betaln(m(:,1)+1,m(:,2)+1)));
    cur_bayes_gibbs =  bayes_gibbs/n_done;
    bayes_gibbs_ext(iter,:)=[n_done,cur_bayes_gibbs,0];
       
    if ~isempty(progress)
        waitbar(n_done/N_actual,h_wait,sprintf('Sampling %d/%d (Elapsed: %.0f secs)',n_done,N_actual,toc));
        if getappdata(h_wait,'canceling')
            bayes_gibbs_ext=bayes_gibbs_ext(1:iter,:);
            bayes_gibbs_ext(iter,3)=1;
            break;
        end
    end
end
if ~isempty(progress)
    delete(h_wait);
end
%fprintf('BF2 time (%g secs)\n',toc);

%% No need to divide by likelihood of null model because it was already done for each sample.
%bayes_gibbs =  exp(log(bayes_gibbs/n_done)-sum(betaln(m(:,1)+1,m(:,2)+1)));
bayes_gibbs = bayes_gibbs/n_done;

