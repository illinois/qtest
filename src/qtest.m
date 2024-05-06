function varargout = qtest(varargin)
% QTEST M-file for qtest.fig
%      QTEST, by itself, creates a new QTEST or raises the existing
%      singleton*.
%
%      H = QTEST returns the handle to a new QTEST or the handle to
%      the existing singleton*.
%
%      QTEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QTEST.M with the given input arguments.
%
%      QTEST('Property','Value',...) creates a new QTEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before qtest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to qtest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help qtest

% Last Modified by GUIDE v2.5 24-Oct-2018 17:30:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @qtest_OpeningFcn, ...
                   'gui_OutputFcn',  @qtest_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before qtest is made visible.
function qtest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to qtest (see VARARGIN)

if isdeployed
    warning('off','all');
end

handles.mother_figure=hObject;
handles.analysis_window=[];

handles.gambles.ID={};
handles.gambles.pairs=[];
handles.gambles.pair_idx=[];
handles.gambles.ROWS=10;
handles.gambles.COLS=5;

handles.data.pairs=[];
handles.data.M={};
handles.data.sets={};

handles.theories={};
handles.results={};

handles.spec.from_file.name={};
handles.spec.from_file.path={};
handles.spec.from_file.A=[];
handles.spec.from_file.B=[];
handles.spec.from_file.A_eq=[];
handles.spec.from_file.B_eq=[];
handles.spec.from_file.ineq_idx=[];
handles.spec.from_file.vertices={};
handles.spec.lambda=0.5;
handles.spec.U_sup=0.5;
handles.spec.U_city=0.5;
handles.spec.U_euc=0.5;
handles.spec.N=1000;
handles.spec.rstate=1;
handles.spec.data_M=20;
handles.spec.log_ref_vol=[]; %3*log(0.5);
handles.spec.gibbs_size=5000;
handles.spec.gibbs_burn=1000;

handles.options.strict_sample_size=0;
handles.options.check_regions=1; 
   %0: no check, 1:check before test, 2:always check
handles.options.opt_tol=1e-10;
handles.options.opt_iter=100;

%fix prob_spec panels stacking order
uistack(handles.uipanel8,'bottom');
uistack(handles.uipanel9,'bottom');
uistack(handles.uipanel10,'bottom');

set(handles.mother_figure,'Name','QTEST');

% Choose default command line output for qtest
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% try
%     h=waitbar(0,'Opening parallel pool...','WindowStyle','modal','Name','QTEST');
%     matlabpool open
% catch exception
% end
% close(h);
% if matlabpool('size')>0
%     set(handles.mother_figure,'Name',sprintf('QTEST (Parallel pool size: %d)',matlabpool('size')));
% end


% UIWAIT makes qtest wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = qtest_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_gambles.
function listbox_gambles_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_gambles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_gambles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_gambles


% --- Executes during object creation, after setting all properties.
function listbox_gambles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_gambles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'string',{});

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_vertices.
function listbox_vertices_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_vertices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_vertices contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_vertices
update_params_list(handles);


% --- Executes during object creation, after setting all properties.
function listbox_vertices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_vertices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function update_data_list(handles,set_idx)
%updates listbox_data (empirical observations) in the Data section
n=length(handles.data.M);
list=cell(n,1);
for idx=1:n
    ID_i=handles.gambles.ID{handles.data.pairs(idx,1)};
    ID_j=handles.gambles.ID{handles.data.pairs(idx,2)};
    list{idx}=sprintf('(%s,%s): %i,%i',ID_i,ID_j, ...
        handles.data.M{idx}(1),handles.data.M{idx}(2));
end
if isempty(get(handles.listbox_data,'value'))
    set(handles.listbox_data,'value',1)
else
    val=get(handles.listbox_data,'value');
    if val<1
        set(handles.listbox_data,'value',1);
    elseif val>n
        set(handles.listbox_data,'value',n);
    end
end
set(handles.listbox_data,'string',list);

if isempty(handles.data.sets)
    set(handles.popupmenu_data,'string',{'Default'});
    set(handles.popupmenu_data,'value',1);
else
    list=cell(length(handles.data.sets),1);
    for idx=1:length(handles.data.sets)
        if isfield(handles.data.sets{idx},'name')
            list{idx}=handles.data.sets{idx}.name;
        else
            list{idx}=sprintf('Set %i',idx);
        end
    end
    set(handles.popupmenu_data,'string',list);
    if nargin>=2
        set(handles.popupmenu_data,'value',set_idx);
    else
        set(handles.popupmenu_data,'value',1);
    end
end


function update_results_list(handles)
%updates listbox_results (list of results) in the Hypothesis Testing
% section
n=length(handles.results);
list=cell(n,1);
for idx=1:n
%     data_hash=get_data_hash(handles.results{idx}.M);
%     if isequal(handles.results{idx}.spec,'file')
%         entry_name=sprintf('%s/%.4f',handles.results{idx}.theory.name, ...
%             data_hash);
%     elseif handles.results{idx}.use_ref>0
%         entry_name=sprintf('%s/r%g/%.4f',handles.results{idx}.theory.name, ...
%             exp(handles.results{idx}.log_ref_vol), data_hash);
%     else
%         entry_name=sprintf('%s/%.2f/%.2f/%.4f',handles.results{idx}.theory.name, ...
%             handles.results{idx}.lambda,handles.results{idx}.U, ...
%             data_hash);
%     end
    list{idx}=sprintf('%s (%s)',get_results_entry_name(handles.results{idx}), ...
        handles.results{idx}.spec);
end
if isempty(get(handles.listbox_results,'value'))
    set(handles.listbox_results,'value',1);
else
    val=get(handles.listbox_results,'value');
    if val<1
        set(handles.listbox_results,'value',1);
    elseif val>n
        set(handles.listbox_results,'value',n);
    end
end
set(handles.listbox_results,'string',list);


% --- Executes on button press in pushbutton_change_param.
function pushbutton_change_param_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_change_param (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

list=get(handles.listbox_params,'string');
if isempty(list)
    return;
end
t_i=get(handles.listbox_theories,'value');
v_i=get(handles.listbox_vertices,'value');

handles=set_params(handles,t_i,v_i);
if ~isempty(handles)
    guidata(handles.mother_figure,handles);
    update_params_list(handles);
    
    if handles.options.check_regions==2
        check_all_regions(t_i,[],handles);
    end
end


% --- Executes on button press in pushbutton_lambda.
function pushbutton_lambda_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

def=sprintf('%g',handles.spec.lambda);
answer=inputdlg('Supermajority Level (Lambda):','Change Parameter',1,{def});
if isempty(answer); return; end
lambda=str2double(answer{1});
if isempty(lambda) || ~isfinite(lambda); return; end
if lambda<0.5 || lambda>1
    msgbox('Lambda must be in [0.5,1]','Error','modal');
    return;
end
handles.spec.lambda=lambda;
guidata(hObject, handles);
set(handles.edit_lambda,'String',sprintf('%g',lambda));
update_vertices_list(handles);

if handles.options.check_regions==2
    check_all_regions([],handles.radiobutton_major,handles);
end


% --- Executes on button press in pushbutton_U_sup.
function pushbutton_U_sup_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_U_sup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

def=sprintf('%g',handles.spec.U_sup);
answer=inputdlg('Max-distance (U):','Change Parameter',1,{def});
if isempty(answer); return; end
U=str2double(answer{1});
if isempty(U) || ~isfinite(U); return; end
if U<=0
    msgbox('U must be positive','Error','modal');
    return;
end
if U>0.5
    msgbox('Warning: a large distance may result in overlapping regions','Warning','modal');
end
handles.spec.U_sup=U;
guidata(hObject, handles);
set(handles.edit_U_sup,'string',sprintf('%g',U));
update_vertices_list(handles);

if handles.options.check_regions==2
    check_all_regions([],handles.radiobutton_sup,handles);
end


% --- Executes on selection change in listbox_data.
function listbox_data_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_data


% --- Executes during object creation, after setting all properties.
function listbox_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uipanel_prob_spec.
function uipanel_prob_spec_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_prob_spec 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

update_vertices_list(handles);


function params=get_vertex_param(hObject,t_i,handles)
%compute parameter values for the vertices in each probabilistic
% specification
switch(get(hObject,'Tag'))
    case 'radiobutton_major'
        n=size(handles.gambles.pairs,1);
        n_vert=length(handles.theories{t_i}.vertices);
        w_total=0;
        for v_i=1:n_vert
            w_total=w_total+handles.theories{t_i}.vertices{v_i}.w;
        end
        if w_total==0 && get(handles.checkbox_volume,'value')>0
            params=[];
            return;
        end
        params=ones(n_vert,1);
        for v_i=1:n_vert
            if get(handles.checkbox_volume,'value')>0
                rvol_i=handles.theories{t_i}.vertices{v_i}.w/w_total;
                if rvol_i==0; continue; end
                lambda=1-exp((log(rvol_i)+handles.spec.log_ref_vol)/n);
            else
                %lambda=1-rvol_i^(1/n)*(1-handles.spec.lambda);
                lambda=handles.spec.lambda;
            end
            params(v_i)=lambda;
        end
    case 'radiobutton_sup'
        n=size(handles.gambles.pairs,1);
        n_vert=length(handles.theories{t_i}.vertices);
        w_total=0;
        for v_i=1:n_vert
            w_total=w_total+handles.theories{t_i}.vertices{v_i}.w;
        end
        if w_total==0 && get(handles.checkbox_volume,'value')>0
            params=[];
            return;
        end
        params=zeros(n_vert,1);
        for v_i=1:n_vert
            if get(handles.checkbox_volume,'value')>0
                rvol_i=handles.theories{t_i}.vertices{v_i}.w/w_total;
                if rvol_i==0; continue; end
                vert=handles.theories{t_i}.vertices{v_i}.pairs(:,3)';
                if all((vert==0)|(vert==1))                
                    U=exp((log(rvol_i)+handles.spec.log_ref_vol)/n);
                else
                    U=search_volume('radiobutton_sup',vert,exp(log(rvol_i)+handles.spec.log_ref_vol));
                end
            else
                %U=rvol_i^(1/n)*handles.spec.U_sup;
                U=handles.spec.U_sup;
            end
            params(v_i)=U;
        end
    case 'radiobutton_city'
        n=size(handles.gambles.pairs,1);
        n_vert=length(handles.theories{t_i}.vertices);
        w_total=0;
        for v_i=1:n_vert
            w_total=w_total+handles.theories{t_i}.vertices{v_i}.w;
        end
        if w_total==0 && get(handles.checkbox_volume,'value')>0
            params=[];
            return;
        end
        params=zeros(n_vert,1);
        for v_i=1:n_vert
            if get(handles.checkbox_volume,'value')>0
                rvol_i=handles.theories{t_i}.vertices{v_i}.w/w_total;
                if rvol_i==0; continue; end
                vert=handles.theories{t_i}.vertices{v_i}.pairs(:,3)';
                if all((vert==0)|(vert==1))                
                    U=exp((log(rvol_i)+handles.spec.log_ref_vol+ ...
                        gammaln(n+1))/n);
                else
                    U=search_volume('radiobutton_city',vert,exp(log(rvol_i)+handles.spec.log_ref_vol));
                end
            else
                %U=rvol_i^(1/n)*handles.spec.U_city;
                U=handles.spec.U_city;
            end
            params(v_i)=U;
        end
    case 'radiobutton_euclid'
        n=size(handles.gambles.pairs,1);
        n_vert=length(handles.theories{t_i}.vertices);
        w_total=0;
        for v_i=1:n_vert
            w_total=w_total+handles.theories{t_i}.vertices{v_i}.w;
        end
        if w_total==0 && get(handles.checkbox_volume,'value')>0
            params=[];
            return;
        end
        params=zeros(n_vert,1);
        for i=1:n_vert
            if get(handles.checkbox_volume,'value')>0
                rvol_i=handles.theories{t_i}.vertices{i}.w/w_total;
                if rvol_i==0; continue; end
                vert=handles.theories{t_i}.vertices{i}.pairs(:,3)';
                if all((vert==0)|(vert==1))                
                    U=exp( (log(rvol_i)+handles.spec.log_ref_vol-n/2*log(pi)+...
                        gammaln(n/2+1)+n*log(2))/n );
                else
                    U=search_volume('radiobutton_euclid',vert,exp(log(rvol_i)+handles.spec.log_ref_vol));
                end
            else
                %U=rvol_i^(1/n)*handles.spec.U_euc;
                U=handles.spec.U_euc;
            end
            params(i)=U;
        end
    otherwise
        params=[];
end


function [A,b,params,new_portahull,Aeq,beq,ineq_idx]=prob_spec(tag,t_i,handles,check_volume)
%compute matrices A and b for the inequalities in each probabilistic
% specification
new_portahull=[];
Aeq=[];
beq=[];
ineq_idx=[];
switch tag
    case 'radiobutton_major'
        n=size(handles.gambles.pairs,1);
        n_vert=length(handles.theories{t_i}.vertices);
        w_total=0;
        for v_i=1:n_vert
            w_total=w_total+handles.theories{t_i}.vertices{v_i}.w;
        end
        if w_total==0 && check_volume>0
            A=[]; b=[]; params=[];
            return;
        end
        A=cell(n_vert,1); b=cell(n_vert,1); params=ones(n_vert,1);
        for v_i=1:n_vert
            if check_volume>0
                rvol_i=handles.theories{t_i}.vertices{v_i}.w/w_total;
                if rvol_i==0; continue; end
                lambda=1-exp((log(rvol_i)+handles.spec.log_ref_vol)/n);
            else
                %lambda=1-rvol_i^(1/n)*(1-handles.spec.lambda);
                lambda=handles.spec.lambda;
            end
%             A{v_i}=[eye(n); -eye(n);];
%             b{v_i}=[ (1-lambda*(handles.theories{t_i}.vertices{v_i}.pairs(:,3)<0.5)); ...
%                 -lambda*(handles.theories{t_i}.vertices{v_i}.pairs(:,3)>0.5)];
            A{v_i}=zeros(2*n,n); b{v_i}=zeros(2*n,1);
            for i=1:n
                A{v_i}(i,i)=1;
                leftover=-min(0,handles.theories{t_i}.vertices{v_i}.pairs(i,3)-0.5*(1-lambda));
                b{v_i}(i)=min(1,leftover+0.5*(1-lambda)+handles.theories{t_i}.vertices{v_i}.pairs(i,3));
                A{v_i}(n+i,i)=-1;
                leftover=max(0,0.5*(1-lambda)+handles.theories{t_i}.vertices{v_i}.pairs(i,3)-1);
                b{v_i}(n+i)=-max(0,handles.theories{t_i}.vertices{v_i}.pairs(i,3)-0.5*(1-lambda)-leftover);
            end
            params(v_i)=lambda;
        end
    case 'radiobutton_borda'
        n_gambles=length(handles.gambles.ID);
        n=size(handles.gambles.pairs,1);
        n_vert=length(handles.theories{t_i}.vertices);
        A=cell(n_vert,1); b=cell(n_vert,1); params=[];
        for v_i=1:n_vert
            A{v_i}=zeros(n,n); b{v_i}=zeros(n,1);
            for i=1:n
                if handles.theories{t_i}.vertices{v_i}.pairs(i,3)>0.5
                    idx1=handles.theories{t_i}.vertices{v_i}.pairs(i,1);
                    idx2=handles.theories{t_i}.vertices{v_i}.pairs(i,2);
                else
                    idx1=handles.theories{t_i}.vertices{v_i}.pairs(i,2);
                    idx2=handles.theories{t_i}.vertices{v_i}.pairs(i,1);
                end
                for j=1:n_gambles
                    if idx1==j; continue; end
                    if handles.gambles.pair_idx(idx1,j)>0
                        idx=handles.gambles.pair_idx(idx1,j);
                        A{v_i}(i,idx)=A{v_i}(i,idx)-1;
                    else
                        idx=-handles.gambles.pair_idx(idx1,j);
                        A{v_i}(i,idx)=A{v_i}(i,idx)+1;
                        b{v_i}(i)=b{v_i}(i)+1;
                    end
                end
                for j=1:n_gambles
                    if idx2==j; continue; end
                    if handles.gambles.pair_idx(idx2,j)>0
                        idx=handles.gambles.pair_idx(idx2,j);
                        A{v_i}(i,idx)=A{v_i}(i,idx)+1;
                    else
                        idx=-handles.gambles.pair_idx(idx2,j);
                        A{v_i}(i,idx)=A{v_i}(i,idx)-1;
                        b{v_i}(i)=b{v_i}(i)-1;
                    end
                end
            end
            A{v_i}=[A{v_i}; eye(n); -eye(n);]; b{v_i}=[b{v_i}; ones(n,1); zeros(n,1)];
            
            %V=porta_extreme([A{v_i}; eye(n); -eye(n)],[b{v_i}; ones(n,1); zeros(n,1)]);
            V=porta_extreme(A{v_i},b{v_i});
            if ~isempty(V)
                n_v=size(V,1);
                v1=ones(n_v-1,1)*V(1,:);
                v2=V(2:end,:)-v1;
                if rank(v2)<n
                    A{v_i}=[]; b{v_i}=[];
                end
            else
                A{v_i}=[]; b{v_i}=[];
            end
        end
    case 'radiobutton_sup'
        n=size(handles.gambles.pairs,1);
        n_vert=length(handles.theories{t_i}.vertices);
        w_total=0;
        for v_i=1:n_vert
            w_total=w_total+handles.theories{t_i}.vertices{v_i}.w;
        end
        if w_total==0 && check_volume>0
            A=[]; b=[]; params=[];
            return;
        end
        A=cell(n_vert,1); b=cell(n_vert,1); params=zeros(n_vert,1);
        for v_i=1:n_vert
            if check_volume>0
                rvol_i=handles.theories{t_i}.vertices{v_i}.w/w_total;
                if rvol_i==0; continue; end
                vert=handles.theories{t_i}.vertices{v_i}.pairs(:,3)';
                if all((vert==0)|(vert==1))                
                    U=exp((log(rvol_i)+handles.spec.log_ref_vol)/n);
                else
                    U=search_volume('radiobutton_sup',vert,exp(log(rvol_i)+handles.spec.log_ref_vol));
                end
            else
                %U=rvol_i^(1/n)*handles.spec.U_sup;
                U=handles.spec.U_sup;
            end
            A{v_i}=zeros(2*n,n); b{v_i}=zeros(2*n,1); params(v_i)=U;
            for i=1:n
                A{v_i}(i,i)=1;
                b{v_i}(i)=min(1,U+handles.theories{t_i}.vertices{v_i}.pairs(i,3));
                A{v_i}(n+i,i)=-1;
                b{v_i}(n+i)=-max(0,handles.theories{t_i}.vertices{v_i}.pairs(i,3)-U);
            end
        end
    case 'radiobutton_city'
        n=size(handles.gambles.pairs,1);
        n_vert=length(handles.theories{t_i}.vertices);
        w_total=0;
        for v_i=1:n_vert
            w_total=w_total+handles.theories{t_i}.vertices{v_i}.w;
        end
        if w_total==0 && check_volume>0
            A=[]; b=[]; params=[];
            return;
        end
        A=cell(n_vert,1); b=cell(n_vert,1); params=zeros(n_vert,1);
        for v_i=1:n_vert
            if check_volume>0
                rvol_i=handles.theories{t_i}.vertices{v_i}.w/w_total;
                if rvol_i==0; continue; end
                vert=handles.theories{t_i}.vertices{v_i}.pairs(:,3)';
                if all((vert==0)|(vert==1))                
                    U=exp((log(rvol_i)+handles.spec.log_ref_vol+ ...
                        gammaln(n+1))/n);
                else
                    U=search_volume('radiobutton_city',vert,exp(log(rvol_i)+handles.spec.log_ref_vol));
                end
            else
                %U=rvol_i^(1/n)*handles.spec.U_city;
                U=handles.spec.U_city;
            end
            params(v_i)=U;
            vert=handles.theories{t_i}.vertices{v_i}.pairs(:,3);
            if all((vert==0)|(vert==1))
                A{v_i}=(1-vert*2)';
                b{v_i}=U+A{v_i}*vert;
            else
                A{v_i}=2*(double(dec2bin(0:(2^n-1)))-48)-1;
                b{v_i}=U + A{v_i}*vert;
            end
            A{v_i}=[A{v_i}; eye(n); -eye(n);]; b{v_i}=[b{v_i}; ones(n,1); zeros(n,1)];
        end
    %case 'radiobutton_euclid'
    case 'radiobutton_from_file'
        params=[];
        if isempty(handles.spec.from_file.name)
            A=[]; b=[];
        else
            A={handles.spec.from_file.A};
            b={handles.spec.from_file.B};
            Aeq={handles.spec.from_file.A_eq};
            beq={handles.spec.from_file.B_eq};
            ineq_idx=handles.spec.from_file.ineq_idx;
        end
    case 'radiobutton_from_porta'
        params=[];
        n=size(handles.gambles.pairs,1);
        n_vert=length(handles.theories{t_i}.vertices);
        V=zeros(n_vert,n);
        for v_i=1:n_vert
            V(v_i,:)=handles.theories{t_i}.vertices{v_i}.pairs(:,3)';
        end
        if isfield(handles.theories{t_i},'portahull') && isequal(handles.theories{t_i}.portahull.V,V)
            A_ineq = handles.theories{t_i}.portahull.A_ineq;
            B_ineq = handles.theories{t_i}.portahull.B_ineq;
            A_eq = handles.theories{t_i}.portahull.A_eq;
            B_eq = handles.theories{t_i}.portahull.B_eq;
            ineq_idx = handles.theories{t_i}.portahull.ineq_idx;
        else
            [A_ineq,B_ineq,A_eq,B_eq,ineq_idx]=porta_hull(V);
            phull.V=V;
            phull.A_ineq=A_ineq;
            phull.B_ineq=B_ineq;
            phull.A_eq=A_eq;
            phull.B_eq=B_eq;
            phull.ineq_idx=ineq_idx;
%             handles.theories{t_i}.portahull.V=V;
%             handles.theories{t_i}.portahull.A_ineq=A_ineq;
%             handles.theories{t_i}.portahull.B_ineq=B_ineq;
%             handles.theories{t_i}.portahull.A_eq=A_eq;
%             handles.theories{t_i}.portahull.B_eq=B_eq;
%             handles.theories{t_i}.portahull.ineq_idx=ineq_idx;
            %new_handles=handles;
            new_portahull.t_i=t_i;
            new_portahull.phull=phull;
        end
        %A={ [A_ineq; A_eq; -A_eq] };
        %b={ [B_ineq; B_eq; -B_eq] };
        A = { A_ineq };
        b = { B_ineq };
        Aeq = { A_eq };
        beq = { B_eq };
        
    otherwise
        error('Unexpected spec');
end

% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path]=uigetfile({'*.*','All Files'},'Load Data');
if file~=0
    f=load([path,file]);
    if ~isfield(f,'qtest_version') || (~isequal(f.qtest_version,'0.3') ...
            && ~isequal(f.qtest_version,'1.0'))
        msgbox('Invalid file or wrong version.','Error','modal');
        return;
    end
    handles.gambles=f.handles.gambles;
    handles.spec=f.handles.spec;
    if ~isfield(handles.spec,'rstate')
        handles.spec.rstate=1;
    end
    if ~isfield(handles.spec,'gibbs_size')
        handles.spec.gibbs_size=5000;
        handles.spec.gibbs_burn=1000;
    end
    if isfield(f.handles,'options')
        handles.options.strict_sample_size=f.handles.options.strict_sample_size;
        handles.options.check_regions=f.handles.options.check_regions;
        if isfield(f.handles.options,'opt_tol')
            handles.options.opt_tol=f.handles.options.opt_tol;
        end
        if isfield(f.handles.options,'opt_iter')
            handles.options.opt_iter=f.handles.options.opt_iter;
        end
    end
    handles.theories=f.handles.theories;
    for t_i=1:length(handles.theories)
        for v_i=1:length(handles.theories{t_i}.vertices)
            if ~isfield(handles.theories{t_i}.vertices{v_i},'name')
                handles.theories{t_i}.vertices{v_i}.name=sprintf('V%i',v_i);
            end
        end
    end
    handles.data=f.handles.data;
    set_idx=1;
    if ~isfield(handles.data,'sets')
        handles.data.sets={};
    else
        if ~isempty(handles.data.sets) && ...
                ~isempty(handles.data.sets{1})
            if ~isfield(handles.data.sets{1},'name')
                %convert to new format
                set_idx=0;
                newsets=cell(length(handles.data.sets),1);
                for i=1:length(newsets)
                    newsets{i}.name=sprintf('Set %i',i);
                    newsets{i}.M=handles.data.sets{i};
                    if isequal(handles.data.M,newsets{i}.M)
                        set_idx=i;
                    end
                end
                handles.data.sets=newsets;
                if set_idx==0
                    handles.data.M=handles.data.sets{1};
                    set_idx=1;
                end
            end
        end
    end
    if ~isfield(handles.spec.from_file,'A_eq')
        handles.spec.from_file.A_eq=[];
        handles.spec.from_file.B_eq=[];
        if isempty(handles.spec.from_file.name)
            handles.spec.from_file.ineq_idx=[];
        else
            handles.spec.from_file.ineq_idx=1:size(handles.spec.from_file.A,2);
        end
    end
    handles.results=f.handles.results;
    guidata(hObject, handles);
    update_ref_vol(handles);
    update_num_gambles(handles);
    update_pairs_list(handles);
    update_data_list(handles,set_idx);
    update_theories_list(handles);
    update_results_list(handles);
    set(handles.edit_lambda,'String',sprintf('%g',handles.spec.lambda));
    set(handles.edit_U_sup,'string',sprintf('%g',handles.spec.U_sup));
    set(handles.edit_U_city,'string',sprintf('%g',handles.spec.U_city));
    set(handles.edit_U_euc,'string',sprintf('%g',handles.spec.U_euc));
    set(handles.edit_N,'string',sprintf('%i',handles.spec.N));
    set(handles.edit_rstate,'string',sprintf('%i',handles.spec.rstate));
    set(handles.pushbutton_M,'string',sprintf('%g',handles.spec.data_M));
    set(handles.edit_spec_file,'string',handles.spec.from_file.name);
    set(handles.edit_gibbs_size,'string',sprintf('%i',handles.spec.gibbs_size));
    set(handles.edit_gibbs_burn,'string',sprintf('%i',handles.spec.gibbs_burn));
    
    if ~isempty(handles.spec.from_file.name)
        if isfield(handles.spec.from_file,'path') && ...
                ~isempty(handles.spec.from_file.path)
             [from_file,msg]=load_spec_file(handles.spec.from_file.name, ...
                 handles.spec.from_file.path, handles);
             if ~isempty(from_file)
                 if ~isequal(from_file.A,handles.spec.from_file.A) || ...
                         ~isequal(from_file.B,handles.spec.from_file.B) || ...
                         ~isequal(from_file.A_eq,handles.spec.from_file.A_eq) || ...
                         ~isequal(from_file.B_eq,handles.spec.from_file.B_eq) || ...
                         ~isequal(from_file.ineq_idx,handles.spec.from_file.ineq_idx) || ...
                         ~isequal(from_file.vertices,handles.spec.from_file.vertices)
                     btn=questdlg(['QTEST has found a valid mixture specification file ', ...
                         sprintf('at %s with different contents, ',[path,file]), ...
                         'would you like to re-load the specifications from this file?'], ...
                         'Reload mixture specification','Yes','No','Yes');
                     if isequal(btn,'Yes')
                         handles.spec.from_file=from_file;
                         guidata(hObject,handles);
                         set(handles.edit_spec_file,'string',handles.spec.from_file.name);
                     end
                 end
             end
        end
    end
