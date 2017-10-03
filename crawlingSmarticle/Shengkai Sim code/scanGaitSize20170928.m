clear all;
dt=1e-5; T=20; TGait=1.6;
D=0.042; L=0.0408; % L is arm length from pivot
D0=0.054; W0=0.022;
m0=0.0248; m1=0.003186;
gaitsizeArray=(10:10:90).*pi/180;
MSpeed=pi/(TGait/4);
miu=0.37; miuS=0.43;
speed1=zeros(1,length(gaitsizeArray)); speed2=speed1;

parfor i=1:length(gaitsizeArray)
    gR=gaitsizeArray(i);
    speed1(i)=crawlSpeedEvaluationT5(dt,T,miu,miuS,D,L,D0,W0,TGait,m0,m1,MSpeed,gR,0);
%     speed2(i)=crawlSpeedEvaluationT5(dt,T,miu,miuS,D,L,D0,W0,TGait,m0,m1,MSpeed,gR,1);
    i*100/length(gaitsizeArray)
end

figure,plot(gaitsizeArray*180/pi,speed1*1000,'o-');
% hold on,plot(gaitsizeArray*180/pi,speed2*1000,'o-');
xlabel('Gait Size (degree)');
ylabel('crawling speed (mm/s)');
legend('clockwise','counterclockwise');