function bayes=bayes_factor_super(m,vertex,lambda)
%BAYES_FACTOR_SUPER computes the exact Bayes factor for supermajority-type
%vertex (i.e. hypercube)
%   BAYES=bayes_factor_super(M,VERTEX,LAMBDA)
%   
%   M is the data matrix, where each row gives the outcome of a binomial
%   test. For example, for a 3-dimensional case, with 20 observations per
%   dimensions, M could be [8,12; 7,13; 11,9]
%   
%   VERTEX is a vector representation for the vertex. Each coordinate must
%   be between 0 and 1 (inclusive). Example vertices for the 3-dimensional
%   case are [0,1,0] and [0.5,0.5,1].
%
%   LAMBDA is the supermajority level parameter. Normally it should be at
%   least 0.5 and less than 1.
%
% Outputs:
%
%   BAYES is the Bayes factor computed with the incomplete Beta function.
%

if lambda<=0 || lambda>=1
    bayes=[];
    return;
end
n=length(vertex);
v=zeros(n,1);
d=0.5*(1-lambda);
for i=1:n
    if vertex(i)>0.5
        extra=max(0,vertex(i)+d-1);
        v(i)=betainc(vertex(i)-d-extra,m(i,1)+1,m(i,2)+1,'upper');
        if vertex(i)+d<1
            v(i)=v(i)-betainc(vertex(i)+d,m(i,1)+1,m(i,2)+1,'upper');
        end
    else
        extra=max(0,d-vertex(i));
        v(i)=betainc(vertex(i)+d+extra,m(i,1)+1,m(i,2)+1,'lower');
        if vertex(i)-d>0
            v(i)=v(i)-betainc(vertex(i)-d,m(i,1)+1,m(i,2)+1,'lower');
        end
    end
end
bayes=prod(v)/((1-lambda)^n);
