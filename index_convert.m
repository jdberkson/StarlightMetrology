function [m,n]=index_convert(j)
%%
% Convert single index for Chebyshev scalar(F) and Gradient(G) Polynomials.
%
% INPUT:
%   j = 1xN array of single index values
% OUTPUT:
%   m = 1xN array of first indices of double index values
%   n = 1xN array of second indices of double index values
%
% REFERENCE:
% "Modal Data Processing for High Resolution Deflectometry" (paper in
% publishing process)
%
% HISTORY:
% 2017-06-26 - Maham Aftab - initial implementation
%%

m=zeros(1,j);
n=zeros(1,j);

m(1,1)=0;
n(1,1)=0;

order=1;
k=1;
count=1;

while k<=j
    terms=order+1;
if terms<=j
    tj=terms;
else
    tj=j;
end
    for g=1:1:tj
            m(1,(count+g))=terms-g;
            n(1,(count+g))=g-1;
    end
    
count=count+tj;
k=k+terms;
order=order+1;
end

m=m(1:j);
n=n(1:j);

end