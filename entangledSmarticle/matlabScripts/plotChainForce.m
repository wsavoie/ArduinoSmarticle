%************************************************************
%* Fig numbers:
%* 1. force vs time with strain overlay
%* 2. plot comparison b/w activated system and regular, Force vs. Time
%* 3. plot single Force vs. Strain
%* 4. plot comparison b/w activated system and regular, Force vs. Strain

%************************************************************
% clearvars -except t
close all;
showFigs=[1 3];
fold=uigetdir('A:\2DSmartData\entangledData');
filez=dir2(fullfile(fold,'Stretch*'));
N=length(filez);

fpars=zeros(N,5); % [type,SD,H,del,v]
L=.26;%meters smarticle chain length
freq=1000; %hz rate for polling F/T sensor
s=struct;
for i=1:N
    [fpars(i,:),s(i).t,s(i).strain,s(i).F]=analyzeEntangleFile(...
        fold,filez(i).name,L,freq);
    s(i).name=filez(i).name;
    s(i).fpars=fpars(i,:);
    [s(i).type,s(i).SD,s(i).H,s(i).del,s(i).v]=separateVec(fpars(i,:),1);
    
end
[type,SD,H,del,v]=separateVec(fpars,1);


%% 1. single force vs time with strain overlay
xx=1;
if(showFigs(showFigs==xx))
figure(xx); lw=2;
hold on;
ind=1;
overlayStrain=1;

pts('F vs. T for ',s(ind).name);
plot(s(ind).t,s(ind).F);
maxF=max(s(ind).F);
maxS=max(s(ind).strain);

if(overlayStrain)
h=plot(s(ind).t,maxF*s(ind).strain/maxS);
% text(0.4,0.9,'scaled strain','units','normalized','color',h.Color)
legend({'Force','Scaled Strain'},'location','south')
end
xlabel('time (s)','fontsize',18);
ylabel('force (N)','fontsize',18);


figText(gcf,16)
end
%% 2.plot comparison b/w activated system and regular, Force vs. Time
xx=2;
if(showFigs(showFigs==xx))
figure(xx); lw=2; fz=18;
hold on;
xlab = 'time (s)';
ylab = 'Force (N)';
xlimz=[0,12];
ylimz=[-1,1];
subplot(1,2,1);
hold on;
title('Regular Chain');
xlabel(xlab);
ylabel(ylab);

%[type,strain, sys width,del,version]
setP1=find(ismember(fpars(:,[1 2 3 4]),[1 0.065,0.105,4],'rows'))';
setP2=find(ismember(fpars(:,[1 2 3 4]),[2 0.065,0.105,4],'rows'))';
for i=setP1
    plot(s(i).t,s(i).F);
%     pause;
end

axis([xlimz,ylimz])
axis square
figText(gcf,fz);
subplot(1,2,2);
hold on;

title('Activate First 2 Smarts During Delay Period');
xlabel(xlab);
for i=setP2
    plot(s(i).t,s(i).F);
%     pause
end
axis([xlimz,ylimz])
axis square
figText(gcf,fz);
end

%% 3. plot single Force vs. Strain
xx=3;
if(showFigs(showFigs==xx))
figure(xx); lw=2;
hold on;
ind=1;

pts('F vs. Strain for ',s(ind).name);
plot(s(ind).strain,s(ind).F);

xlabel('Strain');
ylabel('force (N)');
figText(gcf,16)
end
%% 4 plot comparison b/w activated system and regular, Force vs. Strain
xx=4;
if(showFigs(showFigs==xx))
   
figure(xx); lw=2; fz=18;
hold on;
xlab = 'Strain';
ylab = 'Force (N)';
xlimz=[0,0.25];
ylimz=[-0.65,0.65];
% 
% xlimz=[-0.7,0.7];
% ylimz=[-0.7,0.7];

subplot(1,2,1);
hold on;
title('Regular Chain');
xlabel(xlab);
ylabel(ylab);
for i=find(type==1)'
    plot(s(i).strain,s(i).F);
%     pause;
end
axis([xlimz,ylimz])
% ylim([-0.6,0.6]);
axis square
figText(gcf,fz);
subplot(1,2,2);
hold on;

title('Activate First 2 Smarts During Delay Period');
xlabel(xlab);
for i=find(type==2)'
    plot(s(i).strain,s(i).F);
%     pause
end
axis([xlimz,ylimz])
axis square
% axis equal

figText(gcf,fz);
end

%% 55 old way for force vs. strain
xx=55;
if(showFigs(showFigs==xx))
    
figure(xx); lw=2;
hold on;
% sp=interp1(t_op,diff(z_op)./diff(t_op),t);
z1=interp1(t_op,z_op,t,'linear','extrap');
strain=z1/L;
plot(t)
% plot(t,z1);
% plot(t_op,z_op);
% plot(t(delS),z1(delS),'o');
% 
% plot(t_op(delSop),z_op(delSop),'o');



strain1=t(1:delS)*speed;
strain1=strain1-strain1(1);
strain2=t(delE:end)*speed;
strain2=-1*(strain2-strain2(1));
strain2=strain1(end)+strain2;
strain=[strain1,strain2];

% plot(strain,[F(p1S(2):p1E(2));F(p2S(2):p2E(2))]);
plot(strain1/L,F(1:delS));

plot(strain1(end)/L*ones(1,delE-delS-1),F(delS+1:delE-1))

fm=abs(F(end));
% fm=abs(min(F(delE:end)));
plot(strain2/L,fliplr(F(delE:end)));

% plot(fliplr(strain2/L),fliplr(F(delE:end)'+abs(fm)));

xlabel('Strain','fontsize',18);
ylabel('Force (N)','fontsize',18);
xlim([0,0.5]);
ylim([-0.6,1])
figText(gcf,16);
end