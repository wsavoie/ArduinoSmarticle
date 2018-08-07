function [t,z,x]=getOptiDataMM(fname)
%outputs time and z data in seconds and mm


% file='A:\2DSmartData\entangledData\OPTI_Stretch_0_SD_26_H_10_del_4_v_1.csv';
data = importdata(fname);
% t=t(1:dec:end,:);
% x = -data.data(1:dec:end,ringInd+4); %was 7
% y = data.data(1:dec:end,ringInd+6); %was 9
% z = data.data(1:dec:end,ringInd+5); %was 8
frames=data.data(1:end,1);
t=data.data(1:end,2);
% x=data.data(:,3:3:ends

%ft sensor is connected to end of chain
%farthest point is start of chain

%cs = chain start
%ce = chain end

z=fillmissing(data.data(1:end,5:3:end),'linear');
x=fillmissing(data.data(1:end,3:3:end),'linear');


[~,FTidx]=min(z(1,:),[],2);
[~,CS]=max(z(1,:),[],2);
%assuming 3 markers 3 + 2 + 1=6
CE=6-(FTidx+CS);
ID=[CS,CE,FTidx];
% 
% x=data.data(1:end,3:3:end);
% y=data.data(1:end,4:3:end);
% 
% x=x-x(1,ID(1));
% y=y-y(1,ID(1));
% z=z-z(1,ID(3));

z=z-z(1,ID(2));
z=-z;
z=z(:,ID);

x=x-x(1,ID(2));
x=-x;
x=x(:,ID);



% figure(23);
% clf;
% hold on;
% plot(t,z(:,1),t,z(:,2),t,z(:,3))
% legend({'chain start','chain end','FTsensor'});
% title('asd');
% q=sqrt(x.^2+y.^2+z.^2);


% figure(1);
% plot(t,x);
% title('x')
% 
% figure(2);
% plot(t,y);
% title('y')
% 
% figure(3);
% plot(t,z);
% title('z')
% 
% figure(4);
% q=sqrt(x.^2+y.^2+z.^2);
% plot(t,q);
% title('q')