end

% --- Executes on button press in pushbutton_hypo.
function pushbutton_hypo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_hypo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.data.M); 
    msgbox('Need data to run the hypothesis tests.','Error','modal');
    return; 
end
h_btn=get(handles.uipanel_prob_spec,'SelectedObject');
h_spec_btn=get(handles.uipanel_run_spec,'SelectedObject');
h_theory_btn=get(handles.uipanel_run_theory,'SelectedObject');
h_type_btn=get(handles.uipanel_run_type,'SelectedObject');
if isempty(handles.theories)
    if isempty(handles.spec.from_file.name)
        if h_btn==handles.radiobutton_from_file && ...
                h_spec_btn==handles.radiobutton_run_sel_spec
            msgbox('Please load specification file first.','Error','modal');
            return;
        else
            msgbox('Please create a theory first.','Error','modal');
            return;
        end
    end
    if h_btn~=handles.radiobutton_from_file && ...
            (h_spec_btn==handles.radiobutton_run_sel_spec || ...
            h_theory_btn==handles.radiobutton_run_sel_theory)
        msgbox('Please create a theory first.','Error','modal');
        return;
    end
else
    if h_btn==handles.radiobutton_from_file && ...
            h_spec_btn==handles.radiobutton_run_sel_spec && ...
            isempty(handles.spec.from_file.name)
        msgbox('Please load specification file first.','Error','modal');
        return;
    end        
end
autosave=0;
if get(handles.checkbox_autosave,'value')>0
    [autosave_file,autosave_path]=uiputfile({'*.mat','MAT-files (*.mat)'; ...
        '*.csv','Comma separated values (*.csv)'; ...
        '*.txt','Text files (*.txt)';'*.*','All Files'},'Auto Save Results As');
    if autosave_file==0
        return;
    end
    autosave=1;
end
% tic
% h=waitbar(0,'Please wait...','WindowStyle','modal','Name', ...
%     'Running Analysis'); %,'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
% pos=get(h,'Position'); pos=[(pos(1)-0.5*pos(3)),(pos(2)+2*pos(4)),pos(3:4)];
% set(h,'Position',pos);
if h_spec_btn==handles.radiobutton_run_sel_spec
    spec_list=h_btn;
else
    if isempty(handles.theories)
        spec_list=handles.radiobutton_from_file;
    else
        spec_list=[handles.radiobutton_from_porta; ...
            handles.radiobutton_major; ...
            handles.radiobutton_sup; ...
            handles.radiobutton_city; ...
            handles.radiobutton_euclid];
        if isequal(get(handles.radiobutton_borda,'enable'),'on')
            spec_list=[spec_list; handles.radiobutton_borda];
        end
        if h_theory_btn~=handles.radiobutton_run_sel_theory ... %all theories
                && ~isempty(handles.spec.from_file.name)
            spec_list=[spec_list; handles.radiobutton_from_file];
        end
    end
end
if spec_list==handles.radiobutton_from_file
    t_i_range=0;
elseif h_theory_btn==handles.radiobutton_run_sel_theory
    t_i_range=get(handles.listbox_theories,'value');
elseif spec_list(end)==handles.radiobutton_from_file
    t_i_range=[(1:length(handles.theories)),0];
else
    t_i_range=1:length(handles.theories);
end
set_idx=get(handles.popupmenu_data,'value');
if isempty(handles.data.sets) || set_idx<1 || set_idx>length(handles.data.sets) ...
        || ~isequal(handles.data.sets{set_idx}.M,handles.data.M)
    data_range=0;
else
    if get(handles.uipanel_run_data,'SelectedObject')==handles.radiobutton_run_sel_data
        data_range=set_idx;
    else
        data_range=1:length(handles.data.sets);
    end
end
%count total
total_test=0;
for t_i=t_i_range
    for s_i=1:length(spec_list)
        h_btn=spec_list(s_i);
        if t_i==0 && h_btn~=handles.radiobutton_from_file; continue; end
        if h_btn==handles.radiobutton_from_file && t_i~=0; continue; end
        for data_idx=data_range
            for test_i=1:3
                if test_i==1 %frequentist test
                    if h_type_btn~=handles.radiobutton_type_frequentist && ...
                            h_type_btn~=handles.radiobutton_type_all
                       continue; 
                    end
                    total_test=total_test+1;
                elseif test_i==2 %bayes factor
                    if h_type_btn~=handles.radiobutton_type_bayesian && ...
                            h_type_btn~=handles.radiobutton_type_all
                        continue;
                    end
                    total_test=total_test+1;
                else
                    if h_type_btn~=handles.radiobutton_type_bayes_p && ...
                        h_type_btn~=handles.radiobutton_type_all
                        continue;
                    end
                    total_test=total_test+1;
                end
            end
        end
    end
end
%build test list
warn_res=cell(total_test,1);
err_res=cell(total_test,1);
test_list=cell(total_test,1);
test_details=zeros(total_test,4);
test_idx=0;
spec_tags=cell(length(spec_list),1);
spec_strings=cell(length(spec_list),1);
for s_i=1:length(spec_list)
    spec_tags{s_i}=get(spec_list(s_i),'Tag');
    spec_strings{s_i}=get(spec_list(s_i),'String');
end
for t_i=t_i_range
    for s_i=1:length(spec_list)
        h_btn=spec_list(s_i);
        if t_i==0 && h_btn~=handles.radiobutton_from_file; continue; end
        if h_btn==handles.radiobutton_from_file && t_i~=0; continue; end
        
        if t_i>0
            theory_txt=handles.theories{t_i}.name;
            spec_txt=get(h_btn,'String');
        else
            theory_txt=handles.spec.from_file.name;
            spec_txt='Random preference'; %'Mixture-based'
        end
        for test_i=1:3
            if test_i==1 %frequentist test
                if h_type_btn~=handles.radiobutton_type_frequentist && ...
                        h_type_btn~=handles.radiobutton_type_all
                    continue;
                end
                test_txt='Frequentist';
            elseif test_i==2 %bayes factor
                if h_type_btn~=handles.radiobutton_type_bayesian && ...
                        h_type_btn~=handles.radiobutton_type_all
                    continue;
                end
                test_txt='Bayes factor';
            else
                if h_type_btn~=handles.radiobutton_type_bayes_p && ...
                        h_type_btn~=handles.radiobutton_type_all
                    continue;
                end
                test_txt='Bayes p & DIC';
            end
            for data_idx=data_range
                if data_idx==0
                    data_txt='Default';
                elseif isfield(handles.data.sets{data_idx},'name')
                    data_txt=handles.data.sets{data_idx}.name;
                else
                    data_txt=sprintf('Set %i',data_idx);
                end
                
                test_idx=test_idx+1;
                test_list{test_idx}=sprintf('%d/%d ... %s ... %s ... %s ... %s ...', ...
                    test_idx,total_test,theory_txt, ...
                    spec_txt,test_txt,data_txt);
                test_details(test_idx,:)=[t_i,s_i,test_i,data_idx];
            end
        end
    end
end
%analysis window
if isempty(handles.analysis_window) || ~ishandle(handles.analysis_window(1)) ...
        || ~isappdata(handles.analysis_window(1),'fig_list')
    max_len=0;
    for i=1:length(test_list)
        max_len=max(length(test_list{i}),max_len);
    end
    fig_list=figure('NumberTitle','off','Name','Running Analysis',...
        'Menubar','none','DockControls','off', ...
        'Units','character','WindowStyle','modal','CloseRequestFcn',@do_nothing);
    pos=get(fig_list,'Position'); pos(3)=max(100,min(300,30+max_len)); pos(4)=20;
    set(fig_list,'Position',pos);
    h_list=uicontrol(fig_list,'Style','listbox','String', ...
        test_list, ...
        'Units','normalized', ...
        'Position',[0,0,1,1]);
    setappdata(fig_list,'fig_list',1);
    handles.analysis_window=[fig_list,h_list];
else
    fig_list=handles.analysis_window(1);
    h_list=handles.analysis_window(2);
    set(fig_list,'Name','Running Analysis','WindowStyle','modal','CloseRequestFcn',@do_nothing);
    set(h_list,'String',test_list);
end
%go through tests
test_groups=unique(test_details(:,1:3),'rows','stable');
total_test_count=0;
for tg_i=1:size(test_groups,1)
    idx=find( sum( ones(total_test,1)*test_groups(tg_i,:) == test_details(:,1:3), 2)==3  );
    this_test_details=test_details(idx, :);
    this_total_test=size(this_test_details,1);
    this_warn_res=cell(this_total_test,1);
    this_err_res=cell(this_total_test,1);
    this_new_portahull=cell(this_total_test,1);
    this_results=cell(this_total_test,1);
    this_test_list=cell(this_total_test,1);
    for i=1:length(idx)
        this_test_list{i}=test_list{idx(i)};
    end
    any_user_cancel=0;
    check_volume=get(handles.checkbox_volume,'value');
    multicore=get(handles.checkbox_multicore,'value');
    if multicore>0
        set(h_list,'String',test_list,'Value',min(total_test,total_test_count+1),'ListBoxTop',max(1,total_test_count-5));
        drawnow;
        open_parallel_pool;
        res_hard=zeros(this_total_test,1);
        parfor test_count=1:this_total_test
            tic
            ttd=this_test_details(test_count,:);
            t_i=ttd(1);
            s_i=ttd(2);
            test_i=ttd(3);
            data_idx=ttd(4);
            if test_i==1 %frequentist test
                [res,msg,new_portahull,user_cancel]=run_hypo_test(t_i,spec_tags{s_i},data_idx,handles,check_volume,multicore);
            elseif test_i==2 %bayes factor
                [res,msg,new_portahull,user_cancel]=run_bayes2_test(t_i,spec_tags{s_i},data_idx,handles,check_volume,multicore);
            else
                [res,msg,new_portahull,user_cancel]=run_bayes_p_test(t_i,spec_tags{s_i},data_idx,handles,check_volume,multicore);
            end
            if ~isempty(new_portahull)
                this_new_portahull{test_count}=new_portahull;
            end
            if ~isempty(res)
                if handles.options.check_regions>0
                    [res.outside,res.overlap]=check_regions(t_i,spec_tags{s_i},handles,check_volume);
                else
                    %res.outside=0; res.overlap=0;
                end
                res_hard(test_count) = check_hard_constraints(t_i,spec_tags{s_i},handles,check_volume);
                res.hard_constraint = res_hard(test_count);
            end
            if isempty(res)
                this_err_res{test_count}.msg=msg;
                if t_i>0
                    this_err_res{test_count}.name=handles.theories{t_i}.name;
                    this_err_res{test_count}.spec=spec_strings{s_i};
                else
                    this_err_res{test_count}.name=handles.spec.from_file.name;
                    this_err_res{test_count}.spec='Random preference'; %'Mixture-based'
                end
            else
                this_results{test_count}=res;
                %             res_n=length(handles.results);
                %             res_n=res_n+1;
                %             handles.results{res_n}=res;
                if isfield(res,'outside') && (res.outside || res.overlap)
                    this_warn_res{test_count}=[res.outside,res.overlap,0,0]; %res_n
                end
                if res_hard(test_count)>0
                    if isempty(this_warn_res{test_count})
                        this_warn_res{test_count}=[0,0,res_hard(test_count),0]; %res_n
                    else
                        this_warn_res{test_count}(3)=res_hard(test_count);
                    end
                end
                %             if autosave>0
                %                 export_results(autosave_file,autosave_path,handles,1);
                %             end
            end
            if user_cancel>0
                cancel_txt='[Canceled] ';
            else
                cancel_txt='';
            end
            err_txt='';
            if ~isempty(this_err_res{test_count})
                err_txt=' [ERR]';
            elseif ~isempty(this_warn_res{test_count})
                err_txt=' [WARN]';
            end
            this_test_list{test_count}=[this_test_list{test_count},sprintf(' DONE%s %s(%.0f secs)',err_txt,cancel_txt,toc)];
            any_user_cancel=max(any_user_cancel, user_cancel);
        end
        for i=1:length(idx)
            test_list{idx(i)} = this_test_list{i};
            %store results
            if ~isempty(this_new_portahull{i})
                handles.theories{this_new_portahull{i}.t_i}.portahull = this_new_portahull{i}.phull;
            end
            if ~isempty(this_results{i})
                res_n=length(handles.results) + 1;
                handles.results{res_n}=this_results{i};
                if ~isempty(this_warn_res{i})
                    this_warn_res{i}(4)=res_n;
                end
            end
        end
        if autosave>0
            export_results(autosave_file,autosave_path,handles,1);
        end
        total_test_count=total_test_count+this_total_test;
    else
        for test_count=1:this_total_test
            set(h_list,'String',test_list,'Value',min(total_test,total_test_count+1),'ListBoxTop',max(1,total_test_count-5));
            drawnow;
            tic
            ttd=this_test_details(test_count,:);
            t_i=ttd(1);
            s_i=ttd(2);
            test_i=ttd(3);
            data_idx=ttd(4);
            if test_i==1 %frequentist test
                [res,msg,new_portahull,user_cancel]=run_hypo_test(t_i,spec_tags{s_i},data_idx,handles,check_volume,multicore);
            elseif test_i==2 %bayes factor
                [res,msg,new_portahull,user_cancel]=run_bayes2_test(t_i,spec_tags{s_i},data_idx,handles,check_volume,multicore);
            else
                [res,msg,new_portahull,user_cancel]=run_bayes_p_test(t_i,spec_tags{s_i},data_idx,handles,check_volume,multicore);
            end
            if ~isempty(new_portahull)
                handles.theories{new_portahull.t_i}.portahull = new_portahull.phull;
            end
            if ~isempty(res)
                if handles.options.check_regions>0
                    [res.outside,res.overlap]=check_regions(t_i,spec_tags{s_i},handles,check_volume);
                else
                    %res.outside=0; res.overlap=0;
                end
                res_hard = check_hard_constraints(t_i,spec_tags{s_i},handles,check_volume);
                res.hard_constraint = res_hard;
            end
            if isempty(res)
                this_err_res{test_count}.msg=msg;
                if t_i>0
                    this_err_res{test_count}.name=handles.theories{t_i}.name;
                    this_err_res{test_count}.spec=spec_strings{s_i};
                else
                    this_err_res{test_count}.name=handles.spec.from_file.name;
                    this_err_res{test_count}.spec='Random preference'; %'Mixture-based'
                end
            else
                res_n=length(handles.results) + 1;
                handles.results{res_n}=res;
                if isfield(res,'outside') && (res.outside || res.overlap)
                    this_warn_res{test_count}=[res.outside,res.overlap,0,res_n];
                end
                if res_hard>0
                    if isempty(this_warn_res{test_count})
                        this_warn_res{test_count}=[0,0,res_hard,res_n];
                    else
                        this_warn_res{test_count}(3)=res_hard;
                    end
                end
                if autosave>0
                    export_results(autosave_file,autosave_path,handles,1);
                end
            end
            if user_cancel>0
                cancel_txt='[Canceled] ';
            else
                cancel_txt='';
            end
            err_txt='';
            if ~isempty(this_err_res{test_count})
                err_txt=' [ERR]';
            elseif ~isempty(this_warn_res{test_count})
                err_txt=' [WARN]';
            end
            test_list{idx(test_count)}=[this_test_list{test_count},sprintf(' DONE%s %s(%.0f secs)',err_txt,cancel_txt,toc)];
            total_test_count=total_test_count+1;
            any_user_cancel=max(any_user_cancel, user_cancel);
            if user_cancel>0 && (tg_i<size(test_groups,1) || test_count<this_total_test)
                button=questdlg('Would you like to cancel all remaining tests?','CANCEL','YES','NO','NO');
                if isequal(button,'YES')
                    break;
                end
            end
        end
    end
    set(h_list,'String',test_list,'Value',min(total_test,total_test_count+1),'ListBoxTop',max(1,total_test_count-5));
    for i=1:length(idx)
        warn_res{idx(i)} = this_warn_res{i};
        err_res{idx(i)} = this_err_res{i};
    end
    if any_user_cancel>0
        break;
    end
