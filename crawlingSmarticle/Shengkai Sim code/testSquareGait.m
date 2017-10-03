clear all;

T=1.6;
dt=0.001*T;
t=0:dt:1.0*T;
MSpeed=2*pi/0.4;
gR=90*pi/180;

arm1=zeros(1,length(t));  arm2=arm1;
for i=1:length(t)
%     [arm1(i),arm2(i)]=squareGait3(t(i),T,1);
%     [arm1(i),arm2(i)]=squareGait5(t(i),T,MSpeed,0);
    [arm1(i),arm2(i)]=squareGait6(t(i),T,MSpeed,gR,1);
end
figure,scatter(arm1,arm2,20,t,'filled');
axis equal;
figure,plot(t,arm1);
hold on,plot(t,arm2);
% mT,mR,mAT,20,mAT,'filled'