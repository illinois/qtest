function results_table(handles)
n=length(handles.results);
Borda_res=cell(n,1); borda_n=0;
File_res=cell(n,1); file_n=0;
Nonref_res=cell(n,1); nonref_n=0;
Ref_res=cell(n,1); ref_n=0;
%collect table sizes
for i=1:length(handles.results)
    if isfield(handles.results{i},'sets_M')
        data_str=handles.results{i}.sets_M.name;
    else
        data_str=sprintf('%.4f',get_data_hash(handles.results{i}.M));
    end
    N_str=get_N_str(handles.results{i});
    if isequal(handles.results{i}.spec,'borda')
        entry_name=sprintf('%s\n(%s/%s/%i)', ...
            handles.results{i}.theory.name, ...
            data_str, N_str, ...
            handles.results{i}.rstate);
        found=0;
        for idx=1:borda_n
            r_i=Borda_res{idx}.r_idx;
            if isequal(Borda_res{idx}.name,entry_name) && ...
                    isequal(handles.results{r_i}.M,handles.results{i}.M) && ...
                    is_vertex_equal(handles.results{r_i}.theory.vertices, ...
                    handles.results{i}.theory.vertices)
                found=idx; break;
            end
        end
        if ~found
            borda_n=borda_n+1;
            Borda_res{borda_n}.name=entry_name;
            Borda_res{borda_n}.r_idx=i;
        end
        
    elseif isequal(handles.results{i}.spec,'file') || isequal(handles.results{i}.spec,'mixture')
        entry_name=sprintf('%s\n(%s/%s/%i)', ...
            handles.results{i}.theory.name, ...
            data_str, N_str, ...
            handles.results{i}.rstate);
        file_n=file_n+1;
        File_res{file_n}.name=entry_name;
        File_res{file_n}.r_idx=i;
    elseif handles.results{i}.use_ref>0
        found=0;
        for j=1:ref_n
            if handles.results{i}.log_ref_vol==Ref_res{j}.log_ref_vol
                found=j; break;
            end
        end
        if found
            idx=found;
        else
            ref_n=ref_n+1;
            idx=ref_n;
            Ref_res{idx}.log_ref_vol=handles.results{i}.log_ref_vol;
            Ref_res{idx}.entries={};
        end
        entry_name=sprintf('%s\n(%s/%s/%i)', ...
            handles.results{i}.theory.name, ...
            data_str, N_str, ...
            handles.results{i}.rstate);
        found=0;
        for j=1:length(Ref_res{idx}.entries)
            r_i=Ref_res{idx}.entries{j}.r_idx;
            if isequal(Ref_res{idx}.entries{j}.name,entry_name) && ...
                    isequal(handles.results{r_i}.M,handles.results{i}.M) && ...
                    isequal(handles.results{r_i}.theory.vertices, ...
                    handles.results{i}.theory.vertices)
                found=j; break;
            end
        end
        if found
            k=found;
        else
            k=length(Ref_res{idx}.entries)+1;
            Ref_res{idx}.entries{k}.name=entry_name;
            Ref_res{idx}.entries{k}.r_idx=i;
            Ref_res{idx}.entries{k}.specs=zeros(1,4);
        end
        switch handles.results{i}.spec
            case 'major'
                Ref_res{idx}.entries{k}.specs(1)=i;
            case 'sup'
                Ref_res{idx}.entries{k}.specs(2)=i;
            case 'city'
                Ref_res{idx}.entries{k}.specs(3)=i;
            case 'euclid'
                Ref_res{idx}.entries{k}.specs(4)=i;
        end
    else
        entry_name=sprintf('%s\n(%s/%s/%i)', ...
            handles.results{i}.theory.name, ...
            data_str, N_str, ...
            handles.results{i}.rstate);
        found=0;
        for j=1:nonref_n
            r_i=Nonref_res{j}.r_idx;
            if isequal(Nonref_res{j}.name,entry_name) && ...
                    isequal(handles.results{r_i}.M,handles.results{i}.M) && ...
                    is_vertex_equal(handles.results{r_i}.theory.vertices, ...
                    handles.results{i}.theory.vertices)
                found=j; break;
            end
        end
        if found
            idx=found;
        else
            nonref_n=nonref_n+1;
            idx=nonref_n;
            Nonref_res{idx}.name=entry_name;
            Nonref_res{idx}.r_idx=i;
            Nonref_res{idx}.major=[];
            Nonref_res{idx}.sup=[];
            Nonref_res{idx}.city=[];
            Nonref_res{idx}.euclid=[];
        end
        switch handles.results{i}.spec
            case 'major'
                found=0;
                for j=1:length(Nonref_res{idx}.major)
                    r_i=Nonref_res{idx}.major(j);
                    if handles.results{i}.lambda==handles.results{r_i}.lambda
                        found=1; break;
                    end
                end
                if ~found
                    Nonref_res{idx}.major=[Nonref_res{idx}.major; i];
                end
            case 'sup'
                found=0;
                for j=1:length(Nonref_res{idx}.sup)
                    r_i=Nonref_res{idx}.sup(j);
                    if handles.results{i}.U==handles.results{r_i}.U
                        found=1; break;
                    end
                end
                if ~found
                    Nonref_res{idx}.sup=[Nonref_res{idx}.sup; i];
                end
            case 'city'
                found=0;
                for j=1:length(Nonref_res{idx}.city)
                    r_i=Nonref_res{idx}.city(j);
                    if handles.results{i}.U==handles.results{r_i}.U
                        found=1; break;
                    end
                end
                if ~found
                    Nonref_res{idx}.city=[Nonref_res{idx}.city; i];
                end
            case 'euclid'
                found=0;
                for j=1:length(Nonref_res{idx}.euclid)
                    r_i=Nonref_res{idx}.euclid(j);
                    if handles.results{i}.U==handles.results{r_i}.U
                        found=1; break;
                    end
                end
                if ~found
                    Nonref_res{idx}.euclid=[Nonref_res{idx}.euclid; i];
                end
        end
    end
