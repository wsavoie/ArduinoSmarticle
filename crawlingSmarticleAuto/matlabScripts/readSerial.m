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
del='_';%delimiter

startZero=0;
pause(1);
%%%%%%%send params to uno%%%%%%%%%%
if(~startZero)
maxV=5;x
gaitRadInitial=36;
gaitIncrease=2;
v=2;
direc=mod(v,2)+1;
% a=pts(maxV,d,gaitRadInitial,d,gaitIncrease,d,v,d,dir);
% fprintf(uno,'%s',a);
% fwrite(uno,'1_2_3');
a=horzcat(num2str(maxV),del,num2str(gaitRadInitial),del,num2str(gaitIncrease),del,num2str(v),del,num2str(direc));
fwrite(uno,a,'uint16')
end
%%%%%%%%%%%%%%
pts(fgetl(uno));
while running
    if uno.bytesAvailable
        serialOut=fgetl(uno);
        %     if all(~isnan(serialOut)) && ~isempty(serialOut) && ~strcmp(serialOut,char(10))
        %         pts(serialOut);
        if(strcmp(serialOut,'end'));
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