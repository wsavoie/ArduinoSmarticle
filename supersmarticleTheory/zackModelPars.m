function [XX,YY]=zackModelPars(its,A0,omega,m,gama,m1,m2,g,mu,f,phi,l1)
%zackModelPars
%X= [m_s/m_r,xavg,xstd,xvar]
%Y= [m_s/m_r,yavg,ystd,yvar]

Ai=zeros(its+1,1);
Bi=zeros(its+1,1);

for i=0:its
    
    mr = .25*m + i*.01*m;
    mb = mr;
    
    afun=@(t)(2*(g*(2*m1+m2-mb)*t.*mu+A0*m2*omega*cos(gama+t.*omega)));
    tau=fzero(afun,.0006);
    
%     sets some sort of upper bound?
    if tau>(1/omega)*(pi/2-gama)
        tau=1/omega*(pi/2-gama);
    end
    
    Ai(i+1)=(g*(2*m1+m2-mb)*tau.^2*mu+2*A0*m2*sin(gama+tau*omega))/(m1+m2+mb)...
        -(2*A0*m2*sin(gama))/(m1+m2+mb);
    
    %%%%%%%%%%bfun%%%%%%%%%%%%%%%
    mr = .25*m + i*.01*m;
    mb = mr + m;
    bfun=@(t)(2*(g*(2*m1+m2-mb)*t.*mu+A0*m2*omega*cos(gama+t.*omega)));
    tau=fzero(bfun,.0006);
    if tau>(1/omega)*(pi/2-gama)
        tau=1/omega*(pi/2-gama);
    end
    Bi(i+1)=(g*(2*m1+m2-mb)*tau.^2*mu+2*A0*m2*sin(gama+tau*omega))/(m1+m2+mb)...
        -(2*A0*m2*sin(gama))/(m1+m2+mb);
    
    
    
end


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
    

%this might have to be zero to length of ai when comparing to mathematica
%code
[xx,yy,XX,YY]=deal(zeros(its+1,4));
for i=0:its
    XA=Ai(i+1);
    XB=Bi(i+1);
    YA=Ai(i+1);
    YB=Bi(i+1);

    d1=[XB,XA,XB];
    d0=[0,XA,XA];
    D1=[YB YB YB YB];
    D0=[0 YA YA 0];
    [avg,stdz]=getAvg(X,x,Y,y,D1,D0,d1,d0,f,l1);
    
    xx(i+1,:)=[.25*m+.01*i*m,avg(1),stdz(1),stdz(1)^2];
    yy(i+1,:)=[.25*m+.01*i*m,avg(2),stdz(2),stdz(2)^2];
    
    XX(i+1,:)=[1/(.25+i*.01),avg(1),stdz(1),stdz(1)^2];
    
    YY(i+1,:)=[1/(.25+i*.01),avg(2),stdz(2),stdz(2)^2];
    
end


