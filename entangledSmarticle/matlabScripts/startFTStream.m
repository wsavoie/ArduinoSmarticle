opti='130.207.141.229';
robo='130.207.140.133';
o='0.0.0.0';
t1=udp(opti,1510);
% t1.localhost=opti;
t1.localport=1510;
t1.terminator='';
fopen(t1);
fwrite(t1,'}');
% pause(1);
% fread(t1,3)
t1
fclose(t1);
delete(t1);
clear t1;

% judp('SEND',55000,opti,int8('hi'));