clear all;
T=1.6;
dt=0.001*T;
t=0:dt:1.0*T;
% A1=[1 2 3 4 1];
% A2=[2 1 5 5 2];

% blue slit
% %blue slit given in CCW orientation
% A1=[-0.1745 -1.571 -1.571 -0.3491 0.2618 0.6109 -0.1745];
% A2=[-0.1745 0.6109 0.2618 -0.3491 -1.571 -1.571 -0.1745];

% A1=[-0.1745 -.8685 -1.571 -1.571 -0.996 -0.3491 -0.0672 0.2618 0.6109 0.232 -0.1745]; %a1Extra
% A2=[-0.1745 0.2158 0.6109 0.2618 -0.0257 -0.3491 -0.9129 -1.571 -1.571 -0.8974 -0.1745];%a2Extra

% red slit
%red slit given in CCW orientation
A1=[-0.3491 -1.571 -1.571 -1.396 -0.1745 -0.3491 ];
A2=[-0.1745 -1.396 -1.571 -1.571 -0.3491 -0.1745 ];

% A1=[-0.3491 -0.962 -1.571 -1.571 -1.396 -0.7961 -0.1745 -0.3491 ];%a1Extra
% A2=[-0.1745 -0.787 -1.396 -1.571 -1.571 -0.944 -0.3491 -0.1745 ];%a2Extra

AD1=round(-A1/pi*180+90)
AD2=round(A2/pi*180+90)


arm1=zeros(1,length(t));  arm2=arm1;
for i=1:length(t)
    [arm1(i),arm2(i)]=generalGait1(t(i),T,A1,A2);
end
% figure,scatter(arm1,arm2,20,t,'filled');
% axis equal; colorbar;
% figure,plot(t,arm1);
% hold on,plot(t,arm2);

hold on,scatter(arm1,arm2,20,t,'filled');
axis equal; colorbar;