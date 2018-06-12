% has much of same plots as plotChainForce.m except this is for systems
% with markers on robot arm, first and last smarticle

%************************************************************
%* Fig numbers:
%* 1. force vs time with strain overlay
%* 2. plot comparison b/w activated system and regular, Force vs. Time
%* 3. plot single Force vs. Strain
%* 4. plot comparison b/w activated system and regular, Force vs. Strain
%* 5. plot force vs. time for usedS
%* 6. plot force vs. strain for usedS
%* 7. plot force vs. strain for usedS with slope bar
%* 8. find and save fracture point
%* 9. plot fracture force vs height and strain vs height
%*10. plot max recorded force on fracture runs
%*11. plot select iterations of strain for single run
%*12. get work from select strain iterations for single run
%*13. get work from select strain iterations for many runs
%*14. get work vs strain rate for many runs
%*15. elastic response vs strain
%*16. elastic response vs strain rate
%*17. force (max) vs strain rate
%*18. force (max) vs strain
%*19. redone work vs strain rate
%*20. apparatus strain
%*55. old force vs H data
%************************************************************
% clearvars -except t
% close all;
clear all;

% maxSpeed= 1.016; %m/s
% pctSpeed=.0173;
% speed=pctSpeed*maxSpeed;
samp=120;
[fb,fa]=butter(6,2/(samp/2),'low');


fold=uigetdir('A:\2DSmartData\entangledData\4-17');
% fold='A:\2DSmartData\entangledData\12-19 multimark SAC w=10 weaker';
% fold='A:\2DSmartData\entangledData\before 11-30 (multimarkers)\stretchAll 11-20 paperTrials\type4only';
% fold='A:\2DSmartData\entangledData\4-11 multimarker';
freq=1000; %hz rate for polling F/T sensor
fractD=0;%flag for fractData
if (~exist(fullfile(fold,'dataOut.mat'),'file') && ~exist(fullfile(fold,'fractData.mat'),'file'))
    filez=dir2(fullfile(fold,'Stretch*'));
    N=length(filez);
    allFpars=zeros(N,7); % [type,SD,H,del,spd,its,v]
    s=struct;
    for i=1:N
        pts(i,'/',N);
        [allFpars(i,:),s(i).t,s(i).strain,s(i).F,L,s(i).rob,s(i).chain,s(i).dsPts, s(i).vel]=...
            analyzeEntangleFileMM(fold,filez(i).name,freq,0);
        s(i).name=filez(i).name;
        s(i).fpars=allFpars(i,:);
        %             [s(i).type,s(i).SD,s(i).H,s(i).del,s(i).spd,s(i).its,s(i).v]=separateVec(s(i).fpars(i,:),1);
        [s(i).type,s(i).SD,s(i).H,s(i).del,s(i).spd,s(i).its,s(i).v]=separateVec(allFpars(i,:),1);
    end
    save(fullfile(fold,'dataOut.mat'),'s','allFpars');
else
    
    if exist(fullfile(fold,'fractData.mat'),'file')
        load(fullfile(fold,'fractData.mat'));
        fractD=1;
    end
    
    if exist(fullfile(fold,'dataOut.mat'),'file')
        load(fullfile(fold,'dataOut.mat'));
    end
end


typeTitles={'Inactive Smarticles','Regular Chain','Viscous, open first 2 smarticles',...
    'Elastic, close all smarticles','Fracture On','Stress Avoiding Chain'...
    'Fracture SAC'};
%%%%%%%%%%%%%%%%%%
filtz=1;
% showFigs=[6];
showFigs=[1 3];
tpt=[2 2];
% strains=[65]/1000;
% types=[]; strains=[85]/1000; Hs=[]; dels=[]; spds=[]; its=[]; vs=[];
types=[]; strains=[]; Hs=[]; dels=[]; spds=[]; its=[]; vs=[];
%%%%%%%%%%%%%%%%%%%%%%%%
props={types strains Hs dels spds its vs};
if ~isempty([props{:}])
    warning(['filtering some properties']);
end
setP1=[];
indcnt=1;
% if(fractD==0)
    for i=1:length(s)
        cond=1;
        for j=1:length(props)
            
            if ~isempty(props{j})
                if(~any(props{j}==s(i).fpars(j)))
                    cond=0;
                end
            end
        end
        if(cond)
            if filtz
                s(i).F=filter(fb,fa,s(i).F);  %filtered signal
            end
            usedS(indcnt)=s(i);
            indcnt=indcnt+1;
        end
    end
    if ~exist('usedS','var')
        error('No file with specified parameters exists in folder');
    end
    uN=length(usedS);
    fpars=zeros(uN,7);
    for i=1:uN
        fpars(i,:)=usedS(i).fpars;
    end
    [type,SD,H,del,spd,it,v]=separateVec(fpars,1);
