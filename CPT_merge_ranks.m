function CPT_merge_ranks(job_name)
load([job_name,'.mat'],'alpha'); %load 'alpha'
load(sprintf('%s_all.mat',job_name),'res'); %load 'res'

res_notyet=ones(length(res),1);
alpha_sorted=sort(alpha);
warn_msg=0;
while 1
    idx=find(res_notyet,1,'first');
    if isempty(idx)
        break;
    end
    if isempty(res{idx})
        if ~warn_msg
            fprintf('WARNING: some result entries are empty!!\n\n');
            warn_msg=1;
        end
        res_notyet(idx)=0;
        continue;
    end
    ID1=res{idx}.params.ID1;
    ID2=res{idx}.params.ID2;
    alpha_done=zeros(size(alpha));
    k=0;
    dim=res{idx}.params.dim;
    rank_idx_all=zeros(2^dim,length(alpha));
    param_idx_all=cell(length(alpha),2^dim);
    for i=idx:length(res)
        if ~res_notyet(i)
            continue;
        end
        if isempty(res{i})
            if ~warn_msg
                fprintf('WARNING: some result entries are empty!!\n\n');
                warn_msg=1;
            end
            res_notyet(i)=0;
            continue;
        end
        if res{i}.params.ID1==ID1 && res{i}.params.ID2==ID2
            res_notyet(i)=0;
            k=k+1;
            alpha_done(k)=res{i}.params.alpha;
            rank_idx_all(:,k)=res{i}.rank_idx;
            r_idx=find(res{i}.rank_idx);
            for j=1:length(r_idx)
                param_idx_all{k,r_idx(j)}=res{i}.param_idx{j};
            end
        end
    end
    if isequal(sort(alpha_done),alpha_sorted)
        %save results
        rank_idx_any=any(rank_idx_all,2);
        r_idx=find(rank_idx_any);
        param_idx_cells=cell(length(r_idx),1);
        for i=1:length(r_idx)
            param_idx_cells{i}=cell2mat(param_idx_all(:,r_idx(i)));
        end
        save_results(ID1,ID2,rank_idx_any,param_idx_cells,dim,job_name);
    else
        fprintf('\nWARNING: alpha is not complete for ID1=%d, ID2=%d!!\n',ID1,ID2);
    end
end

function save_results(ID1,ID2,rank_idx,param_cells,dim,job_name)
%turn rank_idx into zeros and ones
rank=dec2bin(find(rank_idx)-1,dim)-'0';
filename=strcat(job_name,'_V',num2str(ID1),'_W',num2str(ID2),'_vertices.mat');
save(filename,'rank','param_cells');