end

%create figure
fh=figure('NumberTitle','off','Name','Results',...
    'resize','off','Menubar','none','DockControls','off', ...
    'Units','characters');
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(fh,'Color',defaultBackground);

fh_panel=uipanel('Parent',fh,'units','normalized', ...
    'position',[0,0,1,1],'bordertype','none');

b_width=15; b_height=1.5;
x_anchor=b_width; y_anchor=b_height;

%ref tables
max_entry_width=0;
for idx=1:ref_n
    n_entries=length(Ref_res{idx}.entries);
    %find entry_width
    entry_width=0;
    for k=1:n_entries
        r_i=Ref_res{idx}.entries{k}.r_idx;
        width=length(Ref_res{idx}.entries{k}.name);
        name_width=length(handles.results{r_i}.theory.name);
        entry_width=max(entry_width,max(name_width,width-name_width));
    end
    entry_width=entry_width+5;
    max_entry_width=max(entry_width,max_entry_width);
    %title
    x=x_anchor;
    y=y_anchor+(2*n_entries+1)*b_height;
    uicontrol(fh_panel,'Style','text','String', ...
        sprintf('Reference volume: %g',exp(Ref_res{idx}.log_ref_vol)), ...
        'Units','character', ...
        'FontWeight','bold','HorizontalAlignment','left', ...
        'Position',[x,y,entry_width+4*b_width,b_height]);
    %header
    y=y_anchor+(2*n_entries)*b_height;
    x=x_anchor+entry_width;
    spec_list={'Supermajority','Supremum','City-block','Euclidean'};
    spec_param_str={'L','U','U','U'};
    for i=1:length(spec_list)
        uicontrol(fh_panel,'Style','text','String', ...
            spec_list{i},'Units','character', ...
            'Position',[x,y,b_width,b_height]);
        x=x+b_width;
    end
    %entries
    y=y_anchor+(2*n_entries-2)*b_height;
    x=x_anchor;
    for k=1:n_entries
        h=uicontrol(fh_panel,'Style','text','String', ...
            Ref_res{idx}.entries{k}.name, ...
            'Units','character', ...
            'Position',[x,y,entry_width,2*b_height]);
        str=sprintf('Vertices:\n');
        r_i=Ref_res{idx}.entries{k}.r_idx;
        w=[];
        for v_i=1:length(handles.results{r_i}.theory.vertices)
            str=[str,sprintf('%s  [Weight: %g]\n', ...
                handles.results{r_i}.theory.vertices{v_i}.name, ...
                handles.results{r_i}.theory.vertices{v_i}.w)];
            w=[w,handles.results{r_i}.theory.vertices{v_i}.w];
        end
        if isfield(handles.results{r_i},'sets_M')
            data_str=sprintf('Data set: %s\n',handles.results{r_i}.sets_M.name);
        else
            data_str='';
        end
        N_str=get_N_str(handles.results{r_i});
        str=[str,sprintf(' \n%sData (hashcode): %.4f\nTest type/sample size: %s\nRandom number seed: %g\n', ...
            data_str,get_data_hash(handles.results{r_i}.M), ...
            N_str, ...
            handles.results{r_i}.rstate)];
        set(h,'TooltipString',str);
        same_w=all(w==w(1));
        x=x+entry_width;
        
        for s_i=1:4 %specs
            h=uicontrol(fh_panel,'Style','text','String','', ... %'Enable','inactive','Min',0,'Max',2, ...
                'BackgroundColor',[1,1,1], ...
                'Units','character','Position',[x,y,b_width,2*b_height]);
            r_i=Ref_res{idx}.entries{k}.specs(s_i);
            if r_i>0
                [str,tt_str]=get_ref_res_str(handles.results{r_i},same_w,spec_param_str{s_i});
                set(h,'String',str);
                set(h,'TooltipString',tt_str);
            end
            x=x+b_width;
        end
        x=x_anchor;
        y=y-2*b_height;
    end
    %update anchor
    y_anchor=y_anchor+(2*n_entries+3)*b_height;