% end
% showFigs=[9 10]

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
        h=plot(s(ind).t,6*maxF*s(ind).strain);
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
    xlimz=[0,35];
    ylimz=[-1,1];
    figure(xx)
    hold on;
    
    xlabel(xlab);
    ylabel(ylab);
    typesZ=[5 5];
    title(typeTitles{typesZ(1)+1});
    %[type,strain, sys width,del,spd, its,version]
    setP1=find(ismember(fpars(:,[1 2 3 4 5 6]),[typesZ(1) 0.026,0.105,4, 2,1],'rows'))';
    setP2=find(ismember(fpars(:,[1 2 3 4 5 6]),[typesZ(2) 0.065,0.105,4, 2,2],'rows'))';
    for i=setP1
        plot(s(i).t,s(i).F);
        %     pause;
    end
    
    axis([xlimz,ylimz])
    axis square
    figText(gcf,fz);
    
    figure(25)
    hold on;
    ylabel(ylab);
    
    title(typeTitles{typesZ(2)+1});
    % title('Activate First 2 Smarts During Delay Period');
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
    
    pts('F vs. Strain for ',usedS(ind).name);
    %     plot(s(ind).strain,s(ind).F);
    %     ff=usedS(ind).F;
    %     ss=usedS(ind).strain;
    %     ff1=filter(fb,fa,ff);  %filtered signal
    colormapline(usedS(ind).strain,usedS(ind).F,[],jet(100));
%     plot(usedS(ind).strain,usedS(ind).F);
    xlabel('Strain');
    ylabel('Force (N)');
    figText(gcf,18)
    
    %     figure(12312)
    %     colormapline(ss,ff1,[],jet(100));
    %     xlabel('Strain');
    %     ylabel('Force (N)');
    %     figText(gcf,18)
end
%% 4 plot comparison b/w activated system and regular, Force vs. Strain
xx=4;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=2; fz=18;
    hold on;
    xlab = 'Strain';
    ylab = 'Force (N)';
    xlimz=[-0.01,0.25];
    ylimz=[-0.35,0.8];
    %
    % xlimz=[-0.7,0.7];
    % ylimz=[-0.7,0.7];
    
    typesZ=[1 5];
    title(typeTitles{typesZ(1)+1});
    xlabel(xlab);
    ylabel(ylab);
    for i=find(type==typesZ(1))'
        plot(s(i).strain,s(i).F);
        %     pause;
    end
    axis([xlimz,ylimz])
    % ylim([-0.6,0.6]);
    axis square
    figText(gcf,fz);
    figure(55)
    hold on;
    
    title(typeTitles{typesZ(2)+1});
    xlabel(xlab);
    for i=find(type==typesZ(2))'
        plot(s(i).strain,s(i).F);
        %     pause
    end
    axis([xlimz,ylimz])
    axis square
    % axis equal
    ylabel(ylab);
    figText(gcf,fz);
