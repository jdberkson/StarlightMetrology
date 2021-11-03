clear all
clc

%This code takes photos down two lines of a hexagonal grid, alternating
%between 6 and 7 hexagons (or images).

COM = 'COM3';
s = serial(COM, 'BaudRate', 9600);
fopen(s);
s.Timeout = 30; %seconds before timeout (default is 10)
readData = fscanf(s); %read in "Ready"
disp(readData);
writedata = 'XF01350'; %command to stages
fwrite(s, writedata) %write data
pause(.5)
vid = videoinput('winvideo', 2, 'RGB8_1024x768');
src = getselectedsource(vid);
vid.FramesPerTrigger = 1;
preview(vid);

counter = 1;
timestamp = [];
xpos = [];

for j = 1:5

    %6 images
    xposition = 19.486;
    for i = 1:6
        %move 39 mm
        %COM = 'COM3';
        readData = fscanf(s); %read in "Ready"
        writedata = 'XF01949'; %command to stages
        fwrite(s, writedata) %write data
        pause(.5)
        %take pic
        src.Exposure = -1;
        src.Gain = 10; 
        src.Gamma = 1;
        start(vid)
        flatim(:,:,i) = getdata(vid, 1, 'uint8');
        timestamp = [timestamp; clock];
        xpos = [xpos; xposition];
        %imagesc(flatim(:,:,i))
        %colormap('gray')
        %colorbar
        stop(vid)
        %save image
        %filename = strcat('fig_',num2str(counter),'.png');
        %saveas(gcf,filename)
        xposition = xposition + 38.971;
        counter = counter + 1;
    end
    
    %COM = 'COM3';
    readData = fscanf(s); %read in "Ready"
    writedata = 'XB12666'; %command to stages to go up 6.5 hexagons
    fwrite(s, writedata) %write data
    pause(22)
    
    %7 images
    xposition = 0;
    for i = 7:13
        %move 39 mm
        %COM = 'COM3';
        readData = fscanf(s); %read in "Ready"
        writedata = 'XF01949'; %command to stages
        fwrite(s, writedata) %write data
        pause(.5)
        %take pic
        src.Exposure = -1;
        src.Gain = 10; 
        src.Gamma = 1;
        start(vid)
        flatim(:,:,i) = getdata(vid, 1, 'uint8');
        timestamp = [timestamp; clock];
        xpos = [xpos; xposition];
        %imagesc(flatim(:,:,i))
        %colormap('gray')
        %colorbar
        stop(vid)
        %save image
        %filename = strcat('fig_',num2str(counter),'.png');
        %saveas(gcf,filename)
        xposition = xposition + 38.971;
        counter = counter + 1;
    end
    
    %COM = 'COM3';
    readData = fscanf(s); %read in "Ready"
    writedata = 'XB12666'; %command to stages to go up 6.5 hexagons
    fwrite(s, writedata) %write data
    pause(22)
   
end

readData = fscanf(s); %read in "Ready"
writedata = 'Home_X!'; %command to stages to go home
fwrite(s, writedata) %write data
fclose(s);
delete(s);
save('star_img.mat','flatim', 'timestamp', 'xpos');