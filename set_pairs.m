function handles=set_pairs(handles)

n=length(handles.gambles.ID);
pairs_val=zeros(n);
for idx=1:size(handles.gambles.pairs,1)
    i=handles.gambles.pairs(idx,1);
    j=handles.gambles.pairs(idx,2);
    pairs_val(i,j)=1;
    pairs_val(j,i)=1;
end
n_all_pairs=n*(n-1)/2;
all_pairs=zeros(n_all_pairs,2);
idx=0;
for i=1:n
    for j=(i+1):n
        idx=idx+1;
        all_pairs(idx,:)=[i,j];
    end
end

ROWS=handles.gambles.ROWS;
COLS=handles.gambles.COLS;
n_pages=ceil(n_all_pairs/(ROWS*COLS));
cur_page=1;

fh=figure('NumberTitle','off','Name','Choose gamble pairs',...
    'resize','off','windowstyle','modal','Units','characters');
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(fh,'Color',defaultBackground);

if n_pages==1
    h_cb=create_controls(pairs_val,all_pairs,1,n_all_pairs, ...
        max(5,min(n_all_pairs,ROWS)),fh,handles);
    n_cols=ceil(n_all_pairs/ROWS);
else
    h_cb=create_controls(pairs_val,all_pairs,1,ROWS*COLS,ROWS,fh,handles);
    n_cols=COLS;
end

userdata.pairs_val=pairs_val;
userdata.all_pairs=all_pairs;
userdata.cur_page=cur_page;
userdata.h_cb=h_cb;
userdata.handles=handles;
userdata.okay=0;
set(fh,'UserData',userdata);

b_pos=get(handles.pushbutton_gambles_change,'Position');
b_width=b_pos(3);
b_height=b_pos(4);
x=b_width*(n_cols+1);
y=b_height*5;
uicontrol(fh,'Style','pushbutton','String','None',...
    'units','character','pos',[x y b_width b_height], ...
    'Callback',{@do_none,fh});
y=y-b_height;
uicontrol(fh,'Style','pushbutton','String','All',...
    'units','character','pos',[x y b_width b_height], ...
    'Callback',{@do_all,fh});
y=y-2*b_height;
uicontrol(fh,'Style','pushbutton','String','OK',...
    'units','character','pos',[x y b_width b_height], ...
    'Callback',{@do_okay,fh});
y=y-b_height;
uicontrol(fh,'Style','pushbutton','String','Cancel',...
    'units','character','pos',[x y b_width b_height], ...
    'Callback',{@do_cancel,fh});

if n_pages>1
    x=b_width*(n_cols+1);
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
pos(3)=b_width*(n_cols+2.5);
pos(4)=b_height*(max(5,min(ROWS,n_all_pairs))+2);
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
    i=ud.h_cb(idx,1);
    j=ud.h_cb(idx,2);
    ud.pairs_val(i,j)=get(ud.h_cb(idx,3),'Value');
    ud.pairs_val(j,i)=ud.pairs_val(i,j);
end
%finalize
handles=ud.handles;
n=length(handles.gambles.ID);
n_pairs=0;
for i=1:n
    for j=(i+1):n
        if ud.pairs_val(i,j)>0
            n_pairs=n_pairs+1;
        end
    end
end
handles.gambles.pairs=zeros(n_pairs,2);
handles.gambles.pair_idx=zeros(n);
idx=0;
for i=1:n
    for j=(i+1):n
        if ud.pairs_val(i,j)>0
            idx=idx+1;
            handles.gambles.pairs(idx,:)=[i,j];
            handles.gambles.pair_idx(i,j)=idx;
            handles.gambles.pair_idx(j,i)=-idx;
        end
    end
end
handles.theories={};
ud.handles=handles;
ud.okay=1;
set(fh,'UserData',ud);
uiresume(fh);

function do_none(src,evnt,fh)
ud=get(fh,'UserData');
n=length(ud.handles.gambles.ID);
for i=1:n
    for j=(i+1):n
        ud.pairs_val(i,j)=0;
        ud.pairs_val(j,i)=0;
    end
