function [Ugxmatrix,Ugymatrix]=G_matrix(N,xdata,ydata,x,y)

%%
% Generates Chebyshev Gradient (G) Polynomials. 1D Chebyshev derivatives 
% are generated using Chebyshev polynomials of the second kind
%
% INPUT:
%    N = integer, representing the number of polynomials to be generated
%       (Polynomials 1 through N will be generated). 
%   [dx, dy] = MxN matrices of x and y gradients 
%   [x, y] = MxN matrices, representing the grid over which measurements
%            were made
%
% OUTPUT:
%   Ugxmatrix = 1x(M.N) array of Gx polynomials (G polynomials in x
%               direction)
%   Ugymatrix = 1x(M.N) array of Gy polynomials (G polynomials in y
%               direction)
%
% REFERENCE:
% "Modal Data Processing for High Resolution Deflectometry" (paper in
% publishing process)

% HISTORY:
% 2017-06-26 - Maham Aftab - initial implementation

%%
[numx,numy]=size(xdata);

indx_nan = find(isnan(xdata));                  %Handles NaNs
indy_nan = find(isnan(ydata));

[m,n]=index_convert(N+1); %Converts polynomial single index to double index

Tx=ones(size(x));         %Initialize scalar polynomials in x
Tx1=x;

Ux=ones(size(x));   %Initilize derivatives (Chebyshev of second kind) in x
Ux1=2*x;

Ty=ones(size(y));
Ty1=y;
Uy=ones(size(y));
Uy1=2*y;

Txf=cell(1,N+1);
Tyf=cell(1,N+1);

Uxf=cell(1,N+1);
Uyf=cell(1,N+1);

Txf{1}=Tx;
Tyf{1}=Ty;

Txf{2}=Tx1;
Tyf{2}=Ty1;

Uxf{1}=Ux;
Uyf{1}=Uy;

Uxf{2}=Ux1;
Uyf{2}=Uy1;

for g=2:1:N+1                   %Recursion for scalars in x and y
    tempx=(2*x.*Tx1)-Tx;
    tempy=(2*y.*Ty1)-Ty;
    Txf{g+1}=tempx;
    Tyf{g+1}=tempy;
    Tx=Tx1;
    Tx1=Txf{g+1};
    Ty=Ty1;
    Ty1=Tyf{g+1};
end

for h=2:1:N+1                   %Recursion for derivatives in x and y
    tempux=(2*x.*Ux1)-Ux;
    tempuy=(2*y.*Uy1)-Uy;
    Uxf{h+1}=tempux;
    Uyf{h+1}=tempuy;
    Ux=Ux1;
    Ux1=Uxf{h+1};
    Uy=Uy1;
    Uy1=Uyf{h+1};
end

Ugxmatrix=zeros(numx*numy,N);
Ugymatrix=zeros(numy*numx,N);

for loop=2:1:N+1 %Put derivatives + scalars together for 2D gradient terms

x_index=m(1,loop)+1;
y_index=n(1,loop)+1;
    
if m(1,loop)==0
    Ugx=zeros(size(x));
else
    ux_index=m(1,loop);
    Ugx=m(1,loop)*(Uxf{ux_index}.*Tyf{y_index});
end

if n(1,loop)==0
    Ugy=zeros(size(y));
else
    uy_index=n(1,loop);
    Ugy=n(1,loop)*(Uyf{uy_index}.*Txf{x_index});
end


Ugx(indx_nan) = 0;  Ugy(indy_nan) = 0;      %Put zero in place of NaNs

Ugx=Ugx(:); Ugy=Ugy(:);

Ugxmatrix(:,loop-1)=Ugx;    Ugymatrix(:,loop-1)=Ugy;

end

end