end


%nonref tables
if nonref_n>0
    %find entry_width
    n_entries=0;
    entry_width=0;
    for idx=1:nonref_n
        r_i=Nonref_res{idx}.r_idx;
        width=length(Nonref_res{idx}.name);
        name_width=length(handles.results{r_i}.theory.name);
        entry_width=max(entry_width,max(name_width,width-name_width));
        n_entries=n_entries+max([length(Nonref_res{idx}.major), ...
            length(Nonref_res{idx}.sup),length(Nonref_res{idx}.city), ...
            length(Nonref_res{idx}.euclid)]);
    end
    entry_width=entry_width+5;
    max_entry_width=max(entry_width,max_entry_width);
    %header
    y=y_anchor+(2*n_entries)*b_height;
    x=x_anchor+entry_width;
    spec_list={'Supermajority','Supremum','City-block','Euclidean'};
    for i=1:length(spec_list)
        uicontrol(fh_panel,'Style','text','String', ...
            spec_list{i},'Units','character', ...
            'Position',[x,y,b_width,b_height]);
        x=x+b_width;
    end
    %entries
    y=y_anchor+(2*n_entries-2)*b_height;
    x=x_anchor;
    for idx=1:nonref_n
        h=uicontrol(fh_panel,'Style','text','String', ...
            Nonref_res{idx}.name, ...
            'Units','character', ...
            'Position',[x,y,entry_width,2*b_height]);
        str=sprintf('Vertices:\n');
        r_i=Nonref_res{idx}.r_idx;
        for v_i=1:length(handles.results{r_i}.theory.vertices)
            str=[str,sprintf('%s\n', ...
                handles.results{r_i}.theory.vertices{v_i}.name)];
        end
        if isfield(handles.results{r_i},'sets_M')
            data_str=sprintf('Data set: %s\n',handles.results{r_i}.sets_M.name);
        else
            data_str='';
        end
        N_str=get_N_str(handles.results{r_i});
        str=[str,sprintf(' \n%sData (hashcode): %.4f\nTest type/sample size: %s\nRandom number seed: %g\n', ...
            data_str,get_data_hash(handles.results{r_i}.M), ...
            N_str, ...
            handles.results{r_i}.rstate)];
        set(h,'TooltipString',str);
        x=x+entry_width;

        n_rows=max([length(Nonref_res{idx}.major), ...
            length(Nonref_res{idx}.sup),length(Nonref_res{idx}.city), ...
            length(Nonref_res{idx}.euclid)]);
        for i=1:n_rows
            h=uicontrol(fh_panel,'Style','text','String','', ... %'Enable','inactive','Min',0,'Max',2, ...
                'BackgroundColor',[1,1,1], ...
                'Units','character','Position',[x,y,b_width,2*b_height]);
            if length(Nonref_res{idx}.major)>=i
                r_i=Nonref_res{idx}.major(i);
                [str,tt_str]=get_nonref_res_str(handles.results{r_i},'L',handles.results{r_i}.lambda);
                set(h,'String',str);
                set(h,'TooltipString',tt_str);
            end
            x=x+b_width;

            h=uicontrol(fh_panel,'Style','text','String','', ... %'Enable','inactive','Min',0,'Max',2, ...
                'BackgroundColor',[1,1,1], ...
                'Units','character','Position',[x,y,b_width,2*b_height]);
            if length(Nonref_res{idx}.sup)>=i
                r_i=Nonref_res{idx}.sup(i);
                [str,tt_str]=get_nonref_res_str(handles.results{r_i},'U',handles.results{r_i}.U);
                set(h,'String',str);
                set(h,'TooltipString',tt_str);
            end
            x=x+b_width;

            h=uicontrol(fh_panel,'Style','text','String','', ... %'Enable','inactive','Min',0,'Max',2, ...
                'BackgroundColor',[1,1,1], ...
                'Units','character','Position',[x,y,b_width,2*b_height]);
            if length(Nonref_res{idx}.city)>=i
                r_i=Nonref_res{idx}.city(i);
                [str,tt_str]=get_nonref_res_str(handles.results{r_i},'U',handles.results{r_i}.U);
                set(h,'String',str);
                set(h,'TooltipString',tt_str);
            end
            x=x+b_width;

            h=uicontrol(fh_panel,'Style','text','String','', ... %'Enable','inactive','Min',0,'Max',2, ...
                'BackgroundColor',[1,1,1], ...
                'Units','character','Position',[x,y,b_width,2*b_height]);
            if length(Nonref_res{idx}.euclid)>=i
                r_i=Nonref_res{idx}.euclid(i);
                [str,tt_str]=get_nonref_res_str(handles.results{r_i},'U',handles.results{r_i}.U);
                set(h,'String',str);
                set(h,'TooltipString',tt_str);
            end
            x=x_anchor+entry_width;
            y=y-2*b_height;
        end
        x=x_anchor;
    end
    %update anchor
    y_anchor=y_anchor+(2*n_entries+2)*b_height;
