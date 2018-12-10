% has much of same plots as plotChainForce.m except this is for systems
% with markers on robot arm, first and last smarticle

%************************************************************
%* Fig numbers:
%* 1. force vs time with strain overlay
%* 2. plot comparison b/w activated system and regular, Force vs. Time
%* 3. plot single Force vs. Strain
%* 4. plot comparison b/w activated system and regular, Force vs. Strain
%* 5. plot force vs. time for all usedS
%* 6. plot Force vs. Strain for usedS
%* 7. plot force vs. strain for usedS with slope bar
%* 8. find and save fracture point
%* 9. plot fracture force vs height and strain vs height
%*10. plot max recorded force on fracture runs
%*11. plot select iterations of strain for single run
%*12. get work from select strain iteration for single run
%*13. get work from select strain iterations for many runs
%*14. get work vs strain rate for many runs
%*15. elastic response vs strain
%*16. elastic response vs strain rate
%*17. force (max) vs strain rate
%*18. force (max) vs strain
%*19. redone work vs strain rate
%*20. apparatus strain
%*21. measure k continuously over course of strain
%*22. another way to do k
%*23. fft of force for SAC trials
%*24. plot force vs strain for fracture
%*25. work vs strain rate each line is different strain
%*26. plot single trial reversability
%*27. plot multitrial  at single SD and SPEED reversability
%*28. plot single cycle multispd reversability
%*29. plot single cycle multisd reversability
%*30. plot para and perp movement vs time
%*55. old force vs H data
%************************************************************
% clearvars -except t
% close all;
clearvars -except kdat LEG1 LEG2;

% maxSpeed= 1.016; %m/s
% pctSpeed=.0173;
% speed=pctSpeed*maxSpeed;
samp=1000; %samples per sec Hz rate for polling F/T sensor
[fb,fa]=butter(6,2/(samp/2),'low');
smartWid=6.2;%centerlink back to arm tip
lams=[0 1.75 2.25 4.15 7.3 17.15]./29.29;

