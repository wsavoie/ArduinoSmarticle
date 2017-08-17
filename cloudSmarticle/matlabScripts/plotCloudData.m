clear all;
% close all;
% load('D:\ChronoCode\chronoPkgs\Smarticles\matlabScripts\amoeba\smarticleExpVids\rmv3\movieInfo.mat');

% fold=uigetdir('A:\2DSmartData\');
fold=uigetdir('A:\2DSmartData\cloud\willData\equal delay\rigid bodies markers messup');
load(fullfile(fold,'movieInfo.mat'));
SPACE_UNITS = 'm';
TIME_UNITS = 's';
pts(fold);

%************************************************************
%* Fig numbers:
%* 1. plot each smarticle's tracks for a particular run
%* 2. plot COM trail of each run
%* 3. granular temperature for translation for single run
%* 4. integral vs xi
%* 5. polygon initial vs. final
%************************************************************
showFigs=[1];

%params we wish to plot
% DIR=[]; RAD=[]; V=[];

% props={};
inds=1;
for i=1:length(movs)
    
    %     cond=true;
    %     for j=1:length(props)
    %         %if empty accept all values
    %         if ~isempty(props{j})
    %             %in case multiple numbers in property
    %             %if no matches then cond = false
    %             if(~any(props{j}==movs(i).pars(j)))
    %                 cond = false;
    %             end
    %         end
    %     end
    %     if(cond)
    usedMovs(inds)=movs(i);
    inds=inds+1;
    %     end
end
N=length(usedMovs); %number of used movs
ROT=isfield(usedMovs(1),'rot');
% allPars=zeros(length(usedMovs),3); %all mov params saved into a single var
% for i=1:length(usedMovs)
%     allPars(i,:)=usedMovs(i).pars;
% end
% if isempty(DIR)
%     D1=find(allPars(:,1)==1);
%     D2=find(allPars(:,1)==2);
% else
%     if(DIR==1)
%         D1=allPars(:,1);
%         D2=[];
%     else
%         D1=[];
%         D2=allPars(:,1);
%     end
% end

%% 1 plot each smarticle's tracks for a particular run
xx=1;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=2;
    hold on;
    
    idx=3; %index of movie to look at
    %     for(i=1:size(usedMovs(idx).x,2) %for the number of smarticle
    for(idx=1:N)
        figure(1000+idx);
        hold on;
        for i=1:numBods %for the number of smarticles
            x= usedMovs(idx).x(:,i);%-usedMovs(idx).x(1,i);
            y= usedMovs(idx).y(:,i);%-usedMovs(idx).y(1,i);
            t= usedMovs(idx).t(:,i);%-usedMovs(idx).y(1,i);
            y= usedMovs(idx).rot(:,i);%-usedMovs(idx).y(1,i);
            subplot(1,2,1);
            hold on;
            plot( usedMovs(idx).x(:,i),usedMovs(idx).y(:,i),'linewidth',lw);
            xlabel('x (m)');
            ylabel('y (m)');
            subplot(1,2,2);
            hold on;
            plot(usedMovs(idx).t(:,i),usedMovs(idx).rot(:,i)*180/pi,'linewidth',lw);
            xlabel('t (s)');
            axis([0,120,-180,180]);
            ylabel('\theta (\circ)');
        end
    end
    pts('plotted: ',usedMovs(idx).fname);
    xlabel('x (m)');
    ylabel('y (m)');
    figText(gcf,16);
    axis equal
end
%% 2 plot COM trail of each run
xx=2;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    %     first get number of gait radii used
    COM=cell(numBods,1);
    for i=1:N
        COM{i}=[sum(usedMovs(i).x,2),sum(usedMovs(i).y,2)]/numBods;
        dists=sqrt(sum(abs(diff(COM{i})).^2,2)); %check for major jumps
        longDists=find(dists>.01);
        
        %eliminate long jumps
        while(longDists)
            COM{i}(longDists(1)+1,:)=COM{i}(longDists(1),:);
            dists=sqrt(sum(abs(diff(COM{i})).^2,2)); %check for major jumps
            longDists=find(dists>.005);
        end
        
        COM{i}=bsxfun(@minus, COM{i}, COM{i}(1,:));
        plot(COM{i}(:,1),COM{i}(:,2),'linewidth',lw);
    end
    
    xlabel('x (m)');
    ylabel('y (m)');
    axis([-.1,.1,-.1,.1]);
    figText(gcf,16);
    
end
%% 3. granular temperature for translation for single run
xx=3;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    idx=1;
    GtM=cell(1,N);
    clear GtM2 GtM1
    if(ROT), GrM=cell(1,N); end
    for idx=1:N
        Gt=zeros(size(usedMovs(idx).xdot,1),numBods);
        if(ROT), Gr=Gt; end
        for i=1:numBods %for the number of smarticles
            Gt(:,i)=usedMovs(idx).xdot(:,i).^2+usedMovs(idx).ydot(:,i).^2;
            if(ROT),Gr(:,i)=usedMovs(idx).rotdot(:,i).^2;end
            
            %     v=usedMovs(i).t
        end
        GtM{idx}=mean(Gt(1:minT-1),1);
        GtM1(idx)=sum(sum(Gt(1:minT-1,:),1));
        GtM2(:,idx)=sum(Gt(1:minT-1,:),2);
        if(ROT),GrM{idx}=mean(Gr(1:minT),1); end
    end
    G2=mean(GtM2,2);
    
    %     G2=sort(G2,'descend');
    %     plot(usedMovs(idx).t(1:minT,1),G2);
    xd=[0:length(G2)-1]./usedMovs(1).fps;
    plot(xd,G2);
    xlabel('t (s)');
    ylabel('speed m/s');
    figText(gcf,18);
    xlim([0 125]);
    err2=std(GtM1);
    fV=mean(GtM1)
end

%% 4. integral vs xi
xx=4;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    %     xi=[0:100:500];
    %     y1=[0.0261,0.0299,0.0035,0.0073,0.0175,0.0057]; %integral area
    %     cc=[0.00520,0.00522,0.00439,1.90782e-05,0.00215,0.00628];%area change
    %     cc=cc/max(cc);
    %     y2=y1.*cc;
    xi=[0 50 100 150 200 250];
    y1=[0.2382,0.1946,0.2525,.2230,0.1689,0]; %integral area
    
    y2=[1.7126,1.5242 ,1.6495, 1.5532,1.3841,1.5857];
    %     cc=[0.00520,0.00522,0.00439,1.90782e-05,0.00215,0.00628];%area change
    %     cc=cc/max(cc);
    %     y2=y1.*cc;
    
    %     plot(xi,y1,'o-');
    plot(xi,y2,'o-');
    xlabel('\xi (ms)');
    ylabel('signal (m)');
    figText(gcf,16);
    axis tight
end
%% 5. polygon initial vs. final
xx=5;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    rI=zeros(numBods,2,N); %initial points
    rF=zeros(numBods,2,N); %final points
    vI=zeros(1,N);
    vF=zeros(1,N);
    
    for(idx=1:N)
        
        rI(1:numBods,:,idx)=[usedMovs(idx).x(1,:)',usedMovs(idx).y(1,:)'];
        rF(1:numBods,:,idx)=[usedMovs(idx).x(end,:)',usedMovs(idx).y(end,:)'];
        
        [~, vI(idx)]=convhull(rI(:,1,idx),rI(:,2,idx));
        [~, vF(idx)]=convhull(rF(:,1,idx),rF(:,2,idx));
        %         %last point is first point
        %         rI(end,:,idx)=[usedMovs(idx).x(1,1)',usedMovs(idx).y(1,1)'];
        %         rF(end,:,idx)=[usedMovs(idx).x(end,1)',usedMovs(idx).y(end,1)'];
    end
    
    %     area(rI(:,1,1),rI(:,2,1));
    %     [ord,v]=convhull(rI(:,1,1),rI(:,2,1));
    %     plot(rI(:,1,1),rI(:,2,1),'-o');
    cc(6)=mean(vF-vI);
    xlabel('\xi');
    ylabel('signal');
    figText(gcf,16);
end