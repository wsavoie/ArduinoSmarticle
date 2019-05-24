%% 53 plot active smart diagram
clear all
xx=53;

% if(showFigs(showFigs==xx))
figure(xx)
hold on;
fold='A:\ArduinoSmarticle\supersmarticleMatlab';
load(fullfile(fold,'trackedLightSmartChannel.mat'));
cols= get(gca,'colorOrder');
cols=cols(1:6,:);
gp=1.6;%gait period
smartChangeTimes=smartChangeTimes/gp; %convert to gaitPeriod
rStart=392; %time when direction starts towards right
rEnd=427;   %time when direction ends towards right

%5 directions over 24:58 mins, we want to weight the trials by their time
% [0-220,220-700,700-981,981-1069,1069-1500]
swTimes=[0,220,700,981,1069,1500.1]/gp;
w=diff(swTimes)/swTimes(end); %
X=zeros(length(w),5); %trials,smarts
for i=1:(length(smartChangeTimes)-1)
    for k=1:length(smartsActive{i})
        %vertices starting from top left clockwise
        %right dir goes 392-427tau or 16:20s and ends at 17:48
        
        xVerts=[smartChangeTimes(i) smartChangeTimes(i+1)...
            smartChangeTimes(i+1) smartChangeTimes(i)];
        
        yVerts=[(smartsActive{i}(k)+0.5),(smartsActive{i}(k)+0.5)...
            (smartsActive{i}(k)-0.5) (smartsActive{i}(k)-0.5)];
        trial=find(smartChangeTimes(i)-swTimes(2:end)<=0,1);
        
        
        if(smartsActive{i}(k))
            X(trial,smartsActive{i}(k))=X(trial,smartsActive{i}(k))+xVerts(2)-xVerts(1);
        end
        %             patch(xVerts-rStart,yVerts,cols(smartsActive{i}(k)+1,:),'linestyle','none');
        patch(xVerts,yVerts,cols(smartsActive{i}(k)+1,:),'linestyle','none');
    end
end
axis tight;
ylim([-0.5,5.5]);

for i=1:length(swTimes)
    plot([swTimes(i) swTimes(i)],[min(ylim),max(ylim)],'k','linewidth',3)
end

%     xlim([0,rEnd-rStart])

set(gca,'ytick',[0:5],'yticklabel',{'' '1' '' '3' '' '5'});
%     set(gca,'xtick',[0:5:35],'xticklabel',{'0' '' '10' '' '20' '' '30' ''});
ylabel('Inactive Index');
xlabel('Time (\tau)');
figText(gcf,16);

% end

figure(22);
hold on;
% [gx,gy]=Gini(X);
ggy=[];
% X=w.*X;
% X=sum(X,2);

%%%%%%% uncomment for weighted average %%%%%%%%%%%%%%%%
for i=1:size(X,1)
    [gx,gy]=Gini(X(i,:));
    xinds=gy(:,1);
    ggy(:,i)=gy(:,2);
    ggx(i)=gx;
end
% % % w=sum(X,2)'/sum(sum(X));
G=sum(w.*ggx);
ggy2=sum(w.*ggy,2);
% % % ggy2=mean(ggy,2);
gy=[xinds,ggy2];
err=std(ggy,w,2);
%%%%%%% uncomment for weighted average %%%%%%%%%%%%%%%%

%%%%%%% uncomment for Gini over full time %%%%%%%%%%%%%%%%
% [gx,gy]=Gini(sum(X,2));
% err=zeros(size(gy,1),1);
% G=gx;
%%%%%%% uncomment for Gini over full time %%%%%%%%%%%%%%%%

fz=20;
x2=[0,1]; y2=[1,0];
x2=interp1(x2,y2,gy(:,1));
y2=interp1(y2,y2,gy(:,1));
errorbar(gy(:,1),gy(:,2),err,'-o','Linewidth',2);
[xout,yout]=intersections(x2,y2,gy(:,1),gy(:,2),1);
text(.05,0.49,[num2str(round(yout*100)),'%-',num2str(round(xout*100)),'%'])
text(0.32,0.7,['G\approx',num2str(G,2)]);
figText(gcf,fz);
%     plot([0,1],[1,0],'k','linewidth',2)
plot([0,xout],[yout,yout],'k--','linewidth',2)
plot([xout,xout],[0,yout],'k--','linewidth',2)
ylabel('Cum. fract. of inactive time');
xlabel('Cum. fract. of smarticles');
axis square




