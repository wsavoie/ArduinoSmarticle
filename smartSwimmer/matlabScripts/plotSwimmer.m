%************************************************************
%* Fig numbers:
%* 1. plot q vs. time for left and right
%* 2. plot travel distance vs. gait size for left and right for all angles
%************************************************************
clear all
fold='D:\Projects\arduinoSmart\smartSwimmer\matlabScripts\data';
if ~exist(fullfile(fold,'dataOut.mat'),'file')
    filez=dir2(fullfile(fold,'*.csv'));
    N=length(filez);
    allFpars=zeros(N,3); % [ang,dir,ver]
    s=struct;
    for i=1:N
        [allFpars(i,:),s(i).t,s(i).x,s(i).y,s(i).q,s(i).xcom,s(i).ycom]=analyzeSwimmer(fold,filez(i).name);
        s(i).name=filez(i).name;
        s(i).fpars=allFpars(i,:);
        [s(i).ang,s(i).dir,s(i).v]=separateVec(allFpars(i,:),1);
        
    end
    save(fullfile(fold,'dataOut.mat'),'s','allFpars');
else
    load(fullfile(fold,'dataOut.mat'));
end


%%%%%%%%%%%%%%%%%%
angs=[]; ds=[]; vs=[];
%%%%%%%%%%%%%%%%%%%%%%%%
props={angs ds vs};

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
fpars=zeros(uN,3);
for i=1:uN
    fpars(i,:)=usedS(i).fpars;
end
[ang,d,v]=separateVec(fpars,1);

showFigs=[1 2];

%% 1. plot q vs. time for left and right for a single ang
xx=1;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    angz=90;
    
    
    idxs=find(allFpars(:,1)==angz);
    
    for i=1:length(idxs)
        pts('q vs. t',s(idxs(i)).name);
        if(allFpars(idxs(i),2)==0)
            col='k';
        else
            col='r';
        end
        plot(s(idxs(i)).t,s(idxs(i)).q*100,'color',col,'linewidth',2);
    end
    title(['R=',num2str(angz),'$^\circ$'],'interpreter','latex');
    %     legend({'Left','Right'},'location','south')
    
    xlabel('time (s)','interpreter','latex');
    ylabel('q (cm)','interpreter','latex');
    
    figText(gcf,18);
end
%% 2. plot travel distance vs. gait size for left and right for all angles
xx=2;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    
    uang=unique(ang);
    for(i=1:length(uang))
        idxs=find(allFpars(:,1)==uang(i));
        Lall=[];
        Rall=[];
        for j=1:length(idxs)
%             pts('q vs. t',s(idxs(i)).name);
            if(allFpars(idxs(j),2)==0)
                Lall=[Lall s(idxs(j)).q(end)*100];
            else
                Rall=[Rall s(idxs(j)).q(end)*100];
            end
        end
        Lm(i)=mean(Lall);
        Le(i)=std(Lall);
        Rm(i)=mean(Rall);
        Re(i)=std(Rall);
    end
    
        
    errorbar(uang,Lm,Le,'color','k','linewidth',lw);
    errorbar(uang,Rm,Re,'color','r','linewidth',lw);
    
    xlabel('Gait Size $(^\circ)$','interpreter','latex');
    ylabel('travel distance (cm)','interpreter','latex');
    leg=legend({'Left','Right'},'location','NorthWest','interpreter','latex');
    figText(gcf,18);
    leg.FontSize=12;
end