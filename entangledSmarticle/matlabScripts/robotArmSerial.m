%% Running the CRS Robotics A465
close all; clear all; clc;

% Turn on controller
% Turn on robot
% Open Robcomm v4.20 in compatibility mode (need this to see files)
% Send the program to the A465


c = [1 1];
a = [];
chanReq=ddeinit('ROBCOMM', 'ROBOT_STATUS');
a = ddereq(chanReq, '0', c, 10000);

chanExec = ddeinit('ROBCOMM', 'RUN');
vv = ddeexec(chanExec,'BLAH', c, 1000000);


% if(exist('ROB','var'))
%     fclose(ROB);
% end
% 
% close all; clear all; clc;
% 
% ROB=serial('COM2', 'BaudRate', 19200, 'DataBits',8);
% ROB.Timeout = 3;
% ROB.InputBufferSize = 48000;
% set(ROB,'terminator', 'CR');
% fopen(ROB);
% 
% ROB.ReadAsyncMode = 'continuous';
% 
% % a=char(fread(ROB))'
% % fprintf(ROB, char(3));
% % fprintf(ROB, ['R!',char(5)]);
% % fprintf(ROB, ['R!',char(5)]);
% fprintf(ROB, 'R!ROBCOMM');
% fprintf(ROB, 'R!ROBCOMM');
% 
% a2=char(fgetl(ROB))
% 
% % Write program to do something we want
% % fprintf(ROB,'STATUS');
% % a3=char(fgetl(ROB))
% 
% 
% if(exist('ROB','var'))
%     fclose(ROB);
% end