end
guidata(hObject,handles);
set(fig_list,'WindowStyle','normal','Name','Running Analysis (DONE)','CloseRequestFcn',@do_close);
%delete(fig_list);
%delete(h);
update_results_list(handles);

%error
err_msg=cell(length(err_res),1);
for i=1:length(err_res)
    if ~isempty(err_res{i})
        err_msg{i}=sprintf('%s - %s\n   %s\n\n', ...
            err_res{i}.name,err_res{i}.spec,err_res{i}.msg);
    end
end
err_msg = unique(err_msg(~cellfun('isempty',err_msg)), 'stable');
if ~isempty(err_msg)
    h=msgbox([sprintf('The following test(s) failed:\n\n'); err_msg], ...
        'Error','modal');
    uiwait(h);
end
%warning
warn_res=cell2mat(warn_res(~cellfun('isempty',warn_res)));
if ~isempty(warn_res)
    warn_msg1=[];
    if sum(warn_res(:,1)>0)
        idx=find(warn_res(:,1)>0);
        warn_msg=cell(length(idx),1);
        for i=1:length(idx)
            warn_msg{i}=sprintf('   %s - %s\n', ...
                    handles.results{warn_res(idx(i),4)}.theory.name, ...
                    handles.results{warn_res(idx(i),4)}.spec);
        end
        warn_msg1=[sprintf('There exists volume outside the unit hypercube in:\n'); unique(warn_msg,'stable')];
    end
    if sum(warn_res(:,2)>0)
        idx=find(warn_res(:,2)>0);
        warn_msg=cell(length(idx),1);
        for i=1:length(idx)
            warn_msg{i}=sprintf('   %s - %s\n', ...
                    handles.results{warn_res(idx(i),4)}.theory.name, ...
                    handles.results{warn_res(idx(i),4)}.spec);
        end
        if isempty(warn_msg1)
            warn_msg1=[sprintf('There exist overlapping volumes in:\n'); unique(warn_msg,'stable')];
        else
            warn_msg1=[warn_msg1; sprintf('\nThere exist overlapping volumes in:\n'); unique(warn_msg,'stable')];
        end
    end
    if sum(warn_res(:,3)>0)
        idx=find(warn_res(:,3)>0);
        warn_msg=cell(length(idx),1);
        for i=1:length(idx)
            warn_msg{i}=sprintf('   %s - %s\n', ...
                    handles.results{warn_res(idx(i),4)}.theory.name, ...
                    handles.results{warn_res(idx(i),4)}.spec);
        end
        if isempty(warn_msg1)
            warn_msg1=[sprintf('Hard (0 or 1) constraint in at least one dimension in:\n'); unique(warn_msg,'stable')];
        else
            warn_msg1=[warn_msg1; sprintf('\nHard (0 or 1) constraint in at least one dimension in:\n'); unique(warn_msg,'stable')];
        end
    end
    warn_msg1=[warn_msg1; sprintf('\nTest results could be misleading!')];
    msgbox(warn_msg1,'Warning','modal');
end

% h=msgbox(sprintf('Total time: %.1f seconds',toc), ...
%     'Done','modal');
% uiwait(h);


function check_all_regions(all_t_i,all_h_btn,handles)
if isempty(all_t_i)
    all_t_i=1:length(handles.theories);
end
if isempty(all_h_btn)
    all_h_btn=[handles.radiobutton_major, handles.radiobutton_borda, ...
        handles.radiobutton_sup, handles.radiobutton_city, ...
        handles.radiobutton_euclid];
end
warn_res=[];
for t_i=all_t_i
    for h_btn=all_h_btn
        [outside,overlap]=check_regions(t_i,get(h_btn,'Tag'),handles,get(handles.checkbox_volume,'value'));
        if outside || overlap
            warn_res=[warn_res; outside,overlap,t_i,h_btn];
        end
    end
end
%warning
if ~isempty(warn_res)
    warn_msg=[];
    if sum(warn_res(:,1)>0)
        warn_msg=sprintf('There exists volume outside the unit hypercube in:\n');
        for i=1:size(warn_res,1)
            if warn_res(i,1)
                warn_msg=[warn_msg,sprintf('   %s - %s\n', ...
                    handles.theories{warn_res(i,3)}.name, ...
                    get(warn_res(i,4),'String'))];
            end
        end
    end
    if sum(warn_res(:,2)>0)
        warn_msg=[warn_msg,sprintf('\nThere exist overlapping volumes in:\n')];
        for i=1:size(warn_res,1)
            if warn_res(i,2)
                warn_msg=[warn_msg,sprintf('   %s - %s\n', ...
                    handles.theories{warn_res(i,3)}.name, ...
                    get(warn_res(i,4),'String'))];
            end
        end
    end
    warn_msg=[warn_msg,sprintf('\nTest results could be misleading!')];
    msgbox(warn_msg,'Warning','modal');
end

function f=check_hard_obj(obj,A,B,Aeq,Beq)
f=[];
l_scale='on';
max_iter=85;
while 1
    options_lin=optimset('LargeScale',l_scale,'Display','off','MaxIter',max_iter);
    [~,f,exitflag]=linprog(obj,A,B,Aeq,Beq,[],[],options_lin);
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
        f=[];
        return;
    end
    break;
end

function h = check_hard_constraints(t_i,tag,handles,check_volume)
h=0;
if isequal(tag,'radiobutton_from_porta') || isequal(tag,'radiobutton_from_file')
    [A_all,b_all,params,new_portahull,A_eq,b_eq,ineq_idx]=prob_spec(tag,t_i,handles,check_volume);
    %must have only 1 polytope!
    if isempty(A_all) || isempty(A_all{1})
        return;
    end
    if isempty(A_eq)
        Aeq=[];
        Beq=[];
    else
        Aeq=A_eq{1};
        Beq=b_eq{1};
    end
    n=size(handles.gambles.pairs,1);
    cube_A=[eye(n); -eye(n)];
    cube_B=[ones(n,1); zeros(n,1)];
    A=[cube_A; A_all{1}];
    B=[cube_B; b_all{1}];
    
    for i=1:n
        obj=zeros(1,size(A,2));
        obj(i)=-1; %max
        f=check_hard_obj(obj,A,B,Aeq,Beq);
        if isempty(f)
            continue;
        end
        if abs(f)<1e-6
            h=1;
            return;
        end
        obj(i)=1; %min
        f=check_hard_obj(obj,A,B,Aeq,Beq);
        if isempty(f)
            continue;
        end
        if abs(f-1)<1e-6
            h=1;
            return;
        end
    end
end



function [outside,overlap]=check_regions(t_i,tag,handles,check_volume)
%check for overlapping and/or out-of-box regions
% on vertices of theory t_i with respect to
% probabilistic specification (of radiobutton handle h_btn -- now the tag)
outside=0; overlap=0;
if isequal(tag,'radiobutton_from_porta')
    return;
end
if ~isequal(tag,'radiobutton_from_file')
    n_vert=length(handles.theories{t_i}.vertices);
    if n_vert==0
        return;
    end
end
if isequal(tag,'radiobutton_euclid')
    n=size(handles.gambles.pairs,1);
    w_total=0;
    for v_i=1:n_vert
        w_total=w_total+handles.theories{t_i}.vertices{v_i}.w;
    end
    if w_total==0 && check_volume>0
        return; 
    end
    params=zeros(n_vert,1);
    for i=1:n_vert
        if check_volume>0
            rvol_i=handles.theories{t_i}.vertices{i}.w/w_total;
            if rvol_i==0; continue; end
            vert=handles.theories{t_i}.vertices{i}.pairs(:,3)';
            if all((vert==0)|(vert==1))                
                U=exp( (log(rvol_i)+handles.spec.log_ref_vol-n/2*log(pi)+...
                    gammaln(n/2+1)+n*log(2))/n );
            else
                U=search_volume('radiobutton_euclid',vert,exp(log(rvol_i)+handles.spec.log_ref_vol));
            end
        else
            %U=rvol_i^(1/n)*handles.spec.U_euc;
            U=handles.spec.U_euc;
        end
        params(i)=U;
    end
    
    %out of unit hypercube
    if sum(params>1)>0
        outside=1;
    end
    %overlap
    for i=1:n_vert
        if params(i)<=0; continue; end
        vert_i=handles.theories{t_i}.vertices{i}.pairs(:,3)';
        for j=(i+1):n_vert
            if params(j)<=0; continue; end
            vert_j=handles.theories{t_i}.vertices{j}.pairs(:,3)';
            if norm(vert_i-vert_j)<params(i)+params(j)
                overlap=1;
                break;
            end
        end
        if overlap; break; end
    end
else
    [A_all,b_all,params]=prob_spec(tag,t_i,handles,check_volume);
    if isempty(A_all)
        return;
    end
    has_valid=0;
    for i=1:length(A_all)
        if ~isempty(A_all{i});
            has_valid=1;
        end
    end
    if ~has_valid
        return;
    end
    
    %out of unit hypercube
    if ~isempty(params)
        if isequal(tag,'radiobutton_major')
            if sum(params<0)>0
                outside=1;
            end
        else
            if sum(params>1)>0
                outside=1;
            end
        end
    end
    %overlap
    n=size(handles.gambles.pairs,1);
    for i=1:length(A_all)
        if isempty(A_all{i}); continue; end
        for j=(i+1):length(A_all)
            if isempty(A_all{j}); continue; end
            
            V=porta_extreme([A_all{i}; A_all{j}; eye(n); -eye(n)],[b_all{i}; b_all{j}; ones(n,1); zeros(n,1)]);
            if ~isempty(V)
                n_v=size(V,1);
                v1=ones(n_v-1,1)*V(1,:);
                v2=V(2:end,:)-v1;
                if rank(v2)>=n
                    overlap=1; break;
                end
            end
        end
        if overlap; break; end
    end
end

function [res,msg,new_portahull,user_cancel]=run_bayes2_test(t_i,tag,set_idx,handles,check_volume,multicore)
%performs bayes factor (bayes2) test on theory t_i and
% probabilistic specification (of radiobutton handle h_btn -- now the tag)
res=[]; msg=[]; new_portahull=[]; user_cancel=0;
if ~isequal(tag,'radiobutton_from_file')
    n_vert=length(handles.theories{t_i}.vertices);
    if n_vert==0
        msg='Need at least 1 vertex defined';
        return;
    end
end

if isequal(tag,'radiobutton_euclid')
    msg='Bayesian test for the Euclidean distance specification currently not supported';
    return;
else
    [A_all,b_all,params,new_portahull,A_eq,b_eq,ineq_idx]=prob_spec(tag,t_i,handles,check_volume);
    if isempty(A_all)
        msg='No valid vertex/probabilistic specification';
        return;
    end
    has_valid=0;
    for i=1:length(A_all)
        if ~isempty(A_all{i});
            has_valid=1;
        end
    end
    if ~has_valid
        msg='No valid vertex/probabilistic specification';
        return;
    end

    res.type='bayes_factor';
    if isequal(tag,'radiobutton_from_file')
        res.theory.name=handles.spec.from_file.name;
    else
        res.theory=handles.theories{t_i};
    end
    switch tag
        case 'radiobutton_major'
            res.spec='major';
            res.U=0;
        case 'radiobutton_borda'
            res.spec='borda';
            res.U=0;
        case 'radiobutton_sup'
            res.spec='sup';
            res.U=handles.spec.U_sup;
        case 'radiobutton_city'
            res.spec='city';
            res.U=handles.spec.U_city;
        case 'radiobutton_from_file'
            res.spec='file';
            res.U=0;
        case 'radiobutton_from_porta'
            res.spec='mixture';
            res.U=0;
    end
    res.lambda=handles.spec.lambda;
    res.use_ref=check_volume;
    res.log_ref_vol=handles.spec.log_ref_vol;
    if set_idx==0
        res.M=handles.data.M;
    else
        res.M=handles.data.sets{set_idx}.M;
        res.sets_M=handles.data.sets{set_idx};
    end
    if size(res.M,2)>1  %matrix version
        res_M=cell2mat(res.M');
    else
        res_M=cell2mat(res.M);
    end
    res.A=A_all{i};
    res.b=b_all{i};
    if isempty(A_eq)
        res.A_eq=[];
        res.b_eq=[];
        res.ineq_idx=1:size(A_all{i},2);
    else
        res.A_eq=A_eq{i};
        res.b_eq=b_eq{i};
        res.ineq_idx=ineq_idx;
    end
    res.params=params;
    res.N=handles.spec.N;
    res.rstate=handles.spec.rstate;
    res.gibbs_size=handles.spec.gibbs_size;
    res.gibbs_burn=handles.spec.gibbs_burn;
    res.res=cell(length(A_all),1);
    %hypercube boundary
    n=size(handles.gambles.pairs,1);
    cube_A=[eye(n); -eye(n)];
    cube_B=[ones(n,1); zeros(n,1)];
    n_vertices=0;
    for i=1:length(A_all)
        if isempty(A_all{i}); continue; end
        n_vertices=n_vertices+1;
    end
    vertex_i=0;
    for i=1:length(A_all)
        if isempty(A_all{i}); continue; end
        if n_vertices>1
            vertex_i=vertex_i+1;
            vertex_txt=sprintf(' (vertex %d/%d)',vertex_i,n_vertices);
        else
            vertex_txt='';
        end
        if isempty(A_eq)
            Aeq=[];
            Beq=[];
        else
            Aeq=A_eq{i};
            Beq=b_eq{i};
        end
        if isempty(ineq_idx)
            ineq_idx=1:size(A_all{i},2);
        end
        if isequal(res.spec,'major')
            res.res{i}.bayes_exact=bayes_factor_super(res_M, ...
                res.theory.vertices{i}.pairs(:,3),params(i));
            res.res{i}.prior_vol=(1-params(i))^n;
            res.res{i}.post_vol=res.res{i}.bayes_exact*res.res{i}.prior_vol;
        else
            if multicore>0
                progress_txt=[];
            else
                progress_txt=['Computing Bayes Factor',vertex_txt];
            end
            [bayes2,bayes2_ext]=bayes_factor_2(res_M,[cube_A; A_all{i}],[cube_B; b_all{i}], ...
                Aeq,Beq,ineq_idx,handles.spec.gibbs_size,handles.spec.rstate, ...
                0,progress_txt);
            user_cancel=bayes2_ext(end,3);
            if bayes2_ext(end,1)<res.gibbs_size
                res.res{i}.n_done=bayes2_ext(end,1);
            end
            res.res{i}.bayes2=bayes2;
            res.res{i}.bayes2_ext=bayes2_ext;
            if isempty(res.res{i}.bayes2)
                res=[];
                msg='Infeasible data point (probability zero?)';
                return;
            end
        end
        res.res{i}.sample=[]; %samples no longer saved
    end
    if isequal(res.spec,'major') && length(A_all)>1
        %compute weighted statistics
        res.weighted_res=supermajority_weighted_bayes2_test(res.res);
    end
end


function [res,msg,new_portahull,user_cancel]=run_bayes_p_test(t_i,tag,set_idx,handles,check_volume,multicore)
%performs bayesian test on theory t_i and
% probabilistic specification (of radiobutton handle h_btn -- now the tag)
res=[]; msg=[]; new_portahull=[]; user_cancel=0;
if ~isequal(tag,'radiobutton_from_file')
    n_vert=length(handles.theories{t_i}.vertices);
    if n_vert==0
        msg='Need at least 1 vertex defined';
        return;
    end
end

if isequal(tag,'radiobutton_euclid')
    msg='Bayesian test for the Euclidean distance specification currently not supported';
    return;
else
    [A_all,b_all,params,new_portahull,A_eq,b_eq,ineq_idx]=prob_spec(tag,t_i,handles,check_volume);
    if isempty(A_all)
        msg='No valid vertex/probabilistic specification';
        return;
    end
    has_valid=0;
    for i=1:length(A_all)
        if ~isempty(A_all{i});
            has_valid=1;
        end
    end
    if ~has_valid
        msg='No valid vertex/probabilistic specification';
        return;
    end

    res.type='bayes_p';
    if isequal(tag,'radiobutton_from_file')
        res.theory.name=handles.spec.from_file.name;
    else
        res.theory=handles.theories{t_i};
    end
    switch tag
        case 'radiobutton_major'
            res.spec='major';
            res.U=0;
        case 'radiobutton_borda'
            res.spec='borda';
            res.U=0;
        case 'radiobutton_sup'
            res.spec='sup';
            res.U=handles.spec.U_sup;
        case 'radiobutton_city'
            res.spec='city';
            res.U=handles.spec.U_city;
        case 'radiobutton_from_file'
            res.spec='file';
            res.U=0;
        case 'radiobutton_from_porta'
            res.spec='mixture';
            res.U=0;
    end
    res.lambda=handles.spec.lambda;
    res.use_ref=check_volume;
    res.log_ref_vol=handles.spec.log_ref_vol;
    if set_idx==0
        res.M=handles.data.M;
    else
        res.M=handles.data.sets{set_idx}.M;
        res.sets_M=handles.data.sets{set_idx};
    end
    if size(res.M,2)>1  %matrix version
        res_M=cell2mat(res.M');
    else
        res_M=cell2mat(res.M);
    end
    res.A=A_all{i};
    res.b=b_all{i};
    if isempty(A_eq)
        res.A_eq=[];
        res.b_eq=[];
        res.ineq_idx=1:size(A_all{i},2);
    else
        res.A_eq=A_eq{i};
        res.b_eq=b_eq{i};
        res.ineq_idx=ineq_idx;
    end
    res.params=params;
    res.N=handles.spec.N;
    res.rstate=handles.spec.rstate;
    res.gibbs_size=handles.spec.gibbs_size;
    res.gibbs_burn=handles.spec.gibbs_burn;
    res.res=cell(length(A_all),1);
    %hypercube boundary
    n=size(handles.gambles.pairs,1);
    cube_A=[eye(n); -eye(n)];
    cube_B=[ones(n,1); zeros(n,1)];
    n_vertices=0;
    for i=1:length(A_all)
        if isempty(A_all{i}); continue; end
        n_vertices=n_vertices+1;
    end
    vertex_i=0;
    for i=1:length(A_all)
        if isempty(A_all{i}); continue; end
        if n_vertices>1
            vertex_i=vertex_i+1;
            vertex_txt=sprintf(' (vertex %d/%d)',vertex_i,n_vertices);
        else
            vertex_txt='';
        end
        if isempty(A_eq)
            Aeq=[];
            Beq=[];
        else
            Aeq=A_eq{i};
            Beq=b_eq{i};
        end
        if isempty(ineq_idx)
            ineq_idx=1:size(A_all{i},2);
        end
        if multicore>0 
            progress_txt=[];
        else
            progress_txt=['Computing Bayes p & DIC',vertex_txt];
        end
        [p,D,pD_ext]=bayes_p_dic(res_M,[cube_A; A_all{i}],[cube_B; b_all{i}], ...
            Aeq,Beq,ineq_idx,handles.spec.gibbs_size,handles.spec.gibbs_burn, ...
            handles.spec.rstate,progress_txt);
        sample=[]; %samples no longer saved
        if isempty(p)
            res=[];
            msg='Infeasible data point (probability zero?)';
            return;
        end
        user_cancel=pD_ext(end,4);
        if pD_ext(end,1)<res.gibbs_size
            res.res{i}.n_done=pD_ext(end,1);
        end
        res.res{i}.p=p;
        res.res{i}.D=D;
        res.res{i}.pD_ext=pD_ext;
        res.res{i}.sample=sample;
        if isequal(res.spec,'major')
            res.res{i}.bayes_exact=bayes_factor_super(res_M, ...
                res.theory.vertices{i}.pairs(:,3),params(i));
            res.res{i}.prior_vol=(1-params(i))^n;
            res.res{i}.post_vol=res.res{i}.bayes_exact*res.res{i}.prior_vol;
        end
    end
    if isequal(res.spec,'major') && length(A_all)>1
        %compute weighted statistics
        res.weighted_res=supermajority_weighted_test(res_M,res.res);
    end
end

function wres=supermajority_weighted_bayes2_test(res)
%%%% bayes factor
total_w=0;
for i=1:length(res)
    if isempty(res{i}); continue; end
    total_w=total_w+res{i}.prior_vol;
end
wres.bayes_exact=0;
for i=1:length(res)
    if isempty(res{i}); continue; end
    w=res{i}.prior_vol/total_w;
    wres.bayes_exact=wres.bayes_exact+w*res{i}.bayes_exact;
end

function wres=supermajority_weighted_test(m,res)
%%%% bayes factor
total_w=0;
for i=1:length(res)
    if isempty(res{i}); continue; end
    total_w=total_w+res{i}.prior_vol;
end
wres.bayes_exact=0;
for i=1:length(res)
    if isempty(res{i}); continue; end
    w=res{i}.prior_vol/total_w;
    wres.bayes_exact=wres.bayes_exact+w*res{i}.bayes_exact;
end
%%%% p, DIC
total_w=0;
for i=1:length(res)
    if isempty(res{i}); continue; end
    total_w=total_w+res{i}.post_vol;
end
wres.p=0;
thetabar=zeros(1,size(m,1));
DBarTheta=0;
for i=1:length(res)
    if isempty(res{i}); continue; end
    w=res{i}.post_vol/total_w;
    % p-value
    wres.p=wres.p+w*res{i}.p;
    % DIC
    %thetabar=thetabar+w*mean(res{i}.sample,1);
    thetabar=thetabar+w*res{i}.D.thetabar;
    DBarTheta=DBarTheta+w*(res{i}.D.GOF+0.5*res{i}.D.complexity);
end    
%compute deviance discrepancy functionv(DDF) of thetabar := "DThetaBar"
m_total=sum(m,2)';
n = m(:,1)';
DThetaBar = 2*sum( n.*log( (n+0.5)./(m_total.*thetabar+0.5) ) + ...
    (m_total-n).*log( (m_total-n+0.5)./(m_total-m_total.*thetabar+0.5) ));
wres.D.GOF=DThetaBar; % (lack of) Goodness of Fit
wres.D.complexity = 2*(DBarTheta-DThetaBar); %Penalty assessed for less complex models
wres.D.DIC= wres.D.GOF + wres.D.complexity; %DIC




function [res,msg,new_portahull,user_cancel]=run_hypo_test(t_i,tag,set_idx,handles,check_volume,multicore)
%performs a single hypothesis test on theory t_i and
% probabilistic specification (of radiobutton handle h_btn -- now the tag)
res=[]; msg=[]; new_portahull=[]; user_cancel=0;
if ~isequal(tag,'radiobutton_from_file')
    n_vert=length(handles.theories{t_i}.vertices);
    if n_vert==0
        msg='Need at least 1 vertex defined';
        return;
    end
end

if isequal(tag,'radiobutton_euclid')
    n=size(handles.gambles.pairs,1);
    w_total=0;
    for v_i=1:n_vert
        w_total=w_total+handles.theories{t_i}.vertices{v_i}.w;
    end
    if w_total==0 && check_volume>0
        msg='Total weight is zero';
        return; 
    end
    
    res.type='frequentist';
    res.theory=handles.theories{t_i};
    res.spec='euclid';
    res.lambda=handles.spec.lambda;
    res.U=handles.spec.U_euc;
    res.use_ref=check_volume;
    res.log_ref_vol=handles.spec.log_ref_vol;
    if set_idx==0
        res.M=handles.data.M;
    else
        res.M=handles.data.sets{set_idx}.M;
        res.sets_M=handles.data.sets{set_idx};
    end
    res.A=[];
    res.b=[];
    res.params=zeros(n_vert,1);
    res.N=handles.spec.N;
    res.rstate=handles.spec.rstate;
    res.res=cell(n_vert,1);
    for i=1:n_vert
        if check_volume>0
            rvol_i=handles.theories{t_i}.vertices{i}.w/w_total;
            if rvol_i==0; continue; end
            vert=handles.theories{t_i}.vertices{i}.pairs(:,3)';
            if all((vert==0)|(vert==1))                
                U=exp( (log(rvol_i)+handles.spec.log_ref_vol-n/2*log(pi)+...
                    gammaln(n/2+1)+n*log(2))/n );
            else
                U=search_volume('radiobutton_euclid',vert,exp(log(rvol_i)+handles.spec.log_ref_vol));
            end
        else
            %U=rvol_i^(1/n)*handles.spec.U_euc;
            U=handles.spec.U_euc;
        end
        if n_vert>1
            vertex_txt=sprintf(' (vertex %d/%d)',i,n_vert);
        else
            vertex_txt='';
        end
        res.params(i)=U;
        vert=handles.theories{t_i}.vertices{i}.pairs(:,3)';
        if multicore>0 
            progress_txt=[];
        else
            progress_txt=['Frequentist test',vertex_txt]; 
        end
        [x,L,w,p,mc_msg,n_done]=mult_con_euclid(res.M,vert,U,handles.spec.N, ...
            handles.spec.rstate,handles.options.opt_tol,handles.options.opt_iter, ...
            progress_txt);
        user_cancel=n_done(2); n_done=n_done(1);
        res.res{i}.x=x;
        res.res{i}.L=L;
        res.res{i}.w=w;
        res.res{i}.p=p;
        res.res{i}.msg=mc_msg;
        res.res{i}.n_done=n_done;
    end
else
    [A_all,b_all,params,new_portahull,A_eq,b_eq]=prob_spec(tag,t_i,handles,check_volume);
    if isempty(A_all)
        msg='No valid vertex/probabilistic specification';
        return;
    end
    has_valid=0;
    for i=1:length(A_all)
        if ~isempty(A_all{i});
            has_valid=1;
            if ~isempty(A_eq) && ~isempty(A_eq{i})
                msg='Equalities in probabilistic specification -- skip frequentist test';
                return;
            end
        end
    end
    if ~has_valid
        msg='No valid vertex/probabilistic specification';
        return;
    end

    res.type='frequentist';
    if isequal(tag,'radiobutton_from_file')
        res.theory.name=handles.spec.from_file.name;
    else
        res.theory=handles.theories{t_i};
    end
    switch tag
        case 'radiobutton_major'
            res.spec='major';
            res.U=0;
        case 'radiobutton_borda'
            res.spec='borda';
            res.U=0;
        case 'radiobutton_sup'
            res.spec='sup';
            res.U=handles.spec.U_sup;
        case 'radiobutton_city'
            res.spec='city';
            res.U=handles.spec.U_city;
        case 'radiobutton_from_file'
            res.spec='file';
            res.U=0;
        case 'radiobutton_from_porta'
            res.spec='mixture';
            res.U=0;
    end
    res.lambda=handles.spec.lambda;
    res.use_ref=check_volume;
    res.log_ref_vol=handles.spec.log_ref_vol;
    if set_idx==0
        res.M=handles.data.M;
    else
        res.M=handles.data.sets{set_idx}.M;
        res.sets_M=handles.data.sets{set_idx};
    end
    res.A=A_all{i};
    res.b=b_all{i};
    res.params=params;
    res.N=handles.spec.N;
    res.rstate=handles.spec.rstate;
    res.res=cell(length(A_all),1);
    n_vertices=0;
    for i=1:length(A_all)
        if isempty(A_all{i}); continue; end
        n_vertices=n_vertices+1;
    end
    vertex_i=0;
    for i=1:length(A_all)
        if isempty(A_all{i}); continue; end
        if n_vertices>1
            vertex_i=vertex_i+1;
            vertex_txt=sprintf(' (vertex %d/%d)',vertex_i,n_vertices);
        else
            vertex_txt='';
        end
        if multicore>0 
            progress_txt=[];
        else
            progress_txt=['Frequentist test',vertex_txt]; 
        end
        [x,L,w,p,mc_msg,n_done]=mult_con(res.M,A_all{i},b_all{i},handles.spec.N, ...
            handles.spec.rstate,handles.options.opt_tol, ...
            progress_txt); %,handles.options.opt_iter);
        if isempty(p)
            res=[];
            msg='Infeasible data point (probability zero?)';
            return;
        end
        user_cancel=n_done(2); n_done=n_done(1);
        res.res{i}.x=x;
        res.res{i}.L=L;
        res.res{i}.w=w;
        res.res{i}.p=p;
        res.res{i}.msg=mc_msg;
        res.res{i}.n_done=n_done;
    end
end



% --- Executes on button press in pushbutton_N.
function pushbutton_N_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_N (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

def=sprintf('%g',handles.spec.N);
answer=inputdlg('Sampling Size:','Chi-bar squared Weights',1,{def});
if isempty(answer); return; end
N=str2double(answer{1});
if isempty(N) || ~isfinite(N); return; end
N=floor(N);
if N<=0
    msgbox('N must be positive','Error','modal');
    return;
end
handles.spec.N=N;
guidata(hObject, handles);
set(handles.edit_N,'string',sprintf('%i',N));


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles_ori)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path]=uiputfile('*.mat','Save Data As');
if file~=0
    qtest_version='1.0';
    try
        handles.gambles=handles_ori.gambles;
        handles.spec=handles_ori.spec;
        handles.options=handles_ori.options;
        handles.theories=handles_ori.theories;
        handles.data=handles_ori.data;
        handles.results=handles_ori.results;
        save([path,file],'handles','qtest_version');
    catch ME
        msgbox(ME.message,'Error','modal');
    end
