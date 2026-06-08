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

if ismac && strcmp(computer('arch'), 'maca64')
    method = 'cddgmpmex_combined';
else
    method = 'porta';
end

disp("V to H conversion - start using method " + method)

switch method
    case 'cddmex'
        Vin = struct('V', V);
        Vreduced = cddmex('reduce_v', Vin);
        Hout = cddmex('hull', Vreduced);
        Hreduced = cddmex('reduce_h', Hout);

    case 'cddgmpmex'
        Vin = struct('V', V, 'VNum', Vnum, 'VDen', Vden);
        % Vreduced = cddgmpmex('reduce_v', Vin);
        Vreduced = Vin;
        Hout = cddgmpmex('hull', Vreduced);
        % Hreduced = cddgmpmex('reduce_h', Hout);
        Hreduced = Hout;

    case 'cddgmpmex_combined'
        Vin = struct('V', V, 'VNum', Vnum, 'VDen', Vden);
        Hout = cddgmpmex('reduce_all_hull', Vin);
        Hreduced = Hout;

    case 'porta'
        clear portamex
        [A,B,AEQ,BEQ,IDX]=portamex(Vnum,Vden);
        IDX=sort(IDX+1);

    otherwise
        error('Unknown method specified');
end

if strcmp(method, 'porta') == 0
    H = [Hreduced.A Hreduced.B];
    He = H(Hreduced.lin, :);
    H(Hreduced.lin, :) = [];

    A = H(:, 1:end-1);
    B = H(:, end);
    AEQ = He(:, 1:end-1);
    BEQ = He(:, end);

    % Convert -0 to 0 to avoid potential issues with negative zero representation
    A(A == 0) = 0;
    B(B == 0) = 0;
    AEQ(AEQ == 0) = 0;
    BEQ(BEQ == 0) = 0;

    % Convert A to its reduced row echelon form and get pivot columns
    [~, p] = rref(A);

    % Free variable indices are those not in pivot columns
    % IDX = setdiff(1:size(A, 2), p);
    IDX = p;
end

disp("V to H conversion - done using method " + method)
