function UDPserver
myip='130.207.141.229';
roboip='130.207.140.133';

% global client
fclose(instrfindall);
if(exist('udpServ'))
delete(udpServ);
end

client = natnet();
client.connect();
udpServ = udp('', 'LocalHost', '', 'LocalPort', 1520);
udpServ.BytesAvailableFcn=@takeOpti;
udpServ.BytesAvailableFcnCount=1;
udpServ.BytesAvailableFcnMode='byte';
fopen(udpServ);

function tt=takeOpti(obj,event)
vidOn=0;
%specifiesTime
ba=obj.bytesavailable;
if(ba>4)
    tt=fread(obj,ba);
    pts(char(tt'));

    runNameOut=strsplit(char(tt'),'|');
    takeName=runNameOut{2}(1:end-4);

    
    %keypresses for starting recording for OBS
    robot = java.awt.Robot;
    

    client.stopRecord;
    
    pts(takeName);
    client.setTakeName(['OPTI_',takeName]);
    
    %make sure to set OBS's hotkeys for record/stop record to f3/f4
    %respectively
    if vidOn
        robot.keyPress(java.awt.event.KeyEvent.VK_F3);
        pause(.05);
        robot.keyRelease(java.awt.event.KeyEvent.VK_F3)
    end
    client.startRecord;

return;
end
if(ba>=1)
    
    out=char(fread(obj,ba)');
    if(out=='}')%end of run delimiter
%         client = natnet();
%         client.ConnectionType = 'Multicast';
%         client.ClientIP ='127.0.0.1';
%         client.HostIP = '127.0.0.1';
%         client.connect();
        client.stopRecord;
        if vidOn
            robot.keyPress(java.awt.event.KeyEvent.VK_F4);
            pause(.1);
            robot.keyRelease(java.awt.event.KeyEvent.VK_F4);
        end
        beep;
    end
end
end
end