end

% --- Executes during object creation, after setting all properties.
function pushbutton_generate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_M.
function pushbutton_M_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

def=sprintf('%g',handles.spec.data_M);
answer=inputdlg('Observations per pair:','Data Generation',1,{def});
if isempty(answer); return; end
m=str2double(answer{1});
if isempty(m) || ~isfinite(m); return; end
m=floor(m);
if m<=0
    msgbox('Must be positive','Error','modal');
    return;
end
handles.spec.data_M=m;
guidata(hObject, handles);
set(handles.pushbutton_M,'string',sprintf('%g',m));


% --- Executes during object creation, after setting all properties.
function pushbutton_N_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_N (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton_U_sup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_U_sup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_enter.
function pushbutton_enter_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_enter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

n=size(handles.data.pairs,1);
if n<1
    return;
end
ori_M=handles.data.M;

[handles,new_set]=enter_data(handles);
if ~isempty(handles)
    set_idx=get(handles.popupmenu_data,'value');
    if new_set
        if isempty(handles.data.sets)
            if ~isempty(ori_M)
                handles.data.sets{1}.name=sprintf('Set 1');
                handles.data.sets{1}.M=ori_M;
                set_idx=2;
            else
                set_idx=1;
            end
        else
            set_idx=length(handles.data.sets)+1;
        end
        handles.data.sets{set_idx}.name=sprintf('Set %i',set_idx);
        handles.data.sets{set_idx}.M=handles.data.M;
        [handles.spec.data_M,data_M_str]=get_spec_data_M(handles.data.M);
        guidata(hObject,handles);
        set(handles.pushbutton_M,'string',data_M_str);
        update_data_list(handles,set_idx);
    else
        if ~isempty(handles.data.sets) && ...
                set_idx>=1 && set_idx<=length(handles.data.sets)
            handles.data.sets{set_idx}.name=sprintf('Set %i',set_idx);
            handles.data.sets{set_idx}.M=handles.data.M;
            [handles.spec.data_M,data_M_str]=get_spec_data_M(handles.data.M);
            guidata(hObject,handles);
            set(handles.pushbutton_M,'string',data_M_str);
            update_data_list(handles,set_idx);
        else
            [handles.spec.data_M,data_M_str]=get_spec_data_M(handles.data.M);
            guidata(hObject,handles);
            set(handles.pushbutton_M,'string',data_M_str);
            update_data_list(handles);
        end
    end
end

function [data_M,data_M_str]=get_spec_data_M(M)
s=zeros(length(M),1);
for i=1:length(M)
    s(i)=sum(M{i});
end
data_M=min(s);
if data_M<max(s)
    data_M_str=sprintf('%d-%d',data_M,max(s));
else
    data_M_str=sprintf('%d',data_M);
end

% --- Executes on button press in pushbutton_visual.
function pushbutton_visual_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_visual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.gambles.ID); return; end
if size(handles.gambles.pairs,1)~=3
    msgbox('For 3-D only','Error','modal');
    return;
end
h_btn=get(handles.uipanel_prob_spec,'SelectedObject');
if isempty(handles.theories) && h_btn~=handles.radiobutton_from_file
    msgbox('Please create a theory first.','Error','modal');
    return;
end
col_scheme=get(handles.popupmenu_color,'value');
col_map=[0,0,0; ...
    1,0.5,0.5; 0.5,1,0.5; 0.5,0.5,1; ...
    1,1,0.5; 0.5,1,1; 1,0.5,1; ...
    0.5,0.5,0.5; 1,1,1; autumn];

invalid_vert=[];
t_i=get(handles.listbox_theories,'value');
if h_btn==handles.radiobutton_euclid
    n=size(handles.gambles.pairs,1);
    n_vert=length(handles.theories{t_i}.vertices);
    for v_i=1:n_vert
        vert=handles.theories{t_i}.vertices{v_i}.pairs(:,3);
        if ~all((vert==0)|(vert==1))
            msgbox('Visualization of Euclidean non-0/1 vertices not supported.','Error','modal');
            return;
        end
    end
    w_total=0;
    for v_i=1:n_vert
        w_total=w_total+handles.theories{t_i}.vertices{v_i}.w;
    end
    if w_total==0 && get(handles.checkbox_volume,'value')>0
        return;
    end
    if get(handles.checkbox_same_figure,'value')>0
        set(handles.mother_figure,'HandleVisibility','off');
        figure(gcf);
        set(handles.mother_figure,'HandleVisibility','callback');
    else
        figure;
    end
    for v_i=1:n_vert
        if get(handles.checkbox_volume,'value')>0
            rvol_i=handles.theories{t_i}.vertices{v_i}.w/w_total;
            if rvol_i==0; continue; end
            U=exp( (log(rvol_i)+handles.spec.log_ref_vol-n/2*log(pi)+...
                gammaln(n/2+1)+n*log(2))/n );
        else
            %U=rvol_i^(1/n)*handles.spec.U_euc;
            U=handles.spec.U_euc;
        end
        [x,y,z]=sphere(32);
        vert=handles.theories{t_i}.vertices{v_i}.pairs(:,3)';
        q_rng=[17,25; 17,25; 9,17; 9,17; 25,33; 25,33; 1,9; 1,9];
        h_rng=[17,33; 1,17; 17,33; 1,17; 17,33; 1,17; 17,33; 1,17];
        i=4*vert(1)+2*vert(2)+vert(3)+1;
        x_rng=x(h_rng(i,1):h_rng(i,2),q_rng(i,1):q_rng(i,2))*U;
        y_rng=y(h_rng(i,1):h_rng(i,2),q_rng(i,1):q_rng(i,2))*U;
        z_rng=z(h_rng(i,1):h_rng(i,2),q_rng(i,1):q_rng(i,2))*U;
        V=[[x_rng(:)+vert(1),y_rng(:)+vert(2),z_rng(:)+vert(3)]; vert];
        K=convhulln(V);
        if col_scheme<=1
            min_v=min(V(:,3));
            max_v=max(V(:,3));
            if max_v==min_v
                v_col=ones(size(V(:,3)))*63+10;
            else
                v_col=(V(:,3)-min_v)/(max_v-min_v)*63+10;
            end
            trisurf(K,V(:,1),V(:,2),V(:,3),'CDataMapping','direct','FaceVertexCData',v_col, ...
                'EdgeColor','none',...
                'FaceColor','interp','FaceAlpha',0.5);
        else
            trisurf(K,V(:,1),V(:,2),V(:,3),'CDataMapping','direct','FaceVertexCData',col_scheme, ...
                'EdgeColor','none',...
                'FaceColor','flat','FaceAlpha',0.5);
        end
        hold on;
        x_rng=x(h_rng(i,1):h_rng(i,2),q_rng(i,1))*U+vert(1);
        y_rng=y(h_rng(i,1):h_rng(i,2),q_rng(i,1))*U+vert(2);
        z_rng=z(h_rng(i,1):h_rng(i,2),q_rng(i,1))*U+vert(3);
        plot3(x_rng,y_rng,z_rng,'k-');
        x_rng=x(h_rng(i,1):h_rng(i,2),q_rng(i,2))*U+vert(1);
        y_rng=y(h_rng(i,1):h_rng(i,2),q_rng(i,2))*U+vert(2);
        z_rng=z(h_rng(i,1):h_rng(i,2),q_rng(i,2))*U+vert(3);
        plot3(x_rng,y_rng,z_rng,'k-');
        x_rng=x(17,q_rng(i,1):q_rng(i,2))*U+vert(1);
        y_rng=y(17,q_rng(i,1):q_rng(i,2))*U+vert(2);
        z_rng=z(17,q_rng(i,1):q_rng(i,2))*U+vert(3);
        plot3(x_rng,y_rng,z_rng,'k-');
    end
elseif h_btn==handles.radiobutton_sup || h_btn==handles.radiobutton_major
    [A_all,b_all]=prob_spec(get(h_btn,'Tag'),t_i,handles,get(handles.checkbox_volume,'value'));
    if isempty(A_all); return; end
    has_valid=0;
    for i=1:length(A_all)
        if isempty(A_all{i});
            invalid_vert=[invalid_vert; i];
        else
            has_valid=1;
        end
    end
    if ~has_valid
        %msgbox('All vertices are invalid.','Warning','modal');
        return; 
    end

    if get(handles.checkbox_same_figure,'value')>0
        set(handles.mother_figure,'HandleVisibility','off');
        figure(gcf);
        set(handles.mother_figure,'HandleVisibility','callback');
    else
        figure;
    end
    for i=1:length(A_all)
        if isempty(A_all{i})
            continue;
        end
%         A=[A_all{i}; 1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1];
%         b=[b_all{i}; 1-1e-6; 1-1e-6; 1-1e-6; 1e-6; 1e-6; 1e-6];
%         [V,nr]=con2vert(A,b);
        
        V=porta_extreme([A_all{i}; 1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1], ...
                            [b_all{i}; 1; 1; 1; 0; 0; 0]);
        
        %V1=sortrows(V,[1,2,3]);
        V1=sortrows(V,1); V1(1:4,:)=sortrows(V1(1:4,:),2); V1(1:2,:)=sortrows(V1(1:2,:),3);
        V(1,:)=V1(1,:);
        %V1=sortrows(V1(2:end,:),[1,3]);
        V1=V1(2:end,:); V1(1:3,:)=sortrows(V1(1:3,:),3);
        V(2,:)=V1(1,:);
        %V1=sortrows(V1(2:end,:),[1,-2]);
        V1=V1(2:end,:); V1(1:2,:)=sortrows(V1(1:2,:),-2);
        V(3:4,:)=V1(1:2,:);
        %V1=sortrows(V1(3:end,:),[2,3]);
        V1=sortrows(V1(3:end,:),2); V1(1:2,:)=sortrows(V1(1:2,:),3);
        V(5,:)=V1(1,:);
        V1=sortrows(V1(2:end,:),3);
        V(6,:)=V1(1,:);
        V(7:8,:)=sortrows(V1(2:end,:),-2);
        faces=[1,2,3,4; 3,4,8,7; 5,6,7,8; 1,2,6,5; 1,4,8,5; 2,3,7,6];
        if col_scheme<=1
            min_v=min(V(:,3));
            max_v=max(V(:,3));
            if max_v==min_v
                v_col=ones(size(V(:,3)))*63+10;
            else
                v_col=(V(:,3)-min_v)/(max_v-min_v)*63+10;
            end
            patch('Vertices',V,'Faces',faces,'CDataMapping','direct','FaceVertexCData',v_col, ...
                'FaceColor','interp','FaceAlpha',0.5);
        else
            patch('Vertices',V,'Faces',faces,'CDataMapping','direct','FaceVertexCData',col_scheme, ...
                'FaceColor','flat','FaceAlpha',0.5);
        end
        if ~ishold; view(3); grid on; end
        hold on;
    end
elseif h_btn==handles.radiobutton_from_porta
    n_vert=length(handles.theories{t_i}.vertices);
    if n_vert<=0; return; end
    
    V=zeros(n_vert,3);
    for v_i=1:n_vert
        V(v_i,:)=handles.theories{t_i}.vertices{v_i}.pairs(:,3)';
    end
    if get(handles.checkbox_same_figure,'value')>0
        set(handles.mother_figure,'HandleVisibility','off');
        figure(gcf);
        set(handles.mother_figure,'HandleVisibility','callback');
    else
        figure;
    end

    n_v=size(V,1);
    v1=ones(n_v-1,1)*V(1,:);
    v2=V(2:end,:)-v1;
    switch rank(v2)
        case 0
            draw_type=0;
        case 1
            draw_type=1;
        case 2
            p_extra=cross(v2(1,:),v2(2,:))+V(1,:);
            K=convhulln([V; p_extra]);
            K=K(max(K,[],2)<=n_v,:);
            draw_type=2;
        otherwise
            K=convhulln(V);
            draw_type=2;
    end

    if col_scheme<=1
        min_v=min(V(:,3));
        max_v=max(V(:,3));
        if max_v==min_v
            v_col=ones(size(V(:,3)))*63+10;
        else
            v_col=(V(:,3)-min_v)/(max_v-min_v)*63+10;
        end
        switch draw_type
            case 0
                plot3(V(:,1),V(:,2),V(:,3),'.','markersize',5, ...
                    'color',col_map(73,:));
            case 1
                plot3(V(:,1),V(:,2),V(:,3),'-','linewidth',2, ...
                    'color',col_map(73,:));
            case 2
                trisurf(K,V(:,1),V(:,2),V(:,3),'CDataMapping','direct','FaceVertexCData',v_col, ...
                    'FaceColor','interp','FaceAlpha',0.5);
        end
    else
        switch draw_type
            case 0
                plot3(V(:,1),V(:,2),V(:,3),'.','markersize',5, ...
                    'color',col_map(col_scheme,:));
            case 1
                plot3(V(:,1),V(:,2),V(:,3),'-','linewidth',2, ...
                    'color',col_map(col_scheme,:));
            case 2
                trisurf(K,V(:,1),V(:,2),V(:,3),'CDataMapping','direct','FaceVertexCData',col_scheme, ...
                    'FaceColor','flat','FaceAlpha',0.5);
        end
    end
    hold on;
    