end
%% 5. force vs time for usedS
xx=5;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;
    overlayStrain=1;
    for(i=1:uN)
        pts('F vs. T for ',usedS(i).name);
        h(i)=plot(usedS(i).t,usedS(i).F);
        maxF(i)=max(usedS(i).F);
        maxS(i)=max(usedS(i).strain);
        
        if(overlayStrain)
            %             h2(i)=plot(usedS(i).t,maxF(i)*usedS(i).strain/maxS(i),'k','linewidth',4);
            h3(i)=plot(usedS(i).t,maxF(i)*usedS(i).strain/maxS(i),'linewidth',2);
            legend({'Force','Scaled Strain'},'location','south')
            %             set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            set(get(get(h3(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            
        end
    end
    xlabel('time (s)','fontsize',18);
    ylabel('force (N)','fontsize',18);
    
    
    figText(gcf,16)
end
%% 6. plot Force vs. Strain for usedS
xx=6;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    % ind=2;
    [speed,tArea,frc]=deal(zeros(uN,1));
    tArea=zeros(uN,1);
    speed=zeros(uN,1);
    strMax=0;
    spds=unique([usedS(:).spd]);
    startIt=3; %iteration to consider as "zero point"
    timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    % plot(s(ind).strain,s(ind).F);
    
    
    for i=1:length(spds)
        pts('F vs. Strain for ',usedS(i).name);
        currSpds=find([usedS(:).spd]==spds(i));
        dspts={usedS(currSpds).dsPts};
        stpt=min(cellfun(@(x) x(timePts(1)*4+1,3),dspts));
        edpt=min(cellfun(@(x) x(timePts(2)*4+4,3),dspts));
        [mforce,mstrainz,ef]=deal(zeros(edpt-stpt+1,length(spds)));
        %         minT=min(cellfun(@(x) size(x,1),{usedS(currSpds).t}));
        strainz=[];
        forcez=[];
        for j=1:length(currSpds)
            strainz(:,j)=usedS(currSpds(j)).strain(stpt:edpt);
            forcez(:,j)=usedS(currSpds(j)).F(stpt:edpt);
            forcez(:,j)=forcez(:,j)-forcez(1,j);
            strainz(:,j)=strainz(:,j)-strainz(1,j);
        end
        mforce(:,i)=mean(forcez,2);
        mstrainz(:,i)=mean(strainz,2);
        ef(:,i)=std(forcez,0,2);
        
        shadedErrorBar(mstrainz(:,i),mforce(:,i),ef(:,i),{'linewidth',2},.5);
        pause
        legT{i}=['$\dot{\epsilon}$=',num2str(spds(i)),'mm/s'];
        
    end
    legend(legT,'interpreter','latex');
    text(0.4,0.9,['\epsilon=',num2str(usedS(1).SD),'mm'],'units','normalized')
    
    xlabel('Strain');
    ylabel('Force (N)');
    figText(gcf,18)
end
%% 7. plot force vs. strain for usedS with slope bar
xx=7;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    subplot(1,2,1)
    hold on;
    % ind=2;
    %     tArea=zeros(uN,1);
    strMax=0;
    legText={};
     timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    for(i=uN:-1:1)
       
        stpt=usedS(i).dsPts(timePts(1)*4+1,3);
        edpt=usedS(i).dsPts(timePts(2)*4+4,3);
        
        pts('F vs. Strain for ',usedS(i).name);
        h1(i)=plot(usedS(i).strain(stpt:edpt),usedS(i).F(stpt:edpt));
        %             colormapline(usedS(i).strain,usedS(i).F,[],jet(100));
        %         tArea(i)=trapz(usedS(i).strain,usedS(i).F);
        %         A(i)=polyarea([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)]);
        [sm(i),smidx]=max(usedS(i).strain(stpt:edpt));
        strMax=max(strMax,sm(i));
        
        h2(i)=plot([0,sm(i)],[0,usedS(i).F(smidx)],'k','linewidth',4);
        h3(i)=plot([0,sm(i)],[0,usedS(i).F(smidx)],'color',h1(i).Color,'linewidth',2);
        
        set(get(get(h1(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        %         set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        %         fill([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)],'k','facecolor','c')
        k(i)=usedS(i).F(smidx)/sm(i);
        legText(i)={['k=',num2str(k(i),2)]};
        
    end
    legend(legText);
    xlabel('Strain');
    ylabel('Force (N)');
    figText(gcf,20)
    axis([0,round(strMax,2),-0.4,0.8]);
    
    subplot(1,2,2)
    hold on;
    xlabel('Strain');
    ylabel('k');
    figText(gcf,20);
    plot(sm,k,'-o','linewidth',2,'markerfacecolor','w')
    
end
%% 8. find and save fracture point
xx=8;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    % ind=2;
    tArea=zeros(uN,1);
    strMax=0;
    fractData=struct;
    set(0,'defaultAxesFontSize',20)
    for(i=1:uN)
        fractData(i).fname=usedS(i).name;
        fractData(i).F=usedS(i).F;
        fractData(i).H=usedS(i).H;
        fractData(i).strain=usedS(i).strain;
        
        hold off
        h=plot(usedS(i).strain,usedS(i).F);
        xlabel('Strain');
        ylabel('Force (N)');
        hold on;
        [fracStrainMax,fracFmax,~,fracInd]=MagnetGInput(h,1,1);
        plot(fracStrainMax,fracFmax,'ko');
        fractData(i).fracStrainMax=fracStrainMax;
        fractData(i).fracFmax=fracFmax;
        fractData(i).fracInd=fracInd;
        [fMax,maxInd]=max(usedS(i).F);
        fractData(i).maxInd=maxInd;
        fractData(i).fMax=fMax;
        fractData(i).maxFStrain=usedS(i).strain(maxInd);
        %         plot(usedS(i).strain(1:ind),usedS(i).F(1:ind));
        pts(i,'/',uN);
        pause();
    end
    save(fullfile(fold,'fractData.mat'),'fractData');
end
%% 9. plot fracture force vs height and strain vs height
xx=9;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    
    smartWid=9.1; %cm
    load(fullfile(fold,'fractData.mat'));
    uH=sort(unique([fractData(:).H]),'ascend');
    allH=[fractData(:).H];
    uF=cell(length(uH),1);
    uS=cell(length(uH),1);
    for i=1:length(uH)
        inds=find(allH==uH(i));
        uF(i)={[fractData(inds).fracFmax]};
        
        %%%Get strains from rob
        h=[];
        for(j=1:length(inds))
            h(j)=usedS(inds(j)).rob(fractData(inds(j)).fracInd)*100;
        end
        uS(i)={h};
        %%%%
        
%         uS(i)={[fractData(inds).fracStrainMax]};
        uFm(i)=mean(uF{i});
        uFerr(i)=std(uF{i});
        uSm(i)=mean(uS{i});
        uSerr(i)=std(uS{i});
    end
    
    subplot(1,2,1)
    hold on;
    title('Force at Fracture');
    errorbar(smartWid./uH,uFm,uFerr,'linewidth',2);
    ylabel('Force (N)');
%     xlabel('Confinement Height (cm)');
    xlabel('\lambda_i');
    figText(gcf,16)
    axis tight;
    
    subplot(1,2,2)
    hold on;
    title('Strain at Fracture');
    errorbar(smartWid./uH,uSm,uSerr,'linewidth',2);
    ylabel('Strain (cm)');
%     xlabel('Confinement Height (cm)');
    xlabel('\lambda_i');
    figText(gcf,16);
    axis tight;
    
    
end
%% 10. plot max force recorded on fracture runs
xx=10;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    
    load(fullfile(fold,'fractData.mat'));
    uH=sort(unique([fractData(:).H]),'ascend');
    allH=[fractData(:).H];
    uF=cell(length(uH),1);
    for i=1:length(uH)
        inds=find(allH==uH(i));
        %         eSIdx=[fractData(inds).ind]; %end strain idx
        uF{i}=[fractData(inds).fMax];
        %         for j=1:length(eSIdx)
        %             uF{i}=[uF{i},fractData(i).fMax];
        %         end
        uFm(i)=mean(uF{i});
        uFerr(i)=std(uF{i});
    end
    
    title('Max force vs. Width');
    errorbar(uH,uFm,uFerr,'linewidth',2);
    ylabel('Force (N)');
    xlabel('Width (smarticle widths)');
    figText(gcf,16)
    axis tight;
end

%% 11. plot certain parts of strain
xx=11;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;
    startIt=3; %iteration to consider as "zero point"
    timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    pts('F vs. Strain for ',usedS(ind).name);
    % plot(s(ind).strain,s(ind).F);
    R=usedS(ind);
    %         time2useS=R.dsPtstimePts(1)*4+1),3);%4 points per iteration
    t2uS=R.dsPts(timePts(1)*4+1,:);%4 points per iteration
    %         time2useE=R.dsPts(timePts(2)*4,3);
    t2uE=R.dsPts(timePts(2)*4+4,:);
    x=R.strain(t2uS(3):t2uE(3));
    y=R.F(t2uS(3):t2uE(3))';
    
    %     figure(588);hold on;plot(usedS(ind).t,usedS(ind).strain);plot(usedS(ind).dsPts(:,1),usedS(ind).dsPts(:,2),'o');
    figure(588);hold on;plot(usedS(ind).t,usedS(ind).strain);
    plot(t2uS(1),t2uS(2),'o');
    plot(t2uE(1),t2uE(2),'o');
    figure(xx)
    %     time2use=usedS(ind).dsPts((startIt-1)*4,3);
    %     x=usedS(ind).strain(time2use:end);
    %     y=usedS(ind).F(time2use:end);
    
    x=x-x(1);%zero at start iteration
    y=y-y(1);
    
    colormapline(x,y,[],jet(100));
    xlabel('Strain');
    ylabel('Force (N)');
    xlim([0,inf]);
    figText(gcf,18)
end
%% 12. get work from select strain iterations for single run
xx=12;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;
    timePts=[2,2]; %iteration to consider as "zero point"
    
    pts('F vs. Strain for ',usedS(ind).name);
    % plot(s(ind).strain,s(ind).F);
    
    time2useS=usedS(ind).dsPts((timePts(1)*4+1),3);%4 points per iteration
    time2useE=usedS(ind).dsPts(timePts(2)*4+4,3);
    
    x=usedS(ind).strain(time2useS:time2useE);
    y=usedS(ind).F(time2useS:time2useE)';
    
    x=x-x(1);%zero at start iteration
    y=y-y(1);
    
    tArea=trapz(x,y);
    %         A(i)=polyarea([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)]);
    [sm(i),smidx]=max(x);
    co=get(gca,'colororder');
    ii=get(gca,'colororderindex');
    %     colormapline(x,y,[],jet(100));
    fill([x,x(1)],[y,y(1)],'k','facecolor',co(ii,:),'facealpha',.5)
    co=set(gca,'colororder');
    xlabel('Strain');
    ylabel('Force (N)');
    
    text(0.4,0.9,['W=',num2str(tArea,3)],'units','normalized')
    
    xlim([0,inf]);
    figText(gcf,18)
end
%% 13. get work from select strain iterations for many runs
xx=13;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;
    timePts=[2,2]; %start and end pts, iteration to consider as "zero point"
    
    % plot(s(ind).strain,s(ind).F);
    
    gammaAmt=sort(unique(spd),'ascend');
    strAmt=sort(unique(SD),'ascend');
    
    %     strF=struct; %strainFinal
    %     strFerr;
    
    velM=0;
    for i=1:length(gammaAmt)
        %I want to find number of SD's for for the given gamma I'm
        %searching
        a=find(spd==gammaAmt(i));
        usd=sort(unique([usedS(a).SD]),'ascend'); %number of unique SD for a certain gamma
        strM=zeros(size(usd));
        strE=zeros(size(usd));
        wkM=zeros(size(usd));
        wkE=zeros(size(usd));
        
        for j=1:length(usd)
            %             [type,SD,H,del,spd,it,v]=separateVec(fpars,1);
            ids=find(fpars(:,2)==usd(j)&fpars(:,5)==gammaAmt(i));
            strMax=zeros(size(ids));
            tArea=zeros(size(ids));
            velMax=zeros(size(ids));
            for k=1:length(ids)
                R=usedS(ids(k)); %to shorten eqns
                time2useS=R.dsPts((timePts(1)*4+1),3);%4 points per iteration
                time2useE=R.dsPts(timePts(2)*4+4,3);
                
                x=R.strain(time2useS:time2useE);
                y=R.F(time2useS:time2useE)';
                x=x-x(1);%zero at start iteration
                y=y-y(1);
                
                tArea(k)=trapz(x,y);
                strMax(k)=max(R.strain);
                
                L=diff(R.chain,1,2);
                velMax(k)=max(R.vel*L(1));
            end
            strM(j)=mean(strMax);
            strE(j)=std(strMax);
            wkM(j)=mean(tArea);
            wkE(j)=std(tArea);
            velM(j,i)=mean(velMax);
        end
        errorbar(strM,wkM,-wkE,wkE,-strE,strE);
    end
    
    xlabel('Strain $\varepsilon$','interpreter','latex');
    ylabel('Work (F $\varepsilon$])','interpreter','latex');
    legz={};
    velM=round(mean(velM,1),3)*100;
    for(i=1:length(velM))
        legz(i)={['$\dot{\varepsilon}$=',num2str(velM(i),2),' cm/s']};
    end
    l=legend(legz,'interpreter','latex');
    axis([0.05,.25,0,.12]);
    figText(gcf,18)
    l.FontSize=12;
end
%% 14. get work vs strain rate for many runs
xx=14;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    %     ind=2;
    timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    % plot(s(ind).strain,s(ind).F);
    
    gammaAmt=sort(unique(spd),'ascend');
    strAmt=sort(unique(SD),'ascend');
    
    %     strF=struct; %strainFinal
    %     strFerr;
    
    sM=0;
    for i=1:length(strAmt)
        %I want to find number of SD's for for the given gamma I'm
        %searching
        a=find(SD==strAmt(i));
        uspd=sort(unique([usedS(a).spd]),'ascend'); %number of unique spd for a certain strain
        
        wkM=zeros(size(uspd));
        wkE=zeros(size(uspd));
        velM=zeros(size(uspd));
        velE=zeros(size(uspd));
        
        for j=1:length(uspd)
            %             [type,SD,H,del,spd,it,v]=separateVec(fpars,1);
            ids=find(fpars(:,5)==uspd(j)&fpars(:,2)==strAmt(i));
            velMax=zeros(size(ids));
            tArea=zeros(size(ids));
            strMax=zeros(size(ids));
            for k=1:length(ids)
           
                R=usedS(ids(k));
                time2useS=R.dsPts(timePts(1)*4+1,3);%4 points per iteration
                time2useE=R.dsPts(timePts(2)*4+4,3);
                x=R.rob(time2useS:time2useE);
                y=R.F(time2useS:time2useE)';
                tt=R.t(time2useS:time2useE);
                
                %                 x=x-x(1);%zero at start iteration
                %                 y=y-y(1);
%                 x=x-R.strain(1);%zero at start iteration
                x=x-x(1);%zero at start iteration
                y=y-y(1);
                
                
                tArea(k)=trapz(x,y);
%                 velMax(k)=max(R.vel);
%                 velMax(k)=max(diff(x)./diff(tt));
                velMax(k)=max(R.spd)
                strMax(k)=max(x);
            end
            velM(j)=mean(velMax);
            velE(j)=std(velMax);
            wkM(j)=mean(tArea);
            wkE(j)=std(tArea);
            sM(j,i)=mean(strMax);
        end
        
        errorbar(velM,wkM,-wkE,wkE,-velE,velE);
    end
    
    legz={};
    sM=round(mean(sM,1),3);
    for(i=1:length(sM))
        legz(i)={['$\varepsilon$=',num2str(sM(i),2)]};
    end
    
    xlabel('Strain Rate $\dot{\varepsilon}$','interpreter','latex');
    ylabel('Work ([F $\varepsilon$])','interpreter','latex');
    l=legend(legz,'interpreter','latex');
    figText(gcf,18)
    axis auto
    %     axis([0 .25 -.05 .15])
    l.FontSize=12;
%     ylim([0 0.2])
end
%% 15. elastic response vs strain
xx=15;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    % ind=2;
    tArea=zeros(uN,1);
    timePts=[2,2];
    strMax=0;
    legText={};
    gammaAmt=sort(unique(spd),'ascend');
    strAmt=sort(unique(SD),'ascend');
    
    %     strF=struct; %strainFinal
    %     strFerr;
    
    velM=zeros(length(usd),length(gammaAmt));
    for i=1:length(gammaAmt)
        %I want to find number of SD's for for the given gamma I'm
        %searching
        a=find(spd==gammaAmt(i));
        usd=sort(unique([usedS(a).SD]),'ascend'); %number of unique SD for a certain gamma
        kkM=zeros(size(usd));
        kkE=zeros(size(usd));
        smM=zeros(size(usd));
        smE=zeros(size(usd));
        
        for j=1:length(usd)
            %             [type,SD,H,del,spd,it,v]=separateVec(fpars,1);
            ids=find(fpars(:,2)==usd(j)&fpars(:,5)==gammaAmt(i));
            kk=zeros(size(ids));
            sm=zeros(size(ids));
            strMax=zeros(size(ids));
            for k=1:length(ids)
                R=usedS(ids(k)); %to shorten eqns
                time2useS=R.dsPts((timePts(1)*4+1),3);%4 points per iteration
                time2useE=R.dsPts(timePts(2)*4+4,3);
                x=R.strain(time2useS:time2useE);
                y=R.F(time2useS:time2useE)';
                
                x=x-x(1);%zero at start iteration
                y=y-y(1);
                
                %get index at middle of plateau of iteration interested in
                smidx=floor((R.dsPts(timePts(2)*4+4-1,3)+R.dsPts(timePts(2)*4+4-2,3))/2+1);
                smidx=smidx-time2useS;
                sm(k)=x(smidx);
                strMax=max(strMax,sm(k));
                kk(k)=y(smidx)/sm(k);
                
                %                 figure(100);
                %                 hold on;
                %                 h1(i)=plot(x,y);
                %                 h2(i)=plot([0,sm(k)],[0,y(smidx)],'k','linewidth',4);
                %                 h3(i)=plot([0,sm(k)],[0,y(smidx)],'color',h1(i).Color,'linewidth',2);
                %                 set(get(get(h1(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                %                 set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                %         %         set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                %         %         fill([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)],'k','facecolor','c')
                %
                L=diff(R.chain,1,2);
                velMax(k)=max(R.vel*L(1));
            end
            kkM(j)=mean(kk);
            kkE(j)=std(kk);
            smM(j)=mean(sm);
            smE(j)=std(sm);
            velM(j,i)=mean(velMax);
        end
        
        errorbar(smM,kkM,-kkE,kkE,-smE,smE);
    end
    legz=cell(size(gammaAmt));
    velM=round(mean(velM,1),3)*100;
    
    for(i=1:length(velM))
        legz(i)={['$\dot{\varepsilon}$=',num2str(velM(i),3),' cm/s']};
    end
    l=legend(legz,'interpreter','latex');
    xlabel('Strain $\varepsilon$','interpreter','latex');
    ylabel('k [$F/\varepsilon$]','interpreter','latex');
    figText(gcf,20)
    l.FontSize=12;
end
%% 16. elastic response vs strain rate
xx=16;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    % ind=2;
    tArea=zeros(uN,1);
    timePts=[2,2];
    strMax=0;
    legText={};
    gammaAmt=sort(unique(spd),'ascend');
    strAmt=sort(unique(SD),'ascend');
    warning('change smidx');
    %     strF=struct; %strainFinal
    %     strFerr;
%     uspd=unique(
%     sM=zeros(length(uspd),length(strAmt));
    for i=1:length(strAmt)
        %I want to find number of SD's for for the given gamma I'm
        %searching
        a=find(SD==strAmt(i));
        uspd=sort(unique([usedS(a).spd]),'ascend'); %number of unique SD for a certain gamma
        kkM=zeros(size(uspd));
        kkE=zeros(size(uspd));
        velM=zeros(size(uspd));
        velE=zeros(size(uspd));
        
        for j=1:length(uspd)
            %             [type,SD,H,del,spd,it,v]=separateVec(fpars,1);
            ids=find(fpars(:,5)==uspd(j)&fpars(:,2)==strAmt(i));
            kk=zeros(size(ids));
            sm=zeros(size(ids));
            strMax=zeros(size(ids));
            for k=1:length(ids)
                R=usedS(ids(k)); %to shorten eqns
                time2useS=R.dsPts((timePts(1)*4+1),3);%4 points per iteration
                time2useE=R.dsPts(timePts(2)*4+4,3);
                x=R.strain(time2useS:time2useE);
                y=R.F(time2useS:time2useE)';
                
                x=x-x(1);%zero at start iteration
                y=y-y(1);
                
                %get index at middle of plateau of iteration interested in
                smidx=floor((R.dsPts(timePts(2)*4+4-1,3)+R.dsPts(timePts(2)*4+4-2,3))/2+1);
                
                %                 smidx=floor((R.dsPts(timePts(2)*4-2,3)));
                smidx=smidx-time2useS;
                sm(k)=x(smidx);
                strMax(k)=max(R.strain);
                velMax(k)=max(R.vel);
                kk(k)=y(smidx)/sm(k);
                
                %                                 figure(100);
                %                                 hold on;
                %                                 h1(i)=plot(x,y);
                %                                 h2(i)=plot([0,sm(k)],[0,y(smidx)],'k','linewidth',4);
                %                                 h3(i)=plot([0,sm(k)],[0,y(smidx)],'color',h1(i).Color,'linewidth',2);
                %                                 set(get(get(h1(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                %                                 set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                %                         %         set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                %                         %         fill([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)],'k','facecolor','c')
                
                %
            end
            kkM(j)=mean(kk);
            kkE(j)=std(kk);
            velM(j)=mean(velMax);
            velE(j)=std(velMax);
            sM(j,i)=mean(strMax);
        end
        
        errorbar(velM,kkM,-kkE,kkE,-velE,velE);
    end
    legz=cell(size(strAmt));
    sM=round(mean(sM,1),3);
    for(i=1:length(sM))
        legz(i)={['$\varepsilon$=',num2str(sM(i),2)]};
    end
    l=legend(legz,'interpreter','latex');
    xlabel('Strain Rate $\dot{\varepsilon}$','interpreter','latex');
    ylabel('k [$F/\varepsilon$]','interpreter','latex');
    figText(gcf,20)
    l.FontSize=12;
    %     xlim([0,round(strMax,2)]);
    
end
%% 17. get force vs strain rate for many runs
xx=17;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    %     ind=2;
    timePts=[3,3]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    % plot(s(ind).strain,s(ind).F);
    
    gammaAmt=sort(unique(spd),'ascend');
    strAmt=sort(unique(SD),'ascend');
    
    %     strF=struct; %strainFinal
    %     strFerr;
    
    
    strMax=0;
    sM=0;%zeros(length(uspd),length(strAmt));
    for i=1:length(strAmt)
        %I want to find number of SD's for for the given gamma I'm
        %searching
        a=find(SD==strAmt(i));
        uspd=sort(unique([usedS(a).spd]),'ascend'); %number of unique spd for a certain strain
        
        fM=zeros(size(uspd));
        fE=zeros(size(uspd));
        velM=zeros(size(uspd));
        velE=zeros(size(uspd));
        
        for j=1:length(uspd)
            %             [type,SD,H,del,spd,it,v]=separateVec(fpars,1);
            ids=find(fpars(:,5)==uspd(j)&fpars(:,2)==strAmt(i));
            F=zeros(size(ids));
            tArea=zeros(size(ids));
            strMax=zeros(size(ids));
            for k=1:length(ids)
                R=usedS(ids(k));
                %                 time2useS=R.dsPts(((timePts(1))*4-3),3);%4 points per iteration
                %                 time2useE=R.dsPts(timePts(2)*4,3);
                time2useS=R.dsPts(timePts(1)*4+1,3);%4 points per iteration
                time2useE=R.dsPts(timePts(2)*4+4,3);
                
                topSectionS=R.dsPts(timePts(1)*4+1+1,3);
                topSectionE=R.dsPts(timePts(1)*4+4-1,3);
                x=R.strain(topSectionS:topSectionE);
                y=R.F(topSectionS:topSectionE)';
                
                %                 x=x-x(1);%zero at start iteration
                %                 y=y-y(1);
                x=x-R.strain(1);%zero at start iteration
                y=y-R.F(1);
                F(k)=mean(y);
                velMax(k)=max(R.vel);
                strMax(k)=max(R.strain);
            end
            velM(j)=mean(velMax);
            velE(j)=std(velMax);
            fM(j)=mean(F);
            fE(j)=std(F);
            sM(j,i)=mean(strMax);
        end
        
        errorbar(velM,fM,-fE,fE,-velE,velE);
    end
    
    legz={};
    sM=round(mean(sM,1),3);
    for(i=1:length(sM))
        legz(i)={['$\varepsilon$=',num2str(sM(i),2)]};
    end
    
    xlabel('Strain Rate $\dot{\varepsilon}$','interpreter','latex');
    ylabel('Force (N)','interpreter','latex');
    l=legend(legz,'interpreter','latex');
    figText(gcf,18)
    %     axis([0 .25 -.05 .15])
    axis auto;
    ylim([0 0.9])
    l.FontSize=12;
    warning('make sure to check what units velocity (velmax) is in check 18''s definition')
end

%% 18. force (max) vs strain
xx=18;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;
    timePts=[2,2]; %start and end pts, iteration to consider as "zero point"
    
    % plot(s(ind).strain,s(ind).F);
    
    gammaAmt=sort(unique(spd),'ascend');
    strAmt=sort(unique(SD),'ascend');
    
    %     strF=struct; %strainFinal
    %     strFerr;
    
    velM=0;%zeros(length(usd),length(gammaAmt));
    for i=1:length(gammaAmt)
        %I want to find number of SD's for for the given gamma I'm
        %searching
        a=find(spd==gammaAmt(i));
        usd=sort(unique([usedS(a).SD]),'ascend'); %number of unique SD for a certain gamma
        strM=zeros(size(usd));
        strE=zeros(size(usd));
        wkM=zeros(size(usd));
        wkE=zeros(size(usd));
        for j=1:length(usd)
            %             [type,SD,H,del,spd,it,v]=separateVec(fpars,1);
            ids=find(fpars(:,2)==usd(j)&fpars(:,5)==gammaAmt(i));
            strMax=zeros(size(ids));
            F=zeros(size(ids));
            for k=1:length(ids)
                                R=usedS(ids(k));
                %                 time2useS=R.dsPts(((timePts(1))*4-3),3);%4 points per iteration
                %                 time2useE=R.dsPts(timePts(2)*4,3);
                time2useS=R.dsPts(timePts(1)*4+1,3);%4 points per iteration
                time2useE=R.dsPts(timePts(2)*4+4,3);
                
                topSectionS=R.dsPts(timePts(1)*4+1+1,3);
                topSectionE=R.dsPts(timePts(1)*4+4-1,3);
                x=R.strain(topSectionS:topSectionE);
                y=R.F(topSectionS:topSectionE)';
                
                %                 x=x-x(1);%zero at start iteration
                %                 y=y-y(1);
                x=x-R.strain(1);%zero at start iteration
                y=y-R.F(1);
                F(k)=mean(y);
%                 velMax(k)=max(R.vel);
                strMax(k)=mean(x);
                
                
                
               
%                 
%                 L=diff(R.chain,1,2);
%                 velMax(k)=max(R.vel*L(1));
            end
            strM(j)=mean(strMax);
            strE(j)=std(strMax);
            fM(j)=mean(F);
            fE(j)=std(F);
            velM(j,i)=mean(velMax);
        end
        errorbar(strM,fM,-fE,fE,-strE,strE);
    end
    
    xlabel('Strain $\varepsilon$','interpreter','latex');
    ylabel('Force (N))','interpreter','latex');
    legz={};
    velM=round(mean(velM,1),3)*100;
    for(i=1:length(velM))
        legz(i)={['$\dot{\varepsilon}$=',num2str(velM(i),2),' cm/s']};
    end
    l=legend(legz,'interpreter','latex');
    axis([0.05,.25,-.1,.12]);
    figText(gcf,18)
    l.FontSize=12;
end
%% 19. redone work vs strain rate
xx=19;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    spds=unique([usedS(:).spd]);
    startIt=3; %iteration to consider as "zero point"
    timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    % plot(s(ind).strain,s(ind).F);
    
    
    for i=1:length(spds)
        pts('F vs. Strain for ',usedS(i).name);
        currSpds=find([usedS(:).spd]==spds(i));
        dspts={usedS(currSpds).dsPts};
        stpt=min(cellfun(@(x) x(timePts(1)*4+1,3),dspts));
        edpt=min(cellfun(@(x) x(timePts(2)*4+4,3),dspts));
        [mforce,mstrainz,ef]=deal(zeros(edpt-stpt+1,length(spds)));
        %         minT=min(cellfun(@(x) size(x,1),{usedS(currSpds).t}));
        strainz=[];
        forcez=[];
        for j=1:length(currSpds)
            strainz(:,j)=usedS(currSpds(j)).strain(stpt:edpt);
            forcez(:,j)=usedS(currSpds(j)).F(stpt:edpt);
            tArea(i,j)=trapz(strainz(:,j),forcez(:,j));
        end
        
    end
    mArea=mean(tArea,2);
    eArea=std(tArea,0,2);
    
    
    errorbar(spds,mArea,eArea,'linewidth',2);
    
    text(0.4,0.9,['\epsilon=',num2str(usedS(1).SD),'mm'],'units','normalized')
    
    xlabel('Strain');
    ylabel('Force (N)');
    figText(gcf,18)
end
%% 20. apparatus strain
xx=20;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    for(i=1:uN)
    pts(usedS(i).name);
    hold on;
    plot(usedS(i).t,usedS(i).rob)
    plot(usedS(i).t,usedS(i).chain(:,1))
    plot(usedS(i).t,usedS(i).chain(:,2))
%     pause
    end
    
    xlabel('time (s)','fontsize',18);
    ylabel('strain ','fontsize',18);
    
    
    figText(gcf,16)
end
%% 55. old force vs h data
xx=55;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    conf=[9.5,10,10.5 11,12];
    F95 =[1.1680    1.2010    1.5190    1.4040    1.2600];
    F10 =[1.1860    1.1430    1.0020    1.3490    1.1540];
    F105=[0.8340    1.0280    1.0430    0.8590    1.1470];
    F11 =[1.0010    0.8800    1.0260    1.0470    0.9770];
    FUn =[0.7960    0.7290    0.7140    0.6430    0.9770];
    
    FAll=[F95;F10;F105;F11;FUn];
    fm=mean(FAll,2);
    ferr=std(FAll,1,2);
    errorbar(conf,fm,ferr,'linewidth',2);
    
    xlabel('Width (smarticle widths)','fontsize',18);
    ylabel('Force (N)','fontsize',18);
    xlim([9.4,12.1]);
    figText(gcf,16);
end
% i=24;plot(s(i).strain);hold on; plot(s(i).dsPts(:,3),s(i).dsPts(:,2),'o');
