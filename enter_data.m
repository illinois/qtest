function [handles,new_set]=enter_data(handles)

n_pairs=size(handles.data.pairs,1);
if isempty(handles.data.M)
    pairs_val=cell(n_pairs,1);
else
    pairs_val=handles.data.M;
end

ROWS=handles.gambles.ROWS;
COLS=handles.gambles.COLS;
n_pages=ceil(n_pairs/(ROWS*COLS));
cur_page=1;

fh=figure('NumberTitle','off','Name','Enter Observations',...
    'resize','off','windowstyle','modal','Units','characters');
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(fh,'Color',defaultBackground);

if n_pages==1
    h_cb=create_controls(pairs_val,1,n_pairs, ...
        max(4,min(n_pairs,ROWS)),fh,handles);
    n_cols=ceil(n_pairs/ROWS);
else
    h_cb=create_controls(pairs_val,1,ROWS*COLS,ROWS,fh,handles);
    n_cols=COLS;
end

userdata.pairs_val=pairs_val;
userdata.cur_page=cur_page;
userdata.h_cb=h_cb;
userdata.handles=handles;
userdata.okay=0;
set(fh,'UserData',userdata);

b_pos=get(handles.pushbutton_gambles_change,'Position');
b_width=b_pos(3);
b_height=b_pos(4);
x=b_width*(2*n_cols+1);
y=b_height*4;
uicontrol(fh,'Style','pushbutton','String','OK',...
    'units','character','pos',[x y b_width b_height], ...
    'Callback',{@do_okay,fh});
y=y-b_height;
uicontrol(fh,'Style','pushbutton','String','Cancel',...
    'units','character','pos',[x y b_width b_height], ...
    'Callback',{@do_cancel,fh});
y=y-2*b_height;
uicontrol(fh,'Style','pushbutton','String','New Set',...
    'units','character','pos',[x y b_width b_height], ...
    'Callback',{@do_new,fh});

if n_pages>1
    x=b_width*(2*n_cols+1);
    y=b_height*ROWS;
    uicontrol(fh,'Style','pushbutton','String','Prev Pg',...
        'units','character','pos',[x y b_width b_height], ...
        'Callback',{@do_prev,fh});
    y=y-b_height;
    uicontrol(fh,'Style','pushbutton','String','Next Pg',...
        'units','character','pos',[x y b_width b_height], ...
        'Callback',{@do_next,fh});
end

pos=get(fh,'position');
old_width=pos(3);
old_height=pos(4);
pos(3)=b_width*(2*n_cols+2.5);
pos(4)=b_height*(max(4,min(ROWS,n_pairs))+2);
pos(1)=pos(1)-(pos(3)-old_width)/2;
pos(2)=pos(2)-(pos(4)-old_height)/2;
set(fh,'position',pos);

uiwait(fh);
if ishandle(fh)
    ud=get(fh,'UserData');
    new_set=0;
    if ud.okay
        handles=ud.handles;
        if ud.okay>1
            new_set=1;
        end
    else
        handles=[];
    end
    close(fh);
else
    handles=[];
end


function [val,msg]=string_to_val(answer,M,strict)
msg=[]; val=[];
answer=strtrim(answer);
if isempty(answer); return; end
p=str2num(answer);
if isempty(p) || ~all(isfinite(p))
    msg='Invalid input';
    return; 
end
p=floor(p);
if ~all(p>=0) || sum(p)==0
    msg='Need at least 1 observation';
    return;
end
if isequal(size(p),[1,2])
    if strict && sum(p)~=M
        msg='Incorrect sample size';
        return;
    end
    val=p;
elseif length(p)==1
    if strict && p>M
        msg='Incorrect sample size';
        return;
    end
    val=[p,max(0,M-p)];
else
    msg='Invalid format';
    return;
end


function new_ud=store_val(ud)
new_ud=[];
%store editbox valus
for idx=1:size(ud.h_cb,1)
    p_idx=ud.h_cb(idx,1);
    answer=get(ud.h_cb(idx,3),'String');
    [val,msg]=string_to_val(answer,ud.handles.spec.data_M,...
        ud.handles.options.strict_sample_size);
    if ~isempty(msg)
        i=ud.handles.data.pairs(p_idx,1);
        j=ud.handles.data.pairs(p_idx,2);
        ID_i=ud.handles.gambles.ID{i};
        ID_j=ud.handles.gambles.ID{j};
        msgbox(sprintf('(%s,%s): %s',ID_i,ID_j,msg), ...
            'Error','modal');
        return;
    else
        ud.pairs_val{p_idx}=val;
    end
end
for p_idx=1:length(ud.pairs_val)
    if isempty(ud.pairs_val{p_idx})
        i=ud.handles.data.pairs(p_idx,1);
        j=ud.handles.data.pairs(p_idx,2);
        ID_i=ud.handles.gambles.ID{i};
        ID_j=ud.handles.gambles.ID{j};
        msgbox(sprintf('(%s,%s): undefined',ID_i,ID_j), ...
            'Error','modal');
        return;
    end
end
new_ud=ud;


function do_okay(src,evnt,fh)
ud=get(fh,'UserData');
ud=store_val(ud);
if isempty(ud)
    return;
end
%finalize
ud.handles.data.M=ud.pairs_val;
ud.okay=1;
set(fh,'UserData',ud);
uiresume(fh);


