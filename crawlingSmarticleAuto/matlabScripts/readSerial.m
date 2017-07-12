if exist('uno','var')
    fclose(uno);
end
if exist('client','var')
    disconnect(client);
end
uno = serial('COM16','BaudRate',9600,'DataBits',8);
set(uno,'terminator','CR/LF')
% s.terminator = '\r\n'; %termination bit arduino sends \r

fopen(uno);
client=natnetInit;
%create listener for serial port
running = 1;
while running
    serialOut=fgetl(uno);
    if all(~isnan(serialOut)) && ~isempty(serialOut) && ~strcmp(serialOut,char(10))
%         pts(serialOut);
        if(strcmp(serialOut,'end'));
            running=0;
            continue;
        end
        %serialOutB4 = serialOut
        serialOut=str2double(strsplit(serialOut,'_'));
        d=datetime(datetime,'Format','yyyyMMDD_hhmmss');
        client.stopRecord;
        %if ~isnan(serialOut)
            cc=[char(d),'_D=',num2str(serialOut(1)),...
                '_R=',num2str(serialOut(2)),'_v=',num2str(serialOut(3))];
        %end
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