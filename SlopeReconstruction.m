
focallengthcam = .050; % in meters
distanceToMirror = 24; % in meters
pixelsize = 3.75E-6; % in meters
MirrorDiameter = 0.762; % in meters
rotatedangle = 38+90; %angle of rotated image sensor
starangledeg = 74;  %Star declination in degrees
%Rotate images
flatim_rot = imrotate(flatim,rotatedangle,'crop');
close all

%Use camera focal length, camera xpos, and pixel pitch to translate images
%to overlap
for i = 1:size(flatim,3)
    
    shift(i) = focallengthcam*(xpos(i)/1000)/distanceToMirror;
    shift_px(i)  = shift(i)/pixelsize;
    flatim_rot_shift(:,:,i) = imtranslate(flatim_rot(:,:,i),[-round(shift_px(i)),0]);
    
end
%Calculate Peak to valley brightness for each pixel across the image stack
%dimension
modulation = max(flatim_rot_shift,[],3)-min(flatim_rot_shift,[],3);

%Open UI to crop mirror with ellipse
imagesc(modulation); axis equal;
e = imellipse;
position = wait(e);
mask = createMask(e);


flatim_rot_shift = double(mask).*double(flatim_rot_shift);
flatim_rot_shift(mask == 0) = NaN;

% gif('starlight_saturated.gif')
% for i = 1:size(flatim,3)
%     
%      imagesc(flatim_rot_shift(:,:,i));
%     gif
% end

time = 60*timestamp(:,5) + timestamp(:,6);

declination = deg2rad(starangledeg); 

velocity = 2*pi*cos(declination)/86400; %angular velocity radians/sec
theta = velocity*time; 
h0 = distanceToMirror*1000*theta; %convert to star image movement at camera
h = h0-h0(1); %reference to initial position (y=0)


%Method to calculate slope error using brightness centroiding
% for i = 1:size(flatim,3)
%     weightedBrightnessX(:,:,i) = flatim_rot_shift(:,:,i)*xpos(i);
%     weightedBrightnessY(:,:,i) = flatim_rot_shift(:,:,i)*h(i);
% 
% end
% XSlopeError = sum(weightedBrightnessX,3)./(2*distanceToMirror*1000*sum(flatim_rot_shift,3));
% YSlopeError = sum(weightedBrightnessY,3)./(2*distanceToMirror*1000*sum(flatim_rot_shift,3));

%Method to calculate slope simply based on x,y location of maximum
%brightness 
for i = 1:size(flatim,1)
    for j = 1:size(flatim,2)
        brightnesspx = flatim_rot_shift(i,j,:);
        brightnesspx = brightnesspx(:);
        [m,idx(i,j)] = max(brightnesspx);
        idxset = find(brightnesspx == m);
        centx = mean(xpos(idxset));
        centy = mean(h(idxset));
           XSlopeError(i,j) = centx/(2*distanceToMirror*1000);
           YSlopeError(i,j) = centy/(2*distanceToMirror*1000);
    end
end
XSlopeError = mask.*XSlopeError;
YSlopeError = mask.*YSlopeError;
XSlopeError(XSlopeError==0) = NaN;
YSlopeError(YSlopeError==0) = NaN;

%Start Integration
[row,col] = find(mask==1); %Find all pixels that aren't NaN
%Integrate slopes on UUT to obtain sag map
dx = MirrorDiameter/(max(col)-min(col)-1); %Size of each pixel on mirror
dy = MirrorDiameter/(max(row)-min(row)-1);
%Crop slope map to just ROI
XSlopeError = XSlopeError(min(row):max(row),min(col):max(col));
YSlopeError = YSlopeError(min(row):max(row),min(col):max(col));
%Southwell integration
Sag = SouthwellAvgIntegration(XSlopeError,YSlopeError,dx,dy);
imagesc(removePlane(Sag)); c = colorbar; ylabel(c,'meters');
title('Sag error from 25m radius')

Flux = sum(flatim_rot_shift,3);

sx = 0:dx:MirrorDiameter+dx;
sy = 0:dy:MirrorDiameter+dy;
[sx,sy] = meshgrid(sx,sy);

%Gradient Vector Polynomial Reconstruction (not as reliable for circular
%apertures
%[SAG,ChebyRms,coeffG]=ReconstructUsingG(XSlopeError,YSlopeError,sx,sy,40);

close all;
figure
imagesc(removePlane(Sag)); c = colorbar; ylabel(c,'meters');
title('Sag error from ideal shape (tip/tilt removed)')


for i = 1:size(flatim_rot_shift,3)
    
   TotalFlux(i) = sum(flatim_rot_shift(:,:,i),'all','omitnan');
   
end

TotalFluxnorm = TotalFlux/max(TotalFlux);

[TotalFluxnorm_sorted,idxsorted] = sort(TotalFluxnorm);

radii = 22.5;
figure
for i = 1:size(flatim_rot_shift,3)
    circles(xpos(idxsorted(i)),h(idxsorted(i)),radii,'edgecolor','None','facecolor',TotalFluxnorm_sorted(i)*ones(1,3),'facealpha',.8)

    hold on
    text(xpos(idxsorted(i)),h(idxsorted(i)),num2str(round(TotalFluxnorm_sorted(i),2)),'FontSize',16,'HorizontalAlignment','center')
end
axis equal


close all


figure
subplot(1,2,1); subplot(1,2,2);
waitforbuttonpress
gif('PSF_Helio.gif','DelayTime',.3,'LoopCount',5)


for i = 1:size(flatim_rot_shift,3)
    subplot(1,2,1)
    imshow(flatim_rot_shift(:,:,i)/255); colormap gray; axis equal;
    title([num2str(floor(time(i)/60)-floor(time(1)/60)) 'm ', num2str(mod(time(i),60)), 's'],'FontSize',24)
    subplot(1,2,2)
    
    xlim([min(xpos)-25,max(xpos)+25]); ylim([min(h)-25,max(h)+25]);
    
    [TotalFluxnorm_sorted,idxsorted] = sort(TotalFluxnorm(1:i));
    for j = 1:i
        circles(xpos(idxsorted(j)),h(idxsorted(j)),radii,'edgecolor','None','facecolor',TotalFluxnorm(idxsorted(j))*ones(1,3),'facealpha',1)
        viscircles([xpos(idxsorted(j)),h(idxsorted(j))],radii);
        hold on
        text(xpos(idxsorted(j)),h(idxsorted(j)),num2str(round(TotalFluxnorm(idxsorted(j)),2)),'FontSize',16,'Color',1-TotalFluxnorm(idxsorted(j))*ones(1,3),'HorizontalAlignment','center')
    end
   colorbar; colormap gray;
    xlabel('Translation Stage Position(mm)');ylabel('Star Image Shift(mm)');
    axis equal
    hold off
    
    gif
    drawnow;
end

    
