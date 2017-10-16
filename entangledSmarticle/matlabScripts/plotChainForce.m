clear all
fold = 'D:\ArduinoSmarticle\entangledSmarticle\Results';
[filez,pName]=uigetfile(fullfile(fold,'*.csv'),'ft data');
% foldz=uigetdir('D:\RobAndFT\Results');

filez
ff=fullfile(pName,filez);
load(ff);

maxSpeed= 1.016; %m/s
pctSpeed=.0173;
speed=pctSpeed*maxSpeed; 
L=.26;%meters
mD=.125;
mT=mD/speed;

%y+ is backwards
freq=1000;
figure(1);
hold on;
out=importdata(ff);
t=[1:length(out(:,2))]./freq;
F=out(:,2);
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
plot([mSPts(2)+mT,mSPts(2)+mT],l,'r')
%% 2. force vs confinement
% conf=[9.5,10,10.5 11,14];
figure(2)
hold on;
p1S=mSPts(1); %[t,idx]
p1E=p1S+mT;
[~,p1S(2)] = min(abs(t-p1S(1)));
[~,p1E(2)] = min(abs(t-p1E(1)));

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
plot(strain1/L,-F(p1S(2):p1E(2)),'b');
plot(strain2/L,-F(p2S(2):p2E(2)),'g');

xlabel('Strain','fontsize',18);
ylabel('Stress (N)','fontsize',18);

