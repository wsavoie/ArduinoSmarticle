function [stdx,stdy]=calcStd(A0,omega,m,gama,m1,m2,g,mu,f,phi,l1,expX)

MR=m/expX(1);

% MR=linspace(m/mx,m/mn,its+1); %.1 is heaviest

AB=[0,0];
for j=1:2
    mb=MR+m*(j-1);    
    abfun=@(t)(2*(g*(2*m1+m2-mb)*t.*mu+A0*m2*omega*cos(gama+t.*omega)));
    tau=fzero(abfun,.0006);
%     sets some sort of upper bound?
    if tau>(1/omega)*(pi/2-gama)
        tau=1/omega*(pi/2-gama);
    end
    AB(j)=(g*(2*m1+m2-mb)*tau.^2*mu+2*A0*m2*sin(gama+tau*omega))/(m1+m2+mb)...
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
XA=AB(1);
XB=AB(2);
YA=AB(1);
YB=AB(2);

d1=[XB,XA,XB];
d0=[0,XA,XA];
D1=[YB YB YB YB];
D0=[0 YA YA 0];

avg=getAvg(X,x,Y,y,D1,D0,d1,d0,f,l1);

T=expX(5);

%varX
prefX=-f/(4*pi^3*T);
llx1=-4*XA*XB*l1*(2*l1+1)*(-l1*phi+phi+pi);
llx2=-XB^2*l1*(pi^3-6*pi*l1+2*pi^2*phi+6*(l1-1)*l1*phi);
llx3=XA^2*(pi^3*(l1-2)+pi*(4*l1^2+2)+2*pi^2*phi-2*(l1-1)*(2*l1^2+1)*phi);
llx4=-2*(-l1*phi+phi+pi)*(XA-XB*l1)*(4*l1*(XA-XB)*sin(phi)+cos(2*phi)*(XA-XB*l1));
llx5=pi^2*sin(2*phi)*(XA.^2-XB.^2*l1);
varx=prefX*(llx1+llx2+llx3+llx4+llx5);

% %varY zacks form
    prefY=f*T/(4*pi*T^2);
    lly1=YB^2*l1*(pi-2*phi);
    lly2=-YA^2*(pi*(l1-2)+2*phi);
    lly3=(YA.^2-YB.^2*l1)*sin(2*phi);
    vary=prefY*(lly1+lly2+lly3);

%varY my form  
%     prefY=f*T/(2*pi*T^2);
%     lly1=-YA^2*(l1-1)*(pi-phi+cos(phi)*sin(phi));
%     lly2=YB^2*pi*l1;
%     vary=prefY*(lly1+lly2);
stdx=[expX(1),avg(1),sqrt(varx)];
stdy=[expX(1),avg(2),sqrt(vary)];



end
