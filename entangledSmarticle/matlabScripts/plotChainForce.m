%************************************************************
%* Fig numbers:
%* 1. force vs. time
%* 2. stress vs strain
%* 3. stress vs strain with delay

%************************************************************
clear all
showFigs=[1 2 3];



% close all
fold = 'A:\2DSmartData\entangledData\smarticlesON';
[filez,pName]=uigetfile(fullfile(fold,'*.csv'),'ft data');
% foldz=uigetdir('D:\RobAndFT\Results');
[~,vals]=parseFileNames(filez);
filez
ff=fullfile(pName,filez);
load(ff);

maxSpeed= 1.016; %m/s
pctSpeed=.0173;%.0173;
speed=pctSpeed*maxSpeed; 
L=.26;%meters smarticle chain length

% mD=.125;
mD=vals(1)/1000;%in mm
mT=mD/speed;

%y+ is backwards
freq=1000;
out=importdata(ff);
t=[1:length(out(:,2))]./freq;
F=-out(:,2);

%% 1. force vs time
figure(1);
hold on;

plot(t,F);
xlabel('time (s)','fontsize',18);
ylabel('force (N)','fontsize',18);

[mSPts,~]=ginput(2);
l=ylim;
%phase 1 start:
plot([mSPts(1),mSPts(1)],l,'r')
%phase 1 end:
plot([mSPts(1)+mT,mSPts(1)+mT],l,'r--');
%phase 2 start:
plot([mSPts(2),mSPts(2)],l,'r')
%phase 2 end:
plot([mSPts(2)+mT,mSPts(2)+mT],l,'r--')
%% 2 plot each smarticle's tracks for a particular run
xx=2;
if(showFigs(showFigs==xx))
    
figure(xx); lw=2;
hold on;

p1S=mSPts(1); %[t,idx]
p1E=p1S+mT;

[~,p1S(2)] = min(abs(t-p1S(1)));
[~,p1E(2)] = min(abs(t-p1E(1)));
F=F-F(p1S(2));
p2S=mSPts(2);
p2E=p2S+mT;
[~,p2S(2)] = min(abs(t-p2S(1)));
[~,p2E(2)] = min(abs(t-p2E(1)));



strain1=[t(p1S(2):p1E(2))]*speed;
strain1=strain1-strain1(1);
strain2=t(p2S(2):p2E(2))*speed;
strain2=-1*(strain2-strain2(1));
strain2=strain1(end)+strain2;
strain=[strain1,strain2];

% plot(strain,[F(p1S(2):p1E(2));F(p2S(2):p2E(2))]);
plot(strain1/L,F(p1S(2):p1E(2)));
plot(strain2/L,F(p2S(2):p2E(2)));

xlabel('Strain','fontsize',18);
ylabel('Stress (N)','fontsize',18);
xlim([0,0.5]);
ylim([-0.6,1])
figText(gcf,16);
end
%% 3. stress vs strain with delay
xx=3;
if(showFigs(showFigs==xx))
figure(xx); lw=2;
hold on;

p1S=mSPts(1); %[t,idx]
p1E=p1S+mT;
[~,p1S(2)] = min(abs(t-p1S(1)));
[~,p1E(2)] = min(abs(t-p1E(1)));

% p2S=mSPts(2);
% p2E=p2S+mT;
% [~,p2S(2)] = min(abs(t-p2S(1)));
% [~,p2E(2)] = min(abs(t-p2E(1)));
% 
% 
% 
% strain1=[t(p1S(2):p1E(2))]*speed;
% strain1=strain1-strain1(1);
% strain2=t(p2S(2):p2E(2))*speed;
% strain2=-1*(strain2-strain2(1));
% strain2=strain1(end)+strain2;
% strain=[strain1,strain2];

strain1=t*speed;
strain=strain1-strain1(1);
plot(strain/L,F);
% plot(strain,[F(p1S(2):p1E(2));F(p2S(2):p2E(2))]);
% plot(strain1/L,F(p1S(2):p1E(2)));
% plot(strain2/L,F(p2S(2):p2E(2)));

xlabel('Strain','fontsize',18);
ylabel('Stress (N)','fontsize',18);
xlim([0,0.5]);
ylim([-0.6,1])
figText(gcf,16);
end
%%