else
    [A_all,b_all,~,~,Aeq,Beq]=prob_spec(get(h_btn,'Tag'),t_i,handles,get(handles.checkbox_volume,'value'));
    if isempty(A_all); return; end
    has_valid=0;
    for i=1:length(A_all)
        if isempty(A_all{i});
            invalid_vert=[invalid_vert; i];
        else
            has_valid=1;
        end
    end
    if ~has_valid
        if h_btn==handles.radiobutton_borda
            msgbox('All vertices are invalid.','Warning','modal');
        end
        return; 
    end

    if get(handles.checkbox_same_figure,'value')>0
        set(handles.mother_figure,'HandleVisibility','off');
        figure(gcf);
        set(handles.mother_figure,'HandleVisibility','callback');
    else
        figure;
    end
    for i=1:length(A_all)
        if isempty(A_all{i})
            continue;
        end
%         A=[A_all{i}; 1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1];
%         b=[b_all{i}; 1-1e-6; 1-1e-6; 1-1e-6; 1e-6; 1e-6; 1e-6];
%         [V,nr]=con2vert(A,b);
%         K=convhulln(V);

        if ~isempty(Aeq)
            for j=1:size(Aeq{i},1)
                A_all{i}=[A_all{i}; Aeq{i}(j,:)];
                b_all{i}=[b_all{i}; Beq{i}(j)];
                A_all{i}=[A_all{i}; -Aeq{i}(j,:)];
                b_all{i}=[b_all{i}; -Beq{i}(j)];
            end
        end

        if h_btn==handles.radiobutton_city
            vert=handles.theories{t_i}.vertices{i}.pairs(:,3);
            V=porta_extreme([A_all{i}; 1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1], ...
                            [b_all{i}; 1; 1; 1; 0; 0; 0],vert);
        else
            V=porta_extreme([A_all{i}; 1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1], ...
                            [b_all{i}; 1; 1; 1; 0; 0; 0]);
        end
        if isempty(V)
            if ~ishold; view(3); grid on; hold on; end
            continue;
        end
        n_v=size(V,1);
        v1=ones(n_v-1,1)*V(1,:);
        v2=V(2:end,:)-v1;
        switch rank(v2)
            case 0
                draw_type=0;
            case 1
                draw_type=1;
            case 2
                p_extra=cross(v2(1,:),v2(2,:))+V(1,:);
                K=convhulln([V; p_extra]);
                K=K(max(K,[],2)<=n_v,:);
                draw_type=2;
            otherwise
                K=convhulln(V);
                draw_type=2;
        end
        
        if col_scheme<=1
            min_v=min(V(:,3));
            max_v=max(V(:,3));
            if max_v==min_v
                v_col=ones(size(V(:,3)))*63+10;
            else
                v_col=(V(:,3)-min_v)/(max_v-min_v)*63+10;
            end
            switch draw_type
                case 1
                    plot3(V(:,1),V(:,2),V(:,3),'-','linewidth',2, ...
                        'color',col_map(73,:));
                case 2
                    trisurf(K,V(:,1),V(:,2),V(:,3),'CDataMapping','direct','FaceVertexCData',v_col, ...
                        'FaceColor','interp','FaceAlpha',0.5);
            end
        else
            switch draw_type
                case 1
                    plot3(V(:,1),V(:,2),V(:,3),'-','linewidth',2, ...
                        'color',col_map(col_scheme,:));
                case 2
                    trisurf(K,V(:,1),V(:,2),V(:,3),'CDataMapping','direct','FaceVertexCData',col_scheme, ...
                        'FaceColor','flat','FaceAlpha',0.5);
            end
        end
        hold on;
    end
end

axis equal; axis([0,1,0,1,0,1]); set(gca,'box','on');
ID_i=handles.gambles.ID{handles.gambles.pairs(1,1)};
ID_j=handles.gambles.ID{handles.gambles.pairs(1,2)};
xlabel(sprintf('(%s,%s)',ID_i,ID_j));
ID_i=handles.gambles.ID{handles.gambles.pairs(2,1)};
ID_j=handles.gambles.ID{handles.gambles.pairs(2,2)};
ylabel(sprintf('(%s,%s)',ID_i,ID_j));
ID_i=handles.gambles.ID{handles.gambles.pairs(3,1)};
ID_j=handles.gambles.ID{handles.gambles.pairs(3,2)};
zlabel(sprintf('(%s,%s)',ID_i,ID_j));
colormap(col_map);
if ~isempty(handles.data.M)
    x=handles.data.M{1}(1)/sum(handles.data.M{1});
    y=handles.data.M{2}(1)/sum(handles.data.M{2});
    z=handles.data.M{3}(1)/sum(handles.data.M{3});
    plot3(x,y,z,'b*','markersize',5);
end

if h_btn~=handles.radiobutton_from_file
    n_vert=length(handles.theories{t_i}.vertices);
    for v_i=1:n_vert
        if ismember(v_i,invalid_vert)
            continue;
        end
        vert=handles.theories{t_i}.vertices{v_i}.pairs(:,3)';
        text(vert(1),vert(2),vert(3), ...
            handles.theories{t_i}.vertices{v_i}.name, ...
            'color',[.1 .1 .5],'fontweight','bold');
    end
else
    for v_i=1:size(handles.spec.from_file.vertices,1)
        vert=handles.spec.from_file.vertices{v_i,1};
        text(vert(1),vert(2),vert(3), ...
            handles.spec.from_file.vertices{v_i,2}, ...
            'color',[.1 .1 .5],'fontweight','bold');
    end
end

if ~isempty(invalid_vert) && h_btn==handles.radiobutton_borda
    err_msg=[];
    for i=1:length(invalid_vert)
        v_i=invalid_vert(i);
        err_msg=[err_msg, sprintf('Vertex %s is invalid.\n', ...
            handles.theories{t_i}.vertices{v_i}.name)];
    end
    msgbox(err_msg,'Warning','modal');
    return;
end


% switch(get(h_btn,'Tag'))
%     case 'radiobutton_major'
%         title(sprintf('Supermajority'));
%     case 'radiobutton_borda'
%         title(sprintf('Borda'));
%     case 'radiobutton_sup'
%         title(sprintf('Distance-based (supremum)'));
%     case 'radiobutton_city'
%         title(sprintf('Distance-based (city-block)'));
%     case 'radiobutton_euclid'
%         title(sprintf('Distance-based (euclidean)'));
% end



% --- Executes during object creation, after setting all properties.
function pushbutton_visual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_visual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_closeall.
function pushbutton_closeall_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_closeall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.mother_figure,'HandleVisibility','off');
close all
set(handles.mother_figure,'HandleVisibility','callback');


% --- Executes on button press in pushbutton_pairs_set.
function pushbutton_pairs_set_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_pairs_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.gambles.ID)
    msgbox('Please set the number of gambles first.','Error','modal')
    return;
end

handles=set_pairs(handles);
if ~isempty(handles)
    n=size(handles.gambles.pairs,1);
    handles.data.pairs=[handles.gambles.pairs,0.5*ones(n,1)];
    handles.data.M={};
    handles.data.sets={};
    handles.spec.from_file.name={};
    handles.spec.from_file.path={};
    handles.spec.from_file.A=[];
    handles.spec.from_file.B=[];
    handles.spec.from_file.A_eq=[];
    handles.spec.from_file.B_eq=[];
    handles.spec.from_file.ineq_idx=[];
    handles.spec.from_file.vertices={};
    guidata(handles.mother_figure,handles);
    set(handles.edit_spec_file,'string','');
    update_pairs_list(handles);
    update_data_list(handles);
    update_theories_list(handles);
end


function edit_num_gambles_Callback(hObject, eventdata, handles)
% hObject    handle to edit_num_gambles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_num_gambles as text
%        str2double(get(hObject,'String')) returns contents of edit_num_gambles as a double


% --- Executes during object creation, after setting all properties.
function edit_num_gambles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_num_gambles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_pairs_none.
function pushbutton_pairs_none_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_pairs_none (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gambles.pairs=[];
handles.gambles.pair_idx=[];
handles.theories={};
handles.data.pairs=[];
handles.data.M={};
handles.data.sets={};
handles.spec.from_file.name={};
handles.spec.from_file.path={};
handles.spec.from_file.A=[];
handles.spec.from_file.B=[];
handles.spec.from_file.A_eq=[];
handles.spec.from_file.B_eq=[];
handles.spec.from_file.ineq_idx=[];
handles.spec.from_file.vertices={};
guidata(hObject,handles);
set(handles.edit_spec_file,'string','');
update_pairs_list(handles);
update_data_list(handles);
update_theories_list(handles);

% --- Executes on button press in pushbutton_pairs_all.
function pushbutton_pairs_all_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_pairs_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n=length(handles.gambles.ID);
handles.gambles.pairs=zeros(n*(n-1)/2,2);
handles.gambles.pair_idx=zeros(n);
idx=0;
for i=1:n
    for j=(i+1):n
        idx=idx+1;
        handles.gambles.pairs(idx,:)=[i,j];
        handles.gambles.pair_idx(i,j)=idx;
        handles.gambles.pair_idx(j,i)=-idx;
    end
end
handles.theories={};
n=size(handles.gambles.pairs,1);
handles.data.pairs=[handles.gambles.pairs,0.5*ones(n,1)];
handles.data.M={};
handles.data.sets={};
handles.spec.from_file.name={};
handles.spec.from_file.path={};
handles.spec.from_file.A=[];
handles.spec.from_file.B=[];
handles.spec.from_file.A_eq=[];
handles.spec.from_file.B_eq=[];
handles.spec.from_file.ineq_idx=[];
handles.spec.from_file.vertices={};
guidata(hObject,handles);
set(handles.edit_spec_file,'string','');
update_pairs_list(handles);
update_data_list(handles);
update_theories_list(handles);

% --- Executes on button press in pushbutton_gambles_change.
function pushbutton_gambles_change_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_gambles_change (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer=inputdlg('Number of gambles:','Gambles');
if isempty(answer); return; end
n=str2double(answer);
if isempty(n) || ~isfinite(n); return; end
n=floor(n);
if n<2
    msgbox('At least 2 gambles please.','Error','modal');
    return;
end
set_num_gambles(n,handles);


function set_num_gambles(n,handles)
%change number of gambles and create gamble ID for each
%create IDs
handles.gambles.ID=cell(n,1);
handles.gambles.ID{1}='A';
for i=2:n
    handles.gambles.ID{i}=handles.gambles.ID{i-1};
    if handles.gambles.ID{i-1}(end)=='Z'
        done=0;
        for j=(length(handles.gambles.ID{i})-1):-1:1
            if handles.gambles.ID{i}(j)<'Z'
                handles.gambles.ID{i}(j)=char(handles.gambles.ID{i}(j)+1);
                handles.gambles.ID{i}((j+1):end)='A';
                done=1;
                break;
            end
        end
        if ~done
            handles.gambles.ID{i}(:)='A';
            handles.gambles.ID{i}=['A',handles.gambles.ID{i}];
        end
    else
        handles.gambles.ID{i}(end)=char(handles.gambles.ID{i}(end)+1);
    end
end
handles.gambles.pairs=[];
handles.gambles.pair_idx=[];
handles.data.pairs=[];
handles.data.M={};
handles.data.sets={};
handles.theories={};
guidata(handles.mother_figure,handles);

update_num_gambles(handles);
update_pairs_list(handles);
update_data_list(handles);
update_theories_list(handles);


% --- Executes on selection change in listbox_theories.
function listbox_theories_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_theories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_theories contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_theories
update_vertices_list(handles);

% --- Executes during object creation, after setting all properties.
function listbox_theories_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_theories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_params.
function listbox_params_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_params contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_params


% --- Executes during object creation, after setting all properties.
function listbox_params_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_theory_add.
function pushbutton_theory_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_theory_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.gambles.pairs)
    msgbox('Gamble pairs must be defined first.','Error','modal');
    return;
end

answer=inputdlg('Enter name for theory:','Theory');
if isempty(answer); return; end
name=strtrim(answer{1});
if isempty(name); return; end
n=length(handles.theories);
for i=1:n
    if isequal(name,handles.theories{i}.name)
        msgbox('Duplicate name','Error','modal');
        return;
    end
end
n=n+1;
handles.theories{n}.name=name;
%handles.theories{n}.color=ceil(rand*64);
handles.theories{n}.vertices={};
guidata(hObject,handles);
update_theories_list(handles,n);


% --- Executes on button press in pushbutton_vertex_add.
function pushbutton_vertex_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_vertex_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.theories)
    return;
end
idx=get(handles.listbox_theories,'value');
n=length(handles.theories{idx}.vertices);
n=n+1;

answer=inputdlg('Enter name for vertex:','Vertex',1,{sprintf('V%i',n)});
if isempty(answer); return; end
name=strtrim(answer{1});
if isempty(name); return; end

handles.theories{idx}.vertices{n}.name=name;
handles.theories{idx}.vertices{n}.w=1.0;
n_pairs=size(handles.gambles.pairs,1);
handles.theories{idx}.vertices{n}.pairs=[handles.gambles.pairs,zeros(n_pairs,1)];
guidata(hObject,handles);
update_vertices_list(handles,n);

if handles.options.check_regions==2
    check_all_regions(idx,[],handles);
end

% --- Executes on button press in pushbutton_vertex_remove.
function pushbutton_vertex_remove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_vertex_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list=get(handles.listbox_vertices,'string');
if isempty(list)
    return;
end
t_i=get(handles.listbox_theories,'value');
idx=get(handles.listbox_vertices,'value');
handles.theories{t_i}.vertices(idx)=[];
guidata(hObject,handles);
update_vertices_list(handles);

if handles.options.check_regions==2
    check_all_regions(t_i,[],handles);
end


% --- Executes on button press in pushbutton_vertex_weight.
function pushbutton_vertex_weight_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_vertex_weight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list=get(handles.listbox_vertices,'string');
if isempty(list)
    return;
end
t_i=get(handles.listbox_theories,'value');
idx=get(handles.listbox_vertices,'value');


def=sprintf('%g',handles.theories{t_i}.vertices{idx}.w);
answer=inputdlg('New weight:','Weight',1,{def});
if isempty(answer); return; end
w=str2double(answer{1});
if isempty(w) || ~isfinite(w); return; end
if w<0
    msgbox('Weight must be non-negative.','Error','modal');
    return;
end
handles.theories{t_i}.vertices{idx}.w=w;
guidata(hObject,handles);
update_vertices_list(handles);

if handles.options.check_regions==2
    check_all_regions(t_i,[],handles);
end

% --- Executes during object creation, after setting all properties.
function pushbutton_gambles_change_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_gambles_change (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function update_ref_vol(handles)
if isempty(handles.spec.log_ref_vol)
    set(handles.edit_volume,'string','');
    set(handles.checkbox_volume,'enable','off');
    set(handles.pushbutton_vertex_weight,'enable','off');
else
    set(handles.edit_volume,'string',sprintf('%g',exp(handles.spec.log_ref_vol)));
    set(handles.checkbox_volume,'enable','on');
    if get(handles.checkbox_volume,'value')>0
        set(handles.pushbutton_vertex_weight,'enable','on');
        update_spec_states(handles,1);
    else
        set(handles.pushbutton_vertex_weight,'enable','off');
        update_spec_states(handles,0);
    end
end

function update_spec_states(handles,use_ref)
if use_ref>0
    set(handles.edit_lambda,'enable','off');
    set(handles.edit_U_sup,'enable','off');
    set(handles.edit_U_city,'enable','off');
    set(handles.edit_U_euc,'enable','off');
    set(handles.pushbutton_lambda,'enable','off');
    set(handles.pushbutton_U_sup,'enable','off');
    set(handles.pushbutton_U_city,'enable','off');
    set(handles.pushbutton_U_euc,'enable','off');
else
    set(handles.edit_lambda,'enable','inactive');
    set(handles.edit_U_sup,'enable','inactive');
    set(handles.edit_U_city,'enable','inactive');
    set(handles.edit_U_euc,'enable','inactive');
    set(handles.pushbutton_lambda,'enable','on');
    set(handles.pushbutton_U_sup,'enable','on');
    set(handles.pushbutton_U_city,'enable','on');
    set(handles.pushbutton_U_euc,'enable','on');
end
update_borda_status(handles);


function update_num_gambles(handles)
%set the number of gambles edit box (Gamble pairs section)
set(handles.edit_num_gambles,'String',sprintf('%i',length(handles.gambles.ID)));

function update_pairs_list(handles)
%update the list of current gamble pairs (Gamble pairs section)
n=size(handles.gambles.pairs,1);
list=cell(n,1);
for idx=1:n
    ID_i=handles.gambles.ID{handles.gambles.pairs(idx,1)};
    ID_j=handles.gambles.ID{handles.gambles.pairs(idx,2)};
    list{idx}=sprintf('(%s,%s)',ID_i,ID_j);
end
if isempty(get(handles.listbox_gambles,'value'))
    set(handles.listbox_gambles,'value',1)
else
    val=get(handles.listbox_gambles,'value');
    if val<1
        set(handles.listbox_gambles,'value',1);
    elseif val>n
        set(handles.listbox_gambles,'value',n);
    end
end
set(handles.listbox_gambles,'string',list);

%update Borda status
update_borda_status(handles);


function update_borda_status(handles)
n=size(handles.gambles.pairs,1);
n_gambles=length(handles.gambles.ID);
if n_gambles*(n_gambles-1)/2==n && get(handles.checkbox_volume,'value')==0
    set(handles.radiobutton_borda,'enable','on');
    set(handles.pushbutton_borda_explain,'visible','off');
else
    if get(handles.uipanel_prob_spec,'SelectedObject')==handles.radiobutton_borda
        set(handles.uipanel_prob_spec,'SelectedObject',handles.radiobutton_major);
    end
    set(handles.radiobutton_borda,'enable','off');
    set(handles.pushbutton_borda_explain,'visible','on');
end



function update_theories_list(handles,sel)
%update the list of theories (Theories section)
n=length(handles.theories);
list=cell(n,1);
for i=1:n
    list{i}=handles.theories{i}.name;
end
if isempty(get(handles.listbox_theories,'value'))
    set(handles.listbox_theories,'value',1)
else
    val=get(handles.listbox_theories,'value');
    if val<1
        set(handles.listbox_theories,'value',1);
    elseif val>n
        set(handles.listbox_theories,'value',n);
    end
end
set(handles.listbox_theories,'string',list);
if nargin>=2
    set(handles.listbox_theories,'value',sel);
end
update_vertices_list(handles);


function update_vertices_list(handles,sel)
%updates list of vertices associated with the selected theory
% in the Theories section
if isempty(handles.theories)
    if isempty(get(handles.listbox_vertices,'value'))
        set(handles.listbox_vertices,'value',1)
    end
    set(handles.listbox_vertices,'string',{});
else
    h_btn=get(handles.uipanel_prob_spec,'SelectedObject');
    idx=get(handles.listbox_theories,'value');
    n=length(handles.theories{idx}.vertices);
    list=cell(n,1);
    params=get_vertex_param(h_btn,idx,handles);
    for i=1:n
        %list{i}=sprintf('V%i',i);
        list{i}=sprintf('%s',handles.theories{idx}.vertices{i}.name);
        if ~isempty(params)
            if get(handles.checkbox_volume,'value')>0
                list{i}=[list{i},sprintf(' (%g)',handles.theories{idx}.vertices{i}.w)];
            end
            list{i}=[list{i},sprintf(' [%g]',params(i))];
        end
    end
    if isempty(get(handles.listbox_vertices,'value'))
        set(handles.listbox_vertices,'value',1)
    else
        val=get(handles.listbox_vertices,'value');
        if val<1
            set(handles.listbox_vertices,'value',1);
        elseif val>n
            set(handles.listbox_vertices,'value',n);
        end
    end
    set(handles.listbox_vertices,'string',list);
    if nargin>=2
        set(handles.listbox_vertices,'value',sel);
    end
end
update_params_list(handles);


function update_params_list(handles)
%update entries in listbox_params (e.g. details on currently
% selected vertex) in the Theories section
list=get(handles.listbox_vertices,'string');
if isempty(list)
    if isempty(get(handles.listbox_params,'value'))
        set(handles.listbox_params,'value',1)
    end
    set(handles.listbox_params,'string',{});
else
    t_i=get(handles.listbox_theories,'value');
    idx=get(handles.listbox_vertices,'value');
    v=handles.theories{t_i}.vertices{idx};
    n=size(v.pairs,1);
    list=cell(n,1);
    for i=1:n
        ID_i=handles.gambles.ID{v.pairs(i,1)};
        ID_j=handles.gambles.ID{v.pairs(i,2)};
        list{i}=sprintf('(%s,%s): %g',ID_i,ID_j,v.pairs(i,3));
    end
    if isempty(get(handles.listbox_params,'value'))
        set(handles.listbox_params,'value',1)
    end
    set(handles.listbox_params,'string',list);
end


% --- Executes on button press in pushbutton_theory_remove.
function pushbutton_theory_remove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_theory_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.theories)
    return;
