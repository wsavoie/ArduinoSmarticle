its=3;
Ai=zeros(its+1,1);
Bi=zeros(its+1,1);
A0 = .05;
omega = 2*pi* 3;
m = .034;
gama= .25*pi;
m1 = (3*m)/34;
m2 = (28*m)/34;
g = 9.81;
mu = .37;
l1=0.76;
l2=1-l1;
phi=pi/5;
f=3.5;
XA=0.014;
XB=0.00718;

YA=0.014;
YB=0.00718;
% its=100;
v=zeros(its,1);


XA=0.014;
XB=0.00718;
l1=0.76;
l2=1-l1;

R1=phi/pi;
R2=(pi/2-phi)/pi;
R3=1/2;

P1=phi/(2*pi);
P2=(pi-phi)/(2*pi);
P3=(pi-phi)/(2*pi);
P4=phi/(2*pi);


r1=sin(phi)/pi;
r2=(1-sin(phi))/pi;
r3=-1/pi;

p1=(1-cos(phi))/(phi);
p2=(1+cos(phi))/(pi-phi);
p3=(-1-cos(phi))/(pi-phi);
p4=(-1+cos(phi))/(phi);


R=[R1 R2 R3];
r=[r1 r2 r3];
P=[P1 P2 P3 P4];
p=[p1 p2 p3 p4];





%this should be 1
%     sum(R);

d1=[XB,XA,XB];
d0=[0,XA,XA];
D1=[YB YB YB YB];
D0=[0 YA YA 0];

[avg,stdz]=getAvg(R,r,P,p,D1,D0,d1,d0,f,l1);

subplot(1,2,1);
hold on;
plot((1:its)./its,stdz(:,1))
plot((1:its)./its,avg(:,1))
h=legend({'stdx','meanx'});
xlabel('\lambda');
ylabel('mean and std');
figText(gcf,16);
subplot(1,2,2);
hold on;
plot((1:its)./its,stdz(:,2))
plot((1:its)./its,avg(:,2))
h=legend({'stdy','meany'});
xlabel('\lambda');
ylabel('mean and std');
figText(gcf,16);