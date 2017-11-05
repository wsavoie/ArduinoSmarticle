function tt=takeOptitrackData(obj,event)
vidOn=0;
%specifiesTime
ba=obj.bytesavailable;
if(ba>15)
    
    tt=fread(obj,ba);
    char(tt')
%     matchStr=regexp(char(tt'),'\w*|','match');
%     t=str2double(matchStr{1})%seconds
    runNameOut=strsplit(char(tt'),'|');
    takeName=runNameOut{2}(1:end-4);
    %     t=str2double(char(tt'))
    %     t=5;
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
    
    out=char(fread(obj,ba)')
    if(out=='}')%end of run delimiter
        client = natnet();
        client.ConnectionType = 'Multicast';
        client.ClientIP ='127.0.0.1';
        client.HostIP = '127.0.0.1';
        client.connect();
        client.stopRecord;
        if vidOn
            robot.keyPress(java.awt.event.KeyEvent.VK_F4);
            pause(.1);
            robot.keyRelease(java.awt.event.KeyEvent.VK_F4);
        end
        beep;
        
    end
end
