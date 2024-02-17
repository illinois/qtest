function [A,B,AEQ,BEQ,IDX]=porta_hull(V,tol)
%PORTA_HULL converts vertices into inequalities and equalities
%   [A,B,AEQ,BEQ,IDX] = porta_hull(V,TOL)
%   
%   V is a matrix where each row contains a vertex.
%
%   TOL is an optional parameter for conversion to rational numbers
%   (default is 1e-6).
%
% Outputs:
%
%   A is a matrix and B is a column vector, specifying the inequalities of
%   the convex hull of V in the form of AX <= B.
%
%   AEQ and BEQ are the corresponding equalities.
%
%   IDX is the list of free variables in the inequalities.
%

if nargin<2
    tol=1e-6;
end

if size(V,1)<1 || size(V,2)<1
    error('Wrong dimension for V!');
end

[Vnum,Vden]=rat(V,tol);
clear portamex
[A,B,AEQ,BEQ,IDX]=portamex(Vnum,Vden);
IDX=sort(IDX+1);
