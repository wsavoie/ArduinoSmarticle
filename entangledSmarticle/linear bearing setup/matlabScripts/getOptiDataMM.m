function [t,z,x,smartPos]=getOptiDataMM(fname)
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

%CS = chain start
%CE = chain end (where FT is connected)
%FTidx= index connected to FT sensor
z=fillmissing(data.data(1:end,5:3:end),'linear');
x=fillmissing(data.data(1:end,3:3:end),'linear');
y=fillmissing(data.data(1:end,4:3:end),'linear');

% % 
% % [~,FTidx]=min(z(1,:),[],2);
% % [~,FTidx2] = max(y(1,:),[],2);
% % if FTidx~=FTidx2
% %     warning('highest point is not FTidx')
% % end
% % 
% % z1=z(1,:); %create a var for first row
% % [~,CS]=min(z1(z1~=z1(FTidx)));
% % if(CS<=FTidx)
% %     CS=CS+FTidx;
% % end
% % [~,CE]=max(z1,[],2); %chain end
% % ID=[CS,CE,FTidx];
% % numMarks=length(z1);
% % if(~(numMarks==3 || numMarks==9))
% % error(['invalid number of markers numMarks=',num2string(numMarks),' ',fullfile(fold,fname)])
% % end
% % 
% % z=z-z(1,ID(2)); %start position from chain arm of first smart (CS)
% % x=x-x(1,ID(2)); %start position from chain arm of first smart (CS)
% % z=-z;

[~,FTidx]=min(z(1,:),[],2);
[~,FTidx2] = max(y(1,:),[],2);
if FTidx~=FTidx2
    warning('highest point is not FTidx')
end
hold on;
z1=z(1,:); %create a var for first row
x1=x(1,:);
[~,M]=sort(z1);
CE=M(2);


[~,CS]=max(z1); %chain start
% figure(100);
% hold on;
% plot(z1,x1,'o');
% plot(z1(CS),x1(CS),'r.');
% plot(z1(CE),x1(CE),'g.');
% plot(z1(FTidx),x1(FTidx),'b.');
% pause
% clf;

numMarks=size(z,2);
if(~(numMarks==3 || numMarks==9))
error(['invalid number of markers numMarks=',num2str(numMarks),' ',fullfile(fold,fname)])
end

z1=z(1,:); %create a var for first row
smartPos = [];
ID=[CS,CE,FTidx];

z=z-z(1,ID(2));
x=x-x(1,ID(2));

z=-z;
x=-x;


if(numMarks==9)
    
    
    %get all non id indices
    indz=setdiff(1:size(z,2),ID);
    smartPos.z=z(:,indz);
    smartPos.x=x(:,indz);
    [~,sortz]=sort(smartPos.z(1,:),'descend');
    smartPos.x=smartPos.x(:,sortz);
    smartPos.z=smartPos.z(:,sortz);
end
z=z(:,ID);
x=x(:,ID);
% % z=z-z(1,2);
% % x=x-x(1,2);

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