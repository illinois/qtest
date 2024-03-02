function V=porta_extreme(A,B,valid)
%PORTA_EXTREME converts inequalities into vertices
%   V = porta_extreme(A,B)
%
%   A is a matrix and B is a column vector, specifying the inequality
%   constraints in the form of AX <= B.
%
% Optionally:
%   V = porta_extreme(A,B,VALID)
%
%   where VALID is a feasible point that satisfies the system.
%
% Outputs:
%
%   V is a matrix where each row contains an extreme point of the convex
%   polytope. 
%
% Caution:
%   
%   The output is undefined if the system is unbounded (e.g. a cone)

if size(A,1)<1 || size(A,2)<1 || size(A,1)~=size(B,1) || size(B,2)~=1
    error('Matrix size mismatch!');
end

if nargin<3
    if isfield(optimset,'LargeScale') && isfield(optimset,'Simplex')
        options_lin=optimset('LargeScale','off','Simplex','off','Display','off');
    else
        options_lin=optimoptions('linprog','Algorithm','dual-simplex','Display','off');
    end
    [valid,lambda,exitflag,output]=linprog(ones(1,size(A,2)),A,B,[],[], ...
        [],[],options_lin);
    if exitflag<=0
        %error('Cannot find a feasible point!');
        V=[];
        return;
    end
%     %use another corner
%     [valid2,~,~,~]=linprog(-ones(1,size(A,2)),A,B,[],[], ...
%         [],[],options_lin);
%     valid=0.5*(valid+valid2)';
    valid=valid';
else
    if size(valid,1)~=1 || size(valid,2)~=size(A,2)
        valid=valid';
        if size(valid,1)~=1 || size(valid,2)~=size(A,2)
            error('The given VALID point has wrong dimension!');
        end
    end
    if sum(A*valid'<=B)<size(A,1)
        error('The given VALID point is not feasible!');
    end
end

tol=1e-6;
[Anum,Aden]=rat(A,tol);
[Bnum,Bden]=rat(B,tol);
[Vnum,Vden]=rat(valid,tol);
valid_sum=valid;
valid_count=1;
while sum((Anum./Aden)*(Vnum./Vden)'>(Bnum./Bden))>0
    if valid_count>=100
        error('porta_extreme: cannot find a valid interior point, need better precision');
    end
    [newvalid,~,~,~]=linprog(2*rand(1,size(A,2))-1,Anum./Aden,Bnum./Bden,[],[], ...
        [],[],options_lin);
    valid_sum=valid_sum+newvalid';
    valid_count=valid_count+1;
    valid=valid_sum/valid_count;
    [Vnum,Vden]=rat(valid,tol);
end
clear portavmex
V=portavmex(Anum,Aden,Bnum,Bden,Vnum,Vden);