function do_new(src,evnt,fh)
ud=get(fh,'UserData');
ud=store_val(ud);
if isempty(ud)
    return;
end
%finalize
ud.handles.data.M=ud.pairs_val;
ud.okay=2; %for new set
set(fh,'UserData',ud);
uiresume(fh);


function do_prev(src,evnt,fh)
ud=get(fh,'UserData');
if ud.cur_page<=1
    return;
end
ROWS=ud.handles.gambles.ROWS;
COLS=ud.handles.gambles.COLS;
n_pairs=length(ud.pairs_val);

%store check box values and remove
for idx=1:size(ud.h_cb,1)
    p_idx=ud.h_cb(idx,1);
    answer=get(ud.h_cb(idx,3),'String');
    [val,msg]=string_to_val(answer,ud.handles.spec.data_M, ...
        ud.handles.options.strict_sample_size);
    if ~isempty(msg)
        i=ud.handles.data.pairs(p_idx,1);
        j=ud.handles.data.pairs(p_idx,2);
        ID_i=ud.handles.gambles.ID{i};
        ID_j=ud.handles.gambles.ID{j};
        msgbox(sprintf('(%s,%s): %s',ID_i,ID_j,msg), ...
            'Error','modal');
        return;
    else
        ud.pairs_val{p_idx}=val;
    end
end
for idx=1:size(ud.h_cb,1)
    delete(ud.h_cb(idx,2));
    delete(ud.h_cb(idx,3));
end
ud.cur_page=ud.cur_page-1;
start_idx=(ud.cur_page-1)*(ROWS*COLS)+1;
end_idx=min(n_pairs,(ud.cur_page)*(ROWS*COLS));
ud.h_cb=create_controls(ud.pairs_val,start_idx, ...
    end_idx,ROWS,fh,ud.handles);

set(fh,'UserData',ud);


function do_next(src,evnt,fh)
ud=get(fh,'UserData');
ROWS=ud.handles.gambles.ROWS;
COLS=ud.handles.gambles.COLS;
n_pairs=length(ud.pairs_val);
n_pages=ceil(n_pairs/(ROWS*COLS));
if ud.cur_page>=n_pages
    return;
end
%store check box values and remove
for idx=1:size(ud.h_cb,1)
    p_idx=ud.h_cb(idx,1);
    answer=get(ud.h_cb(idx,3),'String');
    [val,msg]=string_to_val(answer,ud.handles.spec.data_M, ...
        ud.handles.options.strict_sample_size);
    if ~isempty(msg)
        i=ud.handles.data.pairs(p_idx,1);
        j=ud.handles.data.pairs(p_idx,2);
        ID_i=ud.handles.gambles.ID{i};
        ID_j=ud.handles.gambles.ID{j};
        msgbox(sprintf('(%s,%s): %s',ID_i,ID_j,msg), ...
            'Error','modal');
        return;
    else
        ud.pairs_val{p_idx}=val;
    end
end
for idx=1:size(ud.h_cb,1)
    delete(ud.h_cb(idx,2));
    delete(ud.h_cb(idx,3));
end
ud.cur_page=ud.cur_page+1;
start_idx=(ud.cur_page-1)*(ROWS*COLS)+1;
end_idx=min(n_pairs,(ud.cur_page)*(ROWS*COLS));
ud.h_cb=create_controls(ud.pairs_val,start_idx, ...
    end_idx,ROWS,fh,ud.handles);

set(fh,'UserData',ud);


function do_cancel(src,evnt,fh)
uiresume(fh);


function h_cb=create_controls(pairs_val, ...
    start_idx,end_idx,n_rows,fh,handles)
n_idx=end_idx-start_idx+1;
h_cb=zeros(n_idx,3);

b_f_col=get(handles.edit_num_gambles,'ForegroundColor');
b_b_col=get(handles.edit_num_gambles,'BackgroundColor');
b_pos=get(handles.pushbutton_gambles_change,'Position');
b_width=b_pos(3);
b_height=b_pos(4);
y=b_height*n_rows;
x=0.5*b_width;
offset=start_idx-1;
for idx=1:n_idx
    p_idx=offset+idx;
    i=handles.data.pairs(p_idx,1);
    j=handles.data.pairs(p_idx,2);
    ID_i=handles.gambles.ID{i};
    ID_j=handles.gambles.ID{j};
    h_cb(idx,1)=p_idx;
    h_cb(idx,2)=uicontrol(fh,'Style','text','String', ...
        sprintf('(%s,%s): ',ID_i,ID_j), ...
        'HorizontalAlignment','right', ...
        'Units','character', ...
        'Position',[x,y,b_width,b_height]);
    h_cb(idx,3)=uicontrol(fh,'Style','edit','String', '', ...
        'BackgroundColor',b_b_col,'ForegroundColor',b_f_col, ...
        'HorizontalAlignment','left', ...
        'Units','character', ...
        'Position',[x+b_width,y,b_width,b_height]);
    if ~isempty(pairs_val{p_idx})
        set(h_cb(idx,3),'String',sprintf('%g,%g', ...
            pairs_val{p_idx}(1),pairs_val{p_idx}(2)));
    end
    y=y-b_height;
    if mod(idx,n_rows)==0
        x=x+2*b_width;
        y=b_height*n_rows;
    end
end


