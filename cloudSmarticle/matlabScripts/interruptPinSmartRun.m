t=600; %totalTime
sampRate = 8192;
tt=0:1/sampRate:.2;
freq=500;
period=2.35; %sound playing period, must be slightly > smarticle gait period
player=audioplayer(sin(tt*freq*2*pi), sampRate);
vidOn=1;
if(~exist('robot','var'))
    robot = java.awt.Robot;
end

if ~exist('client','var')
    client = natnet();
end
client.connect;
client.stopRecord;


%make sure to set OBS's hotkeys for record/stop record to f3/f4
%respectively
if vidOn
    robot.keyPress(java.awt.event.KeyEvent.VK_F3);
    pause(.05);
    robot.keyRelease(java.awt.event.KeyEvent.VK_F3)
end
client.startRecord;


for i=1:floor(t/period)
    player.play
    pause(period);
end

client.stopRecord;

if vidOn
    robot.keyPress(java.awt.event.KeyEvent.VK_F4);
    pause(.1);
    robot.keyRelease(java.awt.event.KeyEvent.VK_F4);
end
client.disconnect;
beep;
