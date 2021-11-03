function Chebymatrix=F_matrix(N,x,y)

%%
% Generates Chebyshev Scalar (F) Polynomials. These are 2D Chebyshev
% polynomials of the first kind.
%
% INPUT:
%    N = integer, representing the number of polynomials to be generated
%       (Polynomials 1 through N will be generated). 
%   [x, y] = MxN matrices, representing the grid over which measurements
%            were made
%
% OUTPUT:
%   Chebymatrix = 1x(M.N) array of F polynomials
%
% REFERENCE:
% "Modal Data Processing for High Resolution Deflectometry" (paper in
% publishing process)

% HISTORY:
% 2017-06-26 - Maham Aftab - initial implementation

%%

[numx, numy] = size(x);

[m,n]=index_convert(N+1); 

Tx=ones(size(x));       %Initialize 1D Chebyshevs (in x)
Tx1=x;

Ty=ones(size(y));       %Initialize 1D Chebyshevs (in y)
Ty1=y;

Txf=cell(1,N);
Tyf=cell(1,N);

Txf{1}=Tx1;
Tyf{1}=Ty1;

for g=1:1:N
    tempx=(2*x.*Tx1)-Tx;  %Use recursion relations to generate polynomials
    tempy=(2*y.*Ty1)-Ty;
    Txf{g+1}=tempx;
    Tyf{g+1}=tempy;
    Tx=Tx1;
    Tx1=Txf{g+1};
    Ty=Ty1;
    Ty1=Tyf{g+1};

end

Chebymatrix=zeros(numx*numy,N);

for loop=2:1:N+1

x_index=m(1,loop);
y_index=n(1,loop);


if m(1,loop)==0 && n(1,loop)>0          %Multiply the two 1D polynomials
    T=Tyf{y_index}; 
    else if n(1,loop)==0 && m(1,loop)>0
        T=Txf{x_index};
        else if m(1,loop)==0 && n(1,loop)==0
             T=ones(size(x));
            else
             T=Txf{x_index}.*Tyf{y_index};
            end
        end
end

T=T(:);

Chebymatrix(:,loop-1)=T;

end

end