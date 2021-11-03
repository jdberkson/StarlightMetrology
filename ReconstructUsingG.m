function [SAG,ChebyRms,coeffG]=ReconstructUsingG(dx,dy,x,y,N)

%%
% Fit gradient data modally, using Chebyshev Gradient (G) Polynomials.
% Fitting is in the vector domain, and G polynomial coefficients are
% converted to scalar (F) polynomial coefficients, which can then be used
% to generate the tested surface (or wavefront).
%
% INPUT:
%   [dx, dy] = MxN matrices of x and y gradients 
%   [x, y] = MxN matrices, representing the grid over which measurements were made
%    N = integer, representing the number of polynomials to be used for reconstruction (reconstruction will be done using polynomials 1 through N. 
%
% OUTPUT:
%   SAG= MxN matrix of the Reconstructed surface
%   ChebyRms = RMS of reconstructed surface
%   coeffG = Nx1 array of G polynomial coefficients (from fitting)
%
% REFERENCE:
% "Modal Data Processing for High Resolution Deflectometry" (paper in
% publishing process)
%
% NOTES:
% This function works for any aperture, but the polynomials are only 
% orthogonal over rectnagular apertures(the more polynomials, the better
% the fitting, in general)

% HISTORY:
% 2017-06-26 - Maham Aftab - initial implementation

%%

%G polynomial fit

[numx,numy]=size(dx);
dx2=dx; dy2=dy;            

indx_nan = find(isnan(dx2));  dx2(indx_nan) = 0;  %Replace NaNs with zeros
indy_nan = find(isnan(dy2));  dy2(indy_nan) = 0;

data=[dx2(:);dy2(:)];      

[Ugxmatrix,Ugymatrix]=G_matrix(N,dx2,dy2,x,y); %Generates N vector (G) polynomials over the x, y grid.
G=[Ugxmatrix;Ugymatrix];
 
coeffG=G\data;

Chebymatrix=F_matrix(N,x,y); %Generates N scalar (F) polynomials

SAG=Chebymatrix*coeffG; 
SAG=reshape(SAG,numx,numy);

index=find(isnan(dx) & isnan(dy));  SAG(index)=NaN;     %Put back NaNs
index1=find(isnan(SAG)==0); SAG=SAG-mean(SAG(index1));  %Subtract piston

%%
% Error Analysis

error=0;
count=0;

for i=1:1:numx
    for j=1:1:numy
        if isnan(SAG(i,j))==0
        diff=SAG(i,j).^2;
        error=error+diff;
        count=count+1;
        end
    end
end

ChebyRms=error/count;
ChebyRms=sqrt(ChebyRms);

%Plotting

figure();
h=imagesc(SAG);
set(h,'alphadata',~isnan(SAG));
title('Reconstructed Surface');
colorbar;
    
end