end

%borda
if borda_n>0
    %find entry_width
    n_entries=borda_n;
    entry_width=0;
    for idx=1:borda_n
        r_i=Borda_res{idx}.r_idx;
        width=length(Borda_res{idx}.name);
        name_width=length(handles.results{r_i}.theory.name);
        entry_width=max(entry_width,max(name_width,width-name_width));
    end
    entry_width=entry_width+5;
    max_entry_width=max(entry_width,max_entry_width);
    %header
    y=y_anchor+(2*n_entries)*b_height;
    x=x_anchor+entry_width;
    uicontrol(fh_panel,'Style','text','String', ...
        'Borda score','Units','character', ...
        'Position',[x,y,b_width,b_height]);
    %entries
    y=y_anchor+(2*n_entries-2)*b_height;
    x=x_anchor;
    for idx=1:borda_n
        h=uicontrol(fh_panel,'Style','text','String', ...
            Borda_res{idx}.name, ...
            'Units','character', ...
            'Position',[x,y,entry_width,2*b_height]);
        str=sprintf('Vertices:\n');
        r_i=Borda_res{idx}.r_idx;
        for v_i=1:length(handles.results{r_i}.theory.vertices)
            str=[str,sprintf('%s\n', ...
                handles.results{r_i}.theory.vertices{v_i}.name)];
        end
        if isfield(handles.results{r_i},'sets_M')
            data_str=sprintf('Data set: %s\n',handles.results{r_i}.sets_M.name);
        else
            data_str='';
        end
        N_str=get_N_str(handles.results{r_i});
        str=[str,sprintf(' \n%sData (hashcode): %.4f\nTest type/sample size: %s\nRandom number seed: %g\n', ...
            data_str,get_data_hash(handles.results{r_i}.M), ...
            N_str, ...
            handles.results{r_i}.rstate)];
        set(h,'TooltipString',str);
        x=x+entry_width;

        h=uicontrol(fh_panel,'Style','text','String','', ... %'Enable','inactive','Min',0,'Max',2, ...
            'BackgroundColor',[1,1,1], ...
            'Units','character','Position',[x,y,b_width,2*b_height]);
        r_i=Borda_res{idx}.r_idx;
        [str,tt_str]=get_borda_res_str(handles.results{r_i});
        set(h,'String',str);
        set(h,'TooltipString',tt_str);
        y=y-2*b_height;
        x=x_anchor;
    end
    %update anchor
    y_anchor=y_anchor+(2*n_entries+2)*b_height;
