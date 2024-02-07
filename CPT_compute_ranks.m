function res=CPT_compute_ranks(dim,alpha,ID1,ID2,Xp_mat,beta,gamma,s)
t_all=tic;
res=[];
res.params.name='CPT_compute_ranks';
res.params.dim=dim;
res.params.alpha=alpha;
res.params.ID1=ID1;
res.params.ID2=ID2;
res.params.Xp_mat=Xp_mat;
res.params.beta=beta;
res.params.gamma=gamma;
res.params.s=s;

if ~exist('CPT_v_o_2_par5b','class')
    javaaddpath('.');
end
CPT_obj=javaObject('CPT_v_o_2_par5b');
CPT_obj.computeRanks(dim,alpha,ID1,ID2,Xp_mat,beta,gamma,s);

res.rank_idx=sparse(CPT_obj.getRanks());
param_idx=cell(CPT_obj.getParams());
idx=find(res.rank_idx);
res.param_idx=cell(length(idx),1);
for i=1:length(idx)
    res.param_idx{i}=param_idx{idx(i)};
end

res.time=toc(t_all);
