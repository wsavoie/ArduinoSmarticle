% w/o friction
% center of mass is conserved
clear all;
instantPlot=1;
plotz=0;
k=5e3; m0=0.0248; m1=0.003186; g=9.81;
dt=1e-5; T=18; TGait=1.6; N=round(T/dt); dN0=1000; %round(N/1000)
d0=0.001; u0=0.05; R=1; A=25; % (R,A) controls the restitution
slow=0.00001; % speed threshold to apply static friction
% r=90/90;
MSpeed=pi/(TGait/4);  % pi/(TGait/4);
gR=50*pi/180;
ccw=0;
miu=0.37;
miuS=0.43;
D=0.042; L=0.05; % D: center to pivot,  L: pivot to arm tip
D0=0.054; W0=0.022; % D0: length of center piece % W0: width of center piece
% L=0.5*L;
arm1=0; arm2=0;
ort=zeros(1,N);
x0=ort;  y0=ort;
x0t=ort; y0t=ort; ortt=ort;
x1=ort; y1=ort; x2=ort; y2=ort;
x3=ort; y3=ort; x4=ort; y4=ort;

x2a=ort; y2a=ort; x2b=ort; y2b=ort;
x3a=ort; y3a=ort; x3b=ort; y3b=ort;

ort(1)=0;  x0(1)=0;   y0(1)=0.06; %W0
ortt(1)=1; x0t(1)=0;  y0t(1)=0;

[x1(1),y1(1),x2a(1),y2a(1),x2b(1),y2b(1),x3a(1),y3a(1),...
    x3b(1),y3b(1),x4(1),y4(1),x2(1),y2(1),x3(1),y3(1)]...
    =cfg2coordinateT(D0,W0,D,L,ort(1),arm1,arm2,x0(1),y0(1));

fileName=['crawlingStudy_ThickCenter80',num2str(miu)];
if plotz
    aviobj = VideoWriter(fileName);
%     aviobj = VideoWriter('crawlingStudy4_squareGait_1x.avi');
    open(aviobj);
end
for i=2:N
    t=dt*i;
%     arm1=0;
%     arm2=-0.2*pi*t;
%     arm2=-0.5*(0.5*pi+asin(sin(2*(t+0.75*pi))));
%     arm2=0;

    [arm1,arm2]=squareGait6(t,TGait,MSpeed,gR,ccw);
