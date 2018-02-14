% clear all;
% close all;
% load('D:\ChronoCode\chronoPkgs\Smarticles\matlabScripts\amoeba\smarticleExpVids\rmv3\movieInfo.mat');

% fold=uigetdir('A:\2DSmartData\');
fold=uigetdir('A:\2DSmartData\crawl\diamond gait 9-27-17');
load(fullfile(fold,'movieInfo.mat'));
SPACE_UNITS = 'm';
TIME_UNITS = 's';
fold
%************************************************************
%* Fig numbers:
%* 1. calibrate world direction with DIR
%* 2. plot gait size  or plot avg speed distance/time vs gait radii with std
%* 3. distance per gait
%* 4. plot only left or right
%* 5. plot gait radius pic
%* 6. plotting out x vs t for dan and phase shifting
%* 7. fft of gait
%************************************************************
showFigs=[1 7];

%params we wish to plot
DIR=[]; RAD=[]; V=[];

props={DIR RAD V};
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
    h1=plot(usedMovs(D1(ind)).t,usedMovs(D1(ind)).x,'r','linewidth',lw);
    h2=plot(usedMovs(D2(ind)).t,usedMovs(D2(ind)).x,'k','linewidth',lw);
    [x1]=MagnetGInput(h1,2);
    [x2]=MagnetGInput(h2,2);
    [diff(x1), diff(x2)]
    xlabel('time (s)');
    ylabel('displacement(m)');
    
    legend({'Toward Right', 'Toward Left'});
    text(.1,.1,{'right \uparrow',' left \downarrow'},'units','normalized')
    figText(gcf,16);
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
        vtot2=zeros(length(idxs),1);
        for j=1:length(idxs)
            vtot2(j)=(usedMovs(idxs(j)).x(end)-usedMovs(idxs(j)).x(1))/usedMovs(idxs(j)).t(end);
        end
        VD2(i)=mean(abs(vtot2))*1000;
        stdD2(i)=std(vtot2)*1000;
    end
    
    errorbar(uRadD1,VD1,stdD1,'r','linewidth',lw);
    errorbar(uRadD2,VD2,stdD2,'k','linewidth',lw);
    %     plot(uRadD1*ones(size(vtot)),vtot,'o');
    %     plot(uRadD2*ones(size(vtot2)),vtot2,'o');
    xlabel('Gait size (\circ)');
    ylabel('Velocity (mm/s)');
    legend({'Exp (CCW)', 'Exp (CW)'});
    axis([10 90 0 30])
    figText(gcf,16);
    %     clearvars -except x1 x2 x3 y1 y2 y3
    %     d=get(gca,'children'); x2=d.XData; y2=d.YData;
    % plot(x1,-y1,'o-','linewidth',lw,'markerfacecolor','w')
end
%% 3 get position and time of all gait high&low points for
xx=3;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    figure(12312);
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
    
    [pksT,locsT]=findpeaks(usedMovs(100).z,'MinPeakDistance',usedMovs(100).fps*.9*dist,'minpeakHeight',y(2)*.95);
    [pksB,locsB]=findpeaks(-usedMovs(1).z,'MinPeakDistance',usedMovs(1).fps*.9*dist,'minpeakHeight',-y(1)*1.05);
    
    %     [pksT,locsT]=findpeaks(usedMovs(1).z,usedMovs(1).t,'MinPeakDistance',dist*.9,'minpeakHeight',y(2)*.95);
    %     [pksB,locsB]=findpeaks(-usedMovs(1).z,usedMovs(1).t,'MinPeakDistance',dist*.9,'minpeakHeight',-y(1)*1.1);
    %         plot(usedMovs(1).t,usedMovs(1).z);
    %         hold on;
    %     plot(locsB,-pksB,'o');
    %     plot(locsT,pksT,'o');
    
    plot(usedMovs(100).t(locsT),usedMovs(100).z(locsT),'o');
    plot(usedMovs(101).t(locsT),usedMovs(101).z(locsT),'o');
    gaitzD1=cell(length(uRadD1),1);
    gaitzD2=cell(length(uRadD2),1);
    figure(xx+12312);
    %speed
    hold on;
    plot(diff(usedMovs(1).x(locsT))*1000./(diff(usedMovs(1).t(locsT))));
    plot(diff(-usedMovs(2).x(locsT))*1000./(diff(usedMovs(2).t(locsT))));
    %displacement
    
    %     plot(diff(usedMovs(1).x(locsB))*1000);
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
            gaitzD1{i}{j,1}=[usedMovs(idxs(j)).x(locsT(1:end-1)),diff(usedMovs(idxs(j)).x(locsT))];
            gaitzD1{i}{j,2}=[usedMovs(idxs(j)).x(locsB(1:end-1)),diff(usedMovs(idxs(j)).x(locsB))];
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
            gaitzD2{i}{j,1}=[usedMovs(idxs(j)).x(locsT(1:end-1)),diff(usedMovs(idxs(j)).x(locsT))];
            gaitzD2{i}{j,2}=[usedMovs(idxs(j)).x(locsB(1:end-1)),diff(usedMovs(idxs(j)).x(locsB))];
        end
    end
    figure(xx);
    %avg gait cycles per gait radius
    topGaitAmtD1=zeros(length(gaitzD1),1);
    d1err=topGaitAmtD1;
    topGaitAmtD2=zeros(length(gaitzD1),1);
    d2err=topGaitAmtD2;
    for i=1:length(gaitzD1)
        a=cellfun(@(x) size(x,1),gaitzD1{i}(:,1),'uniformoutput',1);
        topGaitAmtD1(i)=mean(a);
        d1err(i)=std(a);
    end
    for i=1:length(gaitzD2)
        b=cellfun(@(x) size(x,1),gaitzD2{i}(:,1),'uniformoutput',1);
        topGaitAmtD2(i)=mean(b);
        d2err(i)=std(b);
    end
    figText(gcf,16);
    errorbar(uRadD1,topGaitAmtD1,d1err,'r','linewidth',lw);
    errorbar(uRadD2,topGaitAmtD2,d2err,'k','linewidth',lw);
    xlabel('Gait size (\circ)');
    ylabel('Gait cycles')
end
%% 4 plot average speed for left or right
xx=4;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    DIREC=2; %0 = left 1= right 2= both
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
    
    if DIREC==1 %only right
        errorbar(uRadD1,VD1,stdD1,'o-r','markerfacecolor','r','linewidth',lw);
        title('Right Movement');
        
    elseif DIREC==2 %both directions
        h=errorbar(uRadD1,VD1,stdD1,'o-','markerfacecolor','r','linewidth',lw);
        errorbar(uRadD2,VD2,stdD2,'o-','markerfacecolor','k','linewidth',lw,'color',h.Color);
    else%only left
        errorbar(uRadD2,VD2,stdD2,'o-','markerfacecolor','k','linewidth',lw);
        title('Left Movement');
    end
    
    xlabel('Gait size (\circ)');
    ylabel('Velocity (mm/s)');
    %     legend({'Toward Right', 'Toward Left'});
    figText(gcf,16);
    
end

%% 5 plot gait radius pic
xx=5;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    
    radii=[65 80 89];
    shape=1; %1=square, else=diamond
    
    %     set(gca,...
    %         'xtick',[-90 -75 -60 -45 -30 -15 0, 15 30 45 60 75 90],...
    %         'xticklabel',{'-90' '' '-60' '' '-30' '' '0', '' '30' '' '60' '' '90'},...
    %         'ytick',[-75 -60 -45 -30 -15 0, 15 30 45 60 75 90],...
    %         'yticklabel',{'' '-60' '' '-30' '' '0', '' '30' '' '60' '' '90'});
    %
    col=zeros(length(radii),3);
    get(gca,'colororder')
    if shape
        
        for i = 1:length(radii);
            h=plot([-radii(i),radii(i),... %bottom x
                radii(i),radii(i),...    %right x
                radii(i),-radii(i),...    %top x
                -radii(i),-radii(i)],...      %left x
                [-radii(i),-radii(i)...
                -radii(i),radii(i)...
                radii(i),radii(i)...
                radii(i),-radii(i)],...
                'linewidth',1.5);
            col(i,:)=h.Color;
            text(-20/2,-radii(i)+6.5,['r=',num2str(radii(i)),'\circ'],'color',h.Color);
        end
    else
        for i = 1:length(radii);
            h=plot([-radii(i),0,... %left x
                radii(i),0,...    %right x
                -radii(i),...    %top x
                ],...      %left x
                [0,radii(i)...
                0,-radii(i)...
                0],...
                'linewidth',1.5);
            col(i,:)=h.Color;
            text(-20/2,-radii(i)+6.5,['r=',num2str(radii(i)),'\circ'],'color',h.Color);
        end
        
    end
    figText(gcf,30);
    xlabel('\alpha_1 ({\circ})');
    ylabel('\alpha_2 ({\circ})');
    axis square
    xlim([-90 90]);
    ylim([-90 90]);
end

%% 6. plotting out x vs t for dan and phase shifting
xx=6;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;

    plot(usedMovs(100).t,usedMovs(100).x,'o');
    plot(usedMovs(101).t,-(usedMovs(101).x-usedMovs(100).x(1)),'o');
    
    
    hold on
    plot(usedMovs(1).t,usedMovs(1).x,'o');
    plot(usedMovs(2).t,-(usedMovs(2).x-usedMovs(1).x(1)),'o');
    
    
    %velocity
    hold on
    plot(usedMovs(1).t(2:end),diff(usedMovs(1).x),'-');
    plot(usedMovs(2).t(2:end),diff(-(usedMovs(2).x-usedMovs(1).x(1))),'-');
    
    
    %velocity phase shifted to match cycles
    hold on
    plot(usedMovs(100).t(2:end)+.5,diff(usedMovs(100).x),'-');
    plot(usedMovs(101).t(2:end),diff(-(usedMovs(101).x-usedMovs(1).x(100))),'-');
    %pick red
    %finding which peaks are better (more square/diamond)
    x=(9.55-8.1)/2+8.1; %these are particular peak locations in time
    
end
%% 7. fft of gait
xx=7;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    ind=1;
    
    for i = 1:2
        if(i==1)
            dat=usedMovs(D1(ind));
        else
            dat=usedMovs(D2(ind));
        end
        Fs = 1/dat.t(2)            % Sampling frequency
        t = dat.t;        % Time vector
        L = length(t);             % Length of signal        
        T = 1/Fs;             % Sampling period
        
        X=dat.x;
%         X=sin(2*pi*1.5*t)+2*t;
        k=(X(end)-X(1))/(t(end)-t(1));
        X2=X-k.*t;
        Y=fft(X2);
        
        P2 = abs(Y/L);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        f = Fs*(0:(L/2))/L;
        plot(f,P1);
        title('Single-Sided Amplitude Spectrum of X(t)')
        xlabel('f (Hz)')
        ylabel('|P1(f)|')

        
    end
    %
    %
    %     plot(usedMovs(D1(ind)).t,usedMovs(D1(ind)).x,'r','linewidth',lw);
    %     plot(usedMovs(D2(ind)).t,usedMovs(D2(ind)).x,'k','linewidth',lw);
    %     xlabel('time (s)');
    %     ylabel('displacement(m)');
end
