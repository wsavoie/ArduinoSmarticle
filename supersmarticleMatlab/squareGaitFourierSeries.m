R=90; T=1.7;
n=1:11;
an=R*T*(-0.202642 + 0.202642*cos(n.*pi/2)+0.202642*cos(n.*pi)-0.202642*cos(3*n.*pi/2))./(n.^2);
bn=R*T*(0.202642*sin(n.*pi/2)+0.202642*sin(n.*pi)-0.202642*sin(3*n.*pi/2))./(n.^2);

ph=-7/4*pi;
an2=R*T*(-0.202642 + 0.202642*cos(n.*pi/2+ph)+0.202642*cos(n.*pi+ph)-0.202642*cos(3*n.*pi/2+ph))./(n.^2);
bn2=R*T*(0.202642*sin(n.*pi/2+ph)+0.202642*sin(n.*pi+ph)-0.202642*sin(3*n.*pi/2+ph))./(n.^2);


x=0:0.01:3;
y=zeros(1,length(x));
y2=zeros(1,length(x));
arg=zeros(1,length(n));
arg2=zeros(1,length(n));
for i=n
    arg(i)=round(2*pi*i/T,3);
    arg2(i)=round(-2*pi*i/T*(ph),3);
    y=y+an(i)*cos(arg(i).*x)+bn(i)*sin(arg(i).*x);
    y2=y2+an(i)*cos(arg(i).*x+arg2(i))+bn(i)*sin(arg(i).*x+arg2(i));
end
y=y*2/T;
y2=y2*2/T;
hold on;
figure(1)
plot(y,y2);
figure(2)
hold on;
plot(x,y);
plot(x,y2);
