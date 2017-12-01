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
%*17. old force vs H data
%************************************************************
% clearvars -except t
% close all;
clear all;

% maxSpeed= 1.016; %m/s
% pctSpeed=.0173;
% speed=pctSpeed*maxSpeed;

% fold=uigetdir('A:\2DSmartData\entangledData');
fold='A:\2DSmartData\entangledData\initial hysteresis\multimarker string';
freq=1000; %hz rate for polling F/T sensor

if ~exist(fullfile(fold,'dataOut.mat'),'file')
    filez=dir2(fullfile(fold,'Stretch*'));
    N=length(filez);
    allFpars=zeros(N,7); % [type,SD,H,del,v]
    s=struct;
    for i=1:N
        pts(i,'/',N);
        [allFpars(i,:),s(i).t,s(i).strain,s(i).F,L,s(i).rob,s(i).chain,s(i).dsPts]=analyzeEntangleFileMM(...
            fold,filez(i).name,freq);
        s(i).name=filez(i).name;
        s(i).fpars=allFpars(i,:);
        %     [s(i).type,s(i).SD,s(i).H,s(i).del,s(i).spd,s(i).its,s(i).v]=separateVec(fpars(i,:),1);
        [s(i).type,s(i).SD,s(i).H,s(i).del,s(i).spd,s(i).its,s(i).v]=separateVec(allFpars(i,:),1);
    end
    save(fullfile(fold,'dataOut.mat'),'s','allFpars');
else
    load(fullfile(fold,'dataOut.mat'));
end


typeTitles={'Inactive Smarticles','Regular Chain','Viscous, open first 2 smarticles',...
    'Elastic, close all smarticles','Fracture On','Stress Avoiding Chain'...
    'Fracture SAC'};
%%%%%%%%%%%%%%%%%%
% strains=[65]/1000;
types=[]; strains=[]; Hs=[]; dels=[]; spds=[]; its=[]; vs=[];
%%%%%%%%%%%%%%%%%%%%%%%%
props={types strains Hs dels spds its vs};

setP1=[];
indcnt=1;
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
    fpars(i,:)=usedS.fpars;
end
[type,SD,H,del,spd,it,v]=separateVec(fpars,1);

showFigs=[3 11 12];

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
    % plot(s(ind).strain,s(ind).F);
    colormapline(usedS(ind).strain,usedS(ind).F,[],jet(100));
    xlabel('Strain');
    ylabel('Force (N)');
    figText(gcf,18)
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
    
    figure(xx)
    hold on;
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
    tArea=zeros(uN,1);
    strMax=0;
    for(i=1:uN)
        pts('F vs. Strain for ',usedS(i).name);
        %         plot(usedS(i).strain,usedS(i).F);
        colormapline(usedS(i).strain,usedS(i).F,[],jet(100));
        tArea(i)=trapz(usedS(i).strain,usedS(i).F);
        %         A(i)=polyarea([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)]);
        [sm(i),smidx]=max(usedS(i).strain);
        strMax=max(strMax,sm(i));
        
        %         fill([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)],'k','facecolor','c')
    end
    xlabel('Strain');
    ylabel('Force (N)');
    figText(gcf,18)
    axis([0,round(strMax,2),-0.4,0.8]);
    
    figure(100);
    hold on;
    plot([1:5],tArea,'o-','linewidth',2,'markerfacecolor','w');
    xlabel('Speed');
    
    %     plot(sm,tArea,'o-','linewidth',2,'markerfacecolor','w');
    %     xlabel('Strain');
    
    ylabel('Work');
    figText(gcf,18);
end
%% 7. plot force vs. strain for usedS with slope bar
xx=7;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    subplot(1,2,1)
    hold on;
    % ind=2;
    tArea=zeros(uN,1);
    strMax=0;
    legText={};
    
    for(i=uN:-1:1)
        pts('F vs. Strain for ',usedS(i).name);
        h1(i)=plot(usedS(i).strain,usedS(i).F);
        %             colormapline(usedS(i).strain,usedS(i).F,[],jet(100));
        tArea(i)=trapz(usedS(i).strain,usedS(i).F);
        %         A(i)=polyarea([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)]);
        [sm(i),smidx]=max(usedS(i).strain);
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
    
    load(fullfile(fold,'fractData.mat'));
    uH=sort(unique([fractData(:).H]),'ascend');
    allH=[fractData(:).H];
    uF=cell(length(uH),1);
    uS=cell(length(uH),1);
    for i=1:length(uH)
        inds=find(allH==uH(i));
        uF(i)={[fractData(inds).fracFmax]};
        uS(i)={[fractData(inds).fracStrainMax]};
        uFm(i)=mean(uF{i});
        uFerr(i)=std(uF{i});
        uSm(i)=mean(uS{i});
        uSerr(i)=std(uS{i});
    end
    
    subplot(1,2,1)
    hold on;
    title('Force at Fracture');
    errorbar(uH,uFm,uFerr,'linewidth',2);
    ylabel('Force (N)');
    xlabel('Width (smarticle widths)');
    figText(gcf,16)
    axis tight;
    
    subplot(1,2,2)
    hold on;
    title('Strain at Fracture');
    errorbar(uH,uSm,uSerr,'linewidth',2);
    ylabel('Strain');
    xlabel('Width (smarticle widths)');
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
    startIt=2; %iteration to consider as "zero point"
    
    pts('F vs. Strain for ',usedS(ind).name);
    % plot(s(ind).strain,s(ind).F);

    time2use=usedS(ind).dsPts((startIt-1)*4,3);
    x=usedS(ind).strain(time2use:end);
    y=usedS(ind).F(time2use:end);
    
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
    startIt=2; %iteration to consider as "zero point"
    
    pts('F vs. Strain for ',usedS(ind).name);
    % plot(s(ind).strain,s(ind).F);

    time2use=usedS(ind).dsPts((startIt-1)*4,3);
    x=usedS(ind).strain(time2use:end);
    y=usedS(ind).F(time2use:end)';
    
    x=x-x(1);%zero at start iteration
    y=y-y(1);
    
    tArea(i)=trapz(x,y);
        %         A(i)=polyarea([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)]);
    [sm(i),smidx]=max(x);
    
%     colormapline(x,y,[],jet(100));
    fill([x,x(1)],[y,y(1)],'k','facecolor','c')
    xlabel('Strain');
    ylabel('Force (N)');
    
     text(0.4,0.9,['W=',num2str(tArea,3)],'units','normalized')
    
    xlim([0,inf]);
    figText(gcf,18)
end
        
        
        %         fill([usedS(i).strain;usedS(i).strain(1)],[usedS(i).F;usedS(i).F(1)],'k','facecolor','c')


%% 17. old force vs h data
xx=17;
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

