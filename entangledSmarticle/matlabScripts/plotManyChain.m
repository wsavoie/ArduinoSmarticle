
% [filez,pName]=uigetfile({'*.csv'},'F/T data file','D:\RobAndFT\Results');
foldz=uigetdir('D:\ArduinoSmarticle\entangledSmarticle\Results');
filez= dir(fullfile(foldz,'\*.csv'));


NF=length(filez);
for i=1:NF
    
ff=fullfile(foldz,filez(i).name);
load(ff);

%y+ is backwards
freq=1000;
figure(1)
out=importdata(ff);
t=[1:length(out(:,2))]./freq;

plot(t,out(:,2));
xlabel('time (s)','fontsize',18);
ylabel('force (N)','fontsize',18);
F=out(:,2);
[x,~]=ginput(2);
mval(i)=max(abs(F(t>x(1)&t<x(2))));
end
mval
%% 2. force vs confinement
% conf=[9.5,10,10.5 11,14];
conf=[9.5,10,10.5 11,12];
F95 =[1.1680    1.2010    1.5190    1.4040    1.2600];
F10 =[1.1860    1.1430    1.0020    1.3490    1.1540];
F105=[0.8340    1.0280    1.0430    0.8590    1.1470];
F11 =[1.0010    0.8800    1.0260    1.0470    0.9770];
FUn =[0.7960    0.7290    0.7140    0.6430    0.9770];

FAll=[F95;F10;F105;F11;FUn];
fm=mean(FAll,2);
ferr=std(FAll,1,2);
errorbar(conf,fm,ferr,'linewidth',2);

xlabel('H (cm)','fontsize',18);
ylabel('force (N)','fontsize',18);
xlim([9.4,12.1]);
figText(gcf,16);