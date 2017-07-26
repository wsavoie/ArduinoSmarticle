t=120; %seconds
client = natnet();

% Set the conenction type to the multicast of Optitrack and set the proper
% local loopback IPs.
client.ConnectionType = 'Multicast';
client.ClientIP = '127.0.0.1';
client.HostIP = '127.0.0.1';
client.connect();
client.stopRecord;
client.startRecord;

pause(t);
client.stopRecord;
beep;