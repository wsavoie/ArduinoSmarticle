
% [filez,pName]=uigetfile({'*.csv'},'F/T data file','D:\RobAndFT\Results');
foldz=uigetdir('D:\RobAndFT\Results');


ff=fullfile(pName,filez);
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
max(abs(F(t>x(1)&t<x(2))))
%% 2. force vs confinement
% conf=[9.5,10,10.5 11,14];

