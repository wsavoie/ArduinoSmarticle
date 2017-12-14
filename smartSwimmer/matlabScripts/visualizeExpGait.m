clear all;
[FileName,PathName,~]=uigetfile({'*.csv'},'File Selector');
filename=horzcat(PathName,'\', FileName); % fullpath

instantPlot=1; radian=1;

data = importdata(filename);
x4 = data.data(:,3);
y4 = data.data(:,5);
x3 = data.data(:,6);
y3 = data.data(:,8);

x2 = data.data(:,9);
y2 = data.data(:,11);
x1 = data.data(:,12);
y1 = data.data(:,14);
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
        axis equal; axis([x0-0.10,x0+0.10,y0-0.05,y0+0.05]);
        text(x1(i),y1(i),'1');
        text(x2(i),y2(i),'2'); text(x2(i)+0.05,y2(i),num2str(arm1E(i)*180/pi));
        text(x3(i),y3(i),'3'); text(x3(i)-0.05,y3(i),num2str(arm2E(i)*180/pi));
        text(x4(i),y4(i),'4');
        title('angles in degree');
        pause(0.00001);
        clf;
    end
end

figure,plot(tE(1:Np),arm1E(1:Np));
hold on,plot(tE(1:Np),arm2E(1:Np));
legend('arm12','arm34');
xlabel('t (s)');
ylabel('angle (radian)');

% figure,plot(arm1E,arm2E);
if radian
    figure,scatter(arm1E(1:Np),arm2E(1:Np),15,tE(1:Np),'filled'); colorbar;
    xlabel('arm12 (radian)');
    ylabel('arm34 (radian)');
else
    figure,scatter(-arm1E(1:Np)*180/pi,arm2E(1:Np)*180/pi,15,tE(1:Np),'filled'); colorbar;
    xlabel('arm12 (degree)');
    ylabel('arm34 (degree)');
end
axis square;