end

%Mixture (file)
if file_n>0
    %find entry_width
    n_entries=file_n;
    entry_width=0;
    for idx=1:file_n
        r_i=File_res{idx}.r_idx;
        width=length(File_res{idx}.name);
        name_width=length(handles.results{r_i}.theory.name);
        entry_width=max(entry_width,max(name_width,width-name_width));
    end
    entry_width=entry_width+5;
    max_entry_width=max(entry_width,max_entry_width);
    %header
    y=y_anchor+(2*n_entries)*b_height;
    x=x_anchor+entry_width;
    uicontrol(fh_panel,'Style','text','String', ...
        'Mixture','Units','character', ...
        'Position',[x,y,b_width,b_height]);
    %entries
    y=y_anchor+(2*n_entries-2)*b_height;
    x=x_anchor;
    for idx=1:file_n
        h=uicontrol(fh_panel,'Style','text','String', ...
            File_res{idx}.name, ...
            'Units','character', ...
            'Position',[x,y,entry_width,2*b_height]);
        r_i=File_res{idx}.r_idx;
        if isfield(handles.results{r_i},'sets_M')
            data_str=sprintf('Data set: %s\n',handles.results{r_i}.sets_M.name);
        else
            data_str='';
        end
        N_str=get_N_str(handles.results{r_i});
        str=sprintf('%sData (hashcode): %.4f\nTest type/sample size: %s\nRandom number seed: %g\n', ...
            data_str,get_data_hash(handles.results{r_i}.M), ...
            N_str, ...
            handles.results{r_i}.rstate);
        set(h,'TooltipString',str);
        x=x+entry_width;

        h=uicontrol(fh_panel,'Style','text','String','', ... %'Enable','inactive','Min',0,'Max',2, ...
            'BackgroundColor',[1,1,1], ...
            'Units','character','Position',[x,y,b_width,2*b_height]);
        r_i=File_res{idx}.r_idx;
        [str,tt_str]=get_mixture_res_str(handles.results{r_i});
        set(h,'String',str);
        set(h,'TooltipString',tt_str);
        y=y-2*b_height;
        x=x_anchor;
    end
    %update anchor
    y_anchor=y_anchor+(2*n_entries+2)*b_height;
end

%figure size
pos=get(fh,'position');
set(0,'units','characters');
ssize=get(0,'ScreenSize');
pos(3)=b_width*(6)+max_entry_width;
height=y_anchor;
pos(4)=min(height,ssize(4)*.8);
pos(1)=(ssize(3)-pos(3))/2;
pos(2)=(ssize(4)-pos(4))/2;
set(fh,'position',pos);

if height>pos(4)
    pad=height-pos(4);
    set(fh_panel,'units','characters', ...
        'position',[0,-pad,pos(3)-4,pos(4)+pad]);
    fh_slider=uicontrol(fh,'Style','slider', ...
        'Max',pad,'min',0,'value',pad,...
        'SliderStep',[min(1,5/pad),min(1,pos(4)/2/pad)], 'units','characters', ...
        'position',[pos(3)-4,0,4,pos(4)], ...
        'Callback',{@do_scroll,fh});
    set(fh,'WindowScrollWheelFcn',{@mouse_scroll,fh});
    userdata.fh_slider=fh_slider;
    userdata.fh_panel=fh_panel;
    userdata.fh_pos=pos;
    set(fh,'UserData',userdata);
end

function do_scroll(src,evnt,fh)
ud=get(fh,'UserData');
val=get(ud.fh_slider,'Value');
pos=get(ud.fh_panel,'Position');
pos(2)=-val;
pos(4)=ud.fh_pos(4)-pos(2);
set(ud.fh_panel,'Position',pos);

