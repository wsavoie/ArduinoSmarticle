% clear all;
% close all;
% load('D:\ChronoCode\chronoPkgs\Smarticles\matlabScripts\amoeba\smarticleExpVids\rmv3\movieInfo.mat');

% fold=uigetdir('A:\2DSmartData\LightSystem\rossSmarts\superlightring');
% fold=uigetdir('A:\2DSmartData\shortRing\redSmarts\metal_singleInactive_1-1_frame_inactive');


% fold=uigetdir('A:\2DSmartData\comRingPlay\redSmarts\superlightRing\extraMassAdded');
fold=uigetdir('A:\2DSmartData\LightSystem\rossSmarts\superlightring');

% fold=uigetdir('A:\2DSmartData\');
% fold=uigetdir('A:\2DSmartData\regRing\redSmarts\metal_singleInactive_1-4_inactive_frame\all');

load(fullfile(fold,'movieInfo.mat'));
% figure(1)
SPACE_UNITS = 'm';
TIME_UNITS = 's';
fold

%************************************************************
%* Fig numbers:
%* 1. displacement yvsx
%* 2. MSD
%* 3. vcorr
%* 4. drift velocity
%* 5. plot scatter data in x vs y where z axis is time
%* 6. mean of position at each timestep for all tracks
%* 7. rotation
%* 8. 1 2 3 into single plot
%* 9. for each msd traj get linear fit of log
%*10. partial msd fit with log
%*11. for each msd traj get linear fit of log *most recent pom vs mop*
%*12. rotate each each track by the rotation of ring
%*13. polar plot of rotation of ring (used for checking axes)
%*14. Drift correction using velocity correlation
%*15. Normalized drift correction using velocity correlation
%*16. Based on discussions found at:
%*17. Magnitude of displacement over time
%*18. 2D Velocity Histogram
%*19. Stats
%*20. First minutefr
%*21. Plot out inactive particle
%*22. Rotate each each track by the rotation of inactive smarticle
%*23. Plot Y vs. X endpoints
%*24. Plot crawling smarticle velocities
%*25. Rotated inactive smarticle histogram
%*26. rotate each each track by the rotation of inactive smarticle OLDER
%*27. for each msd traj get linear fit of log
%*28. plot inactive particle position rotate by its rotation
%*29. Rot each track by the rotation of inactive smart %%plot rotated%%
%*30. partial Rot each track by the rotation of inactive smart and project
%*31. rotate chord trajectory ring about chord
%*32. plot rotation and euler displacement from center
%*33. plot rotation and total path length
%*34. granular temperature v2
%*35. 31 but linear histogram version
%*36. 31 but linear histogram with seperate axes
%*37-40. plot from table and zach data
%*41. plot ring and smarticle trajectory together
%*42. polar histogram for all active systems
%*43. msd for rotated trajectories
%*44. new MSD analysis for non-directed
%*45-46. plot mean vcorr in non-rotated and rotated frame
%*47-48 plot r for a single trajectory and x,y
%*49. get x and y variance
%*50. view variance dependence on exp time length
%*51. plot gamma vs t
%*52. plot x vs t with light with channel
%*53. plot active smart diagram
%*54. plot histogram of velocities
%*55. true granular temperature mean squared vel
%*56. rotate trajectories by set amount
%************************************************************
% showFigs=[1 23 29];
% showFigs=[1 29 31 36];
% showFigs=[1,  52 53];
showFigs=[1 55];

maf = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
ma = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
ma2 = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
%define curve params [] for all
spk=[]; smart=[]; gait=[]; rob=[]; v=[];

props={spk smart gait rob v};
inds=1;
minT=100000000000;%initalize as a huge number

% [fb,fa]=butter(4,1/120*2*12,'low');

samp=10; %sampleRate
cutoff=2; %cutoff
[fb,fa]=butter(6,cutoff/(samp/2),'low');
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
        ma = ma.addAll(movs(i).data(1));
        usedMovs(inds)=movs(i);
        inds=inds+1;
        minT=min(length(movs(i).t),minT);
        
        fpos=movs(i).data(1);
        fpos{1}(:,2)=filter(fb,fa,fpos{1}(:,2));  %filtered signal
        fpos{1}(:,3)=filter(fb,fa,fpos{1}(:,3));  %filtered signal
        maf=maf.addAll(fpos);
    end
end
if(isempty(ma.tracks))
    error('no tracks found for params given!');
end
N=length(usedMovs);
%% 1 plot Y vs. X
xx=1;
if(showFigs(showFigs==xx))
    figure(xx)
    %     hold on;
    hax1=gca;
    %     ma.plotTracks(hax1,i);
    
    axis([-.25 .25 -.25 .25]);
    for i=1:length(ma.tracks)
        hold on;
        plot(ma.tracks{i}(:,2),ma.tracks{i}(:,3),'-');
        %     pause
    end
    ma.labelPlotTracks
    %     text(0,0+.01,'start')
    h=plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    y=get(gca,'ylim'); x=get(gca,'xlim');
    c=max(abs(x)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.3 .3 -.3 .3]);
    x=xlim; y=ylim;
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]);
    y=get(gca,'ylim'); x=get(gca,'xlim');
    h=plot(x,[0,0],'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    h=plot([0,0],y,'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    xp = 0;
    yp = 0;
    for i=1:length(ma.tracks)
        %         pause(100)
        h=plot([ma.tracks{i}(end,2)], [ma.tracks{i}(end,3)],'ko-','markersize',4,'MarkerFaceColor','r');
        %         leg(i)=h;
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        if ma.tracks{i}(end,2) > 0
            xp = xp + 1;
        end
        
        if ma.tracks{i}(end,3) > 0
            yp = yp + 1;
        end
        
        
        hold on
        x=['v',num2str(usedMovs(i).pars(5))];
        legT{i}=['v',num2str(usedMovs(i).pars(5))];
        
    end
    legend(legT);
    legend off;
    xpercent = xp/length(ma.tracks);
    ypercent = yp/length(ma.tracks);
    %     text(0,-0.25,['Towards X = ',num2str(xpercent,'%.3f')], 'fontsize',16)
    %     text(0, 0.25,['Towards Y = ',num2str(ypercent,'%.3f')],'fontsize',16)
    disp(['Trials = ',num2str(length(ma.tracks),'%.d')])
    disp(['Towards X = ',num2str(xpercent,'%.3f')])
    disp(['Towards Y = ',num2str(ypercent,'%.3f')])
    %     title('Whole Time-Scale Displacements');
    
    %     ringRad=.1905/2;
    %     h=plot(ringRad*cos(0:.01:2*pi),ringRad*sin(0:.01:2*pi),'k','linewidth',2);
    %     set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    figText(gcf,14)
    ringRad=.1905/2;
    h=plot(ringRad*cos(0:.01:2*pi),ringRad*sin(0:.01:2*pi),'k','linewidth',2);
end
%% 2 plot MSD
xx=2;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    if(isempty(ma.msd))
        ma = ma.computeMSD;
    end
    
    hax2=gca;
    set(gcf,'Renderer','painters'); %this allows fig to be copied as vectored img
    %     ma.plotMSD(hax2);
    ma.plotMeanMSD(hax2, 1,[],.5);
    %     ha
    [fo, gof]=ma.fitMeanMSD;
    % [a b]=ma.fitMeanMSD;
    D=fo.p1/2/ma.n_dim;
    ci = confint(fo);
    %     interval=D-ci(1)/2/ma.n_dim; %interval for D
    %     str = sprintf(['D = %.3e \\pm %.3e\n Goodness of fit: R^2 = %.3f.' ], ...
    %         D, interval, gof.adjrsquare);
    %     text(0.05,0.5,str,'units','normalized');
    % fo.p1/2/obj.n_dim, ci(1)/2/obj.n_dim, ci(2)/2/obj.n_dim, gof.adjrsquare);
    figText(gcf,14)
    axis tight
    %     xlim([0 15]);
end
%% 3 plot vcorr
xx=3;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    hax3=gca;
    ma = ma.computeVCorr;
    ma.plotMeanVCorr
    m=ma.vcorr{1};
    nansN=sum(isnan(m(:,2)));
    %     M = mean(m(2:end-nansN-2,2));
    tEnd = 20;
    M = mean(m(2:tEnd,2));
    hold on;
    for i= 1:length(ma.vcorr)
        %         nansN=sum(isnan(ma.vcorr{i}(:,2)));
        nansN=sum(isnan(ma.vcorr{i}(2:tEnd,2)));
        %         M(i)= mean([ma.vcorr{i}(10:end-nansN-1,2)]);
        M(i)= mean([ma.vcorr{i}(2:tEnd,2)]);
        
        
    end
    M=mean(M);
    line([ma.vcorr{1}(10,1) tEnd], [M M],'color','r','linewidth',3);
    figText(gcf,14);
    text(.2,.7,['mean = ',num2str(M,'%.3f')],'units','normalized','fontsize',16)
    axis tight
    xlim([ma.vcorr{1}(10,1) tEnd])
end
%% 4 drift velocity
xx=4;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    ma = ma.computeDrift('velocity');
    ma.plotDrift;
    ma.labelPlotTracks;
end
%% 5 plot scatter data in x vs y where z axis is time
xx=5;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    alld=cell2mat(ma.tracks);
    scatter3(alld(:,2),alld(:,3),alld(:,1),'.');
    xlabel('x (m)'); ylabel('y (m)'); zlabel('t(s)');
end
%% 6 mean of position at each timestep for all tracks
xx=6;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    %get min track size
    idx=min(cellfun(@(x) size(x,1), ma.tracks(:)));
    idxDat=cellfun(@(x) x(1:idx,:),ma.tracks(:),'uniformoutput',false);
    
    %get x and y data for each timestep
    xdat=cell2mat(cellfun(@(x) x(:,2),idxDat,'uniformoutput',false)');
    ydat=cell2mat(cellfun(@(x) x(:,3),idxDat,'uniformoutput',false)');
    
    mxdat=mean(xdat,2);
    mydat=mean(ydat,2);
    
    mmxdat=mean(xdat(end,:));
    mmydat=mean(ydat(end,:));
    
    %     mmydat/mmxdat
    % plot(mxdat,mydat);
    
    ff=polyfitZero(mxdat,mydat,1);
    hold on;
    plot(mxdat,mydat,'k');
    axis([-.25 .25 -.25 .25]);
    x=xlim; y=ylim;
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]);
    %     y=get(gca,'ylim'); x=get(gca,'xlim');
    xfitdat=linspace(x(1),x(2),5);
    plot(xfitdat,ff(1)*xfitdat);
    
    legend off;
    xlabel('x (m)'); ylabel('y (m)');
    %     title(['mean of position for all runs after ',num2str(ma.tracks{1}(idx,1)),' s'])
    text(.7,.2,['m= ',num2str(ff(1),3)],'units','normalized');
    figText(gcf,14);
    
    plot(x,[0,0],'r');
    plot([0,0],y,'r');
end

%% 7 plot rotation
xx=7;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    for(i=1:length(usedMovs))
        r=usedMovs(i).rot; t=usedMovs(i).t;
        
        pp=[r,t];
        pp(any(isnan(pp),2),:)=[];
        dr=diff(pp(:,1));
        f=find(abs(dr)>1);
        while(~isempty(f)) %remove jumps in data due to relabelling (?)
            r(f)=[];
            t(f)=[];
            pp(f,:)=[];
            dr=diff(pp(:,1));
            f=find(abs(dr)>1);
        end
        
        plot(pp(:,2),pp(:,1));
    end
end
%% 8 put 3 mains into subplot
xx=8;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    
    s1=subplot(2,2,1);
    pos=get(s1,'Position');
    delete(s1);
    hax8=copyobj(hax3,hf10);
    set(hax8, 'Position', pos);
    
    
    s1=subplot(2,2,2);
    pos=get(s1,'Position');
    delete(s1);
    hax8=copyobj(hax1,hf10);
    set(hax8, 'Position', pos);
    
    s1=subplot(2,2,[3,4]);
    pos=get(s1,'Position');
    delete(s1);
    hax8=copyobj(hax2,hf10);
    set(hax8, 'Position', pos);
    %    hax1=gca;
    %    hf2=figure(2);
    %    s1=subplot(211);
    %    pos=get(s1,'Position');
    %    delete(s1);
    %    hax2=copyobj(hax1,hf2);
    %    set(hax2, 'Position', pos);
end
%% 9 for each msd traj get linear fit of log
xx=9;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    
    if(isempty(ma.msd))
        ma = ma.computeMSD;
    end
    p=ma.getMeanMSD([]);
    x=p(:,1);
    y=p(:,2);
    y=y(x>1.2&x<15);
    x=x(x>1.2&x<15);
    lx=log(x);
    ly=log(y);
    pom=fit(lx,ly,'poly1');
    
    
    %mean of powers
    clear x y lx ly
    fs=zeros(length(ma.msd),1);
    for i=1:length(ma.msd)
        a=ma.msd{i}(:,1:2);
        x=a(:,1);
        y=a(:,2);
        y=y(x>1.2&x<15);
        x=x(x>1.2&x<15);
        [lx]=log(x);
        [ly]=log(y);
        [f,gof]=fit(lx,ly,'poly1');
        fs(i)=f.p1;
    end
    plot(fs);
    figure
    plot(lx, ly)
    hold on
    plot(lx, lx-10)
    plot(lx, 2*(lx)-10)
    pts('(*)mean of powers=',mean(fs),' stdev=', std(fs),'  power of mean=',pom.p1);
    % std(fs);
