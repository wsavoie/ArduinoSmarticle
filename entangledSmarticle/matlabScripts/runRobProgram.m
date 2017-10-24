function runRobProgram(obj, event)
pause(.05);
ba=obj.bytesAvailable;
if(ba)
    c=fread(obj,ba)';
%     char(c)
    if(strfind(char(c),'{'))
        pts('start FT');
        startFTstream();
    elseif (strfind(char(c),'}'))
        pts('end FT');
    end
%     flushinput(obj)
end
% flushinput(obj);