%     arm1=r*arm1;  arm2=r*arm2;
    [x1Tr,y1Tr,x2aTr,y2aTr,x2bTr,y2bTr,x3aTr,y3aTr,x3bTr,y3bTr,x4Tr,y4Tr,...
        x2Tr,y2Tr,x3Tr,y3Tr]=cfg2coordinateT(D0,W0,D,L,ort(i-1),arm1,arm2,x0(i-1),y0(i-1));

    % Calculate intrusion and relative speed
    n1=-(y1Tr<0)*y1Tr;
    n2b=-(y2bTr<0)*y2bTr;
    n3b=-(y3bTr<0)*y3bTr;
    n4=-(y4Tr<0)*y4Tr;
    u1=(y1(max(i-2,1))-y1(i-1))/dt;    ux1=(x1(i-1)-x1(max(i-2,1)))/dt;
    u2=(y2b(max(i-2,1))-y2b(i-1))/dt;  ux2=(x2b(i-1)-x2b(max(i-2,1)))/dt;
    u3=(y3b(max(i-2,1))-y3b(i-1))/dt;  ux3=(x3b(i-1)-x3b(max(i-2,1)))/dt;
    u4=(y4(max(i-2,1))-y4(i-1))/dt;    ux4=(x4(i-1)-x4(max(i-2,1)))/dt;
    
    % Evaluate forces
    Fy1=R*(n1/d0)+A*(u1/u0)*(n1/d0);
    Fy2=R*(n2b/d0)+A*(u2/u0)*(n2b/d0);
    Fy3=R*(n3b/d0)+A*(u3/u0)*(n3b/d0);
    Fy4=R*(n4/d0)+A*(u4/u0)*(n4/d0);
    if abs(ux1)>slow
        fy1=-sign(ux1)*miu*Fy1;
    else
        fy1=-sign(ux1)*miuS*Fy1;
    end
    
    if abs(ux2)>slow
        fy2=-sign(ux2)*miu*Fy2;
    else
        fy2=-sign(ux2)*miuS*Fy2;
    end
    
    if abs(ux3)>slow
        fy3=-sign(ux3)*miu*Fy3;
    else
        fy3=-sign(ux3)*miuS*Fy3;
    end
    
    if abs(ux4)>slow
        fy4=-sign(ux4)*miu*Fy4;
    else
        fy4=-sign(ux4)*miuS*Fy4;
    end
    
    % Net force
    Fx=fy1+fy2+fy3+fy4;
    Fy=Fy1+Fy2+Fy3+Fy4-(m0+2*m1)*g;
    ytt=Fy/(m0+2*m1);
    xtt=Fx/(m0+2*m1);
    
    % Torque about (x0,y0)
    torN=(x1Tr-x0(i-1))*Fy1+(x2bTr-x0(i-1))*Fy2+(x3bTr-x0(i-1))*Fy3+(x4Tr-x0(i-1))*Fy4;
    g1x=0.5*(x1Tr+x2Tr)-x0(i-1); g1y=0.5*(y1Tr+y2Tr)-y0(i-1);
    g2x=0.5*(x3Tr+x4Tr)-x0(i-1); g2y=0.5*(y3Tr+y4Tr)-y0(i-1);
    torG=cross([g1x,g1y,0],[0,-m1*g,0])+cross([g2x,g2y,0],[0,-m1*g,0]);
    torf=Fx*y0(i-1);
    tor=torN+torG(3)+torf;
    MI=momentOfInertia1T(m0,D0,W0)+...
        momentOfInertia2(m1,D,L,arm1)+momentOfInertia2(m1,D,L,arm2);
    orttt=tor/MI; % counterclockwise
    
    x0t(i)=x0t(i-1)+dt*xtt;
    y0t(i)=y0t(i-1)+dt*ytt;
    ortt(i)=ortt(i-1)+dt*orttt;
    
    x0(i)=x0(i-1)+dt*x0t(i);
    y0(i)=y0(i-1)+dt*y0t(i);
    ort(i)=ort(i-1)+dt*ortt(i);

    [x1(i),y1(i),x2a(i),y2a(i),x2b(i),y2b(i),x3a(i),y3a(i),x3b(i),y3b(i),...
        x4(i),y4(i),x2(i),y2(i),x3(i),y3(i)]...
        =cfg2coordinateT(D0,W0,D,L,ort(i),arm1,arm2,x0(i),y0(i));

    if (mod(i,dN0)==0) % (mod(i,dN0)==0)&&(instantPlot==1)
        i*100/N
        if instantPlot==1
            plotSmarticleT(D0,W0,D,L,ort(i),arm1,arm2,x0(i),y0(i));
            hold on,plot([-1.5*L 4.5*L],[0 0],'k');

            axis equal;
            axis([-1.5*L 4.5*L -0.5*L 1.5*L]);

            xlabel('x (m)');
            ylabel('y (m)');
            
            titleName=['m_{center}=',num2str(m0*1000),'g, m_{single arm}=',...
                num2str(m1*1000),'g, Gait period=',num2str(TGait),'s, \mu=',...
                num2str(miu)];
            title(titleName);

            MM=getframe(gcf);
            if plotz
                writeVideo(aviobj,MM);
            end
            clf;
        end
    end
end

TG=round(TGait/dt);
crawlSpeed=(mean(x2(end-TG:end))-mean(x2(1:TG)))/(T-TGait);

if plotz
    close(aviobj);
end