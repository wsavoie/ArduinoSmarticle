if exist('uno','var')
    fclose(uno);
end
if exist('client','var')
    disconnect(client);
end
uno = serial('COM16','BaudRate',9600,'DataBits',8,'StopBits',1,'Parity','none');
set(uno,'terminator','CR/LF')
% s.terminator = '\r\n'; %termination bit arduino sends \r

fopen(uno);
client=natnetInit;
%create listener for serial port
running = 1;
del=',';%delimiter

pause(1);
%%%%%%%%%%%%%%
pts(fgetl(uno));
% pts(fgetl(uno));
% pts(fgetl(uno));
% pts(fgetl(uno));

while running
    if uno.bytesAvailable
        serialOut=fgetl(uno);
    else
        serialOut=[];
    end
    if all(~isnan(serialOut)) && ~isempty(serialOut) && ~strcmp(serialOut,char(10))
        pts(serialOut);
        if(strcmp(serialOut,'end'))
            pts('read out end')
            running=0;
            client.stopRecord;
            continue;
        end
        serialOut=str2double(strsplit(serialOut,'_'));
        d=datetime(datetime,'Format','yyyyMMDD_hhmmss');
        client.stopRecord;
        cc=[char(d),'_D=',num2str(serialOut(1)),...
            '_R=',num2str(serialOut(2)),'_v=',num2str(serialOut(3))];
        pts(cc);
        client.setTakeName(cc);
        
        %wait a few seconds to allow system to tell smarticle to reverse
        pause(.25);
        client.startRecord;
    end
end

pts('arduino sent out completed command');
%close port after complete
fclose(uno);