function outMap = removePlane(inMap)
% currently it removes 1st order plane only.
% 2020.08.05 heejoo  
[ysize, xsize] = size(inMap);
[ygrid, xgrid] = meshgrid(1:xsize,1:ysize);
% fit matrix
matricIn1 = reshape(xgrid,ysize*xsize,1);
matricIn2 = reshape(ygrid,ysize*xsize,1);
matricIn3 = ones(ysize*xsize,1);
Amatrix = [matricIn1 matricIn2 matricIn3];
Bmatric = reshape(inMap,ysize*xsize,1);
% NaN
AmatrixIn = Amatrix(~isnan(Bmatric),:);
BmatricIn = Bmatric(~isnan(Bmatric));
% fit
fitResult = AmatrixIn\BmatricIn;
% reconstruction
ReconstructedMap = reshape(Amatrix*fitResult, ysize,xsize);
subtractMap = inMap - ReconstructedMap;

outMap = subtractMap;