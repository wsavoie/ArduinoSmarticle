function [XX,YY]=zackModelPars(its,A0,omega,m,gama,m1,m2,g,mu,f,phi,l1,varargin)
%zackModelPars
%X= [m_s/m_r,xavg,xstd,xvar]
%Y= [m_s/m_r,yavg,ystd,yvar]

AB=zeros(its,2);
mx=4;%max ring ratio, (lightest ring) smart/ringWeight=RingRat
mn=0.012; %min ring ratio
MR=linspace(m/mx,m/mn,its); %.1 is heaviest
for i=1:its
    mr=MR(i);    
    for j=1:2
    mb=mr+m*(j-1);    
    abfun=@(t)(2*(g*(2*m1+m2-mb)*t.*mu+A0*m2*omega*cos(gama+t.*omega)));
    tau=fzero(abfun,.0006);
%     sets some sort of upper bound?
    if tau>(1/omega)*(pi/2-gama)
        tau=1/omega*(pi/2-gama);
    end
    AB(i,j)=(g*(2*m1+m2-mb)*tau.^2*mu+2*A0*m2*sin(gama+tau*omega))/(m1+m2+mb)...
        -(2*A0*m2*sin(gama))/(m1+m2+mb);
    end  
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

[XX,YY]=deal(zeros(its,2));

% [XX,YY]=deal(zeros(its+1,4));
% [stdx,stdy]=deal(zeros(its+1,2));
% for i=0:its
for i=1:its
    XA=AB(i,1);
    YA=AB(i,1);
    
    XB=AB(i,2);
    YB=AB(i,2);

    d1=[XB,XA,XB];
    d0=[0,XA,XA];
    D1=[YB YB YB YB];
    D0=[0 YA YA 0];
    avg=getAvg(X,x,Y,y,D1,D0,d1,d0,f,l1);

    XX(i,:)=[m/MR(i),avg(1)];
    YY(i,:)=[m/MR(i),avg(2)];

end


% if length(varargin)
%     T=varargin{1}(:,5);
%     Ms=varargin{1}(:,1);
%     [stdx, stdy]=deal(zeros(length(T),3));
%     varx=zeros(1,length(T));
%     for i=1:length(T)
%         [~,ind]=min(abs(Ms(i)-(m./MR)));
%         XA=Ai(ind);
%         XB=Bi(ind);
%         YA=Ai(ind);
%         YB=Bi(ind);
% 
%         pref=-f/(4*pi^3*T(i));
%         ll1=-4*XA*XB*l1*(2*l1+1)*(phi+pi-l1*phi);
%         ll2=-XB^2*l1*(pi^3-6*pi*l1+2*pi^2*phi+6*(l1-1)*l1*phi);
%         ll3=XA^2*(pi^3*(l1-2)+pi*(4*l1^2+2)+2*pi^2*phi-2*(l1-1)*(2*l1^2+1)*phi);
%         ll4=-2*(-l1*phi+phi+pi)*(XA-XB*l1)*(4*l1*(XA-XB)*sin(phi)+cos(2*phi)*(XA-XB*l1));
%         ll5=pi^2*sin(2*phi)*(XA.^2-XB.^2*l1);
%         varx(i)=pref*(ll1+ll2+ll3+ll4+ll5);
%         
%         stdx(i,:)=[XX(ind,1),XX(ind,2),sqrt(varx(i))];
%         stdy(i,:)=[YY(ind,1),YY(ind,2),sqrt(varx(i))];
%         
%     end     
%      
% end