end
idx=get(handles.listbox_theories,'value');
handles.theories(idx)=[];
guidata(hObject,handles);
update_theories_list(handles);



function edit_lambda_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lambda as text
%        str2double(get(hObject,'String')) returns contents of edit_lambda as a double


% --- Executes during object creation, after setting all properties.
function edit_lambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_U_sup_Callback(hObject, eventdata, handles)
% hObject    handle to edit_U_sup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_U_sup as text
%        str2double(get(hObject,'String')) returns contents of edit_U_sup as a double


% --- Executes during object creation, after setting all properties.
function edit_U_sup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_U_sup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [from_file,msg]=load_spec_file(file,path,handles)
from_file=[]; msg=[];
if ~exist([path,file])
    return;
end
if isequal(lower(file((end-3):end)),'.txt')
    fid=fopen([path,file],'rt');
    try
        C=textscan(fid,'%d %d',1);
        num_rows=C{1};
        num_cols=C{2};
        A=zeros(num_rows,num_cols);
        for r=1:num_rows
            C=textscan(fid,'%n',num_cols);
            A(r,:)=C{1}';
        end
        C=textscan(fid,'%n',num_rows);
        B=C{1};
        if ~isequal(size(A),[num_rows,num_cols]) || ...
                ~isequal(size(B),[num_rows,1])
            fclose(fid);
            msg='Invalid file.';
            return;
        end

        n=size(handles.gambles.pairs,1);
        if size(A,2)~=n
            fclose(fid);
            msg=['Dimensions from file do not match current settings. ',...
                'Please set the currect number of gamble pairs first.'];
            return;
        end
        %equalities
        C=textscan(fid,'%s',1);
        if ~isempty(C) && ~isempty(C{1}) && isequal(lower(strtrim(C{1}{1})),'equalities')
            C=textscan(fid,'%d %d',1);
            num_rows=C{1};
            num_cols=C{2};
            A_eq=zeros(num_rows,num_cols);
            for r=1:num_rows
                C=textscan(fid,'%n',num_cols);
                A_eq(r,:)=C{1}';
            end
            C=textscan(fid,'%n',num_rows);
            B_eq=C{1};
            if ~isequal(size(A_eq),[num_rows,num_cols]) || ...
                    ~isequal(size(B_eq),[num_rows,1])
                fclose(fid);
                msg='Invalid file.';
                return;
            end
            C=textscan(fid,'%d',1);
            c=C{1};
            C=textscan(fid,'%d',c);
            ineq_idx=C{1}';
            
            C=textscan(fid,'%s',1); %scan for vertices
        else
            A_eq=[];
            B_eq=[];
            ineq_idx=1:size(A,2);
        end
        
        %vertices
        if ~isempty(C) && ~isempty(C{1}) && isequal(lower(strtrim(C{1}{1})),'vertices')
            str=[repmat('%n',1,num_cols),'%q'];
            C=textscan(fid,str);
            n_labels=length(C{1});
            for i=1:num_cols
                if length(C{i})~=n_labels
                    msg='Bad vertex labels';
                    return;
                end
            end
            vert=cell2mat(C(1:(end-1)));
            vertices=cell(n_labels,2);
            vertices(:,1)=mat2cell(vert,ones(n_labels,1),num_cols);
            vertices(:,2)=C{end};
        else
            vertices={};
        end
        
        from_file.name=file;
        from_file.path=path;
        from_file.A=A;
        from_file.B=B;
        from_file.A_eq=A_eq;
        from_file.B_eq=B_eq;
        from_file.ineq_idx=ineq_idx;
        from_file.vertices=vertices;
    catch
        msgbox('Invalid file.','Error','modal');
    end
    fclose(fid);
else
    try
        f=load([path,file]);
    catch
        msg='Invalid file.';
        return;
    end
    if ~isfield(f,'A') || ~isfield(f,'B')
        msg='Invalid file.';
        return;
    end
    if size(f.A,2)<=0 || size(f.A,1)~=size(f.B,1) || size(f.B,2)~=1
        msg='Invalid file.';
        return;
    end
    n=size(handles.gambles.pairs,1);
    if size(f.A,2)~=n
        msg=['Dimensions from file do not match current settings. ',...
            'Please set the currect number of gamble pairs first.'];
        return;
    end
    if isfield(f,'vertices')
        if size(f.vertices,2)~=2
            msg='Bad vertex labels';
            return;
        end
        for i=1:size(f.vertices,1)
            if ~isequal(size(f.vertices{i,1}),[1,n])
                msg='Bad vertex labels';
                return;
            end
        end
        vertices=f.vertices;
    else
        vertices={};
    end
    from_file.name=file;
    from_file.path=path;
    from_file.A=f.A;
    from_file.B=f.B;
    if isfield(f,'A_eq') && isfield(f,'B_eq') && isfield(f,'ineq_idx')
        from_file.A_eq=f.A_eq;
        from_file.B_eq=f.B_eq;
        from_file.ineq_idx=f.ineq_idx;
    else
        from_file.A_eq=[];
        from_file.B_eq=[];
        from_file.ineq_idx=1:size(f.A,2);
    end
    from_file.vertices=vertices;
end


% --- Executes on button press in pushbutton_load_spec.
function pushbutton_load_spec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path]=uigetfile({'*.*','All Files'},'Load Specification');
if file~=0
    [from_file,msg]=load_spec_file(file,path,handles);
    if isempty(from_file)
        msgbox(msg,'Error','modal');
    else
        handles.spec.from_file=from_file;
        guidata(hObject,handles);
        set(handles.edit_spec_file,'string',file);
        set(handles.uipanel_prob_spec,'SelectedObject',handles.radiobutton_from_file);
    end
end

function edit_spec_file_Callback(hObject, eventdata, handles)
% hObject    handle to edit_spec_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_spec_file as text
%        str2double(get(hObject,'String')) returns contents of edit_spec_file as a double


% --- Executes during object creation, after setting all properties.
function edit_spec_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_spec_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_sup.
function radiobutton_sup_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sup



function edit_N_Callback(hObject, eventdata, handles)
% hObject    handle to edit_N (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_N as text
%        str2double(get(hObject,'String')) returns contents of edit_N as a double


% --- Executes during object creation, after setting all properties.
function edit_N_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_N (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in listbox_results.
function listbox_results_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_results contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_results


% --- Executes during object creation, after setting all properties.
function listbox_results_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_results_table.
function pushbutton_results_table_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_results_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.results)
    results_table(handles);
end


% --- Executes on button press in pushbutton_results_remove.
function pushbutton_results_remove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_results_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.results)
    return;
end
idx=get(handles.listbox_results,'value');
handles.results(idx)=[];
guidata(hObject,handles);
update_results_list(handles);



function edit_volume_Callback(hObject, eventdata, handles)
% hObject    handle to edit_volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_volume as text
%        str2double(get(hObject,'String')) returns contents of edit_volume as a double


% --- Executes during object creation, after setting all properties.
function edit_volume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_set_volume.
function pushbutton_set_volume_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_set_volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

n=size(handles.gambles.pairs,1);
h_btn=get(handles.uipanel_prob_spec,'SelectedObject');
if isempty(handles.theories) && h_btn~=handles.radiobutton_from_file
    msgbox('Please create a theory first.','Error','modal');
    return;
end
t_i=get(handles.listbox_theories,'value');
n_vert=length(handles.theories{t_i}.vertices);
if n_vert<1 && h_btn~=handles.radiobutton_from_file
    msgbox('Selected theory must have at least one vertex.','Error','modal');
    return;
end
v_total=0;
for v_i=1:n_vert
    vert=handles.theories{t_i}.vertices{v_i}.pairs(:,3)';
    if all((vert==0)|(vert==1))
        switch(get(h_btn,'Tag'))
            case 'radiobutton_major'
                v_total=v_total+(1-handles.spec.lambda)^n;
            case 'radiobutton_sup'
                v_total=v_total+handles.spec.U_sup^n;
            case 'radiobutton_city'
                v_total=v_total+ exp( n*log(handles.spec.U_city)-gammaln(n+1) );
            case 'radiobutton_euclid'
                v_total=v_total+ exp( n/2*log(pi)+n*log(handles.spec.U_euc) ...
                    -gammaln(n/2+1) - n*log(2) );
            otherwise
                msgbox('Cannot use this specification for reference volume.','Error','modal');
                return;
        end
    else
        switch(get(h_btn,'Tag'))
            case 'radiobutton_major'
                v_total=v_total+(1-handles.spec.lambda)^n;
            case 'radiobutton_sup'
                v_total=v_total+estimate_volume(get(h_btn,'Tag'),vert,handles.spec.U_sup);
            case 'radiobutton_city'
                v_total=v_total+estimate_volume(get(h_btn,'Tag'),vert,handles.spec.U_city);
            case 'radiobutton_euclid'
                v_total=v_total+estimate_volume(get(h_btn,'Tag'),vert,handles.spec.U_euc);
            otherwise
                msgbox('Cannot use this specification for reference volume.','Error','modal');
                return;
        end
    end
end
log_ref_vol=log(v_total);
% switch(get(h_btn,'Tag'))
%     case 'radiobutton_major'
%         log_ref_vol=n*log(1-handles.spec.lambda) + log(n_vert);
%     case 'radiobutton_sup'
%         log_ref_vol=n*log(handles.spec.U_sup) + log(n_vert);
%     case 'radiobutton_city'
%         log_ref_vol=n*log(handles.spec.U_city)-gammaln(n+1) + log(n_vert);
%     case 'radiobutton_euclid'
%         log_ref_vol=n/2*log(pi)+n*log(handles.spec.U_euc) ...
%             -gammaln(n/2+1) - n*log(2) + log(n_vert);
%     otherwise
%         msgbox('Cannot use this specification for reference volume.','Error','modal');
%         return;
% end
if get(handles.checkbox_volume,'value')>0
    return;
end
handles.spec.log_ref_vol=log_ref_vol;
guidata(hObject,handles);
update_ref_vol(handles);
update_vertices_list(handles);


function v=estimate_volume(tag,vert,dist)
n=length(vert);
n_sample=100000;
anchor=ones(n_sample,1)*vert;
samples=(2*rand(n_sample,n)-1)*dist+anchor;
switch(tag)
case 'radiobutton_sup'
    v=sum( (max(abs(samples-anchor),[],2)<=dist) & all(samples<=1 & samples>=0,2) )/n_sample;
case 'radiobutton_city'
    v=sum( (sum(abs(samples-anchor),2)<=dist) & all(samples<=1 & samples>=0,2) )/n_sample;
case 'radiobutton_euclid'
    v=sum( (sum((samples-anchor).*(samples-anchor),2)<=dist*dist) & all(samples<=1 & samples>=0,2) )/n_sample;
end
v=v*(2*dist)^n;

function dist=search_volume(tag,vert,vol)
u_dist=1;
l_dist=0;
iter=0;
while 1
    iter=iter+1;
    dist=0.5*(u_dist+l_dist);
    %disp([l_dist,dist,u_dist]);
    if u_dist<=l_dist || iter>10
        break;
    end
    v=estimate_volume(tag,vert,dist);
    if v>vol
        u_dist=dist;
    else
        l_dist=dist;
    end
end

% --- Executes on button press in checkbox_volume.
function checkbox_volume_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_volume

update_vertices_list(handles);
if get(handles.checkbox_volume,'value')>0
    set(handles.pushbutton_vertex_weight,'enable','on');
    update_spec_states(handles,1);
else
    set(handles.pushbutton_vertex_weight,'enable','off');
    update_spec_states(handles,0);
end
if handles.options.check_regions==2
    check_all_regions([],[],handles);
end

% --- Executes on button press in pushbutton_details.
function pushbutton_details_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_details (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.results)
    return;
end
r_idx=get(handles.listbox_results,'value');
if isfield(handles.results{r_idx},'type')
    res_txt=sprintf('Type of test: %s\n\n',handles.results{r_idx}.type);
else
    res_txt=sprintf('Type of test: frequentist\n\n');
end
res_txt=[res_txt,sprintf('Theory: %s\n', ...
    handles.results{r_idx}.theory.name)];

spec_list={'Supermajority','Borda score','Supremum', ...
    'City-block','Euclidean','Random preference (file)','Random preference (vertices)'};
res_spec_name={'major','borda','sup','city','euclid','file','mixture'};

for i=1:length(spec_list)
    if isequal(handles.results{r_idx}.spec,res_spec_name{i})
        res_txt=[res_txt,sprintf('Spec: %s\n',spec_list{i})];
        break;
    end
end

if handles.results{r_idx}.use_ref>0
    if ~isequal(handles.results{r_idx}.spec,'borda') && ...
            ~isequal(handles.results{r_idx}.spec,'file')
        res_txt=[res_txt,sprintf('Reference volume: %g\n', ...
            exp(handles.results{r_idx}.log_ref_vol))];
    end
elseif isequal(handles.results{r_idx}.spec,'major')
    res_txt=[res_txt,sprintf('Supermajority Level: %g\n', ...
        handles.results{r_idx}.lambda)];
elseif isequal(handles.results{r_idx}.spec,'sup') || ...
    isequal(handles.results{r_idx}.spec,'city') || ...
    isequal(handles.results{r_idx}.spec,'euclid')
    res_txt=[res_txt,sprintf('Max-distance: %g\n', ...
        handles.results{r_idx}.U)];
end

if isfield(handles.results{r_idx},'sets_M')
    res_txt=[res_txt,sprintf('\nData set: %s',handles.results{r_idx}.sets_M.name)];
end
total_M=0; first_M=sum(handles.results{r_idx}.M{1}); same_M=1;
for i=1:length(handles.results{r_idx}.M)
    this_M=sum(handles.results{r_idx}.M{i});
    total_M=total_M+this_M;
    if this_M~=first_M
        same_M=0;
    end
end
if same_M
    res_txt=[res_txt,sprintf('\nEmpirical sample size: %i per pair (Total: %i)\n',first_M,total_M)];
else
    res_txt=[res_txt,sprintf('\nEmpirical sample size: varied (Total: %i)\n',total_M)];
end
res_txt=[res_txt,sprintf('Data hash: %.4f\n\n',get_data_hash(handles.results{r_idx}.M))];

if ~isfield(handles.results{r_idx},'type') || isequal(handles.results{r_idx}.type,'frequentist')
    res_txt=[res_txt,sprintf('Simulation sample size: %i\nSeed: %i\n', ...
        handles.results{r_idx}.N,handles.results{r_idx}.rstate)];
    for r_i=1:length(handles.results{r_idx}.res)
        if ~isequal(handles.results{r_idx}.spec,'file') && ~isequal(handles.results{r_idx}.spec,'mixture')
            res_txt=[res_txt,sprintf('\nVertex: %s', ...
                handles.results{r_idx}.theory.vertices{r_i}.name)];
            if handles.results{r_idx}.use_ref>0
                res_txt=[res_txt,sprintf('\n[Weight: %g]   ', ...
                    handles.results{r_idx}.theory.vertices{r_i}.w)];
                if isfield(handles.results{r_idx},'params') && ...
                        ~isempty(handles.results{r_idx}.params)
                    if isequal(handles.results{r_idx}.spec,'major')
                        res_txt=[res_txt,sprintf(' [Level: %g]', ...
                            handles.results{r_idx}.params(r_i))];
                    else
                        res_txt=[res_txt,sprintf(' [Max-distance: %g]', ...
                            handles.results{r_idx}.params(r_i))];
                    end
                end
            end
        end
        if isempty(handles.results{r_idx}.res{r_i}); continue; end
        x=handles.results{r_idx}.res{r_i}.x;
        w=handles.results{r_idx}.res{r_i}.w;
        L=handles.results{r_idx}.res{r_i}.L;
        p=handles.results{r_idx}.res{r_i}.p;
        res_txt=[res_txt,sprintf('\nML parameter:\n')];
        for i=1:length(x)
            res_txt=[res_txt,sprintf('%.4f  ',x(i))];
        end
        if isempty(w)
            res_txt=[res_txt,sprintf('\nAll inequalities satisfied!')];
        else
            res_txt=[res_txt,sprintf('\nChi-bar squared weights:\n')];
            for i=1:length(w)
                res_txt=[res_txt,sprintf('%.4f  ',w(i))];
            end
        end
        res_txt=[res_txt,sprintf('\nLog-likelihood ratio: %.4f\n',L)];
        res_txt=[res_txt,sprintf('p = %.4f\n',p)];
        if isfield(handles.results{r_idx}.res{r_i},'n_done')
            if handles.results{r_idx}.res{r_i}.n_done < handles.results{r_idx}.N
                res_txt=[res_txt,sprintf('[Actual simulation sample size = %d]\n',handles.results{r_idx}.res{r_i}.n_done)];
            end
        end
        if isfield(handles.results{r_idx}.res{r_i},'msg')
            res_txt=[res_txt,sprintf('warn:')];
            for i=1:length(handles.results{r_idx}.res{r_i}.msg)
                res_txt=[res_txt,sprintf(' %s',handles.results{r_idx}.res{r_i}.msg{i})];
            end
            res_txt=[res_txt,sprintf('\n')];
        end
    end
elseif isequal(handles.results{r_idx}.type,'bayes_factor')
    if ~isequal(handles.results{r_idx}.spec,'major')
        res_txt=[res_txt,sprintf('Gibbs sample size: %i\nSeed: %i\n', ...
            handles.results{r_idx}.gibbs_size, ...
            handles.results{r_idx}.rstate)];
    end
    for r_i=1:length(handles.results{r_idx}.res)
        plot_title='';
        if ~isequal(handles.results{r_idx}.spec,'file') && ~isequal(handles.results{r_idx}.spec,'mixture')
            res_txt=[res_txt,sprintf('\nVertex: %s', ...
                handles.results{r_idx}.theory.vertices{r_i}.name)];
            plot_title=sprintf('Vertex: %s',handles.results{r_idx}.theory.vertices{r_i}.name);
            if handles.results{r_idx}.use_ref>0
                res_txt=[res_txt,sprintf('\n[Weight: %g]   ', ...
                    handles.results{r_idx}.theory.vertices{r_i}.w)];
                if isfield(handles.results{r_idx},'params') && ...
                        ~isempty(handles.results{r_idx}.params)
                    if isequal(handles.results{r_idx}.spec,'major')
                        res_txt=[res_txt,sprintf(' [Level: %g]', ...
                            handles.results{r_idx}.params(r_i))];
                    else
                        res_txt=[res_txt,sprintf(' [Max-distance: %g]', ...
                            handles.results{r_idx}.params(r_i))];
                    end
                end
            end
        end
        if isempty(handles.results{r_idx}.res{r_i}); continue; end
        
        res_txt=[res_txt,sprintf('\n')];
        if isfield(handles.results{r_idx}.res{r_i},'bayes2')
            bayes2=handles.results{r_idx}.res{r_i}.bayes2;
            res_txt=[res_txt,sprintf('Bayes factor (sampled) = %g\n',bayes2)];
        end
        if isfield(handles.results{r_idx}.res{r_i},'bayes_exact')
            res_txt=[res_txt,sprintf('Bayes factor (exact) = %g\n',handles.results{r_idx}.res{r_i}.bayes_exact)];
        end
        if isfield(handles.results{r_idx}.res{r_i},'prior_vol')
            res_txt=[res_txt,sprintf('Prior volume = %g\n',handles.results{r_idx}.res{r_i}.prior_vol)];
        end
        if isfield(handles.results{r_idx}.res{r_i},'post_vol')
            res_txt=[res_txt,sprintf('Posterior volume = %g\n',handles.results{r_idx}.res{r_i}.post_vol)];
        end
        if isfield(handles.results{r_idx}.res{r_i},'n_done')
            if handles.results{r_idx}.res{r_i}.n_done < handles.results{r_idx}.gibbs_size
                res_txt=[res_txt,sprintf('[Actual Gibbs sample size = %d]\n',handles.results{r_idx}.res{r_i}.n_done)];
            end
        end
        if isfield(handles.results{r_idx}.res{r_i},'bayes2_ext')
            bayes2_ext=handles.results{r_idx}.res{r_i}.bayes2_ext;
            h_plot=figure;
            plot(bayes2_ext(:,1),bayes2_ext(:,2),'*-');
            xlabel('Sample size'); ylabel('Bayes factor'); grid on
            if ~isempty(plot_title); title(plot_title); end
            set(h_plot,'NumberTitle','off','Name','Results (Bayes factor)');
        end
    end
    if isfield(handles.results{r_idx},'weighted_res')
        if isfield(handles.results{r_idx}.weighted_res,'bayes_exact')
            res_txt=[res_txt,sprintf('\nWeighted Bayes factor (exact) = %g\n', ...
                handles.results{r_idx}.weighted_res.bayes_exact)];
        end
    end
    if isfield(handles.results{r_idx},'hard_constraint') && handles.results{r_idx}.hard_constraint>0
        res_txt=[res_txt,sprintf('\nwarn: Hard 0/1 constraint\n')];
    end
