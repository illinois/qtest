function handles=options_dialog(handles)

fh=figure('NumberTitle','off','Name','Options',...
    'resize','off','windowstyle','modal','Units','characters');
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(fh,'Color',defaultBackground);

b_pos=get(handles.pushbutton_gambles_change,'Position');
b_width=b_pos(3);
b_height=b_pos(4);
main_width=70;
x=b_width;
y=b_height*9;
h_cb_sample=uicontrol(fh,'Style','checkbox','String', ...
    'Strict sample size when entering data', ...
    'Value',handles.options.strict_sample_size, ...
    'Units','character', ...
    'Position',[x,y,main_width,b_height]);
y=b_height*4;
h_cb_region=zeros(1,4);
h_cb_region(1)=uibuttongroup(fh,'Title', ...
    'Volumes overlapping / outside the unit hypercube', ...
    'Units','character', ...
    'Position',[x,y,main_width,4*b_height]);
h_cb_region(2)=uicontrol(h_cb_region(1),'Style','radiobutton', ...
    'String','Do not check','Units','character', ...
    'Position',[0.05*main_width,2*b_height,main_width*0.9,b_height]);
h_cb_region(3)=uicontrol(h_cb_region(1),'Style','radiobutton', ...
    'String','Check and warn only during hypothesis testing','Units','character', ...
    'Position',[0.05*main_width,b_height,main_width*0.9,b_height]);
h_cb_region(4)=uicontrol(h_cb_region(1),'Style','radiobutton', ...
    'String','Check and warn during both design and test', ...
    'Units','character', ...
    'Position',[0.05*main_width,0,main_width*0.9,b_height]);
set(h_cb_region(handles.options.check_regions+2),'value',1);

x=b_width;
y=b_height*2;
uicontrol(fh,'Style','text','String', ...
    'MLE optimality tolerance (Default: 1e-10):','Units','character', ...
    'Position',[x,y,40,b_height]);
x=b_width+40;
h_cb_opt_tol=uicontrol(fh,'Style','edit','String', ...
    sprintf('%g',handles.options.opt_tol), ...
    'Units','character','Enable','inactive', ...
    'Position',[x,y,10,b_height]);
x=b_width+50;
uicontrol(fh,'Style','pushbutton','String','Change...',...
    'units','character','pos',[x,y,b_width,b_height], ...
    'Callback',{@do_opt_tol,fh});

x=b_width;
y=b_height;
uicontrol(fh,'Style','text','String', ...
    'MLE optimality iterations (Default: 100):','Units','character', ...
    'Position',[x,y,40,b_height]);
x=b_width+40;
h_cb_opt_iter=uicontrol(fh,'Style','edit','String', ...
    sprintf('%g',handles.options.opt_iter), ...
    'Units','character','Enable','inactive', ...
    'Position',[x,y,10,b_height]);
x=b_width+50;
uicontrol(fh,'Style','pushbutton','String','Change...',...
    'units','character','pos',[x,y,b_width,b_height], ...
    'Callback',{@do_opt_iter,fh});

userdata.h_cb_sample=h_cb_sample;
userdata.h_cb_region=h_cb_region;
userdata.h_cb_opt_tol=h_cb_opt_tol;
userdata.h_cb_opt_iter=h_cb_opt_iter;
userdata.handles=handles;
userdata.okay=0;
set(fh,'UserData',userdata);

x=1.5*b_width+main_width;
y=b_height*2;
uicontrol(fh,'Style','pushbutton','String','OK',...
    'units','character','pos',[x y b_width b_height], ...
    'Callback',{@do_okay,fh});
y=y-b_height;
uicontrol(fh,'Style','pushbutton','String','Cancel',...
    'units','character','pos',[x y b_width b_height], ...
    'Callback',{@do_cancel,fh});

pos=get(fh,'position');
old_width=pos(3);
old_height=pos(4);
pos(3)=3.5*b_width+main_width;
pos(4)=b_height*10;
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


function do_opt_tol(src,evnt,fh)
ud=get(fh,'UserData');
def=get(ud.h_cb_opt_tol,'String');
answer=inputdlg('Tolerance:','First-order Optimality Measure',1,{def});
if isempty(answer); return; end
tol=str2double(answer{1});
if isempty(tol) || ~isfinite(tol); return; end
if tol<=0
    msgbox('Must be a positive scalar','Error','modal');
    return;
end
if tol<=1e-10
    msgbox('Too small','Error','modal');
    return;
end
set(ud.h_cb_opt_tol,'String',sprintf('%g',tol));

function do_opt_iter(src,evnt,fh)
ud=get(fh,'UserData');
def=get(ud.h_cb_opt_iter,'String');
answer=inputdlg('Max iterations:','First-order Optimality Measure',1,{def});
if isempty(answer); return; end
iter=str2double(answer{1});
if isempty(iter) || ~isfinite(iter); return; end
iter=round(iter);
if iter<=0
    msgbox('Must be a positive integer','Error','modal');
    return;
end
set(ud.h_cb_opt_iter,'String',sprintf('%i',iter));


function do_okay(src,evnt,fh)
ud=get(fh,'UserData');

%finalize
for i=2:4
    if get(ud.h_cb_region(i),'value')>0
        ud.handles.options.check_regions=i-2;
        break;
    end
end
ud.handles.options.strict_sample_size=get(ud.h_cb_sample,'value');
ud.handles.options.opt_tol=str2double(get(ud.h_cb_opt_tol,'string'));
ud.handles.options.opt_iter=str2double(get(ud.h_cb_opt_iter,'string'));
ud.okay=1;
set(fh,'UserData',ud);
uiresume(fh);


function do_cancel(src,evnt,fh)
uiresume(fh);