end
for idx=1:size(ud.h_cb,1)
    set(ud.h_cb(idx,3),'Value',0);
end
set(fh,'UserData',ud);


function do_all(src,evnt,fh)
ud=get(fh,'UserData');
n=length(ud.handles.gambles.ID);
for i=1:n
    for j=(i+1):n
        ud.pairs_val(i,j)=1;
        ud.pairs_val(j,i)=1;
    end
end
for idx=1:size(ud.h_cb,1)
    set(ud.h_cb(idx,3),'Value',1);
end
set(fh,'UserData',ud);


function do_prev(src,evnt,fh)
ud=get(fh,'UserData');
if ud.cur_page<=1
    return;
end
ROWS=ud.handles.gambles.ROWS;
COLS=ud.handles.gambles.COLS;
n_all_pairs=size(ud.all_pairs,1);

%store check box values and remove
for idx=1:size(ud.h_cb,1)
    i=ud.h_cb(idx,1);
    j=ud.h_cb(idx,2);
    ud.pairs_val(i,j)=get(ud.h_cb(idx,3),'Value');
    ud.pairs_val(j,i)=ud.pairs_val(i,j);
    delete(ud.h_cb(idx,3));
end
ud.cur_page=ud.cur_page-1;
start_idx=(ud.cur_page-1)*(ROWS*COLS)+1;
end_idx=min(n_all_pairs,(ud.cur_page)*(ROWS*COLS));
ud.h_cb=create_controls(ud.pairs_val,ud.all_pairs,start_idx, ...
    end_idx,ROWS,fh,ud.handles);

set(fh,'UserData',ud);


function do_next(src,evnt,fh)
ud=get(fh,'UserData');
ROWS=ud.handles.gambles.ROWS;
COLS=ud.handles.gambles.COLS;
n_all_pairs=size(ud.all_pairs,1);
n_pages=ceil(n_all_pairs/(ROWS*COLS));
if ud.cur_page>=n_pages
    return;
end
%store check box values and remove
for idx=1:size(ud.h_cb,1)
    i=ud.h_cb(idx,1);
    j=ud.h_cb(idx,2);
    ud.pairs_val(i,j)=get(ud.h_cb(idx,3),'Value');
    ud.pairs_val(j,i)=ud.pairs_val(i,j);
    delete(ud.h_cb(idx,3));
end
ud.cur_page=ud.cur_page+1;
start_idx=(ud.cur_page-1)*(ROWS*COLS)+1;
end_idx=min(n_all_pairs,(ud.cur_page)*(ROWS*COLS));
ud.h_cb=create_controls(ud.pairs_val,ud.all_pairs,start_idx, ...
    end_idx,ROWS,fh,ud.handles);

set(fh,'UserData',ud);


function do_cancel(src,evnt,fh)
uiresume(fh);


function h_cb=create_controls(pairs_val,all_pairs, ...
    start_idx,end_idx,n_rows,fh,handles)
n_idx=end_idx-start_idx+1;
h_cb=[all_pairs(start_idx:end_idx,:),zeros(n_idx,1)];

b_pos=get(handles.pushbutton_gambles_change,'Position');
b_width=b_pos(3);
b_height=b_pos(4);
y=b_height*n_rows;
x=b_width;
for idx=1:n_idx
    i=h_cb(idx,1);
    j=h_cb(idx,2);
    ID_i=handles.gambles.ID{i};
    ID_j=handles.gambles.ID{j};
    h_cb(idx,3)=uicontrol(fh,'Style','checkbox','String', ...
        sprintf('(%s,%s)',ID_i,ID_j), ...
        'Value',pairs_val(i,j),'Units','character', ...
        'Position',[x,y,b_width,b_height]);
    y=y-b_height;
    if mod(idx,n_rows)==0
        x=x+b_width;
        y=b_height*n_rows;
    end
end


