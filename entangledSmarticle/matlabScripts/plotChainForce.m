%************************************************************
%* Fig numbers:
%* 1. force vs time with strain overlay
%* 2. plot comparison b/w activated system and regular, Force vs. Time
%* 3. plot single Force vs. Strain
%* 4. plot comparison b/w activated system and regular, Force vs. Strain
%* 5. plot force vs. strain for usedS
%* 6. plot force vs. time for usedS
%************************************************************
% clearvars -except t
close all;
clear all;

fold=uigetdir('A:\2DSmartData\entangledData');
filez=dir2(fullfile(fold,'Stretch*'));
N=length(filez);
fpars=zeros(N,7); % [type,SD,H,del,v]
L=.26;%meters smarticle chain length
freq=1000; %hz rate for polling F/T sensor
s=struct;
for i=1:N
    [fpars(i,:),s(i).t,s(i).strain,s(i).F]=analyzeEntangleFile(...
        fold,filez(i).name,L,freq);
    s(i).name=filez(i).name;
    s(i).fpars=fpars(i,:);
    [s(i).type,s(i).SD,s(i).H,s(i).del,s(i).spd,s(i).its,s(i).v]=separateVec(fpars(i,:),1);
    
end
[type,SD,H,del,spd,it,v]=separateVec(fpars,1);
typeTitles={'Inactive Smarticles','Regular Chain','Viscous, open first 2 smarticles','Elastic, close all smarticles','','Stress Avoiding Chain'};
%%%%%%%%%%%%%%%%%%
types=[]; strains=[65]/1000; Hs=[]; dels=[]; spds=[2]; its=[1]; vs=[];
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
showFigs=[6];

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
    xlimz=[0,35];
    ylimz=[-1,1];
    figure(xx)
    hold on;
    
    xlabel(xlab);
    ylabel(ylab);
    types=[5 5];
    title(typeTitles{types(1)+1});
    %[type,strain, sys width,del,spd, its,version]
    setP1=find(ismember(fpars(:,[1 2 3 4 5 6]),[types(1) 0.026,0.105,4, 2,1],'rows'))';
    setP2=find(ismember(fpars(:,[1 2 3 4 5 6]),[types(2) 0.065,0.105,4, 2,2],'rows'))';
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
    
    title(typeTitles{types(2)+1});
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
    % ind=2;
    
    pts('F vs. Strain for ',s(ind).name);
    % plot(s(ind).strain,s(ind).F);
    colormapline(s(ind).strain,s(ind).F,[],jet(100));
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
    types=[5 5];
    title(typeTitles{types(1)+1});
    xlabel(xlab);
    ylabel(ylab);
    for i=find(type==types(1))'
        plot(s(i).strain,s(i).F);
        %     pause;
    end
    axis([xlimz,ylimz])
    % ylim([-0.6,0.6]);
    axis square
    figText(gcf,fz);
    figure(55)
    hold on;
    
    title(typeTitles{types(2)+1});
    xlabel(xlab);
    for i=find(type==types(2))'
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
            h2(i)=plot(usedS(i).t,maxF(i)*usedS(i).strain/maxS(i),'color',h(i).Color);
            % text(0.4,0.9,'scaled strain','units','normalized','color',h.Color)
            %         legend({'Force','Scaled Strain'},'location','south')
            set(get(get(h2(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
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
    for(i=1:uN)
        pts('F vs. Strain for ',s(i).name);
        plot(usedS(i).strain,usedS(i).F);
        %     colormapline(usedS(i).strain,usedS(i).F,[],jet(100));
        
    end
    xlabel('Strain');
    ylabel('Force (N)');
    figText(gcf,18)
    axis([0,.25,-0.2,0.6]);
end