% fold=uigetdir('A:\2DSmartData\entangledData\4-17');
fold=uigetdir('A:\2DSmartData\entangledData\LastRuns\N=6\');
% % fold=uigetdir('A:\2DSmartData\entangledData\11-30 multimarker');
% fold='A:\2DSmartData\entangledData\12-19 multimark SAC w=10 weaker';
% fold='A:\2DSmartData\entangledData\before 11-30 (multimarkers)';
% fold='A:\2DSmartData\entangledData\4-11 multimarker';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filtz=1;
fractD=0;%flag for fractData
% showFigs=[8 9 10];
showFigs=[30];
%19
indx=2;% 8
% showFigs=[5];
tpt=[1 1];

% strains=[65]/1000;
% types=[]; strains=[85]/1000; Hs=[]; dels=[]; spds=[]; its=[]; vs=[];
types=[]; strains=[]; Hs=[]; dels=[]; spds=[]; its=[]; vs=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if (~exist(fullfile(fold,'dataOut.mat'),'file') && ~exist(fullfile(fold,'fractData.mat'),'file'))
    filez=dir2(fullfile(fold,'Stretch*'));
    N=length(filez);
    allFpars=zeros(N,7); % [type,SD,H,del,spd,its,v]
    s=struct;
    for i=1:N
        pts(i,'/',N);
        [allFpars(i,:),s(i).t,s(i).strain,s(i).F,s(i).Fa,L,s(i).rob,s(i).chain,s(i).dsPts, s(i).vel,s(i).zop,s(i).xop,s(i).smartPos]=...
            analyzeEntangleFileMM(fold,filez(i).name,samp,0);
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
            %             s(i).F=filter(fb,fa,s(i).F);  %filtered signal
            %             s(i).F=lowpass(,s(i).F,samps);  %filtered signal
            s(i).F=lowpass(s(i).F,3,samp,'impulseresponse','iir');
            
            %             s(i).F=lowpass(s(i).F,3,samp);
        end
        usedS(indcnt)=s(i);
        indcnt=indcnt+1;
    end
end
if ~exist('usedS','var')
    error('No file with specified parameters exists in folder');
end
clear s;
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
    %     ind=1;
    ind=1;
    unitless=0;
    overlayStrain=1;
    %     t=downsample(s(ind).t,10);
    %     f=downsample(s(ind).F,10);
    %     st=downsample(s(ind).strain,10);
    pts('F vs. T for ',s(ind).name);
    
    
    plot(s(ind).t,s(ind).F);
    maxF=max(s(ind).F);
    maxS=max(s(ind).strain);
    
    %     plot(t,f);
    %     maxF=max(f);
    %     maxS=max(st);
    if(overlayStrain)
        h=plot(s(ind).t,maxF*s(ind).strain/max(s(ind).strain));
        %         h=plot(t,maxF*st);
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
    unitless=0;
    coloredLine=1;
    xl='';
    ind=indx;
    
    
    % 	t=downsample(s(ind).t,10);
    %     f=downsample(s(ind).F,10);
    
    pts('F vs. Strain for ',usedS(ind).name);
    %     plot(s(ind).strain,s(ind).F);
    %     ff=usedS(ind).F;
    %     ss=usedS(ind).strain;
    %     ff1=filter(fb,fa,ff);  %filtered signal
    
    if(unitless)
        x=usedS(ind).strain;
    else
        x=usedS(ind).chain(:,2)*1000;
        xl=' (mm)';
    end
    if(coloredLine)
        colormapline(x,usedS(ind).F,[],jet(100));
    else
        plot(x,usedS(ind).F,[],'-');
    end
    %     colormapline(st,f,[],jet(100));
    xlabel(['Strain' xl]);
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
        hold on;
        maxF(i)=max(usedS(i).F);
        maxS(i)=max(usedS(i).strain);
        
        if(overlayStrain)
            %             h2(i)=plot(usedS(i).t,maxF(i)*usedS(i).strain/maxS(i),'k','linewidth',4);
            h3(i)=plot(usedS(i).t,maxF(i)*usedS(i).strain/maxS(i),'linewidth',2);
            legend({'Force','Scaled Strain'},'location','south')
            %             set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            set(get(get(h3(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            
        end
        xlabel('time (s)','fontsize',18);
        ylabel('force (N)','fontsize',18);
        %         pts(usedS(i).name);
        text(.1,.3,['sd=',num2str(fpars(i,2)),' spd=',num2str(fpars(i,5)),...
            ' v=',num2str(fpars(i,7))],'units','normalized')
        pause
        clf;
        
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
    xl='';
    [speed,tArea,frc]=deal(zeros(uN,1));
    tArea=zeros(uN,1);
    speed=zeros(uN,1);
    strMax=0;
    spds=unique([usedS(:).spd]);
    timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    % plot(s(ind).strain,s(ind).F);
    
    ds=10; %downsample amount
    unitless=0;
    for i=1:length(spds)
        
        currSpds=find([usedS(:).spd]==spds(i));
        dspts={usedS(currSpds).dsPts};
        stpts=cellfun(@(x) x(timePts(1)*4+1,3),dspts);
        edpts=cellfun(@(x) x(timePts(2)*4+4,3),dspts);
        [mm,ID]=min(edpts-stpts);
        edpts=edpts-(edpts-stpts-mm);
        [mforce,mstrainz,ef]=deal(zeros(mm+1,length(spds)));
        %         minT=min(cellfun(@(x) size(x,1),{usedS(currSpds).t}));
        strainz=[];
        forcez=[];
        pause; hold on;
        for j=1:length(currSpds)
            if(unitless)
                strainz(:,j)=usedS(currSpds(j)).strain(stpts(j):edpts(j));
            else
                strainz(:,j)=usedS(currSpds(j)).chain(stpts(j):edpts(j),2)*1000;
                xl=' (mm)';
            end
            
            forcez(:,j)=usedS(currSpds(j)).F(stpts(j):edpts(j));
            forcez(:,j)=forcez(:,j)-min(forcez(:,j));
            strainz(:,j)=strainz(:,j)-strainz(1,j);
            %             plot(strainz(:,j),forcez(:,j));
        end
        pts({usedS(currSpds).name}');
        mforce(:,i)=mean(forcez,2);
        mstrainz(:,i)=mean(strainz,2);
        ef(:,i)=std(forcez,0,2);
        %         plot(mstrainz(:,i),mforce(:,i));
        if(ds)
            shadedErrorBar(downsample(mstrainz(:,i),10),downsample(mforce(:,i),10),downsample(ef(:,i),10),{'linewidth',2},.5);
        else
            shadedErrorBar(mstrainz(:,i),mforce(:,i),ef(:,i),{'linewidth',2},.5);
        end
        
        
        legT{i}=['$\dot{\epsilon}$=',num2str(spds(i)),'mm/s'];
        
    end
    legend(legT,'interpreter','latex');
    %     text(0.4,0.9,['\epsilon=',num2str(usedS(1).SD),'mm'],'units','normalized')
    
    xlabel(['Strain' xl]);
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
    timePts=[0,0]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    for(i=uN:-1:1)
        
        stpt=usedS(i).dsPts(timePts(1)*4,3);
        edpt=usedS(i).dsPts(timePts(2)*4+2,3);
        %         edpt=floor(mean(usedS(i).dsPts([timePts(2)*4+4:timePts(2)*4+5],3)));
        %         edpt=usedS(i).dsPts(timePts(2)*4+4,3);
        strain=usedS(i).strain(stpt:edpt)-usedS(i).strain(stpt);
        frc=usedS(i).F(stpt:edpt)-min(usedS(i).F(stpt:edpt));
        
        pts('F vs. Strain for ',usedS(i).name);
        %         h1(i)=plot(usedS(i).strain(stpt:edpt),usedS(i).F(stpt:edpt));
        h1(i)=plot(strain,frc);
        %             colormapline(usedS(i).strain,usedS(i).F,[],jet(100));
        %         tArea(i)=trapz(usedS(i).strain,usedS(i).F);
        %         A(i)=polyarea([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)]);
        [sm(i),smidx]=max(strain);
        strMax=max(strMax,sm(i));
        
        h2(i)=plot([0,sm(i)],[0,frc(smidx)],'k','linewidth',4);
        h3(i)=plot([0,sm(i)],[0,frc(smidx)],'color',h1(i).Color,'linewidth',2);
        
        set(get(get(h1(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        %         set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        %         fill([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)],'k','facecolor','c')
        k(i)=frc(smidx)/sm(i);
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
    kdat=[kdat;[mean(sm),std(sm),mean(k),std(k)]];
    %     errorbar(kdat(:,1),kdat(:,3),kdat(:,4),kdat(:,4),kdat(:,2),kdat(:,2))
end
%% 8. find and save fracture point
xx=8;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    % ind=2;
    if exist(fullfile(fold,'fractData.mat'),'file')
        pts('fractData already exists');
    else
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
            
            %%%%adding negative value from bias problem
            [~,fracNeg,~,~]=MagnetGInput(h,1,1);
            fracFmax=fracFmax+abs(fracNeg);
            fractData(i).F=fractData(i).F+abs(fracNeg);
            %%%%
            
            
            fractData(i).fracStrainMax=fracStrainMax;
            fractData(i).fracFmax=fracFmax;
            fractData(i).fracInd=fracInd;
            [fMax,maxInd]=max(fractData(i).F);
            fractData(i).maxInd=maxInd;
            fractData(i).fMax=fMax;
            fractData(i).maxFStrain=usedS(i).strain(maxInd);
            %         plot(usedS(i).strain(1:ind),usedS(i).F(1:ind));
            pts(i,'/',uN);
            pause();
        end
        save(fullfile(fold,'fractData.mat'),'fractData');
    end
end
%% 9. plot fracture force vs height and strain vs height
xx=9;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    
    %     smartWid=9.1; %cm %%I think this width of the center links of a 2
    %     smarticle chain?
    unitless=0;
    xl='';
    
    
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
            %             h(j)=usedS(inds(j)).rob(fractData(inds(j)).fracInd)*100;
            if(unitless)
                h(j)=fractData(inds(j)).fracStrainMax;
            else
                h(j)=usedS(inds(j)).chain(fractData(inds(j)).fracInd,2)*1000;
                xl=' (mm)';
            end
            
        end
        uS(i)={h};
        %%%%
        
        %         uS(i)={[fractData(inds).fracStrainMax]};
        uFm(i)=mean(uF{i});
        uFerr(i)=std(uF{i});
        uSm(i)=mean(uS{i});
        uSerr(i)=std(uS{i});
    end
    
    
    hold on;
    title('Force at Fracture');
    errorbar(smartWid./uH,uFm,uFerr,'linewidth',2);
    ylabel('Force (N)');
    xlabel('Confinement fraction');
    %     xlabel('\lambda_i');
    figText(gcf,16)
    axis tight;
    
    figure(100);
    hold on;
    title('Strain at Fracture');
    errorbar(smartWid./uH,uSm,uSerr,'linewidth',2);
    ylabel(['Strain' xl]);
    xlabel('Confinement Fraction');
    %     xlabel('\lambda_i');
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
    ind=5;
    timePts=[0,0]; %iteration to consider as "zero point"
    
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
    timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    
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
    %     axis([0.05,.25,0,.12]);
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
                x=R.strain(time2useS:time2useE);
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
                velMax(k)=max(R.spd);
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
    timePts=[3,3]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    strMax=0;
    legText={};
    gammaAmt=sort(unique(spd),'ascend');
    strAmt=sort(unique(SD),'ascend');
    
    %     strF=struct; %strainFinal
    %     strFerr;
    
    %     velM=zeros(length(usd),length(gammaAmt));
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
    timePts=[3,3]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    strMax=0;
    legText={};
    gammaAmt=sort(unique(spd),'ascend');
    strAmt=sort(unique(SD),'ascend');
    warning('change smidx');
    yl='';
    unitless=0;
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
                time2useS=R.dsPts(timePts(1)*4+1,3);%4 points per iteration
                time2useE=R.dsPts(timePts(2)*4+2,3);
                
                if(unitless)
                    x=R.strain(time2useS:time2useE);
                    v=R.vel;
                else
                    x=R.chain(time2useS:time2useE,2)*1000;
                    
                    ptspan=R.dsPts(1:2,3);
                    %calc speed from middle points of first strain cycle
                    ptspan(1)=round(ptspan(2)/4);
                    ptspan(2)=round(3*ptspan(1));
                    v=diff(R.chain(ptspan,2)*1000)./diff(R.t(ptspan));
                    yl=' (mm/s)';
                end
                y=R.F(time2useS:time2useE-200)';
                
                x=x-x(1);%zero at start iteration
                %                 y=y-y(1);
                
                %get index at middle of plateau of iteration interested in
                %                 samp=diff(R.t(1:2));
                %                 smidx=time2useE+round(R.del/samp/2);%add half of delay to end of strain cycle
                
                %                 smidx=floor((R.dsPts(timePts(2)*4-2,3)));
                %                 smIdx=
                %                 smidx=smidx-time2useS;
                sm(k)=x(end);
                strMax(k)=max(x);
                velMax(k)=v;
                kk(k)=y(end)/x(end);
                
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
    totArea={};
    timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    % plot(s(ind).strain,s(ind).F);
    
    %%%%%%%%%%%%%%%%%
    %                     R=usedS(ids(k));
    %
    %                 time2useS=R.dsPts(timePts(1)*4+1,3);%4 points per iteration
    %                 time2useE=R.dsPts(timePts(2)*4+4,3);
    %                 x=R.strain(time2useS:time2useE);
    %                 y=R.F(time2useS:time2useE)';
    %                 tt=R.t(time2useS:time2useE);
    %
    %                 %                 x=x-x(1);%zero at start iteration
    %                 %                 y=y-y(1);
    %                 %                 x=x-R.strain(1);%zero at start iteration
    %                 x=x-x(1);%zero at start iteration
    %                 y=y-y(1);
    %
    %
    %                 tArea(k)=trapz(x,y);
    %                 %                 velMax(k)=max(R.vel);
    %                 %                 velMax(k)=max(diff(x)./diff(tt));
    %                 velMax(k)=max(R.spd);
    %                 strMax(k)=max(x);
    %%%%%%%%%%%%%%%%%
    for i=1:length(spds)
        pts('F vs. Strain for ',usedS(i).name);
        currSpds=find([usedS(:).spd]==spds(i));
        dspts={usedS(currSpds).dsPts};
        
        stpts=cellfun(@(x) x(timePts(1)*4+1,3),dspts);
        edpts=cellfun(@(x) x(timePts(2)*4+4,3),dspts);
        [mm,ID]=min(edpts-stpts);
        edpts=edpts-(edpts-stpts-mm);
        
        %         stpt=min(cellfun(@(x) x(timePts(1)*4+1,3),dspts));
        %         edpt=min(cellfun(@(x) x(timePts(2)*4+4,3),dspts));
        [mforce,mstrainz,ef]=deal(zeros(mm+1,length(spds)));
        %         minT=min(cellfun(@(x) size(x,1),{usedS(currSpds).t}));
        strainz=[];
        forcez=[];
        tArea=[];
        for j=1:length(currSpds)
            strainz(:,j)=usedS(currSpds(j)).strain(stpts(j):edpts(j)).*diff(usedS(currSpds(j)).chain(stpts(j):edpts(j),:),1,2);
            forcez(:,j)=usedS(currSpds(j)).F(stpts(j):edpts(j));
            %             tArea(i,j)=trapz(strainz(:,j),forcez(:,j));
            tArea(j)=trapz(strainz(:,j),forcez(:,j));
        end
        totArea{i}=tArea;
    end
    %     mArea=mean(tArea,2);
    %     eArea=std(tArea,0,2);
    mArea=cellfun(@mean,totArea);
    eArea=cellfun(@std,totArea);
    
    errorbar(spds,mArea,eArea,'linewidth',2);
    
    text(0.4,0.9,['\epsilon=',num2str(usedS(1).SD),'mm'],'units','normalized')
    
    xlabel('Strain rate');
    ylabel('Work N mm');
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
%% 21. measure k continuously over course of strain
xx=21;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    subplot(1,2,1)
    hold on;
    % ind=2;
    %     tArea=zeros(uN,1);
    strMax=0;
    legText={};
    timePts=[0,0]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    
    for(i=uN:-1:1)
        figure(xx);
        hold off;
        stpt=usedS(i).dsPts(timePts(1)*4+1,3);
        edpt=usedS(i).dsPts(timePts(2)*4+2,3)-300;
        stpt=floor((edpt-stpt)/2+stpt);
        strain=usedS(i).strain(stpt:edpt)-usedS(i).strain(stpt);
        frc=usedS(i).F(stpt:edpt)-usedS(i).F(stpt);
        
        pts('F vs. Strain for ',usedS(i).name);
        %         h1(i)=plot(usedS(i).strain(stpt:edpt),usedS(i).F(stpt:edpt));
        h1(i)=plot(usedS(i).strain-usedS(i).strain(stpt),usedS(i).F-usedS(i).F(stpt),'linewidth',0.5);
        hold on;
        plot(strain,frc,'linewidth',2);
        
        %             colormapline(usedS(i).strain,usedS(i).F,[],jet(100));
        %         tArea(i)=trapz(usedS(i).strain,usedS(i).F);
        %         A(i)=polyarea([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)]);
        
        
        [sm(i),smidx]=max(strain);
        strMax=max(strMax,sm(i));
        %         figure(124);
        %         hold on;
        k{i}=diff(frc)./diff(strain');
        E(i)=(frc(end)-frc(1))/(strain(end)-strain(1));
        %         plot(strain(1:end-1), k{i});
        
        
    end
    figure(124);
    hold on;
    minLen=min(cellfun(@length,k,'UniformOutput',1));
    nk=zeros(minLen,length(k));
    for(i=1:length(k))
        nk(:,i)=k{i}(1:minLen);
    end
    plot(mean(nk,2,'omitnan'));
    
    [mean(E) mean(mean(nk))]
    
    %     legend(legText);
    %     xlabel('Strain');
    %     ylabel('Force (N)');
    %     figText(gcf,20)
    %     axis([0,round(strMax,2),-0.4,0.8]);
    %
    %     subplot(1,2,2)
    %     hold on;
    %     xlabel('Strain');
    %     ylabel('k');
    %     figText(gcf,20);
    %     plot(sm,k,'-o','linewidth',2,'markerfacecolor','w')
    %     kdat=[kdat;[mean(sm),std(sm),mean(k),std(k)]];
    %     errorbar(kdat(:,1),kdat(:,3),kdat(:,4),kdat(:,4),kdat(:,2),kdat(:,2))
end
%% 22. another way to do k
xx=22;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    % ind=2;
    %     tArea=zeros(uN,1);
    strMax=0;
    legText={};
    timePts=[0,0]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    
    spds=unique([usedS(:).spd]);
    timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    % plot(s(ind).strain,s(ind).F);
    
    kval={};
    for i=1:length(spds)
        
        currSpds=find([usedS(:).spd]==spds(i));
        dspts={usedS(currSpds).dsPts};
        stpts=cellfun(@(x) x(timePts(1)*4+1,3),dspts);
        edpts=cellfun(@(x) x(timePts(2)*4+4,3),dspts);
        [mm,ID]=min(edpts-stpts);
        edpts=edpts-(edpts-stpts-mm);
        
        %         stpt=min(cellfun(@(x) x(timePts(1)*4+1,3),dspts));
        %         edpt=min(cellfun(@(x) x(timePts(2)*4+2,3)-300,dspts));
        %         stpt=floor((edpt-stpt)/2+stpt);
        %         strain=usedS(i).strain(stpt:edpt)-usedS(i).strain(stpt);
        
        %         minT=min(cellfun(@(x) size(x,1),{usedS(currSpds).t}));
        strainz=[];
        forcez=[];
        for j=1:length(currSpds)
            s=usedS(currSpds(j)).strain;
            f=usedS(currSpds(j)).F;
            %             s=s-s(1); f=f-f(1);
            strainz(:,j)=s(stpts(j):edpts(j));
            forcez(:,j)=f(stpts(j):edpts(j));
            forcez(:,j)=forcez(:,j);
            strainz(:,j)=strainz(:,j);
            kval{i}(j,:)=polyfit(strainz(:,j),forcez(:,j),1);
        end
        
        %         @f=polyfit(forcez,strainz,1);
        k2{i}=diff(forcez)./diff(strainz);
        E2(i,:)=(forcez(end,:)-forcez(1,:))./(strainz(end,:)-strainz(1,:));
        
    end
    km=cell2mat(cellfun(@mean,kval,'uniformOutput',0)');
    kerr=cell2mat(cellfun(@std,kval,'uniformOutput',0)');
    errorbar(spds,km(:,1),kerr(:,1),'linewidth',2);
    errorbar(spds,2*km(:,2),kerr(:,2),'linewidth',2);
    
    xlabel('strain rate');
    
    %
    %
    %         k{i}=diff(frc)./diff(strain');
    %         E(i)=(frc(end)-frc(1))/(strain(end)-strain(1));
    % figure(124);
    % hold on;
    %    minLen=min(cellfun(@length,k,'UniformOutput',1));
    %    nk=zeros(minLen,length(k));
    %    for(i=1:length(k))
    %         nk(:,i)=k{i}(1:minLen);
    %    end
    %    plot(mean(nk,2,'omitnan'));
    
end
%% 23. fft of force for SAC trials
xx=23;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    
    dat=usedS(1);
    t = dat.t;        % Time vector
    %     lowpass(dat.F,.01,fs)
    lowpass(s(i).F,2,samp,'ImpulseResponse','iir');
    % figure(400)
    % title('unfilt');
    % hold on;
    % plot(dat.t,dat.F)
    
    %
    %
    %            dat=usedS(1);
    %             Fs = 1/diff(dat.t(1:2));          % Sampling frequency
    %             t = dat.t;        % Time vector
    %             L = length(t);             % Length of signal
    %             T = 1/Fs;             % Sampling period
    %
    %             X=dat.F;
    %     %         X=sin(2*pi*1.5*t)+2*t;
    %             k=(X(end)-X(1))/(t(end)-t(1));
    %             X2=X-k.*t;
    %             Y=fft(X2);
    %
    %             P2 = abs(Y/L);
    %             P1 = P2(1:L/2+1);
    %             P1(2:end-1) = 2*P1(2:end-1);
    %             f = Fs*(0:(L/2))/L;
    %             plot(f,P1);
    %             title('Single-Sided Amplitude Spectrum of X(t)')
    %             xlabel('f (Hz)')
    %             ylabel('|P1(f)|')
    
    
    %
end

%% 24. plot force vs strain for fracture
xx=24;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    unitless=0;
    xl='';
    ind=[12];
    
    
    
    
    for(i=1:length(ind))
        ii=ind(i);
        pts('F vs. Strain for ',usedS(ii).name,' ind= ', ii);
        endInd=fractData(ii).fracInd+1000;
        if(unitless)
            x=usedS(ii).strain(1:endInd);
        else
            x=usedS(ii).chain(1:endInd,2)*1000;
            xl=' (mm)';
        end
        
        h=plot(x,usedS(ii).F(1:endInd),'-');
        text(0.1,i/(length(ind)+2),['h/H=',num2str(smartWid./usedS(ii).H,2)],'units','normalized','color',h.Color)
    end
    %     colormapline(st,f,[],jet(100));
    xlabel(['Strain' xl]);
    ylabel('Force (N)');
    figText(gcf,18)
    
    %     figure(12312)
    %     colormapline(ss,ff1,[],jet(100));
    %     xlabel('Strain');
    %     ylabel('Force (N)');
    %     figText(gcf,18)
end

%% 25. redone work vs strain rate with diff lines for diff strains
xx=25;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    
    totArea={};
    timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    
    legZ={};
    strs=unique(SD);
    for(i=1:length(strs))
        sdIDs=find([usedS(:).SD]==strs(i))
        R=usedS(sdIDs);
        spds=unique([R.spd]);
        for(j=1:length(spds))
            
            currSpds=find([R(:).spd]==spds(j));
            dspts={R(currSpds).dsPts};
            stpts=cellfun(@(x) x(timePts(1)*4+1,3),dspts);
            edpts=cellfun(@(x) x(timePts(2)*4+4,3),dspts);
            [mm,ID]=min(edpts-stpts);
            edpts=edpts-(edpts-stpts-mm);
            [mforce,mstrainz,ef]=deal(zeros(mm+1,length(spds)));
            strainz=[];
            forcez=[];
            tArea=[];
            for k=1:length(currSpds)
                pts('F vs. Strain for ',R(currSpds(k)).name);
                strainz(:,k)=R(currSpds(k)).strain(stpts(k):edpts(k)).*diff(R(currSpds(k)).chain(stpts(k):edpts(k),:),1,2);
                forcez(:,k)=R(currSpds(k)).F(stpts(k):edpts(k));
                %             tArea(i,j)=trapz(strainz(:,j),forcez(:,j));
                tArea(k)=trapz(strainz(:,k),forcez(:,k));
            end
            totArea{j}=tArea;
        end
        mArea=cellfun(@mean,totArea);
        eArea=cellfun(@std,totArea);
        errorbar(spds,mArea,eArea,'linewidth',2);
        
        %get type and l value from filename
        [~,a,~]=fileparts(fold);
        [c,d]=parseFileNames(a);
        fp=string(c);
        Tval=d(fp=='T');
        lval=d(fp=='l');
        legz(i)={['T=',num2str(Tval), ' l=',num2str(lval),' SD=',num2str(strs(i)*1000),'mm']};
    end
    
    legend(legz);
    xlabel('Strain rate');
    ylabel('Work N mm');
    figText(gcf,18)
end

%% 26. plot single trial reversability
xx=26;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;
    totArea={};
    timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    
    R=usedS(ind);
    %convert to mm and center at 0
    spx=(R.smartPos.x-R.smartPos.x(1,1))*1000;
    spz=(R.smartPos.z-R.smartPos.z(1,1))*1000;
    
    
    % plot(usedS(ind).smartPos.z(:,S),usedS(ind).smartPos.x(:,S));
    
    ax1=subplot(2,2,[1 2]);
    
    ptSkip=10;
    %SPZ=parallel
    %SPX=perp
    plot(spz(1:ptSkip:end,:),spx(1:ptSkip:end,:))
    hold on;
    stpts=R.dsPts([0 1 2]*4+1,3);
    midspts=R.dsPts([0 1 2]*4+2,3);
    midepts=R.dsPts([0 1 2]*4+3,3);
    edpts=R.dsPts([0 1 2]*4+4,3);
    plot(spz(stpts,:),spx(stpts,:),'r.','markersize',10)
    plot(spz(midspts,:),spx(midspts,:),'g.','markersize',10)
    plot(spz(midepts,:),spx(midepts,:),'b.','markersize',10)
    plot(spz(edpts,:),spx(edpts,:),'k.','markersize',10)
    text(.08,0.9,'strain begin','color','r','units','normalized','fontsize',16)
    text(.08,0.84,'strain return','color','k','units','normalized','fontsize',16)
    xlabel('x (mm)')
    ylabel('y (mm)')
    
    ax2=subplot(2,2,3);
    hold on;
    %eventually change to number of smarticles via size of smartPos
    
    pks=[0:it(ind)/2-1]*4;
    
    res=zeros(6,it(ind)/2);%6 for number of smarts its/2 for cycles
    for(i=1:6)
        res(i,:)=spx(usedS(ind).dsPts([pks+4],3),i)-spx(usedS(ind).dsPts([pks+1],3),i);
    end
    bar(ax2,res)
    legend({'Cycle 1','Cycle 2', 'Cycle 3'});
    ylabel('\Delta(C(perp)) (mm)');
    xlabel('smarticle number')
    set(gca,'xticklabel',{'1' '2' '3' '4' '5' '6'},'xtick',[1:6])
    
    ax3=subplot(2,2,4);
    for(i=1:6)
        res(i,:)=spz(usedS(ind).dsPts([pks+4],3),i)-spz(usedS(ind).dsPts([pks+1],3),i);
    end
    barh(ax3,res)
    legend({'Cycle 1','Cycle 2', 'Cycle 3'});
    xlabel('\Delta(C(parallel)) (mm)');
    ylabel('smarticle number')
    set(gca,'yticklabel',{'1' '2' '3' '4' '5' '6'},'ytick',[1:6])
    
end

%% 27. plot multitrial  at single SD and SPEED reversability

xx=27;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    
    resz=zeros(6,it(1)/2);%6 for number of smarts its/2 for cycles
    resx=zeros(6,it(1)/2);%6 for number of smarts its/2 for cycles
    indxs=find(SD==0.06&spd==5);
    for ii=1:length(indxs)
        
        R=usedS(indxs(ii));
        %convert to mm and center at 0
        spx=(R.smartPos.x-R.smartPos.x(1,1))*1000;
        spz=(R.smartPos.z-R.smartPos.z(1,1))*1000;
        
        ax1=subplot(2,2,[1 2]);
        
        ptSkip=10;
        plot(spz(1:ptSkip:end,:),spx(1:ptSkip:end,:))
        hold on;
        stpts=R.dsPts([0 1 2]*4+1,3);
        midspts=R.dsPts([0 1 2]*4+2,3);
        midepts=R.dsPts([0 1 2]*4+3,3);
        edpts=R.dsPts([0 1 2]*4+4,3);
        plot(spz(stpts,:),spx(stpts,:),'r.','markersize',10)
        plot(spz(midspts,:),spx(midspts,:),'g.','markersize',10)
        plot(spz(midepts,:),spx(midepts,:),'b.','markersize',10)
        plot(spz(edpts,:),spx(edpts,:),'k.','markersize',10)
        text(.08,0.9,'strain begin','color','r','units','normalized','fontsize',16)
        text(.08,0.84,'strain return','color','k','units','normalized','fontsize',16)
        xlabel('x (mm)')
        ylabel('y (mm)')
        
        
        %eventually change to number of smarticles via size of smartPos
        
        pks=[0:R.its/2-1]*4;
        
        
        for(i=1:6)
            resz(i,:,ii)=spz(R.dsPts([pks+4],3),i)-spz(R.dsPts([pks+1],3),i);
        end
        
        for(i=1:6)
            resx(i,:,ii)=spx(R.dsPts([pks+4],3),i)-spx(R.dsPts([pks+1],3),i);
        end
    end
    mresZ=mean(resz,3);
    mresX=mean(resx,3);
    
    eresZ=std(resz,0,3);
    eresX=std(resx,0,3);
    
    ax2=subplot(1,2,1);
    hold on;
    %     bar(ax2,mresZ)
    for i=1:it(1)/2
        errorbar(ax2,1:6,mresZ(:,i),eresZ(:,i));
    end
    legend({'Cycle 1','Cycle 2', 'Cycle 3'});
    ylabel('\Delta(C(parallel)) (mm)');
    xlabel('smarticle number')
    set(gca,'xticklabel',{'1' '2' '3' '4' '5' '6'},'xtick',[1:6])
    figText(gcf,16);
    
    ax3=subplot(1,2,2);
    hold on;
    for i=1:it(1)/2
        errorbar(ax3,1:6,mresX(:,i),eresX(:,i));
    end
    %     barh(ax3,mresX)
    legend({'Cycle 1','Cycle 2', 'Cycle 3'});
    ylabel('\Delta(C(perp)) (mm)');
    xlabel('smarticle number')
    set(gca,'xticklabel',{'1' '2' '3' '4' '5' '6'},'xtick',[1:6])
    figText(gcf,16);
end
%% 28.  plot single cycle multispd reversability

xx=28;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    uvar=unique(spd);
    cycle=1;%1 2 or 3
%     cmap=brewermap(length(uspd),'rdylgn');
%     cmap=fire(length(uspd));
    sd=0.035;
    [~,a,~]=fileparts(fold);
    [c,d]=parseFileNames(a);
    
    cmap=jet(length(uvar));
    titlez=['T=',num2str(d(1)),' l=',num2str(d(2)),' cycle=',num2str(cycle),' sd=',num2str(sd*1000),'mm'];
    for jj=1:length(uvar)
        resz=zeros(6,it(1)/2);%6 for number of smarts its/2 for cycles
        resx=zeros(6,it(1)/2);%6 for number of smarts its/2 for cycles
        indxs=find(SD==sd&spd==uvar(jj));
        for ii=1:length(indxs)
            
            R=usedS(indxs(ii));
            %convert to mm and center at 0
            spx=(R.smartPos.x-R.smartPos.x(1,1))*1000;
            spz=(R.smartPos.z-R.smartPos.z(1,1))*1000;
            
            %eventually change to number of smarticles via size of smartPos
            
            pks=[0:R.its/2-1]*4;
            
            
            for(i=1:6)
                resz(i,:,ii)=spz(R.dsPts([pks+4],3),i)-spz(R.dsPts([pks+1],3),i);
            end
            
            for(i=1:6)
                resx(i,:,ii)=spx(R.dsPts([pks+4],3),i)-spx(R.dsPts([pks+1],3),i);
            end
        end
        mresZ=mean(resz,3);
        eresZ=std(resz,0,3);
        
        mresX=mean(resx,3);
        eresX=std(resx,0,3);
        
        figure(xx)
%         errorbar(1:6,mresZ(:,cycle)+(jj-1)*10,eresZ(:,cycle));
        errorbar(1:6,mresZ(:,cycle),eresZ(:,cycle),'color',cmap(jj,:),'linewidth',2);
%         pause
        
        ylabel('\Delta(C(parallel)) (mm)');
        xlabel('smarticle number')
        set(gca,'xticklabel',{'1' '2' '3' '4' '5' '6'},'xtick',[1:6])
        figText(gcf,16);
        title(titlez);
        
        figure(12312)
        hold on;
        
        errorbar(1:6,mresX(:,cycle),eresX(:,cycle),'color',cmap(jj,:),'linewidth',2);
        
        ylim([-1,8]);
        ylabel('\Delta(C(perp)) (mm)');
        xlabel('smarticle number')
        set(gca,'xticklabel',{'1' '2' '3' '4' '5' '6'},'xtick',[1:6])
        figText(gcf,16);
        title(titlez);
        
    end
    legend({strcat('S=',num2str(uvar),'mm/s')})
    figure(xx);
    legend({strcat('S=',num2str(uvar),'mm/s')})
end
%% 29.  plot single cycle multisd reversability
xx=29;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
%     sdz=5:5:45;
    uvar=unique(SD);
    cycle=1;%1 2 or 3
%     cmap=brewermap(length(usd),'rdylgn');
%     cmap=fire(length(uvar));
    cmap=jet(length(uvar));

    [~,a,~]=fileparts(fold);
    [c,d]=parseFileNames(a);
    

%     titlez=['T=',num2str(d(1)),' l=',num2str(d(2)),' cycle=',num2str(cycle),' spd=',num2str(sdz),'mm/s'];
titlez=['T=',num2str(d(1)),' l=',num2str(d(2)),' cycle=',num2str(cycle),' spd=all','mm/s'];
    for jj=1:length(uvar)
        resz=zeros(6,it(1)/2);%6 for number of smarts its/2 for cycles
        resx=zeros(6,it(1)/2);%6 for number of smarts its/2 for cycles
%         indxs=find(SD==uvar(jj)&spd==sdz);
        indxs=find(SD==uvar(jj));
        for ii=1:length(indxs)
            
            R=usedS(indxs(ii));
            %convert to mm and center at 0
            spx=(R.smartPos.x-R.smartPos.x(1,1))*1000;
            spz=(R.smartPos.z-R.smartPos.z(1,1))*1000;
            
            %eventually change to number of smarticles via size of smartPos
            
            pks=[0:R.its/2-1]*4;
            
            
            for(i=1:6)
                resz(i,:,ii)=spz(R.dsPts([pks+4],3),i)-spz(R.dsPts([pks+1],3),i);
                resx(i,:,ii)=spx(R.dsPts([pks+4],3),i)-spx(R.dsPts([pks+1],3),i);
            end
        end
        mresZ=mean(resz,3);
        eresZ=std(resz,0,3);
        
        mresX=mean(resx,3);
        eresX=std(resx,0,3);
        
        figure(xx)
%         errorbar(1:6,mresZ(:,cycle)+(jj-1)*10,eresZ(:,cycle));
        errorbar(1:6,mresZ(:,cycle),eresZ(:,cycle),'color',cmap(jj,:),'linewidth',2);
%         pause
        
        ylabel('\Delta(C(parallel)) (mm)');
        xlabel('smarticle number')
        set(gca,'xticklabel',{'1' '2' '3' '4' '5' '6'},'xtick',[1:6])
        figText(gcf,16);
        title(titlez);
        
        figure(12312)
        hold on;
        
        errorbar(1:6,mresX(:,cycle),eresX(:,cycle),'color',cmap(jj,:),'linewidth',2);
        
        ylim([-1,8]);
        ylabel('\Delta(C(perp)) (mm)');
        xlabel('smarticle number')
        set(gca,'xticklabel',{'1' '2' '3' '4' '5' '6'},'xtick',[1:6])
        figText(gcf,16);
        title(titlez);
        
    end
    legend({strcat('S=',num2str(uvar*1000),'mm')})
    figure(xx);
    legend({strcat('S=',num2str(uvar*1000),'mm')})
end

%% 30. plot para and perp movement vs time
xx=30;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=1;
    totArea={};
    timePts=[1,1]; %start and end pts, iteration to consider as "zero point"
    if exist('tpt','var')
        timePts=tpt; %if I want to set it up top
    end
    
    R=usedS(ind);
    %convert to mm and center at 0
    spx=(R.smartPos.x-R.smartPos.x(1,1))*1000;
    spz=(R.smartPos.z-R.smartPos.z(1,1))*1000;
    
    
    % plot(usedS(ind).smartPos.z(:,S),usedS(ind).smartPos.x(:,S));
        
    ptSkip=100;
    %SPZ=parallel
    %SPX=perp
%     plot(spz(1:ptSkip:end,:),spx(1:ptSkip:end,:))
    hold on;
    stpts=R.dsPts([0 1 2]*4+1,3);
    midspts=R.dsPts([0 1 2]*4+2,3);
    midepts=R.dsPts([0 1 2]*4+3,3);
    edpts=R.dsPts([0 1 2]*4+4,3);
    
    ax2=subplot(1,2,1);
    hold on;
    
    for jj=1:size(spx,2)
        plot(R.t(1:ptSkip:end),spx(1:ptSkip:end,jj)-spx(1,jj),'linewidth',2);
    end
    ylabel('perp (mm)');
    xlabel('time (s)');
    
    ax3=subplot(1,2,2);
    hold on;
    for jj=1:size(spz,2)
        plot(R.t(1:ptSkip:end),spz(1:ptSkip:end,jj)-spz(1,jj),'linewidth',2);
    end
    xlabel('time (s)');
    ylabel('parallel (mm)')
    
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
