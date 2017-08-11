clear all;
close all;
% load('D:\ChronoCode\chronoPkgs\Smarticles\matlabScripts\amoeba\smarticleExpVids\rmv3\movieInfo.mat');

% fold=uigetdir('A:\2DSmartData\');
fold=uigetdir('A:\2DSmartData\crawl\crawl1.25');
load(fullfile(fold,'movieInfo.mat'));
figure(1)
SPACE_UNITS = 'm';
TIME_UNITS = 's';
fold

%************************************************************
%* Fig numbers:
%* 1. calibrate world direction with DIR
%* 2. plot gait size
%************************************************************
% showFigs=[21 22 23];
showFigs=[1 2];

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
%% 2 plot avg speed distance/time vs gait radii with std