end
%% 10 partial msd fit with log
xx=10;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    for i=1:length(ma.msd)
        
        msd=ma.msd{i};
        msd=msd(msd(:,1)<15&msd(:,1)>0.1,:);
        
        plot(msd(:,1),msd(:,2))
        [lx]=log(msd(:,1));
        [ly]=log(msd(:,2));
        [f]=polyfit(lx,ly,1);
        fs(i)=f(1);
        [fo, gof] = fit(msd(:,1),msd(:,2), 'poly1', 'Weights', msd(:,3));
        %     fo.p1/4
    end
    ma.labelPlotMSD
    [ma]=ma.fitMSD;
    ma.fitMeanMSD;
    
    msd=ma.getMeanMSD;
    msd=msd(msd(:,1)<15&msd(:,1)>0.1,:);
    [lx]=log(msd(:,1));
    [ly]=log(msd(:,2));
    [f2]=polyfit(lx,ly,1);
    meanPow=f2(1)
    a=ma.getMeanMSD;
    cc=ma.lfit;
    cc.a;
    
    figText(gcf,15)
    %     msdanalyzer
end
%% 11 for each msd traj get linear fit of log most recent pom vs mop
xx=11;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    ggg=790;
    
    fitT=0; %linear = 0; exp=1;
    
    if(isempty(ma.msd))
        ma = ma.computeMSD;
    end
    p=ma.getMeanMSD;m
    idx = find(isnan(p(:,3)), 1, 'first');
    p = p(1:idx-1,:);
    
    x=p(:,1);
    y=p(:,2);
    y=y(x>1.2&x<15);
    x=x(x>1.2&x<15);
    lx=log(x);
    ly=log(y);
    
    if(fitT) %exp
        pom=fit(x,y,'exp1');
        pomR=pom.a;
    else
        pom=fit(lx,ly,'poly1');
        pomR=pom.p1;
    end
    
    %     pom=fit(lx,ly,'poly1');
    %     plot(pom,lx,ly)
    
    %     plot(pom,x,y)
    
    %mean of powers
    clear x y lx ly
    fs=zeros(length(ma.msd),1);
    for i=1:length(ma.msd)
        a=ma.msd{i}(1:idx-1,1:2);
        a = a(~any(isnan(a),2),:);
        x=a(:,1);
        y=a(:,2);
        y=y(x>1.2&x<15);
        x=x(x>1.2&x<15);
        
        
        %%%LINEAR FIT%%%
        if(fitT) %exp
            [f,gof]=fit(x,y,'exp1');
            fs(i)=f.b;
            %         plot(f,x,y);
        else
            [lx]=log(x);
            [ly]=log(y);
            [f,gof]=fit(lx,ly,'poly1');
            fs(i)=f.p1;
            %         plot(f,lx,ly);
        end
        
        
    end
    
    errorbar(2,mean(fs),std(fs));
    
    
    %     msd=ma.getMeanMSD;
    %     idx = find(isnan(msd(:,3)), 1, 'first');
    %
    %     msd = msd(1:idx-1,:);
    %
    %     msd=msd(msd(:,1)<15&msd(:,1)>0.1,:);
    %     [lx]=log(msd(:,1));
    %     [ly]=log(msd(:,2));
    %     [f2]=polyfit(lx,ly,1);
    % [f,gof]=fit(lx,ly,'poly1');
    
    %     [f,gof]=fit(x,y,'exp1');
    %     meanPow=f(1);
    
    
    pts('(*)mean of powers=',mean(fs),' stdev=', std(fs),'  power of mean=',pomR);
    % std(fs);
end

%% 12 rotate each each track by the rotation of ring
xx=12;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    figure(xx)
    hold on;
    hax1=gca;
    %     ma.plotTracks
    ma.labelPlotTracks
    %     text(0,0+.01,'start')
    plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim'); x=get(gca,'xlim');
    c=max(abs(x)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.25 .25 -.25 .25]);
    x=xlim; y=ylim;
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]);
    y=get(gca,'ylim'); x=get(gca,'xlim');
    plot(x,[0,0],'r');
    plot([0,0],y,'r');
    for i=1:length(usedMovs)
        % dpos=diff(pos);
        % R = [cosd(theta(2:end)) -sind(theta(2:end)); sind(theta(2:end)) cosd(theta(2:end))];
        pos=usedMovs(i).data{1}(:,2:3);
        r=usedMovs(i).rot-pi/2;
        %         r=r-r(1);
        dpos=[pos(1,:);diff(pos)];
        newpos=dpos;
        for(j=1:size(dpos,1))
            R = [cos(r(j)) -sin(r(j)); sin(r(j)) cos(r(j))];
            newpos(j,:)=R*dpos(j,:)';
            
        end
        
        newpos=cumsum(newpos);
        plot(newpos(:,1),newpos(:,2));
        plot(newpos(end,1),newpos(end,2),'ko','markersize',4,'MarkerFaceColor','r');
        figText(gcf,14)
    end
    
end

%% 13 polar plot of rotation of ring (used for checking axes)
xx=13;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    for i=1:length(usedMovs)
        r=linspace(0,1,length(usedMovs(i).rot));
        polarplot(usedMovs(i).rot,r);
    end
    figText(gcf,14)
end

%% 14 Drift correction using velocity correlation
% Based on discussions found at:
% https://tinevez.github.io/msdanalyzer/tutorial/MSDTuto_drift.html#3

% NOTE: This meothd assumes we are dealing with a homogeneous drift, such
% that the drift will be the same for all particles at any gien point. This
% is not necessarily the case, given the variety of modes which may exist
% within the supersmarticle

xx=14;
if(showFigs(showFigs==xx))
    
    figure(xx)
    hold on;
    hax14=gca;
    ma = ma.computeDrift('velocity');
    ma.plotDrift
    ma.labelPlotTracks
    plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim'); x=get(gca,'xlim');
    c=max(abs(x)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.2 .2 -.2 .2]);
    x=xlim; y=ylim;
    set(gca,'xtick',[-.1:.05:.1],'ytick',[-.1:.05:.1]);
    y=get(gca,'ylim'); x=get(gca,'xlim');
    plot(x,[0,0],'r');
    plot([0,0],y,'r');
    
    plot(ma.drift(end,2),ma.drift(end,3),'ko','markersize',4,'MarkerFaceColor','r');
    
end

%% 15 Nomralized drift correction using velocity correlation
% Based on discussions found at:
% https://tinevez.github.io/msdanalyzer/tutorial/MSDTuto_drift.html#3

% NOTE: This meothd assumes we are dealing with a homogeneous drift, such
% that the drift will be the same for all particles at any gien point. This
% is not necessarily the case, given the variety of modes which may exist
% within the supersmarticle

xx=15;
if(showFigs(showFigs==xx))
    % Normalize ma wrt time
    mad = ma;
    
    % Get the minimum track length
    minlen = NaN;
    for idx = 1:length(mad.tracks)
        if isnan(minlen) || size(mad.tracks{idx}, 1) < minlen
            minlen = size(mad.tracks{idx}, 1);
        end
    end
    minlen = minlen
    for idx = 1:length(mad.tracks)
        interval = floor(size(mad.tracks{idx}, 1)/minlen);
        
        mad.tracks{idx} = mad.tracks{idx}(1:interval:interval*minlen, :);
        mad.tracks{idx}(:,1) = [1:minlen]';
        
    end
    
    figure(xx)
    hold on;
    hax14=gca;
    mad = mad.computeDrift('velocity');
    mad.plotDrift
    mad.labelPlotTracks
    plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim'); x=get(gca,'xlim');
    c=max(abs(x)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.1 .1 -.1 .1]);
    x=xlim; y=ylim;
    set(gca,'xtick',[-.1:.05:.1],'ytick',[-.1:.05:.1]);
    y=get(gca,'ylim'); x=get(gca,'xlim');
    plot(x,[0,0],'r');
    plot([0,0],y,'r');
    
    plot(mad.drift(end,2),mad.drift(end,3),'ko','markersize',4,'MarkerFaceColor','r');
    
end

%% 16
% Based on discussions found at:
% https://tinevez.github.io/msdanalyzer/tutorial/MSDTuto_drift.html#3

xx=16;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    tEnd = 15; % do not consider delays longer than tEnd
    if(isempty(ma.msd))
        ma = ma.computeMSD;
    end
    
    ma.plotMeanMSD(gca, true);
    
    A = ma.getMeanMSD;
    A = A(~any(isnan(A),2),:); % needed to remove NaNs from the very end of the data which will
    A = A(~any(isinf(A),2),:); % needed to remove NaNs from the very end of the data which will
    A = A(A(:,1) < tEnd, :);
    t = A(:, 1); % delay vector
    msd = A(:,2); % msd
    std_msd = A(:,3); % we will use inverse of the std as weights for the fit
    std_msd(1) = std_msd(2); % avoid infinity weight
    
    ft = fittype('a*x + c*x^2');
    [fo, gof] = fit(t, msd, ft, 'Weights', 1./std_msd, 'StartPoint', [0 0]);
    xlim([0 tEnd])
    ylim([0 max(msd)])
    
    
    hold on
    plot(fo)
    legend off
    ma.labelPlotMSD
    
    Dfit = fo.a / 4;
    Vfit = sqrt(fo.c);
    
    ci = confint(fo);
    Dci = ci(:,1) / 4;
    Vci = sqrt(ci(:,2));
    
    fprintf('Parabolic fit of the average MSD curve with 95%% confidence interval:\n')
    
    fprintf('D = %.3g [ %.3g - %.3g ] %s', ...
        Dfit, Dci(1), Dci(2), [SPACE_UNITS '²/' TIME_UNITS]);
    
    fprintf(' V = %.3g [ %.3g - %.3g ] %s', ...
        Vfit, Vci(1), Vci(2), [SPACE_UNITS '/' TIME_UNITS]);
    
    
end

%% 17. Magnitude of displacement over time
xx=17;
if(showFigs(showFigs==xx))
    f1 = figure;
    f2 = figure;
    hold on
    for idx = 1:length(ma.tracks)
        magDisp = conv(ma.tracks{idx}(:,3), ones(30, 1)/30, 'same');
        magPrime = diff(magDisp);
        %         magDisp = sqrt(ma.tracks{idx}(:,2).^2 + ma.tracks{idx}(:,3).^2);
        figure(f1);
        hold on;
        %         plot(ma.tracks{idx}(:,1), magDisp);
        plot(magPrime);
        
    end
end

%% 18. 2D Velocity Histogram
xx=18;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    vel = [];
    for idx = 1:length(ma.tracks)
        newVel = [diff((ma.tracks{idx}(:,2))) diff((ma.tracks{idx}(:,3)))];
        vel = [vel; newVel];
    end
    
    
    hist3(vel, [25 25])
    colormap(fire)
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
    %     set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    xlabel('X Velocity')
    ylabel('Y Velocity')
    axis tight
    
end


%% 20. First minute
xx=20;
if(showFigs(showFigs==xx))
    figure(xx)
    %     hold on;
    hax1=gca;
    %     ma.plotTracks(hax1,i);
    
    axis([-.25 .25 -.25 .25]);
    for i=1:length(ma.tracks)
        hold on;
        B = ma.tracks{i};
        B(B(:, 1) < 60);
        %         ma.tracks{i} = ma.tracks{i}(B, :, :);
        plot(B(:,2), B(:,3),'-');
        %     pause
    end
    ma.labelPlotTracks
    %     text(0,0+.01,'start')
    plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim'); x=get(gca,'xlim');
    c=max(abs(x)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.3 .3 -.3 .3]);
    x=xlim; y=ylim;
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]);
    y=get(gca,'ylim'); x=get(gca,'xlim');
    plot(x,[0,0],'r');
    plot([0,0],y,'r');
    
    xp = 0;
    yp = 0;
    for i=1:length(ma.tracks)
        %         pause(100)
        plot([ma.tracks{i}(end,2)], [ma.tracks{i}(end,3)],'ko-','markersize',4,'MarkerFaceColor','r');
        %         leg(i)=h;
        if ma.tracks{i}(end,2) > 0
            xp = xp + 1;
        end
        
        if ma.tracks{i}(end,3) > 0
            yp = yp + 1;
        end
        
        
        hold on
        x=['v',num2str(usedMovs(i).pars(5))];
        legT{i}=['v',num2str(usedMovs(i).pars(5))];
    end
    xpercent = xp/length(ma.tracks);
    ypercent = yp/length(ma.tracks);
    text(0,-0.25,['Towards X = ',num2str(xpercent,'%.3f')], 'fontsize',16)
    text(0, 0.25,['Towards Y = ',num2str(ypercent,'%.3f')],'fontsize',16)
    
    legend(legT);
    legend off;
    title('First Minute Displacements');
    figText(gcf,14)
    
end
%% 21. plot out inactive particle
xx=21;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    
    
    y=get(gca,'ylim'); x=get(gca,'xlim');
    c=max(abs(x)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.3 .3 -.3 .3]);
    x=xlim; y=ylim;
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]);
    y=get(gca,'ylim'); x=get(gca,'xlim');
    plot(x,[0,0],'r');
    plot([0,0],y,'r');
    xp = 0;
    yp = 0;
    
    p=0:.02:2*pi;
    plot(r.*cos(p),r.*sin(p),'k-','linewidth',2);
    figText(gcf,16);
    title('Inactive particle''s center-link trajectory');
    xlabel('X (m)');
    ylabel('Y (m)');
    
    ptI=zeros(length(usedMovs),2);
    for i=1:length(usedMovs)
        %     for i=9
        xx=usedMovs(i).Ix-usedMovs(i).x;
        yy=usedMovs(i).Iy-usedMovs(i).y;
        plot(xx,yy);
        ptI(i,:)=[xx(i),yy(i)];
    end
    plot(ptI(:,1),ptI(:,2),'ko','markersize',4,'MarkerFaceColor','r');
    
    
    legend;