function mouse_scroll(src,evnt,fh)
ud=get(fh,'UserData');
step=get(ud.fh_slider,'SliderStep');
val=get(ud.fh_slider,'Value');
max_val=get(ud.fh_slider,'Max');
if evnt.VerticalScrollCount<0
    val=min(max_val,val+step(2)*max_val);
elseif evnt.VerticalScrollCount>0
    val=max(0,val-step(2)*max_val);
end
set(ud.fh_slider,'Value',val);
do_scroll([],[],fh);

function N_str=get_N_str(res)
if ~isfield(res,'type') || isequal(res.type,'frequentist')
    N_str=sprintf('freq/%i',res.N);
elseif isequal(res.type,'bayes_factor')
    N_str=sprintf('bayes-f/%i',res.gibbs_size);
else
    N_str=sprintf('bayes-p/%i/%i',res.gibbs_size,res.gibbs_burn);
end

function [p_max,max_r_i,warnmsg,p_all]=get_max_p(res)
warnmsg='';
p_max=-inf; max_r_i=0;
p_all=nan(length(res.res),1);
for r_i=1:length(res.res)
    if ~isempty(res.res{r_i})
        p=res.res{r_i}.p;
        if p>p_max
            p_max=p;
            max_r_i=r_i;
        end
        p_all(r_i)=p;
        if isfield(res.res{r_i},'msg') && ~isempty(res.res{r_i}.msg)
            warnmsg='*';
        end
    end
end

function [p_max,warnmsg,p_all]=get_bayes_p(res)
warnmsg='';
p_max=-inf; p_min=inf;
p_all=nan(length(res.res),1);
for r_i=1:length(res.res)
    if ~isempty(res.res{r_i})
        if isequal(res.type,'bayes_p')
            p=res.res{r_i}.p;
        elseif isfield(res.res{r_i},'bayes_exact')
            p=res.res{r_i}.bayes_exact;
        else
            p=res.res{r_i}.bayes2;
        end
        if p>p_max
            p_max=p;
        end
        if p<p_min
            p_min=p;
        end
        p_all(r_i)=p;
        if isfield(res.res{r_i},'msg') && ~isempty(res.res{r_i}.msg)
            warnmsg='*';
        end
    end
end
if p_min<p_max
    if isequal(res.spec,'major')
        if isequal(res.type,'bayes_p')
            p_max=res.weighted_res.p;
        else
            p_max=res.weighted_res.bayes_exact;
        end
    else
        p_max=[];
    end
end


function [str,tt_str]=get_ref_res_str(res,same_w,spec_param_str)
if isequal(res.type,'frequentist')
    [max_p,max_p_i,warnmsg,p_all]=get_max_p(res);
    str=sprintf('%s%.4f\n',warnmsg,max_p);
    has_params=isfield(res,'params') && ~isempty(res.params);
    if same_w && has_params
        str=[str,sprintf('(%s: %.4f)',spec_param_str, ...
            res.params(1))];
    else
        str=[str,'(~)'];
    end
    tt_str=sprintf('max p: %.4f (%s)',max_p, ...
        res.theory.vertices{max_p_i}.name);
else
    [max_p,warnmsg,p_all]=get_bayes_p(res);
    if isempty(max_p)
        str=sprintf('-\n');
        tt_str=sprintf('-\n');
    else
        str=sprintf('%s%.4f\n',warnmsg,max_p);
        if isequal(res.type,'bayes_p')
            tt_str=sprintf('bayes p: %.4f',max_p);
        elseif isequal(res.spec,'major')
            tt_str=sprintf('bayes factor (exact): %.4f',max_p);
        else
            tt_str=sprintf('bayes factor (sampled): %.4f',max_p);
        end
    end
    has_params=isfield(res,'params') && ~isempty(res.params);
    if same_w && has_params
        str=[str,sprintf('(%s: %.4f)',spec_param_str, ...
            res.params(1))];
    else
        str=[str,'(~)'];
    end
