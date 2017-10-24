%% Running the CRS Robotics A465
close all; clear all; clc;

% Turn on controller
% Turn on robot
% Open Robcomm v4.20 in compatibility mode (need this to see files)
% Send the program to the A465

% MASTER:         R!<ENQ>
% ROBOT:           R!<ACK>
% MASTER:         <SOH>!ÿ<NUL>H<NUL><SOH><NUL><NUL><NUL><NUL><ETX>i
% ROBOT:           <ACK><STX><NUL><ETX><NUL>
% MASTER:         <ACK>
% ROBOT:           <EOT>
% MASTER:        <ACK>
% ROBOT:           <EOT>
% MASTER:         <ETX>
% ROBOT:           <CR><LF>>>
% enq = hex2dec( reshape('522105',[],2) );
enq=char('R','!',5)';
% reads 3

s=1;
fclose(instrfindall)

s = serial('COM1');
set(s,'BaudRate',38400,'StopBits',1);
set(s,'RequestToSend','off');
set(s,'Parity','none');
set(s,'Terminator','');
set(s,'DataBits',8);

pt = 0.1; %pause time



fopen(s);

% flushinput(s);
TurnOffACI(s,pt);
fclose(s);


s.BytesAvailableFcnCount =1;
s.BytesAvailableFcnMode = 'byte';
s.BytesAvailableFcn = @runRobProgram;

fopen(s);
file='SS';
comm=horzcat('RUN ',file,13);

% flushinput(s);

fwrite(s,comm);

% s.bytesavailable
% fclose(s);



% x = 'FAFF3000D1';
% c = [1 1];
% a = [];
% a = ddereq(chanReq, '0', c, 10000);
% 
% chanExec = ddeinit('ROBCOMM', 'RUN');
% vv = ddeexec(chanExec,'BLAH', c, 1000000);
% 

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