end
%% 22 rotate each each track by the rotation of inactive smarticle
xx=22;
dir=0;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    hax1=gca;
    %     ma.plotTracks
    ma.labelPlotTracks
    %     text(0,0+.01,'start')
    %     plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim');
    deltax=get(gca,'xlim');
    c=max(abs(deltax)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.3 .3 -.3 .3]);
    deltax=xlim; y=ylim;
    %set(gca,'xtick',[-.5:.25:.5],'ytick',[-.5:.25:.5]);
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]); %same as 1
    y=get(gca,'ylim'); deltax=get(gca,'xlim');
    h=plot(deltax,[0,0],'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    h=plot([0,0],y,'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    %     for i=9
    %     xp = 0;
    %     yp = 0;
    L=length(usedMovs);
    correctDir=0;
    
    for i=1:length(usedMovs)
        % dpos=diff(pos);
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        %get rid of nans in iapos and rpos
        [nanr,~]=find(isnan(iapos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
            end
        end
        [nanr,~]=find(isnan(rpos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
            end
        end
        
        
        newpos=zeros(size(rpos));
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = rpos(j, :) - rpos(j-1, :);
            
            % Get the vec1, tor from the ring COG to the inactive smarticle
            rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
            rs = rs./norm(rs);
            ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
            ns=-ns;%this gets direction of perpendicular movement correct
            %             deltay = ((rs*deltaR')/norm(rs)^2)*rs;
            %             deltax = deltaR - deltay;
            newpos(j, :) =[deltaR*ns',deltaR*rs'];
            %       newpos(j, :) = [sign((rs./norm(rs))*(deltax'./norm(deltax)))*norm(deltax),...
            %                           sign((rs./norm(rs))*(deltay'./norm(deltay)))*norm(deltay)];
            
            
        end
        newpos=cumsum(newpos);
        if newpos(end,2)>0
            correctDir=correctDir+1;
        end
        plot(newpos(:,1),newpos(:,2));
        h=plot(newpos(end,1),newpos(end,2),'ko','markersize',4,'MarkerFaceColor','r');
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        
        
    end
    
    %     xpercent = xp/length(ma.tracks);
    %     ypercent = yp/length(ma.tracks);
    %     text(0,-0.25,['Towards X = ',num2str(xpercent,'%.3f')], 'fontsize',16)
    %     text(0, 0.25,['Towards Y = ',num2str(ypercent,'%.3f')],'fontsize',16)
    
    text(.1,.9,{['towards inactive: ',num2str(correctDir,2),...
        '/',num2str(L),'=',num2str(correctDir/L,2)]},'units','normalized','Interpreter','latex');
    
    ringRad=.1905/2;
    h=plot(ringRad*cos(0:.01:2*pi),ringRad*sin(0:.01:2*pi),'k','linewidth',2);
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    xlabel('Perpendicular to Inactive Smarticle (m)')
    ylabel('Along Axis of Inactive Smarticle (m)')
    title('Rotated Displacements');
    figText(gcf,14)
end

%% 23 plot Y vs. X endpoints
xx=23;
if(showFigs(showFigs==xx))
    figure(xx)
    %     hold on;
    hax1=gca;
    %     ma.plotTracks(hax1,i);
    
    axis([-.25 .25 -.25 .25]);
    for i=1:length(ma.tracks)
        hold on;
        plot([0 ma.tracks{i}(end,2)], [0 ma.tracks{i}(end,3)],'k-');
        %     pause
    end
    ma.labelPlotTracks
    %     text(0,0+.01,'start')
    plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim'); x=get(gca,'xlim');
    c=max(abs(x)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.3 .3 -.3 .3]);
    x=xlim; y=ylim;
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]);
    y=get(gca,'ylim'); x=get(gca,'xlim');
    plot(x,[0,0],'r');
    plot([0,0],y,'r');
    xp = 0;
    yp = 0;
    for i=1:length(ma.tracks)
        %         pause(100)
        plot([ma.tracks{i}(end,2)], [ma.tracks{i}(end,3)],'ko-','markersize',4,'MarkerFaceColor','r');
        %         leg(i)=h;
        
        if ma.tracks{i}(end,2) > 0
            xp = xp + 1;
        end
        
        if ma.tracks{i}(end,3) > 0
            yp = yp + 1;
        end
        
        
        hold on
        x=['v',num2str(usedMovs(i).pars(5))];
        legT{i}=['v',num2str(usedMovs(i).pars(5))];
    end
    legend(legT);
    legend off;
    xpercent = xp/length(ma.tracks);
    ypercent = yp/length(ma.tracks);
    %     text(0,-0.25,['Towards X = ',num2str(xpercent,'%.3f')], 'fontsize',16)
    %     text(0, 0.25,['Towards Y = ',num2str(ypercent,'%.3f')],'fontsize',16)
    
    %     title('Whole Time-Scale Displacements');
    figText(gcf,14)
    
end

%% 24. Plot crawling smarticle velocities

xx=24;
if(showFigs(showFigs==xx))
    figure(xx)
    speed=[];
    for k = 1:length(movs)
        plot(movs(k).t, movs(k).x);
        hold on
        speed = [speed,(movs(k).x(end) - movs(k).x(1))/(movs(k).t(end) - movs(k).t(1))];
        %polyfit polyval
        %TODO: shift so that all start at position 0
    end
    avgSpeed=mean(speed)
    stdSpeed=std(speed)
    slashInds= find(fold == '\');
    foldName = fold(slashInds(end)+1:end);
    title(foldName);
    xlabel('Time (s)');
    ylabel('Position (m)');
    hold off
end

%% 25 histogram
xx=25;
dir=0;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    hax1=gca;
    L=length(usedMovs);
    correctDir=0;
    endPos=zeros(length(usedMovs),1);
    for i=1:length(usedMovs)
        % dpos=diff(pos);
        % R = [cosd(theta(2:end)) -sind(theta(2:end)); sind(theta(2:end)) cosd(theta(2:end))];
        
        % Ring position
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        newpos=zeros(size(rpos));
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = rpos(j, :) - rpos(j-1, :);
            
            % Get the vec1, tor from the ring COG to the inactive smarticle
            rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
            
            % Project deltaR onto rs(t-1)
            deltay = ((rs*deltaR')/norm(rs)^2)*rs;
            deltax = deltaR - deltay;
            newpos(j, :) = [newpos(j-1,1) + sign(rs*deltax')*norm(deltax), newpos(j-1,2) + sign(rs*deltay')*norm(deltay)];
            if newpos(end,2)>0
                correctDir=correctDir+1;
            end
        end
        
        figText(gcf,14)
        endPos(i)=newpos(end,2);
    end
    h=histogram(endPos,15);
    
    y=h.Values;
    x=h.BinEdges+h.BinWidth/2;
    x(end)=[];
    %     plot(x,y,'-o');
    hold on;
    yy=get(gca,'ylim');
    plot([0,0],yy,'r','linewidth',2);
    %     xpercent = xp/length(ma.tracks);
    %     ypercent = yp/length(ma.tracks);
    %     text(0,-0.25,['Towards X = ',num2str(xpercent,'%.3f')], 'fontsize',16)
    %     text(0, 0.25,['Towards Y = ',num2str(ypercent,'%.3f')],'fontsize',16)
    
    text(.1,.9,{['towards inactive: ',num2str(correctDir,2),...
        '/',num2str(L),'=',num2str(correctDir/L,2)]},'units','normalized','Interpreter','latex');
    
    xlabel('distance D along inactive smarticle axis (m)')
    ylabel('P(D)')
    %     title('Rotated Displacements');
    
end

%% 26 rotate each each track by the rotation of inactive smarticle
xx=26;

dir=0;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    hax1=gca;
    %     ma.plotTracks
    ma.labelPlotTracks
    %     text(0,0+.01,'start')
    plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim');
    deltax=get(gca,'xlim');
    c=max(abs(deltax)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.3 .3 -.3 .3]);
    deltax=xlim; y=ylim;
    %set(gca,'xtick',[-.5:.25:.5],'ytick',[-.5:.25:.5]);
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]); %same as 1
    y=get(gca,'ylim'); deltax=get(gca,'xlim');
    plot(deltax,[0,0],'r');
    plot([0,0],y,'r');
    %     for i=9
    %     xp = 0;
    %     yp = 0;
    L=length(usedMovs);
    correctDir=0;
    figure(123);
    hold on;
    for i=1:length(usedMovs)
        % dpos=diff(pos);
        % R = [cosd(theta(2:end)) -sind(theta(2:end)); sind(theta(2:end)) cosd(theta(2:end))];
        
        % Ring position
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        newpos=zeros(size(rpos));
        a=zeros(size(rpos));
        b=zeros(size(rpos));
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = rpos(j, :) - rpos(j-1, :);
            
            % Get the vec1, tor from the ring COG to the inactive smarticle
            rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
            rs = rs./norm(rs);
            ns=[-rs(2) rs(1)];
            newpos(j, 1) = newpos(j-1,1)+dot(deltaR,ns);
            newpos(j, 2) = newpos(j-1,2)+dot(deltaR,rs);
            
        end
        np=sum(newpos);
        if np(2)<0
            correctDir=correctDir+1;
        end
        figure(123);
        plot(a(:,1),a(:,2),'o')
        %         figure(124);
        %         plot(b(:,1),b(:,2),'o')
        %         if ma.tracks{i}(end,2) > 0
        %             xp = xp + 1;
        %         end
        %
        %         if ma.tracks{i}(end,3) > 0
        %             yp = yp + 1;
        %         end
        figure(xx);
        %         newpos=cumsum(newpos);
        plot(newpos(:,1),newpos(:,2));
        plot(newpos(end,1),newpos(end,2),'ko','markersize',4,'MarkerFaceColor','r');
        figText(gcf,14)
        
        
    end
    
    %     xpercent = xp/length(ma.tracks);
    %     ypercent = yp/length(ma.tracks);
    %     text(0,-0.25,['Towards X = ',num2str(xpercent,'%.3f')], 'fontsize',16)
    %     text(0, 0.25,['Towards Y = ',num2str(ypercent,'%.3f')],'fontsize',16)
    
    text(.1,.9,{['towards inactive: ',num2str(correctDir,2),...
        '/',num2str(L),'=',num2str(correctDir/L,2)]},'units','normalized','Interpreter','latex');
    
    xlabel('Perpendicular to Inactive Smarticle (m)')
    ylabel('Along Axis of Inactive Smarticle (m)')
    title('Rotated Displacements');
    
end

%% 27 for each msd traj get linear fit of log
xx=27;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    
    if(isempty(ma.msd))
        ma = ma.computeMSD;
    end
    [fo, gof]=ma.fitMeanMSD;
    % [a b]=ma.fitMeanMSD;
    D=fo.p1/2/ma.n_dim;
    
    p=ma.getMeanMSD([]);
    x=p(:,1);
    y=p(:,2);
    y=y(x>1.2&x<15);
    x=x(x>1.2&x<15);
    lx=log(x);
    ly=log(y);
    pom=fit(lx,ly,'poly1');
    %mean of powers
    clear x y lx ly
    fs=zeros(length(ma.msd),1);
    
    for i=1:length(ma.msd)
        a=ma.msd{i}(:,1:2);
        x=a(:,1);
        y=a(:,2);
        y=y(x>1.2&x<15);
        x=x(x>1.2&x<15);
        [lx]=log(x);
        [ly]=log(y);
        plot(lx, ly);
        [f,gof]=fit(lx,ly,'poly1');
        fs(i)=f.p1;
    end
    %     figure
    plot(lx, lx*pom.p1+log(D), '-', 'Color',[0,0,0], 'LineWidth', 1)
    xlabel('log(Delay)')
    ylabel('log(MSD)')
    %     hold on
    %     plot(lx, lx-10)
    %     plot(lx, 2*(lx)-10)
    pts('(*)mean of powers=', mean(fs),' stdev=', std(fs),'  power of mean=',pom.p1);
    % std(fs);
    
    
    ma = ma.fitMSD;
    good_enough_fit = ma.lfit.r2fit > 0.8;
    Dmean = mean( ma.lfit.a(good_enough_fit) ) / 2 / ma.n_dim;
    Dstd  =  std( ma.lfit.a(good_enough_fit) ) / 2 / ma.n_dim;
    fprintf('Found D = %.3e ± %.3e (mean ± std, N = %d)\n', ...
        Dmean, Dstd, sum(good_enough_fit));
    
    
end
%% 28 plot inactive particle position rotate by its rotation
xx=28;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    hax1=gca;
    %     ma.plotTracks
    ma.labelPlotTracks
    %     text(0,0+.01,'start')
    %     plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim');
    deltax=get(gca,'xlim');
    c=max(abs(deltax)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.3 .3 -.3 .3]);
    deltax=xlim; y=ylim;
    %set(gca,'xtick',[-.5:.25:.5],'ytick',[-.5:.25:.5]);
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]); %same as 1
    y=get(gca,'ylim'); deltax=get(gca,'xlim');
    h=plot(deltax,[0,0],'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    h=plot([0,0],y,'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    %     for i=9
    %     xp = 0;
    %     yp = 0;
    L=length(usedMovs);
    correctDir=0;
    
    for i=1:length(usedMovs)
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, iapos(1,:));
        irot = usedMovs(i).Irot;
        
        irot = bsxfun(@minus,irot,irot(1,:));
        
        %get rid of nans in iapos and rpos
        [nanr,~]=find(isnan(iapos));
        if ~isempty(nanr)
            for qq=1:length(nanr)
                iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
            end
        end
        [nanr,~]=find(isnan(irot));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                irot(nanr(qq),:)=irot(nanr(qq)-1,:);
            end
        end
        
        
        newpos=zeros(size(iapos));
        diapos=diff(iapos);
        dirot=diff(irot);
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = diapos(j-1,:);
            dang= dirot(j-1);
            newpos(j,:)= deltaR*[cos(dang) -sin(dang); sin(dang) cos(dang)];
        end
        newpos=cumsum(newpos);
        if newpos(end,2)>0
            correctDir=correctDir+1;
        end
        plot(newpos(:,1),newpos(:,2));
        h=plot(newpos(end,1),newpos(end,2),'ko','markersize',4,'MarkerFaceColor','r');
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        
        
    end
    
    %     xpercent = xp/length(ma.tracks);
    %     ypercent = yp/length(ma.tracks);
    %     text(0,-0.25,['Towards X = ',num2str(xpercent,'%.3f')], 'fontsize',16)
    %     text(0, 0.25,['Towards Y = ',num2str(ypercent,'%.3f')],'fontsize',16)
    
    text(.1,.9,{['towards inactive: ',num2str(correctDir,2),...
        '/',num2str(L),'=',num2str(correctDir/L,2)]},'units','normalized','Interpreter','latex');
    
    ringRad=.1905/2;
    h=plot(ringRad*cos(0:.01:2*pi),ringRad*sin(0:.01:2*pi),'k','linewidth',2);
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    xlabel('Perpendicular to Inactive Smarticle (m)')
    ylabel('Along Axis of Inactive Smarticle (m)')
    title('inactive displacements');
    figText(gcf,14)
end

%% 29. Rot each track by the rotation of inactive smart and project
xx=29;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    hax1=gca;
    %     ma.plotTracks
    ma.labelPlotTracks
    %     text(0,0+.01,'start')
    %     plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim');
    deltax=get(gca,'xlim');
    c=max(abs(deltax)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    deltax=xlim; y=ylim;
    %set(gca,'xtick',[-.5:.25:.5],'ytick',[-.5:.25:.5]);
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]); %same as 1
    
    %     for i=9
    %     xp = 0;
    %     yp = 0;
    L=length(usedMovs);
    correctDir=0;
    minT=1e10;
    for i=1:length(usedMovs)
        minT=min(length(usedMovs(i).t),minT);
        % dpos=diff(pos);
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        %get rid of nans in iapos and rpos
        [nanr,~]=find(isnan(iapos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
            end
        end
        [nanr,~]=find(isnan(rpos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
            end
        end
        
        
        newpos=zeros(size(rpos));
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = rpos(j, :) - rpos(j-1, :);
            
            % Get the vec1, tor from the ring COG to the inactive smarticle
            rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
            if(norm(rs))
                rs = rs./norm(rs);
            end
            ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
            %             ns=-ns;%this gets direction of perpendicular movement correct
            %             deltay = ((rs*deltaR')/norm(rs)^2)*rs;
            %             deltax = deltaR - deltay;
            newpos(j, :) =[deltaR*ns',deltaR*rs'];
            %       newpos(j, :) = [sign((rs./norm(rs))*(deltax'./norm(deltax)))*norm(deltax),...
            %                           sign((rs./norm(rs))*(deltay'./norm(deltay)))*norm(deltay)];
            
        end
        %         newpos=cumsum(newpos,2);
        newpos=cumsum(newpos);
        if newpos(end,2)>0
            correctDir=correctDir+1;
        end
        plot(newpos(:,1),newpos(:,2));
        %                 plot(ones(1,length(newpos(:,2)))*.025*i-length(usedMovs)/2*.025,newpos(:,2));
        h=plot(newpos(end,1),newpos(end,2),'ko','markersize',4,'MarkerFaceColor','r');
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        endPos(i)=newpos(end,2);
        nn(i)=newpos(end,2)./usedMovs(i).t(end);
    end
    pts('mean((final y positions)/time)', mean(nn),' +-',std(nn));
    %     pts('avg projected v=',mean(endPos)/(minT/usedMovs(1).fps));
    %     xpercent = xp/length(ma.tracks);
    %     ypercent = yp/length(ma.tracks);
    %     text(0,-0.25,['Towards X = ',num2str(xpercent,'%.3f')], 'fontsize',16)
    %     text(0, 0.25,['Towards Y = ',num2str(ypercent,'%.3f')],'fontsize',16)
    
    text(.1,.9,{['towards inactive: ',num2str(correctDir,2),...
        '/',num2str(L),'=',num2str(correctDir/L,2)]},'units','normalized','Interpreter','latex');
    
    ringRad=.1905/2;
    h=plot(ringRad*cos(0:.01:2*pi),ringRad*sin(0:.01:2*pi),'k','linewidth',2);
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    xlabel('Perpendicular to Inactive Smarticle (m)')
    ylabel('Along Axis of Inactive Smarticle (m)')
    title('Projected displacement');
    figText(gcf,14);
    %     axis tight
    axis equal
    axis([-.35 .35 -.35 .35]);
    h=plot(xlim,[0,0],'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    h=plot([0,0],ylim,'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    
    
    figure(12524);
    dataLen=[40, ];
    mm=[-0.00013641 -0.00021787 -.00014566, -0.00012244 0.0001927, 0.000697 0.00098668];
    mmerr=[0.00011918 0.00027257 0.0004223, 0.0006557,  0.0011994, 0.0010046 0.0013029];
    %     mx=[1/6 1/4 1/3 1/2 1 2 3];
    inactiveMass=34; %grams
    
    %     mx=[1/6 1/4 1/3 1/2 1 2 3];
    %     mx=[superHeavy,regRing1-4,regRing1-3,mediumRing,shortRing,lightRing,superLight]
    mx= inactiveMass./[207,119.9 ,91.1 ,68,29.5,16,9.78];
    
    %     mm=[-0.00013641 -0.00021787 -.00014566, -0.00012244 0.0001927, 0.000697 0.000548];
    %     mmerr=[0.00011918 0.00027257 0.0004223, 0.0006557,  0.0011994, 0.0010046 0.00073104];
    %     mx=[1/6 1/4 1/3 1/2 1 2 3];
    errorbar(mx,mm,mmerr);
    xlabel('M_{inactive}/M_{ring}');
    ylabel('\langle final drift speed\rangle');
    hold on;
    errorbar([0.5],[-0.00017361],[0.00021024])
    figText(gcf,16);
    xl=xlim;
    plot(xl,[0,0],'k');
    
    saveDat=0;
    if saveDat
        %%%%
        load('ssData');
        trialName='shortv3';
        mi=34;
        mr=29.5;
        mRat=mi/mr;
        trialsAmt=length(usedMovs);
        datMean=mean(nn);
        datStd=std(nn);
        datVar=datStd.^2;
        datErr=datStd/sqrt(trialsAmt);
        towardsInactive=correctDir/L;
        ssData2=table(mi,mr,mRat,trialsAmt,datMean,datStd,datVar,datErr,towardsInactive,'RowNames',{trialName});
        ssData=[ssData;ssData2];
        save('ssData3','ssData');
    end
end
%% 30. partial Rot each track by the rotation of inactive smart and project
xx=30;
dir=0;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    hax1=gca;
    %     ma.plotTracks
    ma.labelPlotTracks
    %     text(0,0+.01,'start')
    %     plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim');
    deltax=get(gca,'xlim');
    c=max(abs(deltax)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.3 .3 -.3 .3]);
    deltax=xlim; y=ylim;
    %set(gca,'xtick',[-.5:.25:.5],'ytick',[-.5:.25:.5]);
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]); %same as 1
    y=get(gca,'ylim'); deltax=get(gca,'xlim');
    h=plot(deltax,[0,0],'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    h=plot([0,0],y,'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    %     for i=9
    %     xp = 0;
    %     yp = 0;
    L=length(usedMovs);
    correctDir=0;
    minT=1e10;
    for i=1:length(usedMovs)
        minT=min(length(usedMovs(i).t),minT);
        % dpos=diff(pos);
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        %get rid of nans in iapos and rpos
        [nanr,~]=find(isnan(iapos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
            end
        end
        [nanr,~]=find(isnan(rpos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
            end
        end
        
        
        newpos=zeros(size(rpos));
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = rpos(j, :) - rpos(j-1, :);
            
            % Get the vec1, tor from the ring COG to the inactive smarticle
            rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
            rs = rs./norm(rs);
            ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
            ns=-ns;%this gets direction of perpendicular movement correct
            %             deltay = ((rs*deltaR')/norm(rs)^2)*rs;
            %             deltax = deltaR - deltay;
            newpos(j, :) =[deltaR*ns',deltaR*rs'];
            %       newpos(j, :) = [sign((rs./norm(rs))*(deltax'./norm(deltax)))*norm(deltax),...
            %                           sign((rs./norm(rs))*(deltay'./norm(deltay)))*norm(deltay)];
            
            
        end
        newpos=cumsum(newpos);
        if newpos(end,2)>0
            correctDir=correctDir+1;
        end
        %         plot(newpos(:,1),newpos(:,2));
        plot(ones(1,length(newpos(:,2)))*.025*i-length(usedMovs)/2*.025,newpos(:,2));
        %         h=plot(newpos(end,1),newpos(end,2),'ko','markersize',4,'MarkerFaceColor','r');
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        endPos(i)=newpos(end,2);
        fpt=round(size(newpos,1)*1);%final position
        
        nn(i)=newpos(fpt,2)/usedMovs(i).t(fpt);
    end
    pts('mean((final y positions)/time)', mean(nn),' +-',std(nn));
    %     pts('avg projected v=',mean(endPos)/(minT/usedMovs(1).fps));
    %     xpercent = xp/length(ma.tracks);
    %     ypercent = yp/length(ma.tracks);
    %     text(0,-0.25,['Towards X = ',num2str(xpercent,'%.3f')], 'fontsize',16)
    %     text(0, 0.25,['Towards Y = ',num2str(ypercent,'%.3f')],'fontsize',16)
    
    text(.1,.9,{['towards inactive: ',num2str(correctDir,2),...
        '/',num2str(L),'=',num2str(correctDir/L,2)]},'units','normalized','Interpreter','latex');
    
    ringRad=.1905/2;
    h=plot(ringRad*cos(0:.01:2*pi),ringRad*sin(0:.01:2*pi),'k','linewidth',2);
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    xlabel('Perpendicular to Inactive Smarticle (m)')
    ylabel('Along Axis of Inactive Smarticle (m)')
    title('Projected velocity');
    figText(gcf,14)
    axis tight
    
    %
    %     figText(gcf,16);
    %     xl=xlim;
    %     plot(xl,[0,0],'k');
end
%% 31. rotate chord trajectory ring about chord
xx=31;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    hax1=gca;
    %     ma.plotTracks
    %     ma.labelPlotTracks
    %     text(0,0+.01,'start')
    %     plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim');
    deltax=get(gca,'xlim');
    c=max(abs(deltax)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.3 .3 -.3 .3]);
    deltax=xlim; y=ylim;
    %set(gca,'xtick',[-.5:.25:.5],'ytick',[-.5:.25:.5]);
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]); %same as 1
    y=get(gca,'ylim'); deltax=get(gca,'xlim');
    h=plot(deltax,[0,0],'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    h=plot([0,0],y,'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    %     for i=9
    %     xp = 0;
    %     yp = 0;
    L=length(usedMovs);
    correctDir=0;
    minT=1e10;
    nn=zeros(length(usedMovs),2);
    for i=1:length(usedMovs)
        minT=min(length(usedMovs(i).t),minT);
        % dpos=diff(pos);
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        %get rid of nans in iapos and rpos
        [nanr,~]=find(isnan(iapos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
            end
        end
        [nanr,~]=find(isnan(rpos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
            end
        end
        
        
        newpos=zeros(size(rpos));
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = rpos(j, :) - rpos(j-1, :);
            
            % Get the vec1, tor from the ring COG to the inactive smarticle
            rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
            rs = rs./norm(rs);
            ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
            %             ns=-ns;%this gets direction of perpendicular movement correct
            %             deltay = ((rs*deltaR')/norm(rs)^2)*rs;
            %             deltax = deltaR - deltay;
            newpos(j, :) =[deltaR*ns',deltaR*rs'];
            %       newpos(j, :) = [sign((rs./norm(rs))*(deltax'./norm(deltax)))*norm(deltax),...
            %                           sign((rs./norm(rs))*(deltay'./norm(deltay)))*norm(deltay)];
            
        end
        %         newpos=cumsum(newpos,2);
        newpos=cumsum(newpos);
        nn(i,[1,2])=newpos(end,[1:2]);
        
    end
    hold on;
    theta=atan2(nn(:,2),nn(:,1));
    %     plot(nn(:,1),nn(:,2),'o');
    clf;
    polarhistogram(theta,20);
    set(gca,'ThetaAxisUnits','radians');
    
    hold on;
end
%% 32. plot rotation and euler displacement from center
xx=32;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    idx=5;
    for i=1:size(usedMovs(idx).x,2) %for the number of smarticles
        x= usedMovs(idx).x(:,i);%-usedMovs(idx).x(1,i);
        y= usedMovs(idx).y(:,i);%-usedMovs(idx).y(1,i);
        t= usedMovs(idx).t(:,i);%-usedMovs(idx).y(1,i);
        thet=usedMovs(idx).rot(:,i);
        
        %         x=smooth(x,20);
        %         y=smooth(y,20);
        
        x=x-x(1);
        y=y-y(1);
        thet=thet-thet(1);
        
        subplot(2,1,1);
        hold on;
        title('$\sqrt{x^2+y^2}$','interpreter','latex')
        %             plot( usedMovs(idx).x(:,i),usedMovs(idx).y(:,i),'linewidth',lw);
        dx=diff(x); dy=diff(y);
        q=sqrt((x*100).^2+(y*100).^2);
        plot(t,q,'linewidth',lw);
        
        %             xlabel('x (cm)','interpreter','latex');
        %             ylabel('y (cm)','interpreter','latex');
        xlabel('time (s)','interpreter','latex');
        ylabel('displacement (cm)','interpreter','latex');
        %         axis([0,120,0,6])
        xlim([0,120]);
        figText(gcf,16);
        subplot(2,1,2);
        
        hold on;
        
        a=wrapToPi(thet);
        a=a-a(1);
        plot(t,a,'linewidth',lw);
        %             axis([0 120 -pi-.01,pi+.01]);
        
        axis([0 120 -pi-.01 pi]);
        xlabel('time (s)','interpreter','latex');
        ylabel('$\theta$ (rads)','interpreter','latex');
        %             set(gca,'YTickLabel',{'$-\pi$','','0','','$\pi$'},...
        %                 'ytick',[-pi,-pi/2,0,pi/2,pi],'ticklabelinterpreter','latex');
        
        set(gca,'YTickLabel',{'$-\pi$','','$0$','','$\pi$'},...
            'ytick',[-pi,-pi/2,0,pi/2,pi],'ticklabelinterpreter','latex');
        %             ='A:\2DSmartData\cloud\cloudTests 10-5 diamond and square gaits\rightsquare\close packed';
        %2004 idx 1 for paper fig
        figText(gcf,16);
    end
    pts('plotted: ',usedMovs(idx).fname);
    %     xlabel('x (m)');
    %     ylabel('y (m)');
    
    %     axis equal
    
end
%% 33. plot rotation and total path length
xx=33;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    idx=3;
    for i=1:size(usedMovs(idx).x,2) %for the number of smarticles
        x= usedMovs(idx).x(:,i);%-usedMovs(idx).x(1,i);
        y= usedMovs(idx).y(:,i);%-usedMovs(idx).y(1,i);
        t= usedMovs(idx).t(:,i);%-usedMovs(idx).y(1,i);
        thet=usedMovs(idx).rot(:,i);
        
        plot(x,y);
        title('track');
        xlabel('x (m)','interpreter','latex');
        ylabel('y (m)','interpreter','latex');
        
        x=x-x(1);
        y=y-y(1);
        thet=thet-thet(1);
        %         plot(x,y);
        %         [fb,fa]=butter(6,1/120*2*12,'low');
        x=filter(fb,fa,x);  %filtered signal
        y=filter(fb,fa,y);  %filtered signal
        thet=filter(fb,fa,thet);  %filtered signal
        %         plot(x,y);
        subplot(2,1,1);
        title('$\int\sqrt{dx^2+dy^2}$','interpreter','latex')
        hold on;
        
        dx=diff(x); dy=diff(y);
        q=[0; cumsum(sqrt(dx.^2+dy.^2))]*100;
        plot(t,q,'linewidth',lw);
        xlabel('time (s)','interpreter','latex');
        ylabel('displacement (cm)','interpreter','latex');
        xlim([0,120]);
        figText(gcf,16);
        subplot(2,1,2);
        
        hold on;
        a=wrapToPi(thet);
        a=a-a(1);
        plot(t,a,'linewidth',lw);
        %             axis([0 120 -pi-.01,pi+.01]);
        
        axis([0 120 -pi pi]);
        xlabel('time (s)','interpreter','latex');
        ylabel('$\theta$ (rads)','interpreter','latex');
        %             set(gca,'YTickLabel',{'$-\pi$','','0','','$\pi$'},...
        %                 'ytick',[-pi,-pi/2,0,pi/2,pi],'ticklabelinterpreter','latex');
        
        set(gca,'YTickLabel',{'$-\pi$','','$0$','','$\pi$'},...
            'ytick',[-pi,-pi/2,0,pi/2,pi],'ticklabelinterpreter','latex');
        %             ='A:\2DSmartData\cloud\cloudTests 10-5 diamond and square gaits\rightsquare\close packed';
        %2004 idx 1 for paper fig
        figText(gcf,16);
    end
    pts('plotted: ',usedMovs(idx).fname);
    %     xlabel('x (m)');
    %     ylabel('y (m)');
    
    %     axis equal
    
end
%% 34. granular temperature v2
xx=34;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=2;
    hold on;
    
    idx=1; %index of movie to look at
    %     for(i=1:size(usedMovs(idx).x,2) %for the number of smarticle
    GTTAll=[];
    for k=1:N
        GTT=[];
        for i=1:size(usedMovs(k).x,2) %for the number of smarticles
            x= usedMovs(k).x(1:minT,i);%-usedMovs(idx).x(1,i);
            y= usedMovs(k).y(1:minT,i);%-usedMovs(idx).y(1,i);
            t= usedMovs(k).t(1:minT,i);%-usedMovs(idx).y(1,i);
            thet=usedMovs(k).rot(1:minT,i);
            
            x=x-x(1);
            y=y-y(1);
            thet=thet-thet(1);
            %             [fb,fa]=butter(6,1/120*2*12,'low');
            x=filter(fb,fa,x);  %filtered signal
            y=filter(fb,fa,y);  %filtered signal
            thet=filter(fb,fa,thet);  %filtered signal
            %
            dx=diff(x); dy=diff(y);dr=diff(thet);
            q=[0; cumsum(sqrt(dx.^2+dy.^2))]*100;
            r=[0; cumsum(sqrt(dr.^2))];
            GTT(:,i)=q;
            GTR(:,i)=r;
        end
        GTTAll(:,k)=mean(GTT,2); %translational granular temp
        GTRAll(:,k)=mean(GTR,2); %translational granular temp
        %     GTRAll(:,k)=mean(GTR,2); %rotational granular temp
        plot(t,GTTAll(:,k));
        plot(t,GTRAll(:,k),'--');
    end
    plot(t,mean(GTTAll,2),'k','linewidth',2);
    xlabel('time (s)','interpreter','latex');
    ylabel('displacement,rotation (cm,rads)','interpreter','latex');
    %     plot(t,mean(GTRAll,2),'--k','linewidth',2);
end
%% 35. 31 but linear histogram version
xx=35;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    L=length(usedMovs);
    
    minT=1e10;
    nn=zeros(length(usedMovs),2);
    for i=1:length(usedMovs)
        minT=min(length(usedMovs(i).t),minT);
        % dpos=diff(pos);
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        %get rid of nans in iapos and rpos
        [nanr,~]=find(isnan(iapos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
            end
        end
        [nanr,~]=find(isnan(rpos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
            end
        end
        
        
        newpos=zeros(size(rpos));
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = rpos(j, :) - rpos(j-1, :);
            
            % Get the vec1, tor from the ring COG to the inactive smarticle
            rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
            rs = rs./norm(rs);
            ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
            %             ns=-ns;%this gets direction of perpendicular movement correct
            %             deltay = ((rs*deltaR')/norm(rs)^2)*rs;
            %             deltax = deltaR - deltay;
            newpos(j, :) =[deltaR*ns',deltaR*rs'];
            %       newpos(j, :) = [sign((rs./norm(rs))*(deltax'./norm(deltax)))*norm(deltax),...
            %                           sign((rs./norm(rs))*(deltay'./norm(deltay)))*norm(deltay)];
            
        end
        %         newpos=cumsum(newpos,2);
        newpos=cumsum(newpos);
        nn(i,[1,2])=newpos(end,[1:2]);
        
    end
    hold on;
    
    theta=atan2(nn(:,2),nn(:,1));
    %     plot(nn(:,1),nn(:,2),'o');
    %     clf;
    bins=20;
    [Y,E]=discretize(theta,linspace(-pi,pi,bins+1));
    [x]=histcounts(theta,E);
    %    polarplot(
    x=x;
    nZeros=(x~=0);
    thets=linspace(-pi,pi,bins);
    
    
    type=5;
    if type==1 %,linear beween -pi and pi
        [Y,E]=discretize(theta,linspace(-pi,pi,bins+1));
        thets=linspace(-pi,pi,bins);
        
        plot(linspace(-pi,pi,bins),x,'-');
        set(gca,'ThetaAxisUnits','radians');
    elseif type==2 %polar plot stair version
        polarplot(thets(nZeros),x(nZeros),'-');
        h= polarhistogram(theta,bins,'DisplayStyle','stairs');
    elseif type==3 %Stair linear -pi and pi
        stairs(linspace(-pi,pi,bins),x,'-');
    elseif type==4 %Stair linear 0 to pi on top 0 to -pi on bottom
        [Y,EP]=discretize(theta,linspace(0,pi,bins/2+1));
        [Y,EN]=discretize(theta,linspace(-pi,0,bins/2+1));
        [xp]=histcounts(theta,EP);
        [xn]=histcounts(theta,EN);
        hold on;
        divd=sum([xp,xn]);
        %         divd=max([xp,xn]);
        h=stairs(linspace(0,pi,bins/2),xp./divd,'-');
        stairs(flip(-linspace(-pi,0,bins/2)),-xn./divd,'-','color',h.Color);
        %         stairs(linspace(-pi,0,bins/2),-xn,'-');
        ylim([-0.3,0.3])
    elseif type==5 %line 0 to pi on top 0 to -pi on bottom
        [Y,EP]=discretize(theta,linspace(0,pi,bins/2+1));
        [Y,EN]=discretize(theta,linspace(-pi,0,bins/2+1));
        [xp]=histcounts(theta,EP);
        [xn]=histcounts(theta,EN);
        divd=sum([xp,xn]);
        %         divd=max([xp,xn]);
        hold on;
        
        h=plot(linspace(0,pi,bins/2),xp./divd,'.-');
        plot(flip(-linspace(-pi,0,bins/2)),-xn./divd,'.-','color',h.Color);
        %         stairs(linspace(-pi,0,bins/2),-xn,'-');
        
        ylim([-0.3,0.3])
    end
    xlim([0,pi]);
    plot(xlim,[0 0],'k');
    figText(gcf,16);
end

%% 36. 31 but linear histogram with seperate axes
xx=36;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    L=length(usedMovs);
    
    minT=1e10;
    nn=zeros(length(usedMovs),2);
    for i=1:length(usedMovs)
        minT=min(length(usedMovs(i).t),minT);
        % dpos=diff(pos);
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        %get rid of nans in iapos and rpos
        [nanr,~]=find(isnan(iapos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
            end
        end
        [nanr,~]=find(isnan(rpos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
            end
        end
        
        
        newpos=zeros(size(rpos));
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = rpos(j, :) - rpos(j-1, :);
            
            % Get the vec1, tor from the ring COG to the inactive smarticle
            rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
            rs = rs./norm(rs);
            ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
            %             ns=-ns;%this gets direction of perpendicular movement correct
            %             deltay = ((rs*deltaR')/norm(rs)^2)*rs;
            %             deltax = deltaR - deltay;
            newpos(j, :) =[deltaR*ns',deltaR*rs'];
            %       newpos(j, :) = [sign((rs./norm(rs))*(deltax'./norm(deltax)))*norm(deltax),...
            %                           sign((rs./norm(rs))*(deltay'./norm(deltay)))*norm(deltay)];
            
        end
        %         newpos=cumsum(newpos,2);
        newpos=cumsum(newpos);
        nn(i,[1,2])=newpos(end,[1:2]);
        
    end
    hold on;
    
    theta=atan2(nn(:,2),nn(:,1));
    %     %     plot(nn(:,1),nn(:,2),'o');
    %     clf;
    %     polarhistogram(theta,10)
    %     hold on;
    % histogram(theta)
    top=theta(theta>0);
    bott= theta(theta<=0);
    bins=10;
    edges=linspace(0,1,bins+1);
    
    [NT,~]=histcounts(top,bins);
    [NB,~]=histcounts(-bott,bins);
    ticks=linspace(0,1,5);
    wid=.95;%bar width
    
    set(gca,'xticklabel',{'0','\pi/4','\pi/2','3\pi/2','\pi'},'xtick',ticks)
    
    
    ax1 = gca; % current axes
    ax1_pos = ax1.Position; % position of first axes
    % [0 0.5 1.0 0.5]
    set(ax1,'OuterPosition',[0 0.5 1.0 0.5],...
        'XDir','reverse',...
        'XAxisLocation','bottom',...
        'XColor','k',...
        'xlim',[-0.1,1.1],...
        'box','on');
    
    % ax1.XDir='reverse';
    
    
    % ax1.OuterPosition=[0 0.5 1.0 0.5];
    h1=bar([1:bins]./bins,NT,wid,'facecolor','k','parent',ax1);
    % set();
    
    
    % ,'OuterPosition',[0 0 1.0 0.5],...
    ax2 = axes('Position',[0.1300,0.0550,0.7750 0.4075],...
        'XAxisLocation','top',...
        'YAxisLocation','left',...
        'XDir','reverse',...
        'xticklabel',{'0','-\pi/4','-\pi/2','-3\pi/2','-\pi'},...
        'xtick',ticks,...
        'xlim',[-0.1,1.1],...
        'box','on');
    hold on;
    % set(ax2,'XAxisLocation','bottom');
    
    
    
    % h1=bar([1:bins]./bins,NT,wid,'facecolor','k','parent',ax1);
    
    % ax1 = gca; % current axes
    % ax1.XColor='k';
    % set(ax1,'XAxisLocation','top');
    % ax2 = axes('Position',ax1_pos,...
    %     'XAxisLocation','bottom',...
    %     'YAxisLocation','right',...
    %     'Color','none');
    %
    %
    %
    %
    % ax1.XTick=(ticks);
    % ax1.XTickLabel={'0','\pi/4','\pi/2','3\pi/2','\pi'};
    %
    %
    %
    %
    % ax2.XTick=(ticks);
    % ax2.XTickLabel={'0','-\pi/4','-\pi/2','-3\pi/2','-\pi'};
    % ax2.XColor = 'r';
    % ax2.YColor = 'none';
    %
    %
    % hold on;
    % h=bar([1:bins]./bins,NT,'parent',ax1,'facecolor','k');
    % hold on;
    % h2=bar([1:bins]./bins,NB,'parent',ax2,'facecolor','r');
    
    % bar([1:bins],-NB/pi,'parent',ax1);
    
    h=bar([1:bins]./bins,-NB,wid,'facecolor','r','parent',ax2);
    
end
%% 37. plot from table
xx=37;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    xmax=3.5;     xlim([0,xmax]);
    H=plot(xlim,[0,0],'k');
    load('ssDataComb.mat');
    H.Annotation.LegendInformation.IconDisplayStyle='off';
    errorbar(ssData.mRat,ssData.datMean,ssData.datVar);
    errorbar(ssData.mRat,ssData.datMean,ssData.datStd);
    errorbar(ssData.mRat,ssData.datMean,ssData.datErr);
    legend({'var','std','err'});
    xlabel('m_{inactive}/m_{ring}');
    ylabel('velocity ');
    figText(gcf,16);
    
    figure(38)
    hold on;
    subplot(1,2,1);
    plot(ssData.datStd,ssData.mRat,'o-');
    xlabel('std(velocity)')
    ylabel('m_{inactive}/m_{ring}');
    subplot(1,2,2);
    plot(ssData.mRat,ssData.datStd,'o-');
    xlabel('m_{inactive}/m_{ring}')
    ylabel('std(velocity)');
    
    figure(39)
    hold on;
    plot(ssData.mRat,ssData.towardsInactive*100,'o-');
    plot([0,xmax],[50 50],'r');
    xlabel('m_{inactive}/m_{ring}')
    ylabel('Towards Inactive (%)');
    
    
    figure(40)
    hold on;
    load('zachdat.mat');
    h=plot(topErr(:,1),topErr(:,2),'--');
    plot(bottErr(:,1),bottErr(:,2),'--','color',h.Color);
    plot(simData(:,1),simData(:,2),'-r','linewidth',2);
    plot(xlim,[0 0],'k');
    errorbar(ssData.mRat,ssData.datMean,ssData.datStd);
    xlabel('mass ratio (m_i/m_{ring})');
    ylabel('Drift Velocity m/s');
end
%% 41. plot ring and smarticle trajectory together
xx=41;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    idx=4; %index of movie to look at
    %     for(i=1:size(usedMovs(idx).x,2) %for the number of smarticle
    for k=idx
        GTT=[];
        for i=1:size(usedMovs(k).x,2) %for the number of smarticles
            xo= usedMovs(k).x(1:minT,i);%-usedMovs(idx).x(1,i);
            yo= usedMovs(k).y(1:minT,i);%-usedMovs(idx).y(1,i);
            t= usedMovs(k).t(1:minT,i);%-usedMovs(idx).y(1,i);
            theto=usedMovs(k).rot(1:minT,i);
            ixo= usedMovs(k).Ix(1:minT,i);%-usedMovs(idx).x(1,i);
            iyo= usedMovs(k).Iy(1:minT,i);%-usedMovs(idx).y(1,i);
            iroto=usedMovs(k).Irot(1:minT,i);%-usedMovs(idx).y(1,i);
            
            
            x=xo-xo(1);
            y=yo-yo(1);
            thet=theto-theto(1);
            
            ix=ixo-xo(1);
            iy=iyo-yo(1);
            irot=iroto-theto(1);
            
            %             [fb,fa]=butter(6,1/120*2*12,'low');
            %             x=filter(fb,fa,x);  %filtered signal
            %             y=filter(fb,fa,y);  %filtered signal
            %             thet=filter(fb,fa,thet);  %filtered signal
            
            %             ix=filter(fb,fa,ix);  %filtered signal
            %             iy=filter(fb,fa,iy);  %filtered signal
            %             irot=filter(fb,fa,irot);  %filtered signal
            
            %
            
            
            
            
            
            
            %plot ring trajectory
            plot(x,y);
            
            
            
            %plot active particle trajectory
            set(gca,'colororderindex',5);
            plot(ix,iy);
            
            
            %plot starting point and initial ring placement
            ringRad=.1905/2;
            plot(0,0,'o','markerfacecolor','k','markeredgecolor','none');
            h=plot(ringRad*cos(0:.01:2*pi),ringRad*sin(0:.01:2*pi),'k','linewidth',2);
            %             set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            %             plot(x(1),y(1),'o','markerfacecolor','k','markeredgecolor','none');
            plot(ix(1),iy(1),'o','markerfacecolor','k','markeredgecolor','none');
            
            %             plot(x(600),y(600),'o','markerfacecolor','c','markeredgecolor','none');
            plot(ix(600),iy(600),'o','markerfacecolor','c','markeredgecolor','none');
            
            %             plot(x(900),y(900),'o','markerfacecolor','b','markeredgecolor','none');
            plot(ix(900),iy(900),'o','markerfacecolor','b','markeredgecolor','none');
            
            %             plot(x(end),y(end),'o','markerfacecolor','r','markeredgecolor','none');
            plot(ix(end),iy(end),'o','markerfacecolor','r','markeredgecolor','none');
            
        end
    end
    xlabel('X(m)');
    ylabel('Y(m)');
    
    axis equal
    axis([-.3 .3 -.3 .3])
    %     plot(t,mean(GTRAll,2),'--k','linewidth',2);
    %     plot([0,0],ylim,'r--','linewidth',1);
    %     plot(xlim,[0,0],'r--','linewidth',1);
    set(gca,'xtick',[-.3:0.15:.3],'ytick',[-.3:0.15:.3]); %same as 1
    %     %,'xticklabel',{ '' -0.2 '' -0.1 '' 0 '' 0.1 '' 0.2 ''},'yticklabel',{ '' -0.2 '' -0.1 '' 0 '' 0.1 '' 0.2 ''}
    
    figText(gcf,16);
end
%% 42. polar histogram for all active systems
xx=42;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    hax1=gca;
    %     ma.plotTracks
    ma.labelPlotTracks
    %     text(0,0+.01,'start')
    %     plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    y=get(gca,'ylim');
    deltax=get(gca,'xlim');
    c=max(abs(deltax)); xlim([-c,c]);
    c=max(abs(y)); ylim([-c,c]);
    axis equal
    
    axis([-.3 .3 -.3 .3]);
    deltax=xlim; y=ylim;
    %set(gca,'xtick',[-.5:.25:.5],'ytick',[-.5:.25:.5]);
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]); %same as 1
    y=get(gca,'ylim'); deltax=get(gca,'xlim');
    h=plot(deltax,[0,0],'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    h=plot([0,0],y,'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    %     for i=9
    %     xp = 0;
    %     yp = 0;
    L=length(usedMovs);
    correctDir=0;
    minT=1e10;
    nn=zeros(length(usedMovs),2);
    for i=1:length(usedMovs)
        minT=min(length(usedMovs(i).t),minT);
        % dpos=diff(pos);
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        %get rid of nans in iapos and rpos
        [nanr,~]=find(isnan(iapos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
            end
        end
        [nanr,~]=find(isnan(rpos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
            end
        end
        
        
        nn(i,[1,2])=rpos(end,[1:2]);
        
    end
    hold on;
    theta=atan2(nn(:,2),nn(:,1));
    %     plot(nn(:,1),nn(:,2),'o');
    clf;
    polarhistogram(theta,20);
    set(gca,'ThetaAxisUnits','radians');
    
    hold on;
end
%% 43. msd for rotated trajectories
xx=43;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    ma2 = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
    fitT=0; %linear = 1; parab=0;
    filtz=0; %0=no filtering, 1= filtering
    
    if(isempty(ma.msd))
        ma = ma.computeMSD;
    end
    %     p=ma2.getMeanMSD;
    %     idx = find(isnan(p(:,3)), 1, 'first');
    %     p = p(1:idx-1,:);
    
    
    %rotate data into frame of inactive
    for i=1:length(usedMovs)
        minT=min(length(usedMovs(i).t),minT);
        % dpos=diff(pos);
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        %get rid of nans in iapos and rpos
        [nanr,~]=find(isnan(iapos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
            end
        end
        [nanr,~]=find(isnan(rpos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
            end
        end
        
        
        newpos=zeros(size(rpos));
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = rpos(j, :) - rpos(j-1, :);
            
            % Get the vec1, tor from the ring COG to the inactive smarticle
            rs = iapos(j-1, :) - rpos(j-1, :);
            if(norm(rs))
                rs = rs./norm(rs);
            end
            ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
            newpos(j, :) =[deltaR*ns',deltaR*rs'];
        end
        newpos=cumsum(newpos);
        newposFilt=newpos;
        %         [fb,fa]=butter(4,1/120*2*12,'low');
        newposFilt(:,1)=filter(fb,fa,newpos(:,1));  %filtered signal
        newposFilt(:,2)=filter(fb,fa,newpos(:,2));  %filtered signal
        
        if filtz
            dat={[usedMovs(i).t,newposFilt]};
        else
            dat={[usedMovs(i).t,newpos]};
        end
        
        ma2=ma2.addAll(dat);
    end
    
    ma2 = ma2.computeMSD;
    p=ma2.getMeanMSD;
    
    if(fitT)
        ma2.plotMeanMSD(gca, true);
        [fo, gof] = ma2.fitMeanMSD;
        plot(fo)
        
        ma2 = ma2.fitMSD;
        good_enough_fit = ma2.lfit.r2fit > 0.8;
        Dmean = mean( ma2.lfit.a(good_enough_fit) ) / 2 / ma2.n_dim;
        Dstd  =  std( ma2.lfit.a(good_enough_fit) ) / 2 / ma2.n_dim;
        
        fprintf('Estimation of the diffusion coefficient from linear fit of the MSD curves:\n')
        fprintf('D = %.3g ± %.3g (mean ± std, N = %d)\n', ...
            Dmean, Dstd, sum(good_enough_fit));
    else
        ma2.plotMeanMSD(gca, true)
        A = ma2.getMeanMSD;
        t = A(:, 1); % delay vector
        msd = A(:,2); % msd
        std_msd = A(:,3); % we will use inverse of the std as weights for the fit
        std_msd(1) = std_msd(2); % avoid infinity weight
        
        ft = fittype('a*x + c*x^2');
        [fo, gof] = fit(t, msd, ft, 'Weights', 1./std_msd, 'StartPoint', [0 0]);
        
        hold on
        plot(fo)
        legend off
        ma2.labelPlotMSD
        
        Dfit = fo.a / 4;
        Vfit = sqrt(fo.c);
        
        ci = confint(fo);
        Dci = ci(:,1) / 4;
        Vci = sqrt(ci(:,2));
        
        fprintf('Parabolic fit of the rotated average MSD curve with 95%% confidence interval:\n')
        
        fprintf('D = %.3g [ %.3g - %.3g ] %s\n', ...
            Dfit, Dci(1), Dci(2), [SPACE_UNITS '²/' TIME_UNITS]);
        
        fprintf('V = %.3g [ %.3g - %.3g ] %s\n', ...
            Vfit, Vci(1), Vci(2), [SPACE_UNITS '/' TIME_UNITS]);
    end
    
    
    ma=ma.fitLogLogMSD;
    ma2=ma2.fitLogLogMSD;
    
    pts('loglog fit NON-ROTATED: ',round(mean(ma.loglogfit.alpha),3),'+-',round(std(ma.loglogfit.alpha),3),' r2=',round(mean(ma.loglogfit.r2fit),3),...
        newline,'loglog fit ROTATED:     ',round(mean(ma2.loglogfit.alpha),3),'+-',round(std(ma2.loglogfit.alpha),3),' r2=',round(mean(ma2.loglogfit.r2fit),3));
end

%% 44. new MSD analysis for non-directed
xx=44;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    fitT=0; %linear = 1; parab=0;
    
    
    if(isempty(ma.msd))
        ma = ma.computeMSD;
    end
    
    if(fitT)
        ma.plotMeanMSD(gca, true)
        [fo, gof] = ma.fitMeanMSD;
        plot(fo)
        
        ma = ma.fitMSD;
        good_enough_fit = ma.lfit.r2fit > 0.8;
        Dmean = mean( ma.lfit.a(good_enough_fit) ) / 2 / ma.n_dim;
        Dstd  =  std( ma.lfit.a(good_enough_fit) ) / 2 / ma.n_dim;
        
        fprintf('Estimation of the diffusion coefficient from linear fit of the MSD curves:\n')
        fprintf('D = %.3g ± %.3g (mean ± std, N = %d)\n', ...
            Dmean, Dstd, sum(good_enough_fit));
    else
        ma.plotMeanMSD(gca, true)
        A = ma.getMeanMSD;
        t = A(:, 1); % delay vector
        msd = A(:,2); % msd
        std_msd = A(:,3); % we will use inverse of the std as weights for the fit
        std_msd(1) = std_msd(2); % avoid infinity weight
        
        ft = fittype('a*x + c*x^2');
        [fo, gof] = fit(t, msd, ft, 'Weights', 1./std_msd, 'StartPoint', [0 0]);
        
        hold on
        plot(fo)
        legend off
        ma.labelPlotMSD
        
        Dfit = fo.a / 4;
        Vfit = sqrt(fo.c);
        
        ci = confint(fo);
        Dci = ci(:,1) / 4;
        Vci = sqrt(ci(:,2));
        
        fprintf('Parabolic fit of the average MSD curve with 95%% confidence interval:\n')
        
        fprintf('D = %.3g [ %.3g - %.3g ] %s\n', ...
            Dfit, Dci(1), Dci(2), [SPACE_UNITS '²/' TIME_UNITS]);
        
        fprintf('V = %.3g [ %.3g - %.3g ] %s\n', ...
            Vfit, Vci(1), Vci(2), [SPACE_UNITS '/' TIME_UNITS]);
    end
    
end

%% 45-46. plot mean vcorr in non-rotated and rotated frame
xx=45;
if(showFigs(showFigs==xx))
    figure(45)
    hold on;
    
    warning('filtering happens after the data is rotated perhaps we should do it before');
    filtz=1; %0=no filtering, 1= filtering
    
    if(filtz)
        if(isempty(maf.vcorr))
            maf = maf.computeVCorr;
        end
        maVcorr=maf.getMeanVCorr;
        maf.plotMeanVCorr(gca);
        maf.labelPlotVCorr(gca);
        
    else
        if(isempty(ma.vcorr))
            ma = ma.computeVCorr;
        end
        maVcorr=ma.getMeanVCorr;
        ma.plotMeanVCorr(gca);
        ma.labelPlotVCorr(gca);
    end
    
    
    plot(xlim,mean(maVcorr(maVcorr(:,1)>1.5,2)).*[1,1],'r','linewidth',2);
    figText(gcf,17);
    
    
    figure(46);
    hold on;
    %rotate data into frame of inactive
    if(isempty(ma2.vcorr))
        for i=1:length(usedMovs)
            minT=min(length(usedMovs(i).t),minT);
            % dpos=diff(pos);
            pos = [usedMovs(i).x, usedMovs(i).y];
            rpos = bsxfun(@minus, pos, pos(1,:));
            
            % Subtract initial position
            % Inactive particle position
            iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
            iapos = bsxfun(@minus, iapos, pos(1,:));
            
            %get rid of nans in iapos and rpos
            [nanr,~]=find(isnan(iapos));
            
            %%%%%%%%%%%%%%%%%%%
            if(filtz)
                pos=filter(fb,fa,pos);  %filtered signal
                rpos=filter(fb,fa,rpos);
                iapos=filter(fb,fa,iapos);
            end
            %%%%%%%%%%%%%%%%%%%
            
            
            
            while ~isempty(nanr)
                for qq=1:length(nanr)
                    iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
                end
                [nanr,~]=find(isnan(iapos));
            end
            
            [nanr,~]=find(isnan(rpos));
            while ~isempty(nanr)
                for qq=1:length(nanr)
                    rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
                end
                [nanr,~]=find(isnan(rpos));
            end
            
            
            newpos=zeros(size(rpos));
            for j=2:size(newpos,1)
                % Get the change in the ring position in the world frame
                deltaR = rpos(j, :) - rpos(j-1, :);
                
                % Get the vec1, tor from the ring COG to the inactive smarticle
                rs = iapos(j-1, :) - rpos(j-1, :);
                if(norm(rs))
                    rs = rs./norm(rs);
                end
                ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
                newpos(j, :) =[deltaR*ns',deltaR*rs'];
            end
            newpos=cumsum(newpos);
            newposFilt=newpos;
            
            newposFilt(:,1)=filter(fb,fa,newpos(:,1));  %filtered signal
            newposFilt(:,2)=filter(fb,fa,newpos(:,2));  %filtered signal
            %             if filtz
            %                 dat={[usedMovs(i).t,newposFilt]};
            %             else
            dat={[usedMovs(i).t,newpos]};
            %             end
            ma2=ma2.addAll(dat);
        end
    end
    
    if(isempty(ma2.vcorr))
        ma2=ma2.computeVCorr;
    end
    
    
    ma2Vcorr= ma2.getMeanVCorr;
    ma2.plotMeanVCorr(gca);
    ma2.labelPlotVCorr(gca);
    plot(xlim,mean(ma2Vcorr(ma2Vcorr(:,1)>1.5,2)).*[1,1],'r','linewidth',2);
    figText(gcf,17);
    pts('filt=',filtz,newline,'unrot:',mean(maVcorr(maVcorr(:,1)>1.5,2)),newline,'rot:',mean(ma2Vcorr(ma2Vcorr(:,1)>1.5,2)));
end

%% 47-48 plot r for a single trajectory and x,y
xx=47;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    hax1=gca;
    pIdx=3;
    
    %     [t,x,y]=separateVec(usedMovs(pIdx).data{1},1);
    %     r=sqrt(x.^2+y.^2);
    
    %     subplot(1,2,1);    suptitle(['idx=',num2str(pIdx)]);
    hold on;
    for i=1:8:N
        plot(usedMovs(i).data{1}(:,1),...
            sqrt(sum(usedMovs(i).data{1}(:,2:3).^2,2)));
    end
    %     plot(t,r);
    xlabel('time (s)');
    ylabel('r (m)');
    figText(gcf,16);
    
    %     subplot(1,2,2);
    %     plot(x,y);
    %     xlabel('x (m)');
    %     ylabel('y (m)');
    %     figText(gcf,16);
end

%% 49. get x and y variance
xx=49;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    y=get(gca,'ylim');
    L=length(usedMovs);
    correctDir=0;
    minT=1e10;
    %     vvv=[];
    for i=1:length(usedMovs)
        minT=min(length(usedMovs(i).t),minT);
        % dpos=diff(pos);
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        %get rid of nans in iapos and rpos
        [nanr,~]=find(isnan(iapos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
            end
        end
        [nanr,~]=find(isnan(rpos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
            end
        end
        
        
        newpos=zeros(size(rpos));
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = rpos(j, :) - rpos(j-1, :);
            
            % Get the vec1, tor from the ring COG to the inactive smarticle
            rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
            if(norm(rs))
                rs = rs./norm(rs);
            end
            ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
            %             ns=-ns;%this gets direction of perpendicular movement correct
            %             deltay = ((rs*deltaR')/norm(rs)^2)*rs;
            %             deltax = deltaR - deltay;
            newpos(j, :) =[deltaR*ns',deltaR*rs'];
            %       newpos(j, :) = [sign((rs./norm(rs))*(deltax'./norm(deltax)))*norm(deltax),...
            %                           sign((rs./norm(rs))*(deltay'./norm(deltay)))*norm(deltay)];
            
        end
        %         newpos=cumsum(newpos,2);
        newpos=cumsum(newpos);
        if newpos(end,2)>0
            correctDir=correctDir+1;
        end
        %         vv=diff(newpos)./diff(usedMovs(i).t);
        %         vvv(i)={vv};
        % %         vvv=[vvv;vv];
        %     end
        h=plot(newpos(end,1),newpos(end,2),'ko','markersize',4,'MarkerFaceColor','r');
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        endPos(i)=newpos(end,2);
        nn(i,:)=newpos(end,:)./usedMovs(i).t(end);
    end
    mn=mean(nn);
    sdv=std(nn);
    pts('mean((final y positions)/time)');
    pts('ymean,ystd=',mn(1),',',sdv(1));
    pts('xmean,xstd=',mn(2),',',sdv(2));
    %         meanz=[meanz,mean(nn)];
    %         valz=[valz,std(nn).^2];
    
end
%% 50. view variance dependence on exp time length
xx=50;
if(showFigs(showFigs==xx))
    valz=[];
    meanz=[];
    numz=20;
    for kkk=1:numz
        %     figure(xx)
        %     hold on;
        %     hax1=gca;
        %     ma.plotTracks
        %     ma.labelPlotTracks
        %     text(0,0+.01,'start')
        %     plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
        %     y=get(gca,'ylim');
        %     deltax=get(gca,'xlim');
        %     c=max(abs(deltax)); xlim([-c,c]);
        %     c=max(abs(y)); ylim([-c,c]);
        %     deltax=xlim; y=ylim;
        %set(gca,'xtick',[-.5:.25:.5],'ytick',[-.5:.25:.5]);
        %     set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]); %same as 1
        
        %     for i=9
        %     xp = 0;
        %     yp = 0;
        L=length(usedMovs);
        correctDir=0;
        minT=1e10;
        for i=1:length(usedMovs)
            minT=min(length(usedMovs(i).t),minT);
            % dpos=diff(pos);
            pos = [usedMovs(i).x, usedMovs(i).y];
            rpos = bsxfun(@minus, pos, pos(1,:));
            
            % Subtract initial position
            % Inactive particle position
            iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
            iapos = bsxfun(@minus, iapos, pos(1,:));
            
            %get rid of nans in iapos and rpos
            [nanr,~]=find(isnan(iapos));
            
            if ~isempty(nanr)
                for qq=1:length(nanr)
                    iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
                end
            end
            [nanr,~]=find(isnan(rpos));
            
            if ~isempty(nanr)
                for qq=1:length(nanr)
                    rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
                end
            end
            
            %
            %         newL=round(size(rpos,1)/3);
            %         newL=round(size(rpos,1)/3);
            newL=round(kkk*size(rpos,1)/numz);
            
            
            rpos=rpos(1:newL,:);
            iapos=iapos(1:newL,:);
            %
            
            newpos=zeros(size(rpos));
            %         for j=2:size(newpos,1)
            
            for j=2:newL
                % Get the change in the ring position in the world frame
                deltaR = rpos(j, :) - rpos(j-1, :);
                
                % Get the vec1, tor from the ring COG to the inactive smarticle
                rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
                if(norm(rs))
                    rs = rs./norm(rs);
                end
                ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
                %             ns=-ns;%this gets direction of perpendicular movement correct
                %             deltay = ((rs*deltaR')/norm(rs)^2)*rs;
                %             deltax = deltaR - deltay;
                newpos(j, :) =[deltaR*ns',deltaR*rs'];
                %       newpos(j, :) = [sign((rs./norm(rs))*(deltax'./norm(deltax)))*norm(deltax),...
                %                           sign((rs./norm(rs))*(deltay'./norm(deltay)))*norm(deltay)];
                
            end
            %         newpos=cumsum(newpos,2);
            newpos=cumsum(newpos);
            if newpos(end,2)>0
                correctDir=correctDir+1;
            end
            %         plot(newpos(:,1),newpos(:,2));
            %                 plot(ones(1,length(newpos(:,2)))*.025*i-length(usedMovs)/2*.025,newpos(:,2));
            %         h=plot(newpos(end,1),newpos(end,2),'ko','markersize',4,'MarkerFaceColor','r');
            %         set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            endPos(i)=newpos(end,2);
            nn(i)=newpos(end,2)./usedMovs(i).t(newL);
        end
        pts('mean((final y positions)/time)', mean(nn),' +-',std(nn));
        pts('var=',std(nn).^2);
        meanz=[meanz,mean(nn)];
        valz=[valz,std(nn).^2];
        %     close all
        %     pts('avg projected v=',mean(endPos)/(minT/usedMovs(1).fps));
        %     xpercent = xp/length(ma.tracks);
        %     ypercent = yp/length(ma.tracks);
        %     text(0,-0.25,['Towards X = ',num2str(xpercent,'%.3f')], 'fontsize',16)
        %     text(0, 0.25,['Towards Y = ',num2str(ypercent,'%.3f')],'fontsize',16)
        
        %     text(.1,.9,{['towards inactive: ',num2str(correctDir,2),...
        %         '/',num2str(L),'=',num2str(correctDir/L,2)]},'units','normalized','Interpreter','latex');
        
        ringRad=.1905/2;
        %     h=plot(ringRad*cos(0:.01:2*pi),ringRad*sin(0:.01:2*pi),'k','linewidth',2);
        %     set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        %     xlabel('Perpendicular to Inactive Smarticle (m)')
        %     ylabel('Along Axis of Inactive Smarticle (m)')
        %     title('Projected displacement');
        % %     figText(gcf,14);
        %     axis tight
        %     axis equal
        %     axis([-.35 .35 -.35 .35]);
        %     h=plot(xlim,[0,0],'r');
        %     set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        %     h=plot([0,0],ylim,'r');
        %     set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        
        
        %     figure(12524);
        dataLen=[40,];
        mm=[-0.00013641 -0.00021787 -.00014566, -0.00012244 0.0001927, 0.000697 0.00098668];
        mmerr=[0.00011918 0.00027257 0.0004223, 0.0006557,  0.0011994, 0.0010046 0.0013029];
        %     mx=[1/6 1/4 1/3 1/2 1 2 3];
        inactiveMass=34; %grams
        
        %     mx=[1/6 1/4 1/3 1/2 1 2 3];
        %     mx=[superHeavy,regRing1-4,regRing1-3,mediumRing,shortRing,lightRing,superLight]
        mx= inactiveMass./[207,119.9 ,91.1 ,68,29.5,16,9.78];
        
        %     mm=[-0.00013641 -0.00021787 -.00014566, -0.00012244 0.0001927, 0.000697 0.000548];
        %     mmerr=[0.00011918 0.00027257 0.0004223, 0.0006557,  0.0011994, 0.0010046 0.00073104];
        %     mx=[1/6 1/4 1/3 1/2 1 2 3];
        %     errorbar(mx,mm,mmerr);
        %     xlabel('M_{inactive}/M_{ring}');
        %     ylabel('\langle final drift speed\rangle');
        %     hold on;
        % %     errorbar([0.5],[-0.00017361],[0.00021024])
        %     figText(gcf,16);
        xl=xlim;
        %     plot(xl,[0,0],'k');
        
        
        
        
    end
    figure(xx);
    hold on;
    l1=log((1:numz)./numz);l2=log(valz);scatter(l1,l2);
    ylabel('log(var(v_y))')
    xlabel('log(time)')
    
    figure(12412);
    hold on;
    plot(meanz);
    axis([0,20,-5e-4,0]);
    ylabel('mean(v_y)')
    xlabel('')
end
%% 51 plot gamma vs t
xx=51;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    if(isempty(ma.msd))
        ma = ma.computeMSD;
    end
    %     if(isempty(maf.msd))
    %         maf = maf.computeMSD;
    %     end
    p=ma.getMeanMSD;
    %     pf=maf.getMeanMSD;
    co=.25;
    [ffb,ffa]=butter(6,co/(samp/2),'low');
    
    gam=diff(log(p(2:end,2)))./diff(log(p(2:end,1)));
    %     gam=gam(2:end);
    fgam=filter(ffb,ffa,gam);
%     fgam=movmean(gam,1/diff(p(1:2,1))*1.5);
%     fgam=lowpass(gam,.5,1/diff(p(3:4)));
    plot(p(3:end,1),gam);
    plot(p(3:end,1),fgam);
    %     plot(pf(2:end,1),diff(log(pf(:,2)))./diff(log(pf(:,1))))
    
    legend({'non-filtered','filtered'});
    
    ylabel('\gamma');
    xlabel('delay (s)');
    figText(gcf,16);
end
%% 52 plot x vs t with light with channel
xx=52;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    ind=2;
    xdist=usedMovs(ind).x*100; %in cm
    xdist=xdist-sum([min(xdist) max(xdist)])/2;
    xvt=1; %1 if plotting x vs t
    
    
    
    
    
    lightStart=-1;%going to the left
    t=usedMovs(ind).t;
    t=t/2.5;
    [initDir,light]=readLightData(fullfile(fold,usedMovs(ind).fname));
    light=light/2.5;
    light(end+1)=t(end);%append final time to light vector
    ll=t;
    for i=2:length(light)
        ll(light(i-1)<t&t<=light(i))=-1*initDir*(-1).^(i-1);
    end
    bounds=[max(xdist) min(xdist)];
    max(xdist-sum(bounds)/2);
    
    
    if(~xvt)
        xlabel('x (cm)');
        ylabel('Gait Periods');
        plot(xdist,t);
        plot(ll*ceil(max(xdist)),t,'k.');
    else
        ylabel('x (cm)');
        xlabel('Gait Periods');
        plot(t,xdist);
        plot(t,ll*ceil(max(xdist)),'k.');
        
    end
    
    figText(gcf,16);
    %     negLight=[]
    
    %     x1=1:120;
    %     x2=121:240
    %     x3=241:360
    %     plot(
    
end
%% 53 plot active smart diagram
xx=53;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    ind=2;
    load(fullfile(fold,'trackedLightSmartChannel.mat'));
    cols= get(gca,'colorOrder');
    cols=cols(1:6,:);
    smartChangeTimes=smartChangeTimes/2.5; %convert to gaitPeriod
    rStart=392; %time when direction starts towards right
    rEnd=427;   %time when direction ends towards right
    for i=1:(length(smartChangeTimes)-1)
        for k=1:length(smartsActive{i})
            %vertices starting from top left clockwise
            %right dir goes 392-427tau or 16:20s and ends at 17:48
            
            xVerts=[smartChangeTimes(i) smartChangeTimes(i+1)...
                smartChangeTimes(i+1) smartChangeTimes(i)];
            
            yVerts=[(smartsActive{i}(k)+0.5),(smartsActive{i}(k)+0.5)...
                (smartsActive{i}(k)-0.5) (smartsActive{i}(k)-0.5)];
            patch(xVerts-rStart,yVerts,cols(smartsActive{i}(k)+1,:),'linestyle','none');
        end
    end
    xlim([0,rEnd-rStart])
    ylim([-0.5,5.5]);
    
    set(gca,'ytick',[0:5],'yticklabel',{'' '1' '' '3' '' '5'});
    set(gca,'xtick',[0:5:35],'xticklabel',{'0' '' '10' '' '20' '' '30' ''});
    ylabel('Inactive Index');
    xlabel('Time ()');
    figText(gcf,16);
    
end
%% 54 plot histogram of velocities
xx=54;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    L=length(usedMovs);
    correctDir=0;
    minT=1e10;
    for i=1:length(usedMovs)
        minT=min(length(usedMovs(i).t),minT);
        % dpos=diff(pos);
        pos = [usedMovs(i).x, usedMovs(i).y];
        rpos = bsxfun(@minus, pos, pos(1,:));
        
        % Subtract initial position
        % Inactive particle position
        iapos = [usedMovs(i).Ix, usedMovs(i).Iy];
        iapos = bsxfun(@minus, iapos, pos(1,:));
        
        %get rid of nans in iapos and rpos
        [nanr,~]=find(isnan(iapos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                iapos(nanr(qq),:)=iapos(nanr(qq)-1,:);
            end
        end
        [nanr,~]=find(isnan(rpos));
        
        if ~isempty(nanr)
            for qq=1:length(nanr)
                rpos(nanr(qq),:)=rpos(nanr(qq)-1,:);
            end
        end
        
        
        newpos=zeros(size(rpos));
        for j=2:size(newpos,1)
            % Get the change in the ring position in the world frame
            deltaR = rpos(j, :) - rpos(j-1, :);
            
            % Get the vec1, tor from the ring COG to the inactive smarticle
            rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
            if(norm(rs))
                rs = rs./norm(rs);
            end
            ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
            %             ns=-ns;%this gets direction of perpendicular movement correct
            %             deltay = ((rs*deltaR')/norm(rs)^2)*rs;
            %             deltax = deltaR - deltay;
            newpos(j, :) =[deltaR*ns',deltaR*rs'];
            %       newpos(j, :) = [sign((rs./norm(rs))*(deltax'./norm(deltax)))*norm(deltax),...
            %                           sign((rs./norm(rs))*(deltay'./norm(deltay)))*norm(deltay)];
            
        end
        %         newpos=cumsum(newpos,2);
        newpos=cumsum(newpos);
        if newpos(end,2)>0
            correctDir=correctDir+1;
        end
        endPos(i)=newpos(end,2);
        nn(i)=newpos(end,2)./usedMovs(i).t(end);
    end
    pts('mean((final y positions)/time)', mean(nn),' +-',std(nn));
    ringRad=.1905/2;
    h1=histogram(nn,8);
    xx=cumsum(diff(h1.BinEdges))+h1.BinEdges(1)-diff(h1.BinEdges)/2;
    yy=h1.Values;
    hold off;
    plot(xx,yy);
    hold on;
    xlabel('Drift Velocity (m/s)')
    ylabel('P(v)');
    figText(gcf,16);
end
%% 55. true granular temperature mean squared vel
xx=55;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    %requires that all runs have the same number of smarticles
    n=size(usedMovs(1).x,2);
    filtz=0;
    mT=usedMovs(1).t(minT);
    dsb=5; %downsample amount
    for(idx=1:N)
        
        %         rI(1:numBods,:,idx)=[usedMovs(idx).x(1,:)',usedMovs(idx).y(1,:)'];
        %         rF(1:numBods,:,idx)=[usedMovs(idx).x(end,:)',usedMovs(idx).y(end,:)'];
        
        x=usedMovs(idx).x;
        y=usedMovs(idx).y;
        thet=usedMovs(idx).rot;
        t=usedMovs(idx).t(:,1);
        
        x=x(t(:)<=mT,:);
        y=y(t(:)<=mT,:);
        thet=thet(t(:)<=mT,:);
        t=t(t(:)<=mT,:);
        t=t/2.5; %put in gait period form
        
        x=x-x(1);
        y=y-y(1);
        thet=thet-thet(1);
        
%         x=downsample(x,dsb);
%         y=downsample(y,dsb);
%         thet=downsample(thet,dsb);
%         t=downsample(t,dsb);
        if(filtz)
            %lowpass(x,5,1/diff(t(1:2)),'ImpulseResponse','iir');
            %x=lowpass(y,5,1/diff(t(1:2)));
            x=filter(fb,fa,x);  %filtered signal
            y=filter(fb,fa,y);  %filtered signal
            thet=filter(fb,fa,thet);  %filtered signal
        end
        
        dx=diff(x); dy=diff(y);dr=diff(thet);dt=diff(t);
        
        v(:,idx)=sqrt((dx./dt).^2+(dy./dt).^2);
        vr=sqrt((dr./dt).^2);
    end
    
    VV=mean(v.^2,2)-mean(v,2).^2;
    %     VT=sqrt(VT);
    %     VR=sqrt(VR);

    windowM=movmean(VV,length(VV)/max(t));
    
    plot(t(1:end-1),VV,'k','linewidth',1);
    plot(t(1:end-1),windowM,'linewidth',3);
    xlabel('\tau');
    ylabel('\langlev^2\rangle (m^2/\tau^2)');
    figText(gcf,16);
    xlim([0 80]);
    
%     plot(t(t<7)+73,windowM(t<7),'linewidth',1);    
%     plot(t(t<7)+73,VV(t<7),'r','linewidth',1);

    %a=sort(VSTD)
    pct=@(x,vec) vec(round(((100-x)/100)*length(vec)));
%     err=pct(1,sort(VSTD));
%     shadedErrorBar(xlim,[mean(VSTD),mean(VSTD)],ones(2,1)*pct(5,sort(VSTD)),{},.5)
%     plot(xlim,ones(2,1)*pct(5,sort(VSTD)),'linewidth',2)
yy=ylim;
ylim([0,yy(2)]);

end
%% 56 rotate trajectories by set amount
xx=56;
if(showFigs(showFigs==xx))
    figure(xx)
        hold on;
    hax1=gca;
    %     ma.plotTracks(hax1,i);
    
    axis([-.25 .25 -.25 .25]);
    thet=-pi;
    rotV= [cos(thet) -sin(thet); sin(thet) cos(thet)];
    tracks = ma.tracks;
    tracks=cellfun(@(x) [rotV*[x(:,2),x(:,3)]']',tracks,'UniformOutput',0);
    for i=1:length(tracks)
        hold on;
        plot(tracks{i}(:,1),tracks{i}(:,2),'-');
        vx=norm(tracks{i}(end,1)./ma.tracks{i}(end,1));
        vy=norm(tracks{i}(end,2)./ma.tracks{i}(end,1));
%         v=norm(mean(diff(tracks{i})./diff(ma.tracks{i}(:,1))));
        vvx=[vvx, vx];
        vvy=[vvy, vy];
        %     pause
    end
    ma.labelPlotTracks
    %     text(0,0+.01,'start')
    h=plot(0,0,'ro','markersize',8,'MarkerFaceColor','k');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    yl=get(gca,'ylim'); xl=get(gca,'xlim');
    c=max(abs(xl)); xlim([-c,c]);
    c=max(abs(yl)); ylim([-c,c]);
    axis equal
    
    axis([-.3 .3 -.3 .3]);
    xl=xlim; yl=ylim;
    set(gca,'xtick',[-.2:.1:.2],'ytick',[-.2:.1:.2]);
    yl=get(gca,'ylim'); xl=get(gca,'xlim');
    h=plot(xl,[0,0],'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    h=plot([0,0],yl,'r');
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    xp = 0;
    yp = 0;
    for i=1:length(ma.tracks)
        %         pause(100)
        h=plot([tracks{i}(end,1)], [tracks{i}(end,2)],'ko-','markersize',4,'MarkerFaceColor','r');
        %         leg(i)=h;
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        if tracks{i}(end,1) > 0
            xp = xp + 1;
        end
        
        if tracks{i}(end,2) > 0
            yp = yp + 1;
        end
        
        
        hold on
        x=['v',num2str(usedMovs(i).pars(5))];
        legT{i}=['v',num2str(usedMovs(i).pars(5))];
        
    end
    legend(legT);
    legend off;
    xpercent = xp/length(tracks);
    ypercent = yp/length(tracks);
    %     text(0,-0.25,['Towards X = ',num2str(xpercent,'%.3f')], 'fontsize',16)
    %     text(0, 0.25,['Towards Y = ',num2str(ypercent,'%.3f')],'fontsize',16)
    disp(['Trials = ',num2str(length(tracks),'%.d')])
    disp(['Towards X = ',num2str(xpercent,'%.3f')])
    disp(['Towards Y = ',num2str(ypercent,'%.3f')])
    %     title('Whole Time-Scale Displacements');
    
    %     ringRad=.1905/2;
    %     h=plot(ringRad*cos(0:.01:2*pi),ringRad*sin(0:.01:2*pi),'k','linewidth',2);
    %     set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    figText(gcf,14)
    ringRad=.1905/2;
    h=plot(ringRad*cos(0:.01:2*pi),ringRad*sin(0:.01:2*pi),'k','linewidth',2);
    
end