end
if has_params && (~same_w || length(p_all)>1)
    tt_str=[tt_str,sprintf('\n \n')];
    for v_i=1:length(res.theory.vertices)
        tt_str=[tt_str,sprintf('%s  [Weight: %g]  [%s: %.4f] %.4f\n', ...
            res.theory.vertices{v_i}.name, ...
            res.theory.vertices{v_i}.w, ...
            spec_param_str, ...
            res.params(v_i), ...
            p_all(v_i))];
    end
end
                
function [str,tt_str]=get_nonref_res_str(res,spec_param_str,param)
if isequal(res.type,'frequentist')
    [max_p,max_p_i,warnmsg,p_all]=get_max_p(res);
    str=sprintf('%s%.4f\n(%s: %.4f)',warnmsg,max_p,spec_param_str,param);
    tt_str=sprintf('max p: %.4f (%s)',max_p, ...
        res.theory.vertices{max_p_i}.name);
else
    [max_p,warnmsg,p_all]=get_bayes_p(res);
    if isempty(max_p)
        str=sprintf('-\n');
        tt_str=sprintf('-\n');
    else
        str=sprintf('%s%.4f\n(%s: %.4f)',warnmsg,max_p,spec_param_str,param);
        if isequal(res.type,'bayes_p')
            tt_str=sprintf('bayes p: %.4f',max_p);
        elseif isequal(res.spec,'major')
            tt_str=sprintf('bayes factor (exact): %.4f',max_p);
        else
            tt_str=sprintf('bayes factor (sampled): %.4f',max_p);
        end
    end
end
if length(p_all)>1
    tt_str=[tt_str,sprintf('\n \n')];
    for v_i=1:length(res.theory.vertices)
        tt_str=[tt_str,sprintf('%s: %.4f\n', ...
            res.theory.vertices{v_i}.name, ...
            p_all(v_i))];
    end
end

function [str,tt_str]=get_borda_res_str(res)
if isequal(res.type,'frequentist')
    [max_p,max_p_i,warnmsg,p_all]=get_max_p(res);
    str=sprintf('%s%.4f',warnmsg,max_p);
    tt_str=sprintf('max p: %.4f (%s)',max_p, ...
        res.theory.vertices{max_p_i}.name);
else
    [max_p,warnmsg,p_all]=get_bayes_p(res);
    if isempty(max_p)
        str=sprintf('-\n');
        tt_str=sprintf('-\n');
    else
        str=sprintf('%s%.4f\n',warnmsg,max_p);
        if isequal(res.type,'bayes_p')
            tt_str=sprintf('bayes p: %.4f',max_p);
        elseif isequal(res.spec,'major')
            tt_str=sprintf('bayes factor (exact): %.4f',max_p);
        else
            tt_str=sprintf('bayes factor (sampled): %.4f',max_p);
        end
    end
end
if length(p_all)>1
    tt_str=[tt_str,sprintf('\n \n')];
    for v_i=1:length(res.theory.vertices)
        tt_str=[tt_str,sprintf('%s: %.4f\n', ...
            res.theory.vertices{v_i}.name, ...
            p_all(v_i))];
    end
end

function [str,tt_str]=get_mixture_res_str(res)
if isequal(res.type,'frequentist')
    [max_p,max_p_i,warnmsg]=get_max_p(res);
    str=sprintf('%s%.4f',warnmsg,max_p);
    tt_str=sprintf('p: %.4f',max_p);
else
    [max_p,warnmsg]=get_bayes_p(res);
    if isempty(max_p)
        str=sprintf('-\n');
        tt_str=sprintf('-\n');
    else
        str=sprintf('%s%.4f\n',warnmsg,max_p);
        if isequal(res.type,'bayes_p')
            tt_str=sprintf('bayes p: %.4f',max_p);
        elseif isequal(res.spec,'major')
            tt_str=sprintf('bayes factor (exact): %.4f',max_p);
        else
            tt_str=sprintf('bayes factor (sampled): %.4f',max_p);
        end
    end
end


function c=is_vertex_equal(v1,v2)
c=0;
n1=length(v1);
n2=length(v2);
if n1~=n2
    return;
end
for i=1:n1
    if ~isequal(v1{i}.pairs,v2{i}.pairs) || ...
            ~isequal(v1{i}.name,v2{i}.name)
        return;
    end
end
c=1;
