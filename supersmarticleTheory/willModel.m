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

X1=phi/pi;
X2=(pi/2-phi)/pi;
X3=1/2;

x1=sin(phi)/phi;
x2=(1-sin(phi))/(pi/2-phi);
x3=-2/pi;


Y1=phi/(2*pi);
Y2=(pi-phi)/(2*pi);
Y3=(pi-phi)/(2*pi);
Y4=phi/(2*pi);

y1=(1-cos(phi))/(phi);
y2=(1+cos(phi))/(pi-phi);
y3=(-1-cos(phi))/(pi-phi);
y4=(-1+cos(phi))/(phi);


X=[X1 X2 X3];
x=[x1 x2 x3];
Y=[Y1 Y2 Y3 Y4];
y=[y1 y2 y3 y4];




%this should be 1
%     sum(R);

d1=[XB,XA,XB];
d0=[0,XA,XA];
D1=[YB YB YB YB];
D0=[0 YA YA 0];

[avg,stdz]=getAvg(X,x,Y,y,D1,D0,d1,d0,f,l1);

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