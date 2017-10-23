file='A:\2DSmartData\entangledData\Take 2017-10-17 01.01.49 PM.csv';
data = importdata(file);
% t=t(1:dec:end,:);
% x = -data.data(1:dec:end,ringInd+4); %was 7
% y = data.data(1:dec:end,ringInd+6); %was 9
% z = data.data(1:dec:end,ringInd+5); %was 8
frames=data.data(1:end,1);
t=data.data(1:end,2);
x=data.data(1:end,3);
y=data.data(1:end,4);
z=data.data(1:end,5);

plot3(x,y,z)
xlabel('x');
ylabel('y');
zlabel('z');

figure(2);
hold on;
plot(x,z);
figure(4);
hold on;
plot(t,z);

t0=700;
tf=1540;
tc=t(t0:tf);
xc=x(t0:tf);
yc=y(t0:tf);
zc=z(t0:tf);

t02=20;tf2=
plot(tc,zc);
% l=sqrt((xc(end)-xc(1))^2+...
%         (yc(end)-tc(1))^2+...
%         (zc(end)-zc(1))^2)

Tz=sqrt((zc(end)-zc(1))^2)
Txz=sqrt((zc(end)-zc(1))^2+(xc(end)-xc(1))^2)
Txyz=sqrt((zc(end)-zc(1))^2+(xc(end)-xc(1))^2+(yc(end)-yc(1))^2)

tc(end)-tc(1)