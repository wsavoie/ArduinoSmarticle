myip='130.207.141.229';
roboip='130.207.140.133';

% s=server('hi',1500,3);
% a=clientTCP('localhost',1508);
% s=server('hi',1500,3);
% fclose(instrfindall);
% if(exist('t'))
%     fclose(t);
%     delete(t);
% end
% t=tcpip(roboip);
% t.localport=1520;
% t.localhost='localhost';
% t.remotehost=roboip;
% t.remoteport=1520;
% t = tcpip('0.0.0.0',55000,'NetworkRole','Server');
% t=udp(roboip,1510);
% t.localhost='localhost';
% t.localport=1510;
% 
% t.terminator='';
% % t.localhost='localhost';
% % t.localport=55000;
% t.name='MAT';
if(exist('udpServ'))
fclose(udpServ);
delete(udpServ);
clear udpServ;
fclose(instrfindall);

client.disconnect();
end

client = natnet();
client.connect();
udpServ = udp('', 'LocalHost', '', 'LocalPort', 1520);
udpServ.BytesAvailableFcn=@takeOptitrackData;
udpServ.BytesAvailableFcnCount=1;
udpServ.BytesAvailableFcnMode='byte';
fopen(udpServ);


% 
