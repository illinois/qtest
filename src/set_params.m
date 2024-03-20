function handles=set_params(handles,t_i,v_i)

pairs_val=handles.theories{t_i}.vertices{v_i}.pairs;

ROWS=handles.gambles.ROWS;
COLS=handles.gambles.COLS;
n_pairs=size(pairs_val,1);
n_pages=ceil(n_pairs/(ROWS*COLS));
cur_page=1;

fh=figure('NumberTitle','off','Name','Set Vertex (Preference)',...
    'resize','off','windowstyle','modal','Units','characters');
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(fh,'Color',defaultBackground);

if n_pages==1
    h_cb=create_controls(pairs_val,1,n_pairs, ...
        min(n_pairs,ROWS),fh,handles);
    n_cols=ceil(n_pairs/ROWS);
else
    h_cb=create_controls(pairs_val,1,ROWS*COLS,ROWS,fh,handles);
    n_cols=COLS;
end

userdata.pairs_val=pairs_val;
userdata.cur_page=cur_page;
userdata.h_cb=h_cb;
userdata.handles=handles;
userdata.t_i=t_i;
userdata.v_i=v_i;
userdata.okay=0;
set(fh,'UserData',userdata);

b_pos=get(handles.pushbutton_gambles_change,'Position');
b_width=b_pos(3);
b_height=b_pos(4);
x=b_width*(2*n_cols+1);
y=b_height*2;
uicontrol(fh,'Style','pushbutton','String','OK',...
    'units','character','pos',[x y b_width b_height], ...
    'Callback',{@do_okay,fh});
y=y-b_height;
uicontrol(fh,'Style','pushbutton','String','Cancel',...
    'units','character','pos',[x y b_width b_height], ...
    'Callback',{@do_cancel,fh});

if n_pages>1
    x=b_width*(2*n_cols+1);
    y=b_height*(2*ROWS-1);
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
pos(4)=b_height*(2*min(ROWS,n_pairs)+2);
pos(1)=pos(1)-(pos(3)-old_width)/2;
pos(2)=pos(2)-(pos(4)-old_height)/2;
set(fh,'position',pos);

uiwait(fh);
if ishandle(fh)
    ud=get(fh,'UserData');
    if ud.okay
        handles=ud.handles;
    else
        handles=[];
    end
    close(fh);
else
    handles=[];
end


function do_okay(src,evnt,fh)
ud=get(fh,'UserData');

%store check box values
for idx=1:size(ud.h_cb,1)
    p_idx=ud.h_cb(idx,1);
    sel_h=get(ud.h_cb(idx,2),'SelectedObject');
    if sel_h==ud.h_cb(idx,3)
        ud.pairs_val(p_idx,3)=1;
    else
        ud.pairs_val(p_idx,3)=0;
    end    
end
%finalize
ud.handles.theories{ud.t_i}.vertices{ud.v_i}.pairs=ud.pairs_val;
ud.okay=1;
set(fh,'UserData',ud);
uiresume(fh);


function do_prev(src,evnt,fh)
ud=get(fh,'UserData');
if ud.cur_page<=1
    return;
end
ROWS=ud.handles.gambles.ROWS;
COLS=ud.handles.gambles.COLS;
n_pairs=size(ud.pairs_val,1);

%store check box values and remove
for idx=1:size(ud.h_cb,1)
    p_idx=ud.h_cb(idx,1);
    sel_h=get(ud.h_cb(idx,2),'SelectedObject');
    if sel_h==ud.h_cb(idx,3)
        ud.pairs_val(p_idx,3)=1;
    else
        ud.pairs_val(p_idx,3)=0;
    end
    delete(ud.h_cb(idx,3));
    delete(ud.h_cb(idx,4));
    delete(ud.h_cb(idx,2));
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
n_pairs=size(ud.pairs_val,1);
n_pages=ceil(n_pairs/(ROWS*COLS));
if ud.cur_page>=n_pages
    return;
end
%store check box values and remove
for idx=1:size(ud.h_cb,1)
    p_idx=ud.h_cb(idx,1);
    sel_h=get(ud.h_cb(idx,2),'SelectedObject');
    if sel_h==ud.h_cb(idx,3)
        ud.pairs_val(p_idx,3)=1;
    else
        ud.pairs_val(p_idx,3)=0;
    end
    delete(ud.h_cb(idx,3));
    delete(ud.h_cb(idx,4));
    delete(ud.h_cb(idx,2));
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
h_cb=zeros(n_idx,4);

b_pos=get(handles.pushbutton_gambles_change,'Position');
b_width=b_pos(3);
b_height=b_pos(4);
y=b_height*2*n_rows - b_height;
x=b_width;
offset=start_idx-1;
for idx=1:n_idx
    p_idx=offset+idx;
    i=pairs_val(p_idx,1);
    j=pairs_val(p_idx,2);
    ID_i=handles.gambles.ID{i};
    ID_j=handles.gambles.ID{j};
    h_cb(idx,1)=p_idx;
    h_cb(idx,2)=uibuttongroup(fh,'Title', ...
        sprintf('(%s,%s)',ID_i,ID_j), ...
        'Units','character', ...
        'Position',[x,y,2*b_width,2*b_height]);
    h_cb(idx,3)=uicontrol(h_cb(idx,2),'Style','togglebutton', ...
        'String',ID_i,'Units','character', ...
        'Position',[0,0,b_width*0.9,b_height]);
    h_cb(idx,4)=uicontrol(h_cb(idx,2),'Style','togglebutton', ...
        'String',ID_j,'Units','character', ...
        'Position',[b_width,0,b_width*0.9,b_height]);
    if pairs_val(p_idx,3)>0
        set(h_cb(idx,3),'value',1);
    else
        set(h_cb(idx,4),'value',1);
    end
    y=y-2*b_height;
    if mod(idx,n_rows)==0
        x=x+2*b_width;
        y=b_height*2*n_rows - b_height;
    end
end