else
    res_txt=[res_txt,sprintf('Gibbs sample size: %i\nBurn-in size: %i\nSeed: %i\n', ...
        handles.results{r_idx}.gibbs_size,handles.results{r_idx}.gibbs_burn, ...
        handles.results{r_idx}.rstate)];
    for r_i=1:length(handles.results{r_idx}.res)
        plot_title='';
        if ~isequal(handles.results{r_idx}.spec,'file') && ~isequal(handles.results{r_idx}.spec,'mixture')
            res_txt=[res_txt,sprintf('\nVertex: %s', ...
                handles.results{r_idx}.theory.vertices{r_i}.name)];
            plot_title=sprintf('Vertex: %s',handles.results{r_idx}.theory.vertices{r_i}.name);
            if handles.results{r_idx}.use_ref>0
                res_txt=[res_txt,sprintf('\n[Weight: %g]   ', ...
                    handles.results{r_idx}.theory.vertices{r_i}.w)];
                if isfield(handles.results{r_idx},'params') && ...
                        ~isempty(handles.results{r_idx}.params)
                    if isequal(handles.results{r_idx}.spec,'major')
                        res_txt=[res_txt,sprintf(' [Level: %g]', ...
                            handles.results{r_idx}.params(r_i))];
                    else
                        res_txt=[res_txt,sprintf(' [Max-distance: %g]', ...
                            handles.results{r_idx}.params(r_i))];
                    end
                end
            end
        end
        if isempty(handles.results{r_idx}.res{r_i}); continue; end
        D=handles.results{r_idx}.res{r_i}.D;
        p=handles.results{r_idx}.res{r_i}.p;
        res_txt=[res_txt,sprintf('\nBayesian p = %.4f\n',p)];
        res_txt=[res_txt,sprintf('DIC = %.4f\n',D.DIC)];
        if isfield(handles.results{r_idx}.res{r_i},'prior_vol')
            res_txt=[res_txt,sprintf('Prior volume = %g\n',handles.results{r_idx}.res{r_i}.prior_vol)];
        end
        if isfield(handles.results{r_idx}.res{r_i},'post_vol')
            res_txt=[res_txt,sprintf('Posterior volume = %g\n',handles.results{r_idx}.res{r_i}.post_vol)];
        end
        if isfield(handles.results{r_idx}.res{r_i},'n_done')
            if handles.results{r_idx}.res{r_i}.n_done < handles.results{r_idx}.gibbs_size
                res_txt=[res_txt,sprintf('[Actual Gibbs sample size = %d]\n',handles.results{r_idx}.res{r_i}.n_done)];
            end
        end
        if isfield(handles.results{r_idx}.res{r_i},'pD_ext')
            pD_ext=handles.results{r_idx}.res{r_i}.pD_ext;
            h_plot=figure;
            subplot(2,1,1);
            plot(pD_ext(:,1),pD_ext(:,2),'*-');
            ylabel('Bayesian p'); grid on
            if ~isempty(plot_title); title(plot_title); end
            subplot(2,1,2);
            plot(pD_ext(:,1),pD_ext(:,3),'*-');
            xlabel('Sample size'); ylabel('DIC'); grid on
            set(h_plot,'NumberTitle','off','Name','Results (Bayes factor)');
        end
    end
    if isfield(handles.results{r_idx},'weighted_res')
        res_txt=[res_txt,sprintf('\nWeighted Bayesian p = %.4f\n',handles.results{r_idx}.weighted_res.p)];
        res_txt=[res_txt,sprintf('Weighted DIC = %.4f\n',handles.results{r_idx}.weighted_res.D.DIC)];
    end
    if isfield(handles.results{r_idx},'hard_constraint') && handles.results{r_idx}.hard_constraint>0
        res_txt=[res_txt,sprintf('\nwarn: Hard 0/1 constraint\n')];
    end
end
msgbox(res_txt,'Results','non-modal');


% --- Executes on button press in pushbutton_clear_results.
function pushbutton_clear_results_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clear_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.results)
    return;
end
handles.results={};
guidata(hObject,handles);
update_results_list(handles);


% --- Executes on button press in pushbutton_load_data.
function pushbutton_load_data_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path]=uigetfile({'*.*','All Files'},'Load Observations');
if file~=0
    if isequal(lower(file((end-3):end)),'.txt')
        fid=fopen([path,file],'rt');
        try
            C=textscan(fid,'%d %d %d %d',1);
            num_rows=C{1};
            num_cols=C{2};
            num_sets=C{3};
            use_name=C{4};
            sets=cell(1,num_sets);
            for i=1:num_sets
                if use_name
                    C=textscan(fid,'%q',1);
                    sets{i}.name=C{1}{1};
                else
                    sets{i}.name=sprintf('Set %i',i);
                end
                sets{i}.M=cell(num_rows,1);
                C=textscan(fid,'%n %n',num_rows);
                for j=1:num_rows
                    sets{i}.M{j}=[C{1}(j),C{2}(j)];
                    if ~all(isfinite(sets{i}.M{j})) || ...
                            ~all(sets{i}.M{j}>=0)
                        if use_name
                            msgbox([sprintf('Invalid file. \n\n'), ...
                                '(Note: make sure double-quotes are used for names that contain spaces)'], ...
                                'Error','modal');
                        else
                            msgbox('Invalid file.','Error','modal');
                        end
                    end
                end
            end
            if num_sets<1
                fclose(fid);
                msgbox('Invalid file.','Error','modal');
                return;
            end
            n=size(handles.gambles.pairs,1);
            if num_rows~=n
                fclose(fid);
                msgbox(['Dimensions from file do not match current settings. ',...
                    'Please set the currect number of gamble pairs first.'],...
                    'Error','modal');
                return;
            end
            if num_cols~=2
                fclose(fid);
                msgbox('Dimensions from file do not match current settings. ',...
                    'Error','modal');
                return;
            end
            handles.data.sets=sets;
            handles.data.M=sets{1}.M;
            [handles.spec.data_M,data_M_str]=get_spec_data_M(handles.data.M);
            guidata(hObject,handles);
            set(handles.pushbutton_M,'string',data_M_str);
            update_data_list(handles);
        catch
            msgbox('Invalid file.','Error','modal');
        end
        fclose(fid);
    else
        
        try
            f=load([path,file]);
        catch
            msgbox('Invalid file.','Error','modal');
            return;
        end
        n=size(handles.gambles.pairs,1);
        if isfield(f,'sets')
            if ~iscell(f.sets)
                msgbox('Invalid file.','Error','modal');
                return;
            end
            sets=cell(length(f.sets),1);
            for i=1:length(sets)
                if iscell(f.sets{i})
                    sets{i}.name=sprintf('Set %i',i);
                    sets{i}.M=f.sets{i};
                elseif isfield(f.sets{i},'name')
                    sets{i}=f.sets{i};
                else
                    msgbox('Invalid file.','Error','modal');
                    return;
                end
            end
            for i=1:length(sets)
                if length(sets{i}.M)~=n
                    msgbox(['Dimensions from file do not match current settings. ',...
                        'Please set the currect number of gamble pairs first.'],...
                        'Error','modal');
                    return;
                end
                for j=1:n
                    if ~isequal(size(sets{i}.M{j}),[1,2])
                        msgbox('Dimensions from file do not match current settings. ',...
                            'Error','modal');
                        return;
                    end
                end
            end
            handles.data.M=sets{1}.M;
            handles.data.sets=sets;
            [handles.spec.data_M,data_M_str]=get_spec_data_M(handles.data.M);
            guidata(hObject,handles);
            set(handles.pushbutton_M,'string',data_M_str);
            update_data_list(handles);
            return;
        end
        if ~isfield(f,'M') || ~iscell(f.M)
            msgbox('Invalid file.','Error','modal');
            return;
        end
        if length(f.M)~=n
            msgbox(['Dimensions from file do not match current settings. ',...
                'Please set the currect number of gamble pairs first.'],...
                'Error','modal');
            return;
        end
        for i=1:n
            if ~isequal(size(f.M{i}),[1,2])
                msgbox('Dimensions from file do not match current settings. ',...
                    'Error','modal');
                return;
            end
        end
        handles.data.M=f.M;
        handles.data.sets={};
        [handles.spec.data_M,data_M_str]=get_spec_data_M(handles.data.M);
        guidata(hObject,handles);
        set(handles.pushbutton_M,'string',data_M_str);
        update_data_list(handles);
    end
end


% --- Executes on selection change in popupmenu_data.
function popupmenu_data_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_data

set_idx=get(handles.popupmenu_data,'value');
if length(handles.data.sets)<set_idx
    return;
end
handles.data.M=handles.data.sets{set_idx}.M;
[handles.spec.data_M,data_M_str]=get_spec_data_M(handles.data.M);
guidata(hObject,handles);
set(handles.pushbutton_M,'string',data_M_str);
update_data_list(handles,set_idx);

% --- Executes during object creation, after setting all properties.
function popupmenu_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function export_results(file,path,handles,silent)
if isequal(lower(file((end-3):end)),'.mat')
    results=handles.results;
    while 1>0
        try
            save([path,file],'results');
            return;
        catch
            h=msgbox(['Unable to write to file ',path,file,'. Please close it if you are currently using it, then click OK.'], ...
                'Auto Save Error','modal');
            uiwait(h);
        end
    end
elseif isequal(lower(file((end-3):end)),'.txt')
    fid=fopen([path,file],'wt');
    while fid<0
        h=msgbox(['Unable to write to file ',path,file,'. Please close it if you are currently using it, then click OK.'], ...
            'Auto Save Error','modal');
        uiwait(h);
        fid=fopen([path,file],'wt');
    end
    for i=1:length(handles.results)
        fprintf(fid,'[Result %i]\n',i);
        if isfield(handles.results{i},'type')
            fprintf(fid,'test type: %s\n',handles.results{i}.type);
        else
            fprintf(fid,'test type: frequentist\n');
        end
        fprintf(fid,'theory: %s\n',handles.results{i}.theory.name);
        fprintf(fid,'spec: %s\n',handles.results{i}.spec);
        fprintf(fid,'lambda: %g\n',handles.results{i}.lambda);
        fprintf(fid,'U: %g\n',handles.results{i}.U);
        if ~isfield(handles.results{i},'type') || isequal(handles.results{i}.type,'frequentist')
            fprintf(fid,'N: %g\n',handles.results{i}.N);
            fprintf(fid,'\n');
            for j=1:length(handles.results{i}.res)
                fprintf(fid,'[Result %i Vertex %i]\n',i,j);
                if isempty(handles.results{i}.res{j})
                    fprintf(fid,'\n');
                    continue;
                end
                fprintf(fid,'x: ');
                for k=1:length(handles.results{i}.res{j}.x)
                    fprintf(fid,'%g ',handles.results{i}.res{j}.x(k));
                end
                fprintf(fid,'\n');
                fprintf(fid,'L: %g\n',handles.results{i}.res{j}.L);
                fprintf(fid,'w: ');
                for k=1:length(handles.results{i}.res{j}.w)
                    fprintf(fid,'%g ',handles.results{i}.res{j}.w(k));
                end
                fprintf(fid,'\n');
                fprintf(fid,'p: %g\n',handles.results{i}.res{j}.p);
                if isfield(handles.results{i}.res{j},'msg')
                    fprintf(fid,'warn: ');
                    for k=1:length(handles.results{i}.res{j}.msg)
                        fprintf(fid,'%s ',handles.results{i}.res{j}.msg{k});
                    end
                    fprintf(fid,'\n');
                end
                fprintf(fid,'\n');
            end
        else
            fprintf(fid,'Gibbs sample size: %g\n',handles.results{i}.gibbs_size);
            fprintf(fid,'Gibbs burn-in size: %g\n',handles.results{i}.gibbs_burn);
            fprintf(fid,'\n');
            for j=1:length(handles.results{i}.res)
                fprintf(fid,'[Result %i Vertex %i]\n',i,j);
                if isempty(handles.results{i}.res{j})
                    fprintf(fid,'\n');
                    continue;
                end
                if isfield(handles.results{i}.res{j},'p')
                    fprintf(fid,'p: %g\n',handles.results{i}.res{j}.p);
                end
                if isfield(handles.results{i}.res{j},'D')
                    fprintf(fid,'DIC: %g\n',handles.results{i}.res{j}.D.DIC);
                end
                if isfield(handles.results{i}.res{j},'prior_vol')
                    fprintf(fid,'Prior volume: %g\n',handles.results{i}.res{j}.prior_vol);
                end
                if isfield(handles.results{i}.res{j},'post_vol')
                    fprintf(fid,'Posterior volume: %g\n',handles.results{i}.res{j}.post_vol);
                end
                if isfield(handles.results{i}.res{j},'bayes1')
                    fprintf(fid,'bayes1: %g\n',handles.results{i}.res{j}.bayes1);
                end
                if isfield(handles.results{i}.res{j},'bayes2')
                    fprintf(fid,'bayes2: %g\n',handles.results{i}.res{j}.bayes2);
                end
                if isfield(handles.results{i}.res{j},'bayes_exact')
                    fprintf(fid,'bayes_exact: %g\n',handles.results{i}.res{j}.bayes_exact);
                end
                fprintf(fid,'\n');
            end
            if isfield(handles.results{i},'weighted_res')
                fprintf(fid,'Weighted Bayesian p = %g\n',handles.results{i}.weighted_res.p);
                fprintf(fid,'Weighted DIC = %g\n',handles.results{i}.weighted_res.D.DIC);
                if isfield(handles.results{i}.weighted_res,'bayes_exact')
                    fprintf(fid,'Weighted Bayes factor (exact) = %g\n',handles.results{i}.weighted_res.bayes_exact);
                end
                fprintf(fid,'\n');
            end
        end
    end
    fclose(fid);
else
    fid=fopen([path,file],'wt');
    while fid<0
        h=msgbox(['Unable to write to file ',path,file,'. Please close it if you are currently using it, then click OK.'], ...
            'Auto Save Error','modal');
        uiwait(h);
        fid=fopen([path,file],'wt');
    end
    flabels={'Data set','Test type','Theory','Specification','Reference volume', ...
        'Lambda','U','N','Random seed','Gibbs sample size','Burn-in size', ...
        'Vertex','Vertex weight','Vertex L/U', ...
        'Likelihood ratio','p-value','Warning','DIC','Prior volume', ...
        'Posterior volume','Bayes factor 1','Bayes factor 2','Bayes factor exact', ...
        'Weighted p-value','Weighted DIC','Weighted Bayes factor'};
    fnames={'dataset','type','theory','spec','volume','lambda', ...
        'U','N','rstate','gibbs_size','gibbs_burn','vertex','v_weight','v_param', ...
        'loglike','p','warning','DIC','prior_vol','post_vol','bayes1','bayes2','bayes_exact', ...
        'weighted_p','weighted_DIC','weighted_bf'};
    for i=1:length(fnames)
        fprintf(fid,flabels{i});
        for r_idx=1:length(handles.results)
            for j=1:length(handles.results{r_idx}.res)
                fprintf(fid,',%s', ...
                    get_results_field(handles.results{r_idx},fnames{i},j));
            end
        end
        fprintf(fid,'\n');
    end
    %find max mle dimension
    n_x=-1; n_w=-1;
    for r_idx=1:length(handles.results)
        for j=1:length(handles.results{r_idx}.res)
            if ~isempty(handles.results{r_idx}.res{j}) && isfield(handles.results{r_idx}.res{j},'x')
                if n_x==-1
                    n_x=length(handles.results{r_idx}.res{j}.x);
                    n_w=length(handles.results{r_idx}.res{j}.w);
                else
                    if n_x~=length(handles.results{r_idx}.res{j}.x)
                        if ~silent
                            msgbox('WARNING: Not all result entries have the same dimension.','Warning','modal');
                        end
                    end
                    n_x=max(n_x,length(handles.results{r_idx}.res{j}.x));
                    n_w=max(n_w,length(handles.results{r_idx}.res{j}.w));
                end
            end
        end
    end
    for i=1:n_x
        fprintf(fid,'MLE %i',i);
        for r_idx=1:length(handles.results)
            for j=1:length(handles.results{r_idx}.res)
                if isempty(handles.results{r_idx}.res{j}) || ...
                        ~isfield(handles.results{r_idx}.res{j},'x') || ...
                        length(handles.results{r_idx}.res{j}.x)<i
                    fprintf(fid,',');
                else
                    fprintf(fid,',%g',handles.results{r_idx}.res{j}.x(i));
                end
            end
        end
        fprintf(fid,'\n');
    end
    for i=1:n_w
        fprintf(fid,'Chi bar sq weight %i',i-1);
        for r_idx=1:length(handles.results)
            for j=1:length(handles.results{r_idx}.res)
                if isempty(handles.results{r_idx}.res{j}) || ...
                        ~isfield(handles.results{r_idx}.res{j},'w') || ...
                        length(handles.results{r_idx}.res{j}.w)<i
                    fprintf(fid,',');
                else
                    fprintf(fid,',%g',handles.results{r_idx}.res{j}.w(i));
                end
            end
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
end


% --- Executes on button press in pushbutton_results_export.
function pushbutton_results_export_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_results_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path]=uiputfile({'*.mat','MAT-files (*.mat)'; '*.csv','Comma separated values (*.csv)'; ...
    '*.txt','Text files (*.txt)';'*.*','All Files'},'Export Results As');
if file~=0
    export_results(file,path,handles,0);
end

function f=get_results_field(res,fname,i)
f='';
switch fname
    case 'dataset'
        if isfield(res,'sets_M')
            f=res.sets_M.name;
        else
            f=sprintf('%.4f',get_data_hash(res.M));
        end
    case 'type'
        if isfield(res,'type')
            f=res.type;
        else
            f='frequentist';
        end
    case 'theory'
        f=res.theory.name;
    case 'spec'
        f=res.spec;
    case 'volume'
        if res.use_ref>0 && ~isequal(res.spec,'borda') && ~isequal(res.spec,'file')
            f=sprintf('%g',exp(res.log_ref_vol));
        end
    case 'lambda'
        if res.use_ref<=0 && isequal(res.spec,'major')
            f=sprintf('%g',res.lambda);
        end
    case 'U'
        if res.use_ref<=0 && (isequal(res.spec,'sup') || ...
                isequal(res.spec,'city') || isequal(res.spec,'euclid'))
            f=sprintf('%g',res.U);
        end
    case 'N'
        if ~isfield(res,'type') || isequal(res.type,'frequentist')
            f=sprintf('%i',res.N);
        end
    case 'rstate'
        f=sprintf('%i',res.rstate);
    case 'gibbs_size'
        if isfield(res,'type') && isequal(res.type(1:5),'bayes')
            f=sprintf('%i',res.gibbs_size);
        end
    case 'gibbs_burn'
        if isfield(res,'type') && isequal(res.type(1:5),'bayes')
            f=sprintf('%i',res.gibbs_burn);
        end
    case 'vertex'
        if ~isequal(res.spec,'file')
            f=res.theory.vertices{i}.name;
        end
    case 'v_weight'
        if ~isequal(res.spec,'file') && res.use_ref>0
            f=sprintf('%g',res.theory.vertices{i}.w);
        end
    case 'v_param'
        if res.use_ref>0 && isfield(res,'params') && ~isempty(res.params)
            f=sprintf('%g',res.params(i));
        end
    case 'loglike'
        if ~isempty(res.res{i}) && isfield(res.res{i},'L')
            f=sprintf('%g',res.res{i}.L);
        end
    case 'p'
        if ~isempty(res.res{i}) && isfield(res.res{i},'p')
            f=sprintf('%g',res.res{i}.p);
        end
    case 'warning'
        if ~isempty(res.res{i}) && isfield(res.res{i},'msg')
            for j=1:length(res.res{i}.msg)
                f=[f,res.res{i}.msg{j},' '];
            end
        end
        if isfield(res,'hard_constraint') && res.hard_constraint>0
            f=[f,'hard_0/1'];
        end
    case 'DIC'
        if ~isempty(res.res{i}) && isfield(res.res{i},'D')
            f=sprintf('%g',res.res{i}.D.DIC);
        end
    case 'prior_vol'
        if ~isempty(res.res{i}) && isfield(res.res{i},'prior_vol')
            f=sprintf('%g',res.res{i}.prior_vol);
        end
    case 'post_vol'
        if ~isempty(res.res{i}) && isfield(res.res{i},'post_vol')
            f=sprintf('%g',res.res{i}.post_vol);
        end
    case 'bayes1'
        if ~isempty(res.res{i}) && isfield(res.res{i},'bayes1')
            f=sprintf('%g',res.res{i}.bayes1);
        end
    case 'bayes2'
        if ~isempty(res.res{i}) && isfield(res.res{i},'bayes2')
            f=sprintf('%g',res.res{i}.bayes2);
        end
    case 'bayes_exact'
        if ~isempty(res.res{i}) && isfield(res.res{i},'bayes_exact')
            f=sprintf('%g',res.res{i}.bayes_exact);
        end
    case 'weighted_p'
        if isfield(res,'weighted_res') && isfield(res.weighted_res,'p')
            f=sprintf('%g',res.weighted_res.p);
        end
    case 'weighted_DIC'
        if isfield(res,'weighted_res') && isfield(res.weighted_res,'D')
            f=sprintf('%g',res.weighted_res.D.DIC);
        end
    case 'weighted_bf'
        if isfield(res,'weighted_res') && isfield(res.weighted_res,'bayes_exact')
            f=sprintf('%g',res.weighted_res.bayes_exact);
        end
