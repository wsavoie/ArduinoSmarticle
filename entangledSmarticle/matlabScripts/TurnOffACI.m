function []=TurnOffACI(s,pt)
% <NUL>=0
% <NUL>=0=^@
% <SOH>=1=^A
% <STX>=2=^B
% <ETX>=3=^C
% <EOT>=4=^D
% <ENQ>=5=^E
% <ACK>=6=^F
% <BEL>=7=^G
% <BS>=8=^H
% <HT>=9=^I
% <LF>=10=^J
% <CR>=13=^M
% <DC2>=18=^R
% <NAK>=21=^U
% <SUB>=26=^Z


% R!<ENQ> %returns 
enq=char('R','!',5)';

% <SOH>!ÿ<NUL>H<NUL><SOH><NUL><NUL><NUL><NUL><ETX>i
header=char(1,'!','ÿ',0,'H',0,1,0,0,0,0,3,'i');
%<ACK>
ack=char(6);
%<ETX>
etx=char(3);
%nohelp\r
nohelp=horzcat('NOHELP',char(13));
% <DC2>
noecho=char(18);


% R!<ENQ> %returns 
enq=char('R','!',5)';

% <SOH>!ÿ<NUL>H<NUL><SOH><NUL><NUL><NUL><NUL><ETX>i
header=char(1,'!','ÿ',0,'H',0,1,0,0,0,0,3,'i')';
%<ACK>
ack=char(6);
%<ETX>
etx=char(3);
%nohelp\r
nohelp=horzcat('NOHELP',char(13));
% <DC2>
noecho=char(18);
fwrite(s,enq);
pause(pt);
a=s.bytesAvailable;
if a==3
% enqRet=fread(s,3)';
% pts('enq done');

fwrite(s,header);
pause(pt);
% headerRet=fread(s,5)';
% pts(headerRet);

fwrite(s,ack);
pause(pt);
% s.bytesavailable
% % ack1Ret=fread(s,1)';
% pts('ack1 done');
% 
fwrite(s,ack);
pause(pt);

% % ack2Ret=fread(s,1)';
% pts('ack2 done');
% 
fwrite(s,etx);
pause(pt);

fwrite(s,etx);
pause(pt);
% s.bytesavailable
% % etxRet=fread(s,4)';
% pts('etx done');
% 
fwrite(s,nohelp);
pause(pt);
% pause(pt)
% s.bytesavailable
% % nohelpRet=freqd(s,5)';
% pts('nohelp done');
% 
fwrite(s,noecho);
pause(pt);
% pts('noecho done');
% % no return on noecho

end
fwrite(s,noecho);
pause(pt);