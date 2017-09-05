function [ calmat,maxes,DIST_UNITS,F_UNITS,T_UNITS,RANGE] = getCalibInfo(calibrationFile)

tree = xmlread(calibrationFile);
dataStruct = parseChildNodes(tree);
dataStruct=dataStruct(8); %the other 7 indices only contain the comment
DIST_UNITS=dataStruct.Children(1,2).Attributes(1,3).Value;
F_UNITS=dataStruct.Children(1,2).Attributes(1,4).Value;
T_UNITS=dataStruct.Children(1,2).Attributes(1,11).Value;
RANGE=str2double(dataStruct.Children(1,2).Attributes(1,9).Value);

fS=dataStruct.Children(1,2);%FT sensor struct
fx=str2num(fS.Children(1,16).Attributes(1,3).Value);
fxmax=str2num(fS.Children(1,16).Attributes(1,2).Value);

fy=str2num(fS.Children(1,18).Attributes(1,3).Value);
fymax=str2num(fS.Children(1,18).Attributes(1,2).Value);

fz=str2num(fS.Children(1,20).Attributes(1,3).Value);
fzmax=str2num(fS.Children(1,20).Attributes(1,2).Value);

tx=str2num(fS.Children(1,22).Attributes(1,3).Value);
txmax=str2num(fS.Children(1,22).Attributes(1,2).Value);

ty=str2num(fS.Children(1,24).Attributes(1,3).Value);
tymax=str2num(fS.Children(1,24).Attributes(1,2).Value);

tz=str2num(fS.Children(1,26).Attributes(1,3).Value);
tzmax=str2num(fS.Children(1,26).Attributes(1,2).Value);

calmat=[fx;fy;fz;tx;ty;tz];
maxes=[fxmax;fymax;fzmax;txmax;tymax;tzmax];

end

