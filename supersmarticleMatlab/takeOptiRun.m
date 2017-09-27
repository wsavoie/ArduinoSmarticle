t=90; %seconds
client = natnet();

%keypresses for starting recording for OBS
robot = java.awt.Robot;


% Set the conenction type to the multicast of Optitrack and set the proper
% local loopback IPs./
client.ConnectionType = 'Multicast';
client.ClientIP ='127.0.0.1';
client.HostIP = '127.0.0.1';
client.connect();
client.stopRecord;
%make sure to set OBS's hotkeys for record/stop record to f3/f4
%respectively
robot.keyPress(java.awt.event.KeyEvent.VK_F3);
pause(.05);
client.startRecord;
robot.keyRelease(java.awt.event.KeyEvent.VK_F3)
pause(t);
client.stopRecord;
robot.keyPress(java.awt.event.KeyEvent.VK_F4);
pause(.1);
robot.keyRelease(java.awt.event.KeyEvent.VK_F4);

beep;