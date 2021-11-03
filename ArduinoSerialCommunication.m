%Emily Rodriguez
%Serial communication with arduino to stepper motor

% Please input a six character command, where the first character 
% corresponds to the axis (X or Y), the direction (F or B), and the number 
% of steps to move (0001-9999).
% For example, to move 40 steps backwards on the X translation stage, you 
% would send XB0040.**Can actually do 7 steps now
% To home a stage, send Home_X!, Home_Y!, or Home_XY

clc
clear all

COM = 'COM3';

s = serial(COM, 'BaudRate', 9600);
fopen(s);

s.Timeout = 30; %seconds before timeout (default is 10)

readData = fscanf(s); %read in "Ready"
disp(readData);



writedata = 'Home_X!'; %command to stages
fwrite(s, writedata) %write data



fclose(s);
delete(s);
