function [x1,y1,x2a,y2a,x2b,y2b,x3a,y3a,x3b,y3b,x4,y4,x2,y2,x3,y3]=cfg2coordinateT(D0,W0,D,L,ort,arm1,arm2,x0,y0)
R=[cos(ort) -sin(ort);sin(ort) cos(ort)];
q=R*[-0.5*D0;0.5*W0];   x2a=q(1)+x0; y2a=q(2)+y0;
q=R*[-0.5*D0;-0.5*W0];  x2b=q(1)+x0; y2b=q(2)+y0;
q=R*[0.5*D0;-0.5*W0];   x3b=q(1)+x0; y3b=q(2)+y0;
q=R*[0.5*D0;0.5*W0];    x3a=q(1)+x0; y3a=q(2)+y0;
q=R*[-0.5*D-L*cos(arm1);L*sin(arm1)];
x1=q(1)+x0;  y1=q(2)+y0;
q=R*[0.5*D+L*cos(arm2);L*sin(arm2)];
x4=q(1)+x0;  y4=q(2)+y0;
x3=x0+0.5*D*cos(ort);
y3=y0+0.5*D*sin(ort);
x2=2*x0-x3;
y2=2*y0-y3;
end