clear all;
[FileName,PathName,~]=uigetfile({'*.csv'},'File Selector');
filename=horzcat(PathName,'\', FileName); % fullpath

instantPlot=0; radian=1;

data = importdata(filename);


y= data.data(:,[8 11 14 5]);
x= data.data(:,[6 9 12 3]);
y1av=mean(y,1);
[B,I] = sort(y1av);
y=y(:,I);
x=x(:,I);
% idA=id(I);

x1=x(:,1); y1=y(:,1);
x2=x(:,2); y2=y(:,2);
x3=x(:,3); y3=y(:,3);
x4=x(:,4); y4=y(:,4);

tE = data.data(:,2);

x0=0.5*(mean(x2)+mean(x3));
y0=0.5*(mean(y2)+mean(y3));

N=length(tE);
r=1; Np=round(r*N);

arm1E=zeros(1,Np); arm2E=arm1E;

figure;
for i=1:Np
    [arm1E(i),arm2E(i)]=pos2ang(x1(i),y1(i),x2(i),y2(i),x3(i),y3(i),x4(i),y4(i));
    arm1E(i)=-arm1E(i); arm2E(i)=-arm2E(i);
    if instantPlot
        plot([x1(i) x2(i)],[y1(i) y2(i)],'linewidth',2);
        hold on,plot([x2(i) x3(i)],[y2(i) y3(i)],'linewidth',2);
        hold on,plot([x3(i) x4(i)],[y3(i) y4(i)],'linewidth',2);
        axis equal; axis([x0-0.10,x0+0.10,y0-0.10,y0+0.10]);
        text(x1(i),y1(i),'1');
        text(x2(i),y2(i),'2'); text(x2(i)+0.05,y2(i),num2str(arm1E(i)*180/pi));
        text(x3(i),y3(i),'3'); text(x3(i)-0.05,y3(i),num2str(arm2E(i)*180/pi));
        text(x4(i),y4(i),'4');
        title('angles in degree');
        pause(0.00001);
        clf;
    end
end
[a b]=parseFileNames(FileName)

% figure(79)
% hold on;
% plot(tE(1:Np),arm1E(1:Np));
% plot(tE(1:Np),arm2E(1:Np));
% legend('arm12','arm34');
% xlabel('t (s)');
% ylabel('angle (radian)');

figure(80);
plot(arm1E,arm2E);
if radian
    figure(80);
%     
    scatter(arm1E(1:Np),arm2E(1:Np),15,tE(1:Np),'filled'); colorbar;
    xlabel('arm12 (radian)');
    ylabel('arm34 (radian)');
else
    figure(80);
    figure,scatter(-arm1E(1:Np)*180/pi,arm2E(1:Np)*180/pi,15,tE(1:Np),'filled'); colorbar;
    xlabel('arm12 (degree)');
    ylabel('arm34 (degree)');
end
axis square;
xpos=mean([x2 x3],2); %get xpos of center at all times
ypos=mean([y2,y3],2); %get ypos of center at all times

xpos=xpos-xpos(1);
ypos=ypos-ypos(1);


result=([xpos(end),ypos(end)]./norm([xpos(end),ypos(end)]))*[xpos,ypos]';

figure(81);
hold on;
plot(result*1000);
xlabel('time');
ylabel('y pos (mm)');

figure(82);
hold on;
axis square
plot(xpos,ypos);
% colormapline(xpos,ypos,[],jet(100));
% ln1=get(gcf);pos=ln1.CurrentAxes.Parent.CurrentObject.Position; m=pos(4)/pos(3)