end


% --- Executes on button press in checkbox_same_figure.
function checkbox_same_figure_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_same_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_same_figure



function edit_rstate_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rstate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rstate as text
%        str2double(get(hObject,'String')) returns contents of edit_rstate as a double


% --- Executes during object creation, after setting all properties.
function edit_rstate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rstate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_rstate.
function pushbutton_rstate_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rstate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

def=sprintf('%g',handles.spec.rstate);
answer=inputdlg('Random number seed:','Random number seed',1,{def});
if isempty(answer); return; end
rstate=str2double(answer{1});
if isempty(rstate) || ~isfinite(rstate); return; end
rstate=floor(rstate);
if rstate<0
    msgbox('Seed must be non-negative integer','Error','modal');
    return;
end
handles.spec.rstate=rstate;
guidata(hObject, handles);
set(handles.edit_rstate,'string',sprintf('%i',rstate));


% --- Executes on button press in pushbutton_duplicate.
function pushbutton_duplicate_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_duplicate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.theories)
    msgbox('Please select a theory first.','Error','modal');
    return;
end
t_i=get(handles.listbox_theories,'value');

answer=inputdlg('Enter name for new theory:','Duplicate Theory');
if isempty(answer); return; end
name=strtrim(answer{1});
if isempty(name); return; end
n=length(handles.theories);
for i=1:n
    if isequal(name,handles.theories{i}.name)
        msgbox('Duplicate name','Error','modal');
        return;
    end
end
n=n+1;
handles.theories{n}.name=name;
handles.theories{n}.vertices=handles.theories{t_i}.vertices;
guidata(hObject,handles);
update_theories_list(handles,n);



function edit_U_city_Callback(hObject, eventdata, handles)
% hObject    handle to edit_U_city (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_U_city as text
%        str2double(get(hObject,'String')) returns contents of edit_U_city as a double


% --- Executes during object creation, after setting all properties.
function edit_U_city_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_U_city (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_U_city.
function pushbutton_U_city_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_U_city (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

def=sprintf('%g',handles.spec.U_city);
answer=inputdlg('Max-distance (U):','Change Parameter',1,{def});
if isempty(answer); return; end
U=str2double(answer{1});
if isempty(U) || ~isfinite(U); return; end
if U<=0
    msgbox('U must be positive','Error','modal');
    return;
end
if U>0.5
    msgbox('Warning: a large distance may result in overlapping regions','Warning','modal');
end
handles.spec.U_city=U;
guidata(hObject, handles);
set(handles.edit_U_city,'string',sprintf('%g',U));
update_vertices_list(handles);

if handles.options.check_regions==2
    check_all_regions([],handles.radiobutton_city,handles);
end


function edit_U_euc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_U_euc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_U_euc as text
%        str2double(get(hObject,'String')) returns contents of edit_U_euc as a double


% --- Executes during object creation, after setting all properties.
function edit_U_euc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_U_euc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_U_euc.
function pushbutton_U_euc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_U_euc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

def=sprintf('%g',handles.spec.U_euc);
answer=inputdlg('Max-distance (U):','Change Parameter',1,{def});
if isempty(answer); return; end
U=str2double(answer{1});
if isempty(U) || ~isfinite(U); return; end
if U<=0
    msgbox('U must be positive','Error','modal');
    return;
end
if U>0.5
    msgbox('Warning: a large distance may result in overlapping regions','Warning','modal');
end
handles.spec.U_euc=U;
guidata(hObject, handles);
set(handles.edit_U_euc,'string',sprintf('%g',U));
update_vertices_list(handles);

if handles.options.check_regions==2
    check_all_regions([],handles.radiobutton_euclid,handles);
end


% --- Executes on button press in radiobutton_borda.
function radiobutton_borda_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_borda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_borda


% --- Executes on button press in pushbutton_vol_manual.
function pushbutton_vol_manual_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_vol_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer=inputdlg('New reference volume:','Reference Volume');
if isempty(answer); return; end
ref_vol=str2double(answer{1});
if isempty(ref_vol) || ~isfinite(ref_vol); return; end
if ref_vol<=0
    msgbox('Reference volume must be positive','Error','modal');
    return;
end
handles.spec.log_ref_vol=log(ref_vol);
guidata(hObject,handles);
update_ref_vol(handles);
update_vertices_list(handles);
if get(handles.checkbox_volume,'value')>0
    if handles.options.check_regions==2
        check_all_regions([],[],handles);
    end
end

% --- Executes on button press in pushbutton_about.
function pushbutton_about_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msg='QTEST 2.1';
msg=[msg,sprintf('\n \nProgrammed by Shiau Hong Lim\n \n'), ...
    sprintf('QTEST uses PORTA by Thomas Christof and Andreas Loebel.\n \n'), ...
    'This program was developed with support by the National', ...
    ' Science Foundation grants SES 08-20009, SES 10-62045 and SES 14-59699', ... 
    ' (PI: Michel Regenwetter) and the Humboldt Foundation (Co-PIs Jeff Stevens', ...
    ' and Michel Regenwetter).', ...
    sprintf('\n \nSpecial thanks to Daniel R. Cavagnaro, Yun-Shil Cha, Clintin P. Davis-Stober, '), ...
    'Bryanna Fields, Ying Guo, Michael Lackner, William Messner, ', ...
    'Anna Popova, Michel Regenwetter, Yixin Zhang and Christopher E. Zwilling.', ...
    sprintf('\n \n \nDeveloped with MATLAB.\n'), ...
    sprintf('MATLAB is a registered trademark of The MathWorks, Inc.'), ...
    ];
msgbox(msg,'About','modal');


% --- Executes on button press in pushbutton_options.
function pushbutton_options_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=options_dialog(handles);
if ~isempty(handles)
    guidata(hObject,handles);
end



% --- Executes on selection change in popupmenu_color.
function popupmenu_color_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_color contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_color


% --- Executes during object creation, after setting all properties.
function popupmenu_color_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_borda_explain.
function pushbutton_borda_explain_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_borda_explain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(hObject,'enable','off');
% drawnow
% set(hObject,'enable','on');
% uicontrol(hObject);
h=msgbox(sprintf('%s:\n\n%s\n%s','Borda score is only available when', ...
    '1) all gamble pairs are used, AND','2) reference volume is not used'), ...
    'Borda score','modal');


% --- Executes on button press in pushbutton_save_data.
function pushbutton_save_data_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path]=uiputfile({'*.mat','MAT-files (*.mat)'; ...
    '*.txt','Text files (*.txt)';'*.*','All Files'},'Save Observations');
if file~=0
    try
        if isequal(lower(file((end-3):end)),'.txt')
            fid=fopen([path,file],'wt');
            if fid==-1
                msgbox(['Unable to open file ',path,file],'Error','modal');
                return;
            end
            if ~isempty(handles.data.sets)
                fprintf(fid,'%d 2 %d 1\n\n',length(handles.data.sets{1}.M), ...
                    length(handles.data.sets));
                for i=1:length(handles.data.sets)
                    fprintf(fid,'"%s"\n',handles.data.sets{i}.name);
                    for j=1:length(handles.data.sets{i}.M)
                        fprintf(fid,'%d %d\n',handles.data.sets{i}.M{j}(1), ...
                            handles.data.sets{i}.M{j}(2));
                    end
                    fprintf(fid,'\n');
                end
            else
                fprintf(fid,'%d 2 1\n\n',length(handles.data.M));
                for j=1:length(handles.data.M)
                    fprintf(fid,'%d %d\n',handles.data.M{j}(1), ...
                        handles.data.M{j}(2));
                end
            end
            fclose(fid);
        else
            if ~isempty(handles.data.sets)
                sets=handles.data.sets;
                save([path,file],'sets');
            else
                M=handles.data.M;
                save([path,file],'M');
            end
        end
    catch ME
        msgbox(ME.message,'Error','modal');
    end
end




% --- Executes during object creation, after setting all properties.
function pushbutton_save_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton_load_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_data_clear.
function pushbutton_data_clear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_data_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data.M={};
handles.data.sets={};
guidata(hObject,handles);
update_data_list(handles);


% --- Executes on button press in pushbutton_data_name.
function pushbutton_data_name_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_data_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.data.M)
    return;
end

if isempty(handles.data.sets)
    answer=inputdlg('Enter name for data set:','Data Set');
else
    set_idx=get(handles.popupmenu_data,'value');
    answer=inputdlg('Enter name for data set:','Data Set', ...
        1,{sprintf('%s',handles.data.sets{set_idx}.name)});
end
if isempty(answer); return; end
name=strtrim(answer{1});
if isempty(name); return; end
if ~isempty(findstr('"',name))
    msgbox('Double quotes are not allowed in names.','Error','modal');
    return;
end

if isempty(handles.data.sets)
    handles.data.sets{1}.name=name;
    handles.data.sets{1}.M=handles.data.M;
    set_idx=1;
else
    handles.data.sets{set_idx}.name=name;
end
guidata(hObject,handles);
update_data_list(handles,set_idx);


% --- Executes on button press in pushbutton_theory_load.
function pushbutton_theory_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_theory_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.gambles.pairs)
    msgbox('Gamble pairs must be defined first.','Error','modal');
    return;
end

[file,path]=uigetfile({'*.*','All Files'},'Load Theory');
if file~=0
    fid=fopen([path,file],'rt');
    try
        C=textscan(fid,'%s','delimiter','\n','whitespace','');
        idx=1;
        while isempty(strtrim(strrep(C{1}{idx},',','')))
            idx=idx+1;
        end
        v_names=textscan(C{1}{idx},'%s','delimiter',',');
        v_names=v_names{1};
        if length(v_names)<1
            fclose(fid);
            msgbox('Invalid file (first line must be vertex names).','Error','modal');
            return;
        end
        num_vertices=length(v_names);
        for i=1:num_vertices
            if isempty(strtrim(v_names{i}))
                fclose(fid);
                msgbox('Invalid file (vertex names must not be empty).','Error','modal');
                return;
            end
        end
        idx=idx+1;
        while isempty(strtrim(strrep(C{1}{idx},',','')))
            idx=idx+1;
        end
        weights=textscan(C{1}{idx},'%n','delimiter',',');
        weights=weights{1};
        if length(weights)~=num_vertices
            fclose(fid);
            msgbox('Invalid file (inconsistent number of vertices).','Error','modal');
            return;
        end
        n_pairs=size(handles.gambles.pairs,1);
        values=zeros(n_pairs,num_vertices);
        for i=1:n_pairs
            idx=idx+1;
            while isempty(strtrim(strrep(C{1}{idx},',','')))
                idx=idx+1;
            end
            val=textscan(C{1}{idx},'%n','delimiter',',');
            val=val{1};
            if length(val)~=num_vertices
                fclose(fid);
                msgbox('Invalid file (inconsistent number of vertices).','Error','modal');
                return;
            end
            values(i,:)=val';
        end
        idx=idx+1;
        while idx<=length(C{1})
            if ~isempty(strtrim(strrep(C{1}{idx},',','')))
                fclose(fid);
                msgbox('Invalid file (please verify gamble pairs).','Error','modal');
                return;
            end
            idx=idx+1;
        end

        answer=inputdlg('Enter name for theory:','Theory');
        if isempty(answer); fclose(fid); return; end
        name=strtrim(answer{1});
        if isempty(name); fclose(fid); return; end
        n=length(handles.theories);
        for i=1:n
            if isequal(name,handles.theories{i}.name)
                fclose(fid);
                msgbox('Duplicate name','Error','modal');
                return;
            end
        end
        n=n+1;
        
        handles.theories{n}.name=name;
        handles.theories{n}.vertices=cell(1,num_vertices);
        for v_i=1:num_vertices
            handles.theories{n}.vertices{v_i}.name=v_names{v_i};
            handles.theories{n}.vertices{v_i}.w=weights(v_i);
            handles.theories{n}.vertices{v_i}.pairs=[handles.gambles.pairs,values(:,v_i)];
        end
        guidata(hObject,handles);
        update_theories_list(handles,n);
    catch
        msgbox('Invalid file (make sure gamble pairs are set correctly).','Error','modal');
    end
    fclose(fid);
end


% --- Executes on button press in pushbutton_theory_save.
function pushbutton_theory_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_theory_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.theories) 
    msgbox('Please select a theory first.','Error','modal');
    return;
end
t_i=get(handles.listbox_theories,'value');
if isempty(handles.theories{t_i}.vertices)
    msgbox('Must have at least one vertex.','Error','modal');
    return;
end

[file,path]=uiputfile({'*.csv','Comma separated values (*.csv)';'*.*','All Files'},'Save Theory');
if file~=0
    try
        fid=fopen([path,file],'wt');
        if fid==-1
            msgbox(['Unable to open file ',path,file],'Error','modal');
            return;
        end
        
        n_pairs=size(handles.gambles.pairs,1);
        for v_i=1:length(handles.theories{t_i}.vertices)
            if v_i>1; fprintf(fid,','); end
            fprintf(fid,'%s',handles.theories{t_i}.vertices{v_i}.name);
        end
        fprintf(fid,'\n');
        for v_i=1:length(handles.theories{t_i}.vertices)
            if v_i>1; fprintf(fid,','); end
            fprintf(fid,'%g',handles.theories{t_i}.vertices{v_i}.w);
        end
        fprintf(fid,'\n\n');
        for i=1:n_pairs
            for v_i=1:length(handles.theories{t_i}.vertices)
                if v_i>1; fprintf(fid,','); end
                fprintf(fid,'%g',handles.theories{t_i}.vertices{v_i}.pairs(i,3));
            end
            fprintf(fid,'\n');
        end
        fclose(fid);
    catch ME
        msgbox(ME.message,'Error','modal');
    end
end


% --- Executes on button press in checkbox_autosave.
function checkbox_autosave_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_autosave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_autosave


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% try
%     h=waitbar(0,'Closing parallel pool...','WindowStyle','modal','Name','QTEST');
%     matlabpool close
% catch exception
% end
% close(h);

delete(hObject);


% --- Executes on button press in pushbutton_gibbs_size.
function pushbutton_gibbs_size_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_gibbs_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

def=sprintf('%g',handles.spec.gibbs_size);
answer=inputdlg('Sample Size:','Gibbs sampling',1,{def});
if isempty(answer); return; end
N=str2double(answer{1});
if isempty(N) || ~isfinite(N); return; end
N=floor(N);
if N<=0
    msgbox('Must be positive','Error','modal');
    return;
end
handles.spec.gibbs_size=N;
guidata(hObject, handles);
set(handles.edit_gibbs_size,'string',sprintf('%i',N));



function edit_gibbs_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gibbs_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gibbs_size as text
%        str2double(get(hObject,'String')) returns contents of edit_gibbs_size as a double


% --- Executes during object creation, after setting all properties.
function edit_gibbs_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gibbs_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_gibbs_burn.
function pushbutton_gibbs_burn_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_gibbs_burn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

def=sprintf('%g',handles.spec.gibbs_burn);
answer=inputdlg('Burn-In Size:','Gibbs sampling',1,{def});
if isempty(answer); return; end
N=str2double(answer{1});
if isempty(N) || ~isfinite(N); return; end
N=floor(N);
if N<0
    msgbox('Must be non-negative','Error','modal');
    return;
end
handles.spec.gibbs_burn=N;
guidata(hObject, handles);
set(handles.edit_gibbs_burn,'string',sprintf('%i',N));



function edit_gibbs_burn_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gibbs_burn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gibbs_burn as text
%        str2double(get(hObject,'String')) returns contents of edit_gibbs_burn as a double


% --- Executes during object creation, after setting all properties.
function edit_gibbs_burn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gibbs_burn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_save_spec.
function pushbutton_save_spec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.theories)
    msgbox('Please create a theory first.','Error','modal');
    return;
end
t_i=get(handles.listbox_theories,'value');
if length(handles.theories{t_i}.vertices)<1
    msgbox('Need at least 1 vertex defined');
    return;
end
n=size(handles.gambles.pairs,1);
n_vert=length(handles.theories{t_i}.vertices);
V=zeros(n_vert,n);
for v_i=1:n_vert
    V(v_i,:)=handles.theories{t_i}.vertices{v_i}.pairs(:,3)';
end

[file,path]=uiputfile({'*.mat','MAT-files (*.mat)'; ...
    '*.txt','Text files (*.txt)';'*.*','All Files'},'Save Specification');
if file~=0
    
    if ~isfield(handles.theories{t_i},'portahull') || ~isequal(handles.theories{t_i}.portahull.V,V)
         btn=questdlg(['PORTA not yet run on theory ',handles.theories{t_i}.name,'. ', ...
             'Run PORTA and save the output now?'], ...
             'PORTA','Yes','No','Yes');
         if isequal(btn,'Yes')
             h=waitbar(0,'Please wait...','WindowStyle','modal','Name', ...
                ['Running PORTA on ',handles.theories{t_i}.name],'CloseRequestFcn',@do_nothing);
             [A,B,A_eq,B_eq,ineq_idx]=porta_hull(V);
             handles.theories{t_i}.portahull.V=V;
             handles.theories{t_i}.portahull.A_ineq=A;
             handles.theories{t_i}.portahull.B_ineq=B;
             handles.theories{t_i}.portahull.A_eq=A_eq;
             handles.theories{t_i}.portahull.B_eq=B_eq;
             handles.theories{t_i}.portahull.ineq_idx=ineq_idx;
             guidata(hObject,handles);
             delete(h);
         else
             return;
         end
    else
        A = handles.theories{t_i}.portahull.A_ineq;
        B = handles.theories{t_i}.portahull.B_ineq;
        A_eq = handles.theories{t_i}.portahull.A_eq;
        B_eq = handles.theories{t_i}.portahull.B_eq;
        ineq_idx = handles.theories{t_i}.portahull.ineq_idx;
    end
    
    vertices=cell(n_vert,2);
    for v_i=1:n_vert
        vertices{v_i,1}=handles.theories{t_i}.vertices{v_i}.pairs(:,3)';
        vertices{v_i,2}=handles.theories{t_i}.vertices{v_i}.name;
    end
    
    if isequal(lower(file((end-3):end)),'.txt')
        fid=fopen([path,file],'wt');
        while fid<0
            h=msgbox(['Unable to write to file ',path,file,'. Please close it if you are currently using it, then click OK.'], ...
                'Save Error','modal');
            uiwait(h);
            fid=fopen([path,file],'wt');
        end
        num_rows=size(A,1);
        num_cols=size(A,2);
        fprintf(fid,'%d %d\n\n',num_rows,num_cols);
        for r=1:num_rows
            for c=1:num_cols
                fprintf(fid,'%g ',A(r,c));
            end
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
        for r=1:num_rows
            fprintf(fid,'%g\n',B(r));
        end
        
        if ~isempty(A_eq)
            fprintf(fid,'\nEqualities\n\n');
            num_rows=size(A_eq,1);
            num_cols=size(A_eq,2);
            fprintf(fid,'%d %d\n\n',num_rows,num_cols);
            for r=1:num_rows
                for c=1:num_cols
                    fprintf(fid,'%g ',A_eq(r,c));
                end
                fprintf(fid,'\n');
            end
            fprintf(fid,'\n');
            for r=1:num_rows
                fprintf(fid,'%g\n',B_eq(r));
            end
            fprintf(fid,'\n');
            fprintf(fid,'%d\n',length(ineq_idx));
            for c=1:length(ineq_idx)
                fprintf(fid,'%d ',ineq_idx(c));
            end
            fprintf(fid,'\n');
        end
        
        fprintf(fid,'\nVertices\n\n');
        for r=1:size(vertices,1)
            for c=1:length(vertices{r,1})
                fprintf(fid,'%g ',vertices{r,1}(c));
            end
            fprintf(fid,'"%s"\n',vertices{r,2});
        end
        
        fclose(fid);
    else
        while 1>0
            try
                save([path,file],'A','B','A_eq','B_eq','ineq_idx','vertices');
                return;
            catch
                h=msgbox(['Unable to write to file ',path,file,'. Please close it if you are currently using it, then click OK.'], ...
                    'Save Error','modal');
                uiwait(h);
            end
        end
    end
end

function do_nothing(src,evt)
return;

function do_close(src,evt)
delete(src);

function open_parallel_pool
if exist('parpool')
    poolobj=gcp('nocreate');
    if isempty(poolobj) || poolobj.NumWorkers<=0
        h=waitbar(0,'Opening parallel pool, please wait ...','WindowStyle','modal','Name','Multicore','CloseRequestFcn',@do_nothing);
        parpool;
        delete(h);
    end
elseif exist('matlabpool')
    if matlabpool('size')<=0
        h=waitbar(0,'Opening parallel pool, please wait ...','WindowStyle','modal','Name','Multicore','CloseRequestFcn',@do_nothing);
        matlabpool open
        delete(h);
    end
end

% --- Executes on button press in checkbox_multicore.
function checkbox_multicore_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_multicore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_multicore

if get(handles.checkbox_multicore,'value')>0
    open_parallel_pool
end
