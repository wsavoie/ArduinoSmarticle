clear all;
close all;
% load('D:\ChronoCode\chronoPkgs\Smarticles\matlabScripts\amoeba\smarticleExpVids\rmv3\movieInfo.mat');

% fold=uigetdir('A:\2DSmartData\');
fold=uigetdir('A:\2DSmartData\crawl');
load(fullfile(fold,'movieInfo.mat'));
figure(1)
SPACE_UNITS = 'm';
TIME_UNITS = 's';
fold

%************************************************************
%* Fig numbers:
%* 1. calibrate world direction with DIR
%* 2. plot gait size  or plot avg speed distance/time vs gait radii with std
%* 3. distance per gait
%************************************************************
showFigs=[3];

%params we wish to plot
DIR=[]; RAD=[]; V=[];

props={};
inds=1;
for i=1:length(movs)
    
    cond=true;
    for j=1:length(props)
        %if empty accept all values
        if ~isempty(props{j})
            %in case multiple numbers in property
            %if no matches then cond = false
            if(~any(props{j}==movs(i).pars(j)))
                cond = false;
            end
        end
    end
    if(cond)
        usedMovs(inds)=movs(i);
        inds=inds+1;
    end
end

N=length(usedMovs); %number of used movs
allPars=zeros(length(usedMovs),3); %all mov params saved into a single var
lw=2; %linewidth
for i=1:length(usedMovs)
    allPars(i,:)=usedMovs(i).pars;
end
if isempty(DIR)
    D1=find(allPars(:,1)==1);
    D2=find(allPars(:,1)==2);
else
    if(DIR==1)
        D1=allPars(:,1);
        D2=[];
    else
        D1=[];
        D2=allPars(:,1);
    end
end

%% 1 calibrate world direction with DIR
xx=1;
if(showFigs(showFigs==xx))
    
    figure(xx)
    hold on;
    if(~isempty(DIR))
        error('you want to reload save with no DIR specified');
    end
    hax1=gca;
    ind=1;
    plot(usedMovs(D1(ind)).t,usedMovs(D1(ind)).x,'r','linewidth',lw);
    plot(usedMovs(D2(ind)).t,usedMovs(D2(ind)).x,'k','linewidth',lw);
    xlabel('time (s)');
    ylabel('displacement(m)');
    figText(gcf,16);
    legend({'Toward Right', 'Toward Left'});
end
%% 2 plot avg speed distance/time vs gait radii with std
xx=2;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    %     first get number of gait radii used
    uRadD1=unique(allPars(D1,2));
    uRadD2=unique(allPars(D2,2));
    
    VD1=zeros(length(uRadD1),1); stdD1=VD1;
    VD2=zeros(length(uRadD2),1); stdD2=VD2;
    
    for i=1:length(uRadD1)
        idxs=find(allPars(:,1)==1&allPars(:,2)==uRadD1(i));
        vtot=zeros(length(idxs),1);
        for j=1:length(idxs)
            vtot(j)=(usedMovs(idxs(j)).x(end)-usedMovs(idxs(j)).x(1))/usedMovs(idxs(j)).t(end);
        end
        VD1(i)=mean(vtot)*1000;
        stdD1(i)=std(vtot)*1000;
    end
    
    for i=1:length(uRadD2)
        idxs=find(allPars(:,1)==2&allPars(:,2)==uRadD2(i));
        vtot=zeros(length(idxs),1);
        for j=1:length(idxs)
            vtot(j)=(usedMovs(idxs(j)).x(end)-usedMovs(idxs(j)).x(1))/usedMovs(idxs(j)).t(end);
        end
        VD2(i)=mean(abs(vtot))*1000;
        stdD2(i)=std(vtot)*1000;
    end
    
    errorbar(uRadD1,VD1,stdD1,'r','linewidth',lw);
    errorbar(uRadD2,VD2,stdD2,'k','linewidth',lw);
    xlabel('Gait radius (\circ)');
    ylabel('Velocity (mm/s)');
    legend({'Toward Right', 'Toward Left'});
    figText(gcf,16);
    
end
%% 3 avg speed vs position
xx=3;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    %     first get number of gait radii used
    
    uRadD1=unique(allPars(D1,2));
    uRadD2=unique(allPars(D2,2));
    
    %get 3 z heights
    %bottom and top of same gait, then bottom of next gait
    plot(usedMovs(1).t,usedMovs(1).z);
    [x,y]=ginput(3);
    dist=x(3)-x(1);
    gBott=y(1); %bottom of gait height
    gTop=y(3);  %top of gait height
    
    [pksT,locsT]=findpeaks(usedMovs(1).z,'MinPeakDistance',usedMovs(1).fps*.9*dist,'minpeakHeight',y(2)*.95);
    [pksB,locsB]=findpeaks(-usedMovs(1).z,'MinPeakDistance',usedMovs(1).fps*.9*dist,'minpeakHeight',-y(1)*1.05);
%     [pksT,locsT]=findpeaks(usedMovs(1).z,usedMovs(1).t,'MinPeakDistance',dist*.9,'minpeakHeight',y(2)*.95);
%     [pksB,locsB]=findpeaks(-usedMovs(1).z,usedMovs(1).t,'MinPeakDistance',dist*.9,'minpeakHeight',-y(1)*1.1);
    %         plot(usedMovs(1).t,usedMovs(1).z);
    %         hold on;
%     plot(locsB,-pksB,'o');
%     plot(locsT,pksT,'o');

    plot(usedMovs(1).t(locsT),usedMovs(1).z(locsT),'o');
    plot(usedMovs(1).t(locsB),usedMovs(1).z(locsB),'o');
    gaitzD1=cell(length(uRadD1),1);
    gaitzD2=cell(length(uRadD2),1);
    for i=1:length(uRadD1)
        
        idxs=find(allPars(:,1)==1&allPars(:,2)==uRadD1(i));
        %         get indexes of particular gait radii
        
        gaitzD1{i}=cell(length(idxs),2);
        for j=1:length(idxs)
            [pksT,locsT]=findpeaks(usedMovs(idxs(j)).z,'MinPeakDistance',usedMovs(idxs(j)).fps*.9*dist,'minpeakHeight',y(2)*.95);
            [pksB,locsB]=findpeaks(-usedMovs(idxs(j)).z,'MinPeakDistance',usedMovs(idxs(j)).fps*.9*dist,'minpeakHeight',-y(1)*1.05);
%             [pksT,locsT]=findpeaks(usedMovs(idxs(j)).z,usedMovs(idxs(j)).t,'MinPeakDistance',dist*.9,'minpeakHeight',y(2)*.8);
%             [pksB,locsB]=findpeaks(-usedMovs(idxs(j)).z,usedMovs(idxs(j)).t,'MinPeakWidth',dist*.9,'minpeakHeight',-y(1)*1.2);
%             gaitzD1{i}{j,1}=[pksT,locsT];
%             gaitzD1{i}{j,2}=[-pksB,locsB];
            gaitzD1{i}{j,1}=[usedMovs(idxs(j)).x(locsT),diff(usedMovs(idxs(j)).x(locsT))];
            gaitzD1{i}{j,2}=[usedMovs(idxs(j)).x(locsB),diff(usedMovs(idxs(j)).x(locsB))];
        end
    end
    
    for i=1:length(uRadD2) 
        idxs=find(allPars(:,1)==2&allPars(:,2)==uRadD2(i));
        gaitzD2{i}=cell(length(idxs),2);
        for j=1:length(idxs)
            [pksT,locsT]=findpeaks(usedMovs(idxs(j)).z,'MinPeakDistance',usedMovs(idxs(j)).fps*.9*dist,'minpeakHeight',y(2)*.95);
            [pksB,locsB]=findpeaks(-usedMovs(idxs(j)).z,'MinPeakDistance',usedMovs(idxs(j)).fps*.9*dist,'minpeakHeight',-y(1)*1.05);
%             [pksT,locsT]=findpeaks(usedMovs(idxs(j)).z,usedMovs(idxs(j)).t,'MinPeakDistance',dist*.9,'minpeakHeight',y(2)*.8);
%             [pksB,locsB]=findpeaks(-usedMovs(idxs(j)).z,usedMovs(idxs(j)).t,'MinPeakDistance',dist*.9,'minpeakHeight',-y(1)*1.2);
%             gaitzD2{i}{j,1}=[pksT,locsT];
%             gaitzD2{i}{j,2}=[-pksB,locsB];
            gaitzD2{i}{j,1}=[usedMovs(idxs(j)).x(locsT),diff(usedMovs(idxs(j)).x(locsT))];
            gaitzD2{i}{j,2}=[usedMovs(idxs(j)).x(locsB),diff(usedMovs(idxs(j)).x(locsB))];
        end
    end
    figText(gcf,16);
    xlabel('gait num');
    ylabel('displacement (mm)')
end


