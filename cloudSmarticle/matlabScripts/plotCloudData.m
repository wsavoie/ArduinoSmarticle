clear all;
% close all;
% load('D:\ChronoCode\chronoPkgs\Smarticles\matlabScripts\amoeba\smarticleExpVids\rmv3\movieInfo.mat');

% fold=uigetdir('A:\2DSmartData\');
% f='A:\2DSmartData\singleSmarticleTrack';
% f='A:\2DSmartData\cloud\cloudTests 10-5 diamond and square gaits\';
% f='A:\2DSmartData\cloud\cloud 9-30';
% f='A:\2DSmartData\cloud\cloud 2-27\';
f='A:\2DSmartData\cloud\cloud 5-2-18\';
fold=uigetdir(f);
load(fullfile(fold,'movieInfo.mat'));
SPACE_UNITS = 'm';
TIME_UNITS = 's';
pts(fold);

%************************************************************
%* Fig numbers:
%* 1. plot each smarticle's tracks for a particular run
%* 2. plot COM trail of each run
%* 3. integral vs xi
%* 4. polygon initial vs. final
%* 5. granular temperature for translation for single run
%* 6. granular temperature for ensemble
%* 7. phi vs. time
%* 8. vector field plot of positions
%* 9. radial displacement vs time and theta vs time for single smarticle
%*10. total path length vs time and theta vs time for single smarticle
%*11. granular temperature v2
%*12. compiled granular temperature data
%*13. d<s>/dt
%*14. rand amp vs. contact cycles
%*15. plot final phi for diff gait types
%*16. plot stretched exponential data for different delays
%*17-19. plot out phi for different delays
%*20. plot out all gran temp data for different delays
%*21. final gran temp R and T for all delays
%*22/23. histogram of phi changes
%*24. phi changes at all D
%*25. cloud diffusion all smart tracks
%*26. cloud diffusion com tracks
%*27. cloud nearest neighbor distance
%*28. cloud nearest neighbor distance for all runs *NOT DONE*
%*29. phidt vs. granular temp
%*30. mean velocity vs time
%*31. true granular temperature mean squared vel
%*32. another version of COM plot with cleaner code
%*33. MSD added from 44 on multimsd file
%*34. plot gamma vs t
%************************************************************
% showFigs=[7 11 27];
% showFigs=[25 33 31 7 29];
showFigs=[35];
%params we wish to plot
% DIR=[]; RAD=[]; V=[];
% cutoff/(sample/2)
cutoff=2;
sampRate=30;
filtOrder=6;
[fb,fa]=butter(filtOrder,cutoff/(sampRate/2),'low');

%  [b,a]=butter(6,1/120*2,'low');
% props={};
inds=1;
maxT=0;
minT=1e28;
singInd=4;
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
    maxT=max(maxT,usedMovs(inds).t(end));
    minT=min(minT,usedMovs(inds).t(end));
    inds=inds+1;
    %     end
end
N=length(usedMovs); %number of used movs
ROT=isfield(usedMovs(1),'rot');


%% 1 plot each smarticle's tracks for a particular run
xx=1;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=1;
    hold on;
    
    idx=1; %index of movie to look at
    %     for(i=1:size(usedMovs(idx).x,2) %for the number of smarticle
    
    for i=1:size(usedMovs(idx).x,2) %for the number of smarticles
        figure(1000+i);
        x= usedMovs(idx).x(:,i)*1000;
        y= usedMovs(idx).y(:,i)*1000;
        t= usedMovs(idx).t(:,i)*1000;
        rot= usedMovs(idx).rot(:,i);
        x=x-x(1);   y=y-y(1);  rot=rot-rot(1);
        
        %         [b,a]=butter(3,1/120*2,'low');
        xF=filter(fb,fa,x);  %filtered signal
        yF=filter(fb,fa,y);  %filtered signal
        rotF=filter(fb,fa,rot);  %filtered signal
        
        subplot(1,2,1);
        hold on;
        plot(x,y,'linewidth',lw);
        plot(xF,yF,'linewidth',lw);
        xlabel('x (mm)');
        ylabel('y (mm)');
        figText(gcf,16);
        subplot(1,2,2);
        hold on;
        plot(t,rot*180/pi,'linewidth',lw);
        plot(t,rotF*180/pi,'linewidth',lw);
        %         pts('i=',i,' maxrot=',max(abs(rot*180/pi)));
        xlabel('t (s)');
        ylabel('\theta (\circ)');
        axis auto
        figText(gcf,16);
        
        
        
        
        
    end
    pts('plotted: ',usedMovs(idx).fname);
    %     xlabel('x (m)');
    %     ylabel('y (m)');
    figText(gcf,16);
    axis auto
end
%% 2 plot COM trail of each run
xx=2;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    %     first get number of gait radii used
    COM=cell(N,1);
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
    
    plot([-0.3,-0.3,0.3,0.3,-0.3],[0.3,-0.3,-0.3,0.3,0.3,],'k','linewidth',2);
    xlabel('x (m)');
    ylabel('y (m)');
    %     axis([-.1,.1,-.1,.1]);
    axis equal
    figText(gcf,16);
    
end
%% 3. integral vs xi
xx=3;
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
%% 4. polygon initial vs. final
xx=4;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    rI=zeros(numBods,2,N); %initial points
    rF=zeros(numBods,2,N); %final points
    vI=zeros(1,N);
    vF=zeros(1,N);
    A=.051*.021; %area (l*w) of smarticle in m
    
    for(idx=1:N)
        n=size(usedMovs(idx).x,2);%number of particles
        rI(1:numBods,:,idx)=[usedMovs(idx).x(1,:)',usedMovs(idx).y(1,:)'];
        rF(1:numBods,:,idx)=[usedMovs(idx).x(end,:)',usedMovs(idx).y(end,:)'];
        
        [~, vI(idx)]=convhull(rI(:,1,idx),rI(:,2,idx));
        [~, vF(idx)]=convhull(rF(:,1,idx),rF(:,2,idx));
        %         %last point is first point
        rI(end,:,idx)=[usedMovs(idx).x(1,1)',usedMovs(idx).y(1,1)'];
        rF(end,:,idx)=[usedMovs(idx).x(end,1)',usedMovs(idx).y(end,1)'];
        
    end
    
    %         area(rI(:,1,1),rI(:,2,1));
    [ord,v]=convhull(rI(:,1,1),rI(:,2,1));
    %     plot(rI(:,1,1),rI(:,2,1),'-o');
    %     plot(vF-vI);
    
    %area change (m^2)
    cc=mean(vF-vI)
    cerr=std(vF-vI)
    
    %
    cc2=mean(n*A./vF-n*A./vI)
    c2err=std(n*A./vF-n*A./vI)
    sigma = [0     , 200   , 400   , 800  ];
    vChange=[.022  , 0.0244, 0.0202, 0.0253 ];
    vCerr=  [0.0053, 0.0045, 0.0074, 0.008];
    
    phiChange=[-.2510  , -0.2878, -0.2394, -0.3529 ];
    phiErr=  [0.0493, 0.0757, 0.0586, 0.1214];
    
    %         plot(sigma,vChange);
    errorbar(sigma,vChange,vCerr)
    xlabel('$\xi (ms)$','interpreter','latex');
    ylabel('Area Change $(m^2)$','interpreter','latex');
    figText(gcf,16);
    %
    %     %plot out in change of area fraction instead
    %     figure(50);
    %     hold on;
    %     errorbar(sigma,phiChange,phiErr)
    %     xlabel('$\xi (ms)$','interpreter','latex');
    %     ylabel('$\Delta\phi$','interpreter','latex');
    %     figText(gcf,16);
end
%% 5. granular temperature for translation for single run
xx=5;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=2;
    %         clf
    hold on;
    idx=1;
    pts(usedMovs(idx).fname);
    %     GtM=cell(1);
    clear GtM2 GtM1
    %     [GrM,GtM2]=deal(zeros(minT-1,N));
    %     if(ROT), GrM=zeros(minT,N); end
    %     GtM1=zeros(minT,N);
    m=.032; %mass of red smarticle
    L=.14; %total length smarticle
    I=(1/12)*m*L^2;
    
    %     for idx=1:N
    Gt=zeros(size(usedMovs(idx).xdot,1),numBods);
    if(ROT), Gr=Gt; end
    for i=1:numBods %for the number of smarticles
        Gt(:,i)=sqrt(usedMovs(idx).xdot(:,i).^2+usedMovs(idx).ydot(:,i).^2);
        if(ROT)
            Gr(:,i)=sqrt(usedMovs(idx).rotdot(:,i).^2);
        end
        
        %     v=usedMovs(i).t
    end
    GtM=mean(Gt(1:minT-1),1);
    %         GtM1(idx)=sum(sum(Gt(1:minT-1,:),1));
    %         GtM1(:,idx)=mean(mean(Gt(1:minT-1,:),1),2); %mean speed of each particle over each run
    %         GtM2(:,idx)=mean(Gt(1:minT-1,:),2); %mean speed of particles at each timestep
    
    GtM2=mean(Gt(1:minT-1,:),2); %mean speed of particles at each timestep
    TT=mean(.5*GtM2.^2*m,2);
    
    if(ROT)
        %             GrM1(:,idx)=mean(mean(Gr(1:minT-1,:),1),2); %mean omega of each particle over each run
        %             GrM2(:,idx)=mean(Gr(1:minT-1,:),2); %mean omega of particles at each timestep
        GrM1=mean(mean(Gr(1:minT-1,:),1),2); %mean omega of each particle over each run
        GrM2=mean(Gr(1:minT-1,:),2); %mean omega of particles at each timestep
        TR=mean(I.*GrM2.^2,2);
    else
        TR=zeros(size(TT));
    end
    %     end
    ktot=TT+TR;
    
    G2=mean(GtM2,2);
    G3=mean(GrM2,2);
    %     G2=sort(G2,'descend');
    %     plot(usedMovs(idx).t(1:minT,1),G2);
    xd=[0:length(G2)-1]./usedMovs(1).fps;
    %     plot(xd,G2);
    %      plot(1:size(ktot,1),ktot(:,1));
    xlabel('t (s)');
    ylabel('total kinetic energy J');
    figText(gcf,18);
    %     xlim([0 125]);
    %     err2=std(GtM1);
    %     fV=mean(GtM1);
    subplot(2,2,1)
    hold on;
    plot(xd,TT(:,1));
    title('translational');
    xlabel('time');
    ylabel('energy (J)');
    subplot(2,2,2)
    hold on;
    plot(xd,TR(:,1));
    xlabel('time (s)');
    ylabel('energy (J)');
    title('rotational');
    subplot(2,2,[3 4])
    hold on;
    plot(xd,ktot(:,1));
    title('total kinetic');
    xlabel('time (s)');
    ylabel('energy (J)');
    figText(gcf,16);
end


%% 6. granular temperature for ensemble
xx=6;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    idx=4;
    GtM=cell(1,N);
    clear GtM2 GtM1
    %     [GrM,GtM2]=deal(zeros(minT-1,N));
    %     if(ROT), GrM=zeros(minT,N); end
    %     GtM1=zeros(minT,N);
    mb=.025; Lb=0.054;
    ma=.07/2; La=0.035;
    m=2*ma+mb;
    L=.052;%com of arm to center body com
    Ia=(1/12)*ma*(.0032^2+.035^2)+ma*L^2;
    Ib=(1/12)*mb*(.054^2+.022^2);
    I=2*Ia+Ib;
    
    %     m=.032; %mass of red smarticle
    %     L=Lb*; %total length smarticle
    %     I=(1/12)*m*L^2;
    
    for idx=1:N
        %translation granTemp
        Gt=zeros(size(usedMovs(idx).xdot,1),numBods);
        if(ROT), Gr=Gt; end
        for i=1:numBods %for the number of smarticles
            Gt(:,i)=sqrt(usedMovs(idx).xdot(:,i).^2+usedMovs(idx).ydot(:,i).^2);
            if(ROT)
                Gr(:,i)=sqrt(usedMovs(idx).rotdot(:,i).^2);
            end
            
            %     v=usedMovs(i).t
        end
        GtM{idx}=mean(Gt(1:minT-1),1);
        %         GtM1(idx)=sum(sum(Gt(1:minT-1,:),1));
        %         GtM1(:,idx)=mean(mean(Gt(1:minT-1,:),1),2); %mean speed of each particle over each run
        %         GtM2(:,idx)=mean(Gt(1:minT-1,:),2); %mean speed of particles at each timestep
        
        GtM2=mean(Gt(1:minT-1,:),2); %mean speed of particles at each timestep
        TT(:,idx)=mean(.5*GtM2.^2*m,2);
        
        if(ROT)
            %             GrM1(:,idx)=mean(mean(Gr(1:minT-1,:),1),2); %mean omega of each particle over each run
            %             GrM2(:,idx)=mean(Gr(1:minT-1,:),2); %mean omega of particles at each timestep
            GrM1(:,idx)=mean(mean(Gr(1:minT-1,:),1),2); %mean omega of each particle over each run
            GrM2=mean(Gr(1:minT-1,:),2); %mean omega of particles at each timestep
            TR(:,idx)=mean(I.*GrM2.^2,2);
        else
            TR=zeros(size(TT));
        end
    end
    ktot=TT+TR/2;
    
    G2=mean(GtM2,2);
    G3=mean(GrM2,2);
    %     G2=sort(G2,'descend');
    %     plot(usedMovs(idx).t(1:minT,1),G2);
    xd=[0:length(G2)-1]./usedMovs(1).fps;
    %     plot(xd,G2);
    %      plot(1:size(ktot,1),ktot(:,1));
    xlabel('t (s)');
    ylabel('total kinetic energy J');
    figText(gcf,18);
    %     xlim([0 125]);
    %     err2=std(GtM1);
    %     fV=mean(GtM1);
    subplot(2,2,1)
    
    plot(xd,mean(TT,2));
    title('translational');
    xlabel('time(s)');
    ylabel('energy (J)');
    % axis([0,1200,0,0.08]);
    % xlim([0 1200]);
    subplot(2,2,2)
    % plot(1:size(TR,1),mean(TR(:,1),2));
    TR2=mean(TR,2);
    % TR2(TR2>3*mean(TR2))=median(TR2);
    
    plot(xd,TR2);
    xlabel('time (s)');
    ylabel('energy (J)');
    title('rotational');
    % axis([0,1200,0,0.08]);
    % xlim([0 1200]);
    
    subplot(2,2,[3 4])
    plot(xd,mean(ktot,2));
    title('total kinetic');
    xlabel('time (s)');
    ylabel('energy (J)');
    figText(gcf,16);
    axis tight
    % xlim([0 1200]);
    ylim([0 max(mean(ktot,2)*1.2)]);
    % axis([0,1200,0,0.08]);
    
    % figure(1123);
    % a=usedMovs(1).rotdot*L/2;
    % rr=reshape(a,[1,size(a,1)*size(a,2)]);
    % hist(rr,50);
    
    
end

%% 7. phi vs time
xx=7;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ind=2;
    single = 0; % plotting out a single run
    
    %      figure(123123)
    %      [k,v]=convhull(R(:,1),R(:,2));
    %      A=R(k,:)
    % plot(A(:,1),A(:,2),'o-')
    % axis square
    
    for(idx=1:N)
        
        %         rI(1:numBods,:,idx)=[usedMovs(idx).x(1,:)',usedMovs(idx).y(1,:)'];
        %         rF(1:numBods,:,idx)=[usedMovs(idx).x(end,:)',usedMovs(idx).y(end,:)'];
        t=usedMovs(idx).t(:,1);
        x=usedMovs(idx).x;
        y=usedMovs(idx).y;
        x=x(t(:)<minT,:);
        y=y(t(:)<minT,:);
        t=t(t(:)<minT,:);
        t=t/2.5; %put in gait period form
        t=downsample(t,10);
        x=downsample(x,10);
        y=downsample(y,10);
        %         V=zeros(1,length(usedMovs(idx).x);
        V=zeros(1,length(x));
        for i=1:length(x)
            R=[x(i,:)',y(i,:)'];
            [~,V(i)]=convhull(R(:,1),R(:,2));
        end
        %         %last point is first point
        %         rI(end,:,idx)=[usedMovs(idx).x(1,1)',usedMovs(idx).y(1,1)'];
        %         rF(end,:,idx)=[usedMovs(idx).x(end,1)',usedMovs(idx).y(end,1)'];
        phi(:,idx)=V;
    end
    A=.051*.021; %area (l*w) of smarticle in m
    n=size(usedMovs(idx).x,2);%number of particles
    s=0.1428;%straight leg length of smarticle
    otherAngs=(180-(1-2/n)*180)/2*pi/180;
    sig=s*cos(otherAngs);%optitrack straight length of regular polygon
    maxAreaOpti=1/4*n*sig^2*cot(pi/n); %max optitrack convex hull area
    phi=(A*n)./phi;
    if(single)
        plot(t,phi(:,single));
        id=single;
    else
        for(j=1:size(phi,2))
            plot(t,phi(:,j));
        end
        %         for j=1:length(phi)
        %             aphi(j,:)=(A*n)./phi(j);
        %             plot(t,(A*n)./phi(j));
        %             %                 allDistances = sqrt((usedMovs(j).x(end,:)-meanx).^2+(usedMovs(j).y-meany).^2);
        %         end
        id=j;
    end
    plot([0,t(end)],[n*A/maxAreaOpti,n*A/maxAreaOpti],'r--');
    xlabel('\tau');
    ylabel('Area Fraction \phi');
    figText(gcf,16);
    
    %mean distance btween points
    
    if(~single)
        %         minT= min(cellfun(@length,aphi));
        %         phimat=zeros(minT,length(aphi));
        %         for(i=1:length(aphi))
        %             phimat(:,i)=aphi{i}(1:minT);
        %         end
        %
        
        mphi=mean(phi,2);
        ephi=std(phi,0,2);
        shadedErrorBar(t,mphi,ephi,{'color','k','linewidth',2},0.5);
        
        mphi(end)
    end
    saveOut=0;
    if(saveOut)
        if(exist('phi.mat','file')==2) %if first run has been saved
            load('phi.mat');
            
            fps=[fps,usedMovs(1).fps];
            xi=[xi,usedMovs(1).rAmp];
            finalPhi=[finalPhi;mphi(end)];
            allmPhi=[allmPhi,{mphi}];
            allePhi=[allePhi,{ephi}];
        else
            fps=usedMovs(1).fps;
            xi= usedMovs(1).rAmp;
            finalPhi=mphi(end);
            allmPhi={mphi};
            allePhi={ephi};
        end
        save('phi.mat','fps','xi','finalPhi','allmPhi','allePhi');
    end
    ylim([0.1 0.6])
    
end
%% 8. vector field plot of positions
xx=8;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    
end
%% 9 displacement vs time and theta vs time for single smarticle
xx=9;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=2;
    hold on;
    
    idx=1; %index of movie to look at
    %     for(i=1:size(usedMovs(idx).x,2) %for the number of smarticle
    
    for i=1:size(usedMovs(idx).x,2) %for the number of smarticles
        figure(xx)
        hold on;
        x= usedMovs(idx).x(:,i);%-usedMovs(idx).x(1,i);
        y= usedMovs(idx).y(:,i);%-usedMovs(idx).y(1,i);
        t= usedMovs(idx).t(:,i);%-usedMovs(idx).y(1,i);
        thet=usedMovs(idx).rot(:,i);
        
        plot(x,y);
        title('track');
        xlabel('x (m)','interpreter','latex');
        ylabel('y (m)','interpreter','latex');
        
        figure(4000+i);
        %         x=smooth(x,20);
        %         y=smooth(y,20);
        
        x=x-x(1);
        y=y-y(1);
        thet=thet-thet(1);
        
        subplot(2,1,1);
        title('$\sqrt{x^2+y^2}$','interpreter','latex')
        hold on;
        
        dx=diff(x); dy=diff(y);
        q=sqrt((x*100).^2+(y*100).^2);
        
        plot(t,q,'linewidth',lw);
        xlabel('time (s)','interpreter','latex');
        ylabel('displacement (cm)','interpreter','latex');
        
        xlim([0 maxT]);
        figText(gcf,16);
        subplot(2,1,2);
        
        hold on;
        a=wrapTo2Pi(thet-.16);
        plot(t,a,'linewidth',lw);
        %             axis([0 120 -pi-.01,pi+.01]);
        
        axis([0 maxT 0 2*pi]);
        xlabel('time (s)','interpreter','latex');
        ylabel('$\theta$ (rads)','interpreter','latex');
        %             set(gca,'YTickLabel',{'$-\pi$','','0','','$\pi$'},...
        %                 'ytick',[-pi,-pi/2,0,pi/2,pi],'ticklabelinterpreter','latex');
        
        set(gca,'YTickLabel',{'0','','$\pi$','','$2\pi$'},...
            'ytick',[0,pi/2,pi,3*pi/2,2*pi],'ticklabelinterpreter','latex');
        %             ='A:\2DSmartData\cloud\cloudTests 10-5 diamond and square gaits\rightsquare\close packed';
        %2004 idx 1 for paper fig
        figText(gcf,16);
        
        
        
    end
    pts('plotted: ',usedMovs(idx).fname);
    %     xlabel('x (m)');
    %     ylabel('y (m)');
    figText(gcf,16);
    %     axis equal
end

% f='A:\2DSmartData\cloud\cloudTests 10-5 diamond and square gaits\rightsquare\close packed';
%paper figure plot in at 'Take 2017-10-05 04.03.06 PM.csv'
% a=wrapTo2Pi(thet-.16); to remove wrapping

% f='A:\2DSmartData\singleSmarticleTrack' for single smarticle non-cloud
% a=wrapTo2Pi(thet+.05); to remove wrapping
%% 10. total path length vs time and theta vs time for single smarticle
xx=10;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=2;
    hold on;
    
    idx=1; %index of movie to look at
    %     for(i=1:size(usedMovs(idx).x,2) %for the number of smarticle
    
    for i=1:size(usedMovs(idx).x,2) %for the number of smarticle
        
        x= usedMovs(idx).x(:,i);%-usedMovs(idx).x(1,i);
        y= usedMovs(idx).y(:,i);%-usedMovs(idx).y(1,i);
        t= usedMovs(idx).t(:,i);%-usedMovs(idx).y(1,i);
        thet=usedMovs(idx).rot(:,i);
        %             y= usedMovs(idx).rot(:,i);%-usedMovs(idx).y(1,i);
        %         x=smooth(x,20);
        %         y=smooth(y,20);
        
        
        
        x=x-x(1);
        y=y-y(1);
        thet=thet-thet(1);
        %         [b,a]=butter(6,1/120*2,'low');
        x=filter(fb,fa,x);  %filtered signal
        y=filter(fb,fa,y);  %filtered signal
        thet=filter(fb,fa,thet);  %filtered signal
        
        figure(2000+i);
        subplot(2,1,1);
        title('$\int\sqrt{dx^2+dy^2}$','interpreter','latex')
        hold on;
        dx=diff(x); dy=diff(y);
        q=[0; cumsum(sqrt(dx.^2+dy.^2))]*100;
        plot(t,q,'linewidth',lw);
        GT(:,i)=q;
        
        %         plot(t,q,'linewidth',lw);
        %             xlabel('x (cm)','interpreter','latex');
        %             ylabel('y (cm)','interpreter','latex');
        xlabel('time (s)','interpreter','latex');
        ylabel('displacement (cm)','interpreter','latex');
        %             axis([0,120,0,6])
        xlim([0 maxT]);
        figText(gcf,16);
        subplot(2,1,2);
        
        hold on;
        
        a=wrapToPi(thet);
        set(gca,'YTickLabel',{'$-\pi$','','0','','$\pi$'},...
            'ytick',[-pi,-pi/2,0,pi/2,pi],'ticklabelinterpreter','latex');
        axis([0 maxT -pi pi])
        
        %         a=wrapTo2Pi(thet);
        %         set(gca,'YTickLabel',{'0','','$\pi$','','$2\pi$'},...
        %             'ytick',[0,pi/2,pi,3*pi/2,2*pi],'ticklabelinterpreter','latex');
        %         axis([0 120 0 2*pi])
        
        a=a-a(1);
        plot(t,a,'linewidth',lw);
        %             axis([0 120 -pi-.01,pi+.01]);
        
        %         axis([0 120 0 2*pi]);
        xlabel('time (s)','interpreter','latex');
        ylabel('$\theta$ (rads)','interpreter','latex');
        
        
        
        
        
        %         set(gca,'YTickLabel',{'0','','$\pi$','','$2\pi$'},...
        %             'ytick',[0,pi/2,pi,3*pi/2,2*pi],'ticklabelinterpreter','latex');
        %         axis([0 120 0 2*pi])
        %             ='A:\2DSmartData\cloud\cloudTests 10-5 diamond and square gaits\rightsquare\close packed';
        %2004 idx 1 for paper fig
        figText(gcf,16);
        
        
        figure(xx);
        
        subplot(2,1,1);
        hold on;
        title('$\int\sqrt{dx^2+dy^2}$','interpreter','latex')
        plot(t,q,'linewidth',lw);
        xlabel('time (s)','interpreter','latex');
        ylabel('displacement (cm)','interpreter','latex');
        figText(gcf,16);
        subplot(2,1,2);
        hold on;
        plot(t,a,'linewidth',lw);
        xlabel('time (s)','interpreter','latex');
        ylabel('$\theta$ (rads)','interpreter','latex');
        set(gca,'YTickLabel',{'0','','$\pi$','','$2\pi$'},...
            'ytick',[0,pi/2,pi,3*pi/2,2*pi],'ticklabelinterpreter','latex');
    end
    pts('plotted: ',usedMovs(idx).fname);
    %     xlabel('x (m)');
    %     ylabel('y (m)');
    figText(gcf,16);
    %     axis equal
end

% f='A:\2DSmartData\cloud\cloudTests 10-5 diamond and square gaits\rightsquare\close packed';
%paper figure plot in at 'Take 2017-10-05 04.03.06 PM.csv'
% a=wrapTo2Pi(thet-.16); to remove wrapping

% f='A:\2DSmartData\singleSmarticleTrack' for single smarticle non-cloud
% a=wrapTo2Pi(thet+.05); to remove wrapping

%% 11. granular temperature v2
xx=11;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=2;
    hold on;
    saveOut=0;
    filtz=0;
    idx=singInd; %index of movie to look at
    %     for(i=1:size(usedMovs(idx).x,2) %for the number of smarticle
    GTTAll=[];
    GTRAll=[];
    for k=1:N
        GTT=[];
        for i=1:size(usedMovs(k).x,2) %for the number of smarticles
            x= usedMovs(k).x(:,i);%-usedMovs(idx).x(1,i);
            y= usedMovs(k).y(:,i);%-usedMovs(idx).y(1,i);
            t= usedMovs(k).t(:,i);%-usedMovs(idx).y(1,i);
            thet=usedMovs(k).rot(:,i);
            
            x=x(t(:)<minT,:);
            y=y(t(:)<minT,:);
            thet=thet(t(:)<minT,:);
            t=t(t(:)<minT,:);
            t=t/2.5; %put in gait period form
            
            x=x-x(1);
            y=y-y(1);
            thet=thet-thet(1);
            t=downsample(t,10);
            x=downsample(x,10);
            y=downsample(y,10);
            thet=downsample(thet,10);
            if(filtz)
                %                  s(i).F=lowpass(x,5,samp,'ImpulseResponse','iir');
                %                 thet=lowpass(thet,5,1/diff(t(1:2)));
                %                 lowpass(x,5,1/diff(t(1:2)),'ImpulseResponse','iir');
                %                 x=lowpass(y,5,1/diff(t(1:2)));
                %             [b,a]=butter(6,1/120*2,'low');
                x=filter(fb,fa,x);  %filtered signal
                y=filter(fb,fa,y);  %filtered signal
                thet=filter(fb,fa,thet);  %filtered signal
                
            end
            dx=diff(x); dy=diff(y);dr=diff(thet);
            q=[0; cumsum(sqrt(dx.^2+dy.^2))]*100;
            r=[0; cumsum(sqrt(dr.^2))];
            GTT(:,i)=q;
            GTR(:,i)=r;
        end
        GTTAll(:,k)=mean(GTT,2); %translational granular temp
        GTRAll(:,k)=mean(GTR,2); %translational granular temp
        %     GTRAll(:,k)=mean(GTR,2); %rotational granular temp
        figure(55);
        hold on;
        plot(t,GTTAll(:,k));
        figure(124);
        hold on;
        plot(t,GTRAll(:,k),'--');
    end
    figure(55);
    plot(t,mean(GTTAll,2),'k','linewidth',2);
    figure(124);
    plot(t,mean(GTRAll,2),'--k','linewidth',2);
    
    xlabel('\tau');
    ylabel('displacement,rotation (cm,rads)');
    
    %     xlim([0 maxT]);
    mt=[max(mean(GTTAll,2))];
    mte=std(max(GTTAll,[],2),0,1);
    mr=[max(mean(GTRAll,2))];
    mre=std(max(GTRAll,[],2),0,1);
    % f='A:\2DSmartData\cloud\cloudTests 10-5 diamond and square gaits\rightsquare\close packed';
    %paper figure plot in at 'Take 2017-10-05 04.03.06 PM.csv'
    % a=wrapTo2Pi(thet-.16); to remove wrapping
    
    % f='A:\2DSmartData\singleSmarticleTrack' for single smarticle non-cloud
    % a=wrapTo2Pi(thet+.05); to remove wrapping
    [mt,mte;mr,mre]
    
    
    if(saveOut)
        if(exist('GT.mat','file')==2) %if first run has been saved
            load('GT.mat');
            gtR=[gtR,{mean(GTRAll,2)}];
            egtR=[egtR,{std(GTRAll,0,2)}];
            gtT=[gtT,{mean(GTTAll,2)}];
            egtT=[egtT,{std(GTTAll,0,2)}];
            
            t=[t,{[1:length(mean(GTRAll,2))]./usedMovs(1).fps}];
            fps=[fps,usedMovs(1).fps];
            xi=[xi,usedMovs(1).rAmp];
        else
            gtR={mean(GTRAll,2)};
            egtR={std(GTRAll,0,2)};
            gtT={mean(GTTAll,2)};
            egtT={std(GTTAll,0,2)};
            
            fps=usedMovs(1).fps;
            t={[1:length(mean(GTRAll,2))]./fps};
            xi=usedMovs(1).rAmp;
        end
        save('GT.mat','gtR','gtT','egtR','egtT','fps','t','cutoff','sampRate','filtOrder','xi');
    end
    ylim([0 180]);
    %
    
    
    %     figure(444)
    %     hold on;
    %     plot(t(1:end-1),diff(mean(GTTAll,2))./diff(t),'linewidth',1);
    %     ylabel('d<S>/dt');
    %     xlabel('t(s)');
end
%% 12. compiled granular temperature data
xx=12;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=2;
    hold on;
    
    x=[0 200 400 600 800 1000];
    
    %nonfiltered
    % yt=[81.8878 94.5277 127.6742 72.6423];
    % yte=[26.3643 29.5863 42.6499 20.0665];
    % yr=[118.5865 68.6063 151.3340 60.6466];
    % yre=[42.2075 26.0797 66.8817 17.5103];
    
    %filtered
    yt=[41.7259 55.0991 70.9126 72.2794 67.0875 73.0501];
    yte=[13.6990 18.9334 26.0592 25.1421 18.9005 22.5646];
    % yr=[76.3638 53.9141 106.9800 18.9320];
    % yre=[26.8491 19.0759 37.3578 6.5970];
    yr=[53.6353 53.9141 64.1974 59.6325 64.2384  66.8990] ;
    yre=[19.5214 19.0759 23.1742 20.7481 19.5432 21.5626];
    
    
    errorbar(x,yt,yte,'linewidth',2);
    errorbar(x,yr,yre,'--','linewidth',2);
    legz={'$G_t$','$G_r$'};
    
    xlabel('Random Amplitude $\xi$ (ms)','interpreter','latex');
    ylabel('$G_t$ (cm); $G_r$ (rads)','interpreter','latex');
    figText(gcf,16);
    legend(legz,'interpreter','latex','fontsize',12);
    xlim([0,1000])
end

%% 13. d<s>/dt
xx=13;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ti=100; %initial t
    filtz=1; %0 if no filter 1=filter
    expfit=2;
    idx=1; %index of movie to look at
    %     for(i=1:size(usedMovs(idx).x,2) %for the number of smarticle
    GTTAll=[];
    for k=1:N
        GTT=[];
        for i=1:size(usedMovs(k).x,2) %for the number of smarticles
            x= usedMovs(k).x(:,i);%-usedMovs(idx).x(1,i);
            y= usedMovs(k).y(:,i);%-usedMovs(idx).y(1,i);
            t= usedMovs(k).t(:,i);%-usedMovs(idx).y(1,i);
            thet=usedMovs(k).rot(:,i);
            
            x=x(t(:)<minT,:);
            y=y(t(:)<minT,:);
            thet=thet(t(:)<minT,:);
            t=t(t(:)<minT,:);
            
            
            
            x=x-x(1);
            y=y-y(1);
            thet=thet-thet(1);
            
            
            if(filtz)
                x=filter(fb,fa,x);  %filtered signal
                y=filter(fb,fa,y);  %filtered signal
                thet=filter(fb,fa,thet);  %filtered signal
            end
            dx=diff(x); dy=diff(y);dr=diff(thet);
            q=[0; cumsum(sqrt(dx.^2+dy.^2))]*100;
            r=[0; cumsum(sqrt(dr.^2))];
            GTT(:,i)=q;
            GTR(:,i)=r;
        end
        GTTAll(:,k)=mean(GTT,2); %translational granular temp
        GTRAll(:,k)=mean(GTR,2); %translational granular temp
        %     GTRAll(:,k)=mean(GTR,2); %rotational granular temp
        
    end
    
    mGTTAll=mean(GTTAll,2);
    mGTRAll=mean(GTRAll,2);
    
    %     figure(23)
    %     hold on;
    %         h=plot(t(1:end-1),diff(mGTTAll)./diff(t),'linewidth',1);
    %         plot(t(1:end-1),diff(mGTRAll)./diff(t),'--','linewidth',1);
    %
    
    
    x=t(ti:end-1);
    y=diff(mGTTAll(ti:end))./diff(t(ti:end));
    
    saveOut=0;
    
    if(expfit==1)
        f=fit(x,y,'exp1');
        text(.1, 0.25,['ae^{bx}',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f')],'fontsize',16,'units','normalized')
        yf=f.a*exp(f.b*x);
    elseif (expfit==2) %stretched exp
        y=y/max(y);
        fo = fitoptions('Method','NonlinearLeastSquares',...
            'Lower',[0,0],...
            'Upper',[Inf,max(y)],...
            'StartPoint',[1 1]);
        ft = fittype('exp(-(x./a).^b)','options',fo);
        f=fit(x,y,ft);
        %         text(.1, 0.25,['ax^{b}+c',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f'),newline,'c=',num2str(f.c,'%.3f')],'fontsize',16,'units','normalized')
        %         yf=f.a*x.^f.b+f.c;
        %         text(.1, 0.25,['ax^{b}',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f')],'fontsize',16,'units','normalized');
        yf=exp(-(x./f.a).^(f.b));
        
        
        if(saveOut)
            if(exist('expz.mat','file')==2) %if first run has been saved
                load('expz.mat');
                expz=[expz;usedMovs(1).rAmp,f.a,f.b];
            else
                expz=[usedMovs(1).rAmp,f.a,f.b];
            end
            save('expz.mat','expz');
        end
        text(.7, 0.8,['exp[-(x/\tau)^{\beta}]',newline,'\tau=',num2str(f.a,'%.3f'),newline,'\beta=',num2str(f.b,'%.3f')],'fontsize',16,'units','normalized');
    else
        f=fit(x,y,'power1');
        %         text(.1, 0.25,['ax^{b}+c',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f'),newline,'c=',num2str(f.c,'%.3f')],'fontsize',16,'units','normalized')
        %         yf=f.a*x.^f.b+f.c;
        text(.7, 0.8,['ax^{b}',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f')],'fontsize',16,'units','normalized');
        if(saveOut)
            if(exist('powFit.mat','file')==2) %if first run has been saved
                load('powFit.mat');
                powFit=[powFit;usedMovs(1).rAmp,f.a,f.b];
            else
                powFit=[usedMovs(1).rAmp,f.a,f.b];
            end
            save('powFit.mat','powFit');
        end
        
        yf=f.a*x.^f.b;
    end
    plot(x,yf,'-r');
    plot(x,y,'linewidth',1);
    ylabel('d<S>/dt');
    xlabel('t(s)');
    
    %     figure(99);
    %     plot(f,x,y,'.');
    %
    %     figure(27);
    %     hold on;
    % %     plot(x,yf);
    %
    %     yi=yf(end);
    %     idx=max(find(abs(yf-yi)>=0.66*yi));
    %     xv=[0 200 400 600 800 1000];
    % %     v=x(idx)
    %     vv=[  55.6667 44.6583 34.2667 71.0333 33.8500 39.8000];
    % plot(xv,vv);
end

%% 14. plot contact time vs rand amp
xx=14;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=2;
    hold on;
    
    cyc0= [9 7 4 3 4 2 4 3 25 30 7 6 2 3 2 1 3 1 2 2 7 24 2]; % 0 rand del
    cyc200=[0];
    cyc400=[3 7 11 5 8 7 11 21 8 19 4 8 5 10 5 20 4 24]; % 400 rand del
    cyc600=[0];
    cyc800=[0];
    cyc1000=[0];
    
    cyc={cyc0,cyc200,cyc400,cyc600,cyc800,cyc1000};
    mCyc=cellfun(@mean,cyc);
    eCyc=cellfun(@std,cyc);
    errCyc=eCyc./sqrt(cellfun(@length,cyc));
    del=[0 200 400 600 800 1000];
    
    errorbar(del,mCyc,eCyc);
    
    
end

%% 15 plot final phi for diff gait types
xx=15;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=2;
    hold on;
    
    
    single = 0; % plotting out a single run
    
    finalPhi=zeros(N,1);
    iPhi=zeros(N,1);
    for(idx=1:N)
        
        %         rI(1:numBods,:,idx)=[usedMovs(idx).x(1,:)',usedMovs(idx).y(1,:)'];
        %         rF(1:numBods,:,idx)=[usedMovs(idx).x(end,:)',usedMovs(idx).y(end,:)'];
        V=zeros(1,length(usedMovs(idx).x));
        for i=1:length(usedMovs(idx).x)
            R=[usedMovs(idx).x(i,:)',usedMovs(idx).y(i,:)'];
            [~,V(i)]=convhull(R(:,1),R(:,2));
            
        end
        %         %last point is first point
        %         rI(end,:,idx)=[usedMovs(idx).x(1,1)',usedMovs(idx).y(1,1)'];
        %         rF(end,:,idx)=[usedMovs(idx).x(end,1)',usedMovs(idx).y(end,1)'];
        phi{idx}=V;
    end
    A=.051*.021; %area (l*w) of smarticle in m
    n=size(usedMovs(idx).x,2);%number of particles
    s=0.1428;%straight leg length of smarticle
    otherAngs=(180-(1-2/n)*180)/2*pi/180;
    sig=s*cos(otherAngs);%optitrack straight length of regular polygon
    maxAreaOpti=1/4*n*sig^2*cot(pi/n); %max optitrack convex hull area
    %      warning('cutting off runs at 2 mins or 1440 frames for 30fps');
    if(single)
        
        
        %         finalPhi=[finalPhi,phival(end)];
        finalPhi=[finalPhi,phival(end)];
        
        plot((1:length(phi{single}))./usedMovs(single).fps,phival);
        id=single;
    else
        for j=1:length(phi)
            phival=(A*n)./phi{j};
            finalPhi(j)=phival(end);
            iPhi(j)=phival(1);
            %             plot((1:length(phi{j}))./usedMovs(j).fps,phival);
            meanx = mean(usedMovs(j).x(end,:));
            meany = mean(usedMovs(j).y(end,:),2);
            %                 allDistances = sqrt((usedMovs(j).x(end,:)-meanx).^2+(usedMovs(j).y-meany).^2);
        end
        id=j;
    end
    %     plot([0,usedMovs(id).t(end)],[n*A/maxAreaOpti,n*A/maxAreaOpti],'r--');
    xlabel('gait type');
    ylabel('\phi_f');
    figText(gcf,16);
    
    LDcp=[0.2704 0.1936 0.1781 0.2119 0.2089];
    LDlp=[0.1816 0.2332 0.2202 0.2178 0.1877 0.1926];
    
    LScp=[0.2480 0.1673 0.2000 0.1710 0.1809 0.1861];
    LSlp=[0.1611 0.1985 0.3008 0.2783 0.2386 0.1588];
    
    RScp=[0.1756 0.2216 0.1501 0.1959 0.1948 0.1404 0.2919];
    
    
    
    
    %mean distance btween points
    %     finalPhi
    pts(mean(finalPhi),'+-',std(finalPhi));
    pts(mean(iPhi-finalPhi),'+-',std(iPhi-finalPhi));
    xlim([0 6])
    x=[1 2 3 4 5];
    y=[mean(LDcp) mean(LDlp) mean(LScp) mean(LSlp) mean(RScp)];
    yerr=[std(LDcp) std(LDlp) std(LScp) std(LSlp) std(RScp)];
    set(gca,'xtick',[1 2 3 4 5],'xticklabel',{'LDcp','LDlp','LScp','LSlp','RScp'},'colororderindex',3);
    bar(x,y);
    errorbar(x,y,yerr,'.');
    
end

%% 16 plot stretched exponential data for different delays
xx=16;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on
    %     load('expzn.mat');
    load('expz.mat');
    %     yf=exp(-(x./f.a).^(f.b));
    %   [xi,tau,beta]
    [xi,tau,beta]=separateVec(expz,1);
    xi(1)=1;
    t0=max(tau);
    b0=max(beta);
    plot(xi,tau);
    plot(xi,beta);
    plot(xi,log(tau));
    hold on;
    xlabel('\xi');
    ylabel('fit pars \tau[1/s], \beta');
    legend({'\tau','\beta','log(\tau/t0)'})
    title('stretch exp fits exp(-(t/{\tau})^{\beta})')
    
end

%% 17 plot out phi for different delays
xx=17;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on
    load('phi.mat');
    
    
    [ftau,fbeta]=deal(zeros(length(allmPhi),1));
    for(i=1:length(allmPhi))
        tt=[1:length(allmPhi{i})]'./fps(i);
        y=allmPhi{i};
        %         plot(tt,allmPhi{i});
        
        fo = fitoptions('Method','NonlinearLeastSquares',...
            'Lower',[0,0],...
            'Upper',[Inf,max(y)],...
            'StartPoint',[1 1]);
        ft = fittype('exp(-(x./a).^b)','options',fo);
        f=fit(tt,y,'power1');
        ftau(i)=f.a; fbeta(i)=f.b;
        plot(f,tt,y);
        %         pause(1);
    end
    xlabel('t(s)');
    ylabel('\phi');
    
    figure(18);
    err=zeros(length(allePhi),1);
    for i=1:length(err)
        err(i)=allePhi{i}(end);
    end
    errorbar(xi,finalPhi,err,'linewidth',2);
    xlabel('\xi(s)');
    ylabel('\phi_f');
    xlabel('Random Amplitude $\xi$ (ms)','interpreter','latex');
    figText(gcf,16);
    xlim([-20,1020]);
    figure(19);
    hold on;
    xlabel('\xi(s)');
    ylabel('\tau,\beta');
    plot(xi,ftau);
    plot(xi,fbeta);
end

%% 20 plot out all gran temp data for different delays
xx=20;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on
    load('GT.mat');
    %     yf=exp(-(x./f.a).^(f.b));
    %   [xi,tau,beta]
    hold on;
    expfit=0;
    
    its=length(gtT);
    [coef,pow]=deal(zeros(its,1));
    
    for i=1:its
        x=t{i}';
        y=gtT{i};
        
        if(expfit==1)
            f=fit(x,y,'exp1');
            text(.1, 0.25,['ae^{bx}',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f')],'fontsize',16,'units','normalized')
            yf=f.a*exp(f.b*x);
        elseif (expfit==2) %stretched exp
            y=y/max(y);
            fo = fitoptions('Method','NonlinearLeastSquares',...
                'Lower',[0,0],...
                'Upper',[Inf,max(y)],...
                'StartPoint',[1 1]);
            ft = fittype('exp(-(x./a).^b)','options',fo);
            f=fit(x,y,ft);
            %         text(.1, 0.25,['ax^{b}+c',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f'),newline,'c=',num2str(f.c,'%.3f')],'fontsize',16,'units','normalized')
            %         yf=f.a*x.^f.b+f.c;
            %         text(.1, 0.25,['ax^{b}',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f')],'fontsize',16,'units','normalized');
            yf=exp(-(x./f.a).^(f.b));
            %         expz=[f.a,f.b];
            %                 load('expz.mat');
            %                 expz=[expz;f.a,f.b];
            %                 save('expz.mat','expz');
        else
            f=fit(x,y,'power1');
            %         text(.1, 0.25,['ax^{b}+c',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f'),newline,'c=',num2str(f.c,'%.3f')],'fontsize',16,'units','normalized')
            %         yf=f.a*x.^f.b+f.c;
            %             text((i-1)/its, 0.25,['ax^{b}',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f')],'fontsize',16,'units','normalized');
            %             text(.1, 0.25,['ax^{b}',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f')],'fontsize',16,'units','normalized');
            yf=f.a*x.^f.b;
        end
        
        plot(x,y,'linewidth',2);
        plot(x,yf,'r--')
        coef(i)=f.a; pow(i)=f.b;
        pause(1);
        
    end
    figure(453);
    hold on;
    plot(xi,coef);
    plot(xi,pow);
    xlabel('\xi');
    ylabel('fit pars');
    legend({'coefficient','power'})
    title('fitting gran temperature to ax^b')
end
%% 21 final gran temp R and T for all delays
xx=21;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on
    if(exist(fullfile(fold,'GT.mat'),'file'))
        load('GT.mat');
    elseif(exist(fullfile(fold,'..\GT.mat'),'file'))
        load(fullfile(fold,'..\GT.mat'));
    else
        error('couldn''t find GT.mat');
    end
    
    for i=1:length(egtR)
        errR(i)=egtR{i}(end);
        errT(i)=egtT{i}(end);
        R(i)=gtR{i}(end);
        T(i)=gtT{i}(end);
    end
    errorbar(xi,T,errT,'linewidth',2);
    errorbar(xi,R,errR,'--','linewidth',2);
    
    legz={'$G_t$','$G_r$'};
    xlabel('Random Amplitude $\xi$ (ms)','interpreter','latex');
    ylabel('$G_t$ (cm); $G_r$ (rads)','interpreter','latex');
    
    xlim([-20,1020]);
    figText(gcf,16);
    legend(legz,'interpreter','latex','fontsize',12);
end
%% 22 histogram of phi changes
xx=22;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    %     ind=9;
    single = 6; % plotting out a single run
    ts=1;
    %      figure(123123)
    %      [k,v]=convhull(R(:,1),R(:,2));
    %      A=R(k,:)
    % plot(A(:,1),A(:,2),'o-')
    % axis square
    
    
    for(idx=1:N)
        
        %         rI(1:numBods,:,idx)=[usedMovs(idx).x(1,:)',usedMovs(idx).y(1,:)'];
        %         rF(1:numBods,:,idx)=[usedMovs(idx).x(end,:)',usedMovs(idx).y(end,:)'];
        V=zeros(1,length(usedMovs(idx).x));
        for i=1:length(usedMovs(idx).x)
            R=[usedMovs(idx).x(i,:)',usedMovs(idx).y(i,:)'];
            [~,V(i)]=convhull(R(:,1),R(:,2));
            
        end
        %         %last point is first point
        %         rI(end,:,idx)=[usedMovs(idx).x(1,1)',usedMovs(idx).y(1,1)'];
        %         rF(end,:,idx)=[usedMovs(idx).x(end,1)',usedMovs(idx).y(end,1)'];
        phi{idx}=V;
    end
    A=.051*.021; %area (l*w) of smarticle in m
    n=size(usedMovs(idx).x,2);%number of particles
    s=0.1428;%straight leg length of smarticle
    otherAngs=(180-(1-2/n)*180)/2*pi/180;
    sig=s*cos(otherAngs);%optitrack straight length of regular polygon
    maxAreaOpti=1/4*n*sig^2*cot(pi/n); %max optitrack convex hull area
    minT=min(cellfun(@length,phi));
    if(single)
        id=single;
        %         plot((1:length(phi{single}))./usedMovs(id).fps,(A*n)./phi{id});
        aphi=(A*n)./phi{id}(1:minT)';
        figure(23);
        plot((1:length(phi{id}))./usedMovs(id).fps,(A*n)./phi{id});
        xlabel('time (s)');
        ylabel('\phi');
        figText(gcf,16);
        figure(22);
        hold on;
    else
        
        for j=1:length(phi)
            aphi(:,j)=(A*n)./phi{j}(1:minT);
            %             plot((1:length(phi{j}))./usedMovs(j).fps,(A*n)./phi{j});
            %                 allDistances = sqrt((usedMovs(j).x(end,:)-meanx).^2+(usedMovs(j).y-meany).^2);
        end
        id=j;
    end
    aphi=aphi(1:ts:end,:);
    
    %     plot([0,usedMovs(id).t(end)],[n*A/maxAreaOpti,n*A/maxAreaOpti],'r--');
    daphi=diff(aphi,1,1)/((1/usedMovs(1).fps*ts));
    
    sk=skewness(daphi)'
    mean(mean(sk))
    %     daphi=daphi(:);
    d2=filter(fb,fa,daphi);  %filtered signal
    histogram(daphi);
    % sk=skewness(d2)'
    xlabel(['\phi(t_n-t_{n-',num2str(ts),'})']);
    ylabel('counts');
    figText(gcf,16);
    
end
%% 24 phi changes at all D
xx=24;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    single = 9; % plotting out a single run
    
    
    frames=size(usedMovs(single).x,1);
    robs=7;
    P=zeros(robs,robs,frames);
    outlen=(robs^2-robs)/2;
    pv=zeros(outlen,frames);
    for i=1:frames
        [X1,X2]=meshgrid(usedMovs(single).x(i,:));
        [Y1,Y2]=meshgrid(usedMovs(single).y(i,:));
        
        % Z1=cat(3,triu(X1),triu(Y1));
        % Z2=cat(3,triu(X2),triu(Y2));
        % P(:,:,i)=sqrt(sum((Z1-Z2).^2,3));
        
        Z1=cat(3,triu(X1),triu(Y1));
        Z2=cat(3,triu(X2),triu(Y2));
        
        %     Z1=Z1(triu(Z1)>0);
        %     Z2=Z2(triu(Z2)>0);
        p=sqrt(sum((Z1-Z2).^2,3));
        pv(:,i)=p(triu(p)>0);
        P(:,:,i)=sqrt(sum((Z1-Z2).^2,3));
    end
    dpv=diff(pv,1,2);
    dpvr=reshape(dpv,[numel(dpv),1]);
    pvr=reshape(pv(:,1:end-1),[numel(pv(:,1:end-1)),1]);
    [Y,E]=discretize(pvr,300);
    Z=E(Y);
    scatter(Z,dpvr,'k.');
    %     scatter(pvr,dpvr,'k.');
    %     for(i=1:outlen)
    %         scatter(pv(i,1:end-1),dpv(i,:),'k.');
    %     end
    ylabel('Dist out');
    ylabel('Dist in');
    figure(123);
    histogram(dpvr);
    
    figText(gcf,16);
    
end
%% 25 cloud diffusion all smart tracks
xx=25;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ma = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
    filtz=0;
    COM=cell(N*numBods,1);
    countIdx=1;
    for k=1:N
        
        for(i=1:numBods)
            x= usedMovs(k).x(:,i);%-usedMovs(idx).x(1,i);
            y= usedMovs(k).y(:,i);%-usedMovs(idx).y(1,i);
            t= usedMovs(k).t(:,1);%-usedMovs(idx).y(1,i);
            if(filtz)
                x=filter(fb,fa,x);  %filtered signal
                y=filter(fb,fa,y);  %filtered signal
            end
            COM{countIdx}=[t,x,y];
            countIdx=countIdx+1;
        end
    end
    ma = ma.addAll(COM);
    tic;
    
    if(isempty(ma.msd))
        %         ma = ma.computeMSD;
        if(filtz)
            if exist(fullfile(fold,'maSmartDatFilt.mat'),'file')
                load(fullfile(fold,'maSmartDatFilt.mat'));
            else
                ma = ma.computeMSD;
                save(fullfile(fold,'maSmartDatFilt.mat'),'ma');
            end
        else
            if exist(fullfile(fold,'maSmartDatRaw.mat'),'file')
                load(fullfile(fold,'maSmartDatRaw.mat'));
            else
                ma = ma.computeMSD;
                save(fullfile(fold,'maSmartDatRaw.mat'),'ma');
            end
            %             load(fullfile(fold,'maCOMDatRaw.mat'));
        end
    end
    toc
    
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
    
    toc
end
%% 26 cloud diffusion com tracks
xx=26;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    ma = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
    filtz=0;
    COM=cell(N,1);
    
    for i=1:N
        t= usedMovs(i).t(:,1);%-usedMovs(idx).y(1,i);
        if(filtz)
            x=filter(fb,fa,usedMovs(i).x);  %filtered signal
            y=filter(fb,fa,usedMovs(i).y);  %filtered signal
        end
        COM{i}=[t,sum(usedMovs(i).x,2)/numBods,sum(usedMovs(i).y,2)/numBods];
        %         COM{i}=COM{i}-COM{i}(1,:);
        %         plot(COM{i}(:,2),COM{i}(:,3),'linewidth',lw);
        
    end
    ma = ma.addAll(COM);
    tic
    if(isempty(ma.msd))
        %         ma = ma.computeMSD;
        if(filtz)
            if exist(fullfile(fold,'maCOMDatFilt.mat'),'file')
                load(fullfile(fold,'maCOMDatFilt.mat'));
            else
                ma = ma.computeMSD;
                save(fullfile(fold,'maCOMDatFilt.mat'),'ma');
            end
        else
            if exist(fullfile(fold,'maCOMDatRaw.mat'),'file')
                load(fullfile(fold,'maCOMDatRaw.mat'));
            else
                ma = ma.computeMSD;
                save(fullfile(fold,'maCOMDatRaw.mat'),'ma');
            end
            %             load(fullfile(fold,'maCOMDatRaw.mat'));
        end
    end
    toc
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
%% 27 cloud nearest neighbor distance for single run
xx=27;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    downSampBy=10;
    n=size(usedMovs(singInd).x,2);
    x=usedMovs(singInd).x;
    y=usedMovs(singInd).y;
    thet=usedMovs(singInd).rot;
    t=usedMovs(singInd).t(:,1);
    
    x=x(t(:)<minT,:);
    y=y(t(:)<minT,:);
    thet=thet(t(:)<minT,:);
    t=t(t(:)<minT,:);
    t=t/2.5; %put in gait period form
    
    x=x-x(1);
    y=y-y(1);
    
    x=downsample(x,downSampBy);
    y=downsample(y,downSampBy);
    t=downsample(t,downSampBy);
    
    frames=length(t(t<minT));
    %     P=zeros(robs,robs,frames);
    P=zeros(n,n,1);
    outlen=(n^2-n)/2;
    %     pv=zeros(outlen,frames);
    d=zeros(frames,n-1);
    v=zeros(frames,n-1);
    
    for i=1:frames
        [X1,X2]=meshgrid(usedMovs(singInd).x(i,:));
        [Y1,Y2]=meshgrid(usedMovs(singInd).y(i,:));
        
        
        
        Z1=cat(3,X1,Y1);
        Z2=cat(3,X2,Y2);
        % P(:,:,i)=sqrt(sum((Z1-Z2).^2,3));
        
        %         Z1=cat(3,triu(X1),triu(Y1));
        %         Z2=cat(3,triu(X2),triu(Y2));
        
        %         p=sqrt(sum((Z1-Z2).^2,3));
        %         pv(:,i)=p(triu(p)>0);
        distMat=sqrt(sum((Z1-Z2).^2,3));
        distMat(distMat==0)=nan;
        %         [d(i,:) v(i,:)]=min(distMat,[],1,'omitnan');
        
        [dTemp vTemp]=min(distMat);
        % indices to unique values in column 3
        v2=vTemp; %for plotting out in commented code below
        
        [~, ind] = unique(vTemp+[1:n]);
        % duplicate indices
        dup = setdiff(1:size(vTemp, 1), ind);
        vTemp(dup)=[];
        dTemp(dup)=[];
        v(:,i)=vTemp; d(:,i)=dTemp;
        
        %         plot out shortest dist
        
        %remove 0 diagonals from matrix
        %a = distMat';
        %distMat = reshape(a(~eye(size(a))), size(distMat, 2)-1, [])';
        
        for k=(1:n)
            scatter(x(i,k),y(i,k));
            plot([x(i,k),x(i,v2(i,k))],...
                [y(i,k),y(i,v2(i,k))]);
        end
    end
    dOut=d(:);
    xAx=ceil((1:frames*robs)/robs);
    scatter(xAx./usedMovs(singInd).fps,dOut);
    plot([1:frames]./usedMovs(singInd).fps,mean(d,2),'k','linewidth',2);
    
    ylabel('min(smart distance)');
    xlabel('time(s)');
    
    
    figure(1234);
    hold on;
    md=mean(d,2);
    [dm,idx]=sort(mean(d(2:end,:),2));
    dgt=diff(GTTAll(:,singInd));
    dgr=diff(GTRAll(:,singInd));
    gt=GTTAll(2:end,singInd);
    gr=GTRAll(2:end,singInd);
    
    dgt=dgt(idx);
    dgr=dgr(idx);
    
    plot(dm,dgr,'--');
    plot(dm,dgt,'-');
    
    %     plot([1:frames]/usedMovs(singInd).fps,md);
    ylabel('\Delta \langleSystem Granular Temp\rangle');
    xlabel('\langleMin smarticle distance\rangle');
    figText(gcf,16);
    
    
    figure(124);
    plot([1:frames]/usedMovs(singInd).fps,md);
    xlabel('time(s)');
    ylabel('\langleMin smarticle distance\rangle');
    figText(gcf,16);
    
    figure(1256);
    phiz=(A*n)./phi{singInd};
    phiz=phiz(1:frames-1);
    plot(dm,phiz)
    xlabel('\langleMin smarticle distance\rangle');
    ylabel('\phi');
    figText(gcf,16);
    
    figure(3256);
    plot(dm,gr,'--');
    plot(dm,gt,'-');
    ylabel('\langleSystem Granular Temp\rangle');
    xlabel('\langleMin smarticle distance\rangle');
    figText(gcf,16);
end
%% 28 cloud nearest neighbor distance for all runs *NOT DONE*
xx=28;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    
    frames=size(usedMovs(singInd).t(:)<minT,1);
    robs=7;
    %     P=zeros(robs,robs,frames);
    P=zeros(robs,robs,1);
    outlen=(robs^2-robs)/2;
    %     pv=zeros(outlen,frames);
    d=zeros(frames,robs);
    v=zeros(frames,robs);
    for j=1:N
        
        x=usedMovs(j).x;
        y=usedMovs(j).y;
        thet=usedMovs(j).rot;
        t=usedMovs(j).t(:,1);
        
        x=x(t(:)<minT,:);
        y=y(t(:)<minT,:);
        thet=thet(t(:)<minT,:);
        t=t(t(:)<minT,:);
        t=t/2.5; %put in gait period form
        
        x=x-x(1);
        y=y-y(1);
        
        x=downsample(x,downSampBy);
        y=downsample(y,downSampBy);
        t=downsample(t,downSampBy);
        for i=1:frames
            [X1,X2]=meshgrid(x);
            [Y1,Y2]=meshgrid(y);
            
            
            
            Z1=cat(3,X1,Y1);
            Z2=cat(3,X2,Y2);
            % P(:,:,i)=sqrt(sum((Z1-Z2).^2,3));
            
            %         Z1=cat(3,triu(X1),triu(Y1));
            %         Z2=cat(3,triu(X2),triu(Y2));
            
            %         p=sqrt(sum((Z1-Z2).^2,3));
            %         pv(:,i)=p(triu(p)>0);
            P(:,:)=sqrt(sum((Z1-Z2).^2,3));
            P(P==0)=nan;
            [d(i,:) v(i,:)]=min(P,[],1,'omitnan');
            %         plot out shortest dist
            %         for k=(1:robs)
            %         scatter(usedMovs(single).x(i,k),usedMovs(single).y(i,k));
            %         plot([usedMovs(single).x(i,k),usedMovs(single).x(i,v(i,k))],...
            %             [usedMovs(single).y(i,k),usedMovs(single).y(i,v(i,k))]);
            %         end
        end
    end
    dOut=d(:);
    xAx=ceil((1:frames*robs)/robs);
    scatter(xAx,dOut);
    plot([1:frames]./usedMovs(1).fps,mean(d,2));
    
    ylabel('min(smart distance)');
    xlabel('frames');
    figText(gcf,16);
    
    
    
end
%% 29. phidt vs. granular temp
xx=29;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    %requires that all runs have the same number of smarticles
    A=.051*.021; %area (l*w) of smarticle in m
    n=size(usedMovs(1).x,2);
    downSampBy=10;
    s=0.1428;%straight leg length of smarticle
    otherAngs=(180-(1-2/n)*180)/2*pi/180;
    sig=s*cos(otherAngs);%optitrack straight length of regular polygon
    maxAreaOpti=1/4*n*sig^2*cot(pi/n); %max optitrack convex hull area
    GTTAll=[];
    GTRAll=[];
    filtz=0;
    for(idx=1:N)
        
        %         rI(1:numBods,:,idx)=[usedMovs(idx).x(1,:)',usedMovs(idx).y(1,:)'];
        %         rF(1:numBods,:,idx)=[usedMovs(idx).x(end,:)',usedMovs(idx).y(end,:)'];
        
        x=usedMovs(idx).x;
        y=usedMovs(idx).y;
        thet=usedMovs(idx).rot;
        t=usedMovs(idx).t(:,1);
        
        x=x(t(:)<minT,:);
        y=y(t(:)<minT,:);
        thet=thet(t(:)<minT,:);
        t=t(t(:)<minT,:);
        t=t/2.5; %put in gait period form
        
        x=x-x(1);
        y=y-y(1);
        thet=thet-thet(1);
        
        x=downsample(x,downSampBy);
        y=downsample(y,downSampBy);
        thet=downsample(thet,downSampBy);
        t=downsample(t,downSampBy);
        
        if(filtz)
            %lowpass(x,5,1/diff(t(1:2)),'ImpulseResponse','iir');
            %x=lowpass(y,5,1/diff(t(1:2)));
            x=filter(fb,fa,x);  %filtered signal
            y=filter(fb,fa,y);  %filtered signal
            thet=filter(fb,fa,thet);  %filtered signal
        end
        
        dx=diff(x); dy=diff(y);dr=diff(thet);
        
        %         V=zeros(1,length(usedMovs(idx).x);
        V=zeros(1,size(x,1));
        for i=1:length(t)
            R=[x(i,:)',y(i,:)'];
            [~,V(i)]=convhull(R(:,1),R(:,2));
        end
        phi(:,idx)=A*n./V;
        
        GTTAll(:,idx)=mean([zeros(1,n); cumsum(sqrt(dx.^2+dy.^2))],2);
        GTRAll(:,idx)=mean([zeros(1,n); cumsum(sqrt(dr.^2))],2);
        
    end
    GT=sum([mean(GTTAll,2),mean(GTRAll,2)],2);
    finGT=GTTAll(end,:)+GTRAll(end,:);
    scatter(trapz(t,phi),finGT);
    
    xlabel('\int\phid\tau');
    ylabel('gran temp (G_r+G_t)');
    figText(gcf,16);
end
%% 30. mean velocity vs time
xx=30;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    %requires that all runs have the same number of smarticles
    A=.051*.021; %area (l*w) of smarticle in m
    n=size(usedMovs(1).x,2);
    downSampBy=10;
    s=0.1428;%straight leg length of smarticle
    otherAngs=(180-(1-2/n)*180)/2*pi/180;
    sig=s*cos(otherAngs);%optitrack straight length of regular polygon
    maxAreaOpti=1/4*n*sig^2*cot(pi/n); %max optitrack convex hull area
    GTTAll=[];
    GTRAll=[];
    filtz=0;
    for(idx=1:N)
        
        %         rI(1:numBods,:,idx)=[usedMovs(idx).x(1,:)',usedMovs(idx).y(1,:)'];
        %         rF(1:numBods,:,idx)=[usedMovs(idx).x(end,:)',usedMovs(idx).y(end,:)'];
        
        x=usedMovs(idx).x;
        y=usedMovs(idx).y;
        thet=usedMovs(idx).rot;
        t=usedMovs(idx).t(:,1);
        
        x=x(t(:)<minT,:);
        y=y(t(:)<minT,:);
        thet=thet(t(:)<minT,:);
        t=t(t(:)<minT,:);
        t=t/2.5; %put in gait period form
        
        x=x-x(1);
        y=y-y(1);
        thet=thet-thet(1);
        
        x=downsample(x,downSampBy);
        y=downsample(y,downSampBy);
        thet=downsample(thet,downSampBy);
        t=downsample(t,downSampBy);
        
        if(filtz)
            %lowpass(x,5,1/diff(t(1:2)),'ImpulseResponse','iir');
            %x=lowpass(y,5,1/diff(t(1:2)));
            x=filter(fb,fa,x);  %filtered signal
            y=filter(fb,fa,y);  %filtered signal
            thet=filter(fb,fa,thet);  %filtered signal
        end
        
        dx=diff(x); dy=diff(y);dr=diff(thet);dt=diff(t);
        %dim 1 represents time progression
        %dim 2 = [mean(|tran V| many smarts), mean(|rot V| many smarts)
        %dim 3 = exps
        v(:,:,idx)=[mean(sqrt((dx./dt).^2+(dy./dt).^2),2),mean(sqrt((dr./dt).^2),2)];
        %         v(:,:,idx)=[mean(dx.dy./dt,2),mean(dr./dt,2)];
        %         v(:,:,idx)=[mean(dx./dt,2),mean(dy./dt,2),mean(dr./dt,2)];
        %         h(idx)=plot(t(1:end-1),sqrt(v(:,1,idx).^2+v(:,2,idx).^2));
        %         plot(t(1:end-1),sqrt(v(:,3,idx).^2),'--','color',h(idx).Color);
    end
    
    %     vt=squeeze(sqrt(v(:,1,:).^2+v(:,2,:).^2));
    %     vr=squeeze(sqrt(v(:,3,:).^2));
    %     vr=squeeze(vr);
    vt=squeeze(v(:,1,:));
    vr=squeeze(v(:,2,:));
    VT=mean(vt.^2,2)-mean(vt,2).^2;
    VR=mean(vr.^2,2)-mean(vr,2).^2;
    
    VT=sqrt(VT);
    VR=sqrt(VR);
    plot(t(1:end-1),VT,'k','linewidth',2);
    %     plot(t(1:end-1),sqrt(VR),'k','linewidth',2);
    %     plot(t(1:end-1),VT,'k','linewidth',2);
    
    %     plot(t(1:end-1),sqrt(vm(:,1).^2+vm(:,2).^2),'k','linewidth',2);
    %     plot(t(1:end-1),sqrt(vm(:,3).^2),'--k','linewidth',2);
    xlabel('\tau');
    ylabel('velocity cm/period');
    figText(gcf,16);
    xlim([0 70]);
end

%% 31. true granular temperature mean squared vel
xx=31;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    %requires that all runs have the same number of smarticles
    A=.051*.021; %area (l*w) of smarticle in m
    n=size(usedMovs(1).x,2);
    downSampBy=10;
    s=0.1428;%straight leg length of smarticle
    otherAngs=(180-(1-2/n)*180)/2*pi/180;
    sig=s*cos(otherAngs);%optitrack straight length of regular polygon
    maxAreaOpti=1/4*n*sig^2*cot(pi/n); %max optitrack convex hull area
    GTTAll=[];
    GTRAll=[];
    filtz=0;
    for(idx=1:N)
%             for(idx=3)
        %         rI(1:numBods,:,idx)=[usedMovs(idx).x(1,:)',usedMovs(idx).y(1,:)'];
        %         rF(1:numBods,:,idx)=[usedMovs(idx).x(end,:)',usedMovs(idx).y(end,:)'];
        
        x=usedMovs(idx).x;
        y=usedMovs(idx).y;  
        thet=usedMovs(idx).rot;
        t=usedMovs(idx).t(:,1);
        
        x=x(t(:)<minT,:);
        y=y(t(:)<minT,:);
        thet=thet(t(:)<minT,:);
        t=t(t(:)<minT,:);
        t=t/2.5; %put in gait period form
        
        x=x-x(1);
        y=y-y(1);
        thet=thet-thet(1);
        
        if(filtz)
            %lowpass(x,5,1/diff(t(1:2)),'ImpulseResponse','iir');
            %x=lowpass(y,5,1/diff(t(1:2)));
            x=filter(fb,fa,x);  %filtered signal
            y=filter(fb,fa,y);  %filtered signal
            thet=filter(fb,fa,thet);  %filtered signal
        end
        
        dx=diff(x); dy=diff(y);dr=diff(thet);dt=diff(t);
        v=sqrt((dx./dt).^2+(dy./dt).^2);
        
        v2=v.^2;
        vr=sqrt((dr./dt).^2);
        
        figure(50034);
        hold on;
        title('velocity of all particles in a single run');
        ylabel('v^2');
        xlabel('\tau');
        
%         plot(t(2:end),mean(v.^2,2),'k','linewidth',2);
%         plot(t(2:end),mean(v(:,1).^2,2));
%         rr=mean(v.^2,2)-mean(v,2).^2;
        
        wm=movmean(rr,length(rr)/max(t));
%         plot(t(2:end),wm*50+.2);
        %dim 1 represents time progression
        %dim 2 = [mean(|tran V| many smarts), mean(|rot V| many smarts)
        %dim 3 = exps
        %mean(mean(v)) of noisefloor;
        %         nf=8.856e-4;
        %         nfr=.0205;

        v3(:,idx)=mean(v.^2,2)-mean(v,2).^2;
        v4(:,idx)=mean(v.^2,2);
    end
    %     vt=squeeze(sqrt(v(:,1,:).^2+v(:,2,:).^2));
    %     vr=squeeze(sqrt(v(:,3,:).^2));
    %     vr=squeeze(vr);
%     v2t=squeeze(mV(:,1,:));
%     vt=squeeze(V(:,1,:));
%     vr=squeeze(V(:,2,:));
%     VT=mean(vt,2);
% %     VV=mean(v2t,2)-mean(vt,2).^2;
    
%     VR=mean(vr,2);
    VV=mean(v3,2);
    VSTD=mean(v4,2);
    %     VT=sqrt(VT);
    %     VR=sqrt(VR);
    figure(xx);
    hold on;
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
%% 32 another version of COM plot with cleaner code
xx=32;
if(showFigs(showFigs==xx))
    figure(xx); lw=2;
    hold on;
    %     first get number of gait radii used
    COM=[];
    downSampBy=10;
    for i=1:N
        x=usedMovs(i).x;
        y=usedMovs(i).y;
        t=usedMovs(i).t(:,1);
        
        x=x(t(:)<minT,:);
        y=y(t(:)<minT,:);
        t=t(t(:)<minT,:);
        t=t/2.5; %put in gait period form
        
        x=x-x(1);
        y=y-y(1);
        
        x=downsample(x,downSampBy);
        y=downsample(y,downSampBy);
        t=downsample(t,downSampBy);
        
        COM(:,:,i)=[sum(x,2),sum(y,2)]./numBods;
        COM(:,:,i)=COM(:,:,i)-COM(1,:,i);
        %         dists=sqrt(sum(abs(diff(COM(:,i))).^2,2)); %check for major jumps
        %         COM(:,i)=
        %         longDists=find(dists>.01);
        %
        %         %eliminate long jumps
        %         while(longDists)
        %             COM(longDists(1)+1,:)=COM(longDists(1),:);
        %             dists=sqrt(sum(abs(diff(COM(:,i))).^2,2)); %check for major jumps
        %             longDists=find(dists>.005);
        %         end
        %         COM(:,i)=COM(:,i)-COM(1,:);
        plot(COM(:,1,i),COM(:,2,i),'linewidth',lw);
    end
    
    %     plot([-0.3,-0.3,0.3,0.3,-0.3],[0.3,-0.3,-0.3,0.3,0.3,],'k','linewidth',2);
    xlabel('X (m)');
    ylabel('Y (m)');
    axis([-.115,.115,-.115,.115]);
    set(gca,'XTick',[-0.1:.05:0.1],'XTicklabels',{'-0.1','','0','','0.1'});
    set(gca,'YTick',[-0.1:.05:0.1],'YTicklabels',{'-0.1','','0','','0.1'});
    %     axis equal
    figText(gcf,16);
    
end
%% 33. MSD added from 44 on multimsd file
xx=33;
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
        fprintf('D = %.3g +- %.3g (mean +- std, N = %d)\n', ...
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
%% 34 plot gamma vs t
xx=34;
if(showFigs(showFigs==xx))
    figure(xx)
    hold on;
    if(isempty(ma.msd))
        ma = ma.computeMSD;
    end
    COM2={};
    mb = msdanalyzer(2, SPACE_UNITS, TIME_UNITS);
    inds=[10];
    for(i=1:length(inds))
        x= [usedMovs(inds(i)).t(:,1),mean(usedMovs(inds(i)).x,2),mean(usedMovs(inds(i)).y,2)];
        COM2{i}=downsample(x,9);
    end
    mb=mb.addAll(COM2);
    mb=mb.computeMSD;
    
    p=mb.getMeanMSD;
    %     pf=maf.getMeanMSD;
    co=.25;
    [ffb,ffa]=butter(6,co/(sampRate/2),'low');
    
    gam=diff(log(p(2:end,2)))./diff(log(p(2:end,1)));
    %     gam=gam(2:end);
%     fgam=filter(ffb,ffa,gam);
    fgam=movmean(gam,1/diff(p(1:2,1))*1.5);
    co=80; %cut off ending inds;
    plot(p(3:end-co,1),gam(1:end-co));
    plot(p(3:end-co,1),fgam(1:end-co));
    %     plot(pf(2:end,1),diff(log(pf(:,2)))./diff(log(pf(:,1))))
    ylim([-0.5,2.5]);
    xlim([0,120]);
    legend({'non-filtered','filtered'});
    
    ylabel('\gamma');
    xlabel('delay (s)');
    figText(gcf,16);

    
end

%% 35. gran temp and phi
xx=35;
if(showFigs(showFigs==xx))
    figure(xx);
    hold on;
    %requires that all runs have the same number of smarticles
    A=.051*.021; %area (l*w) of smarticle in m
    n=size(usedMovs(1).x,2);
    downSampBy=10;
    s=0.1428;%straight leg length of smarticle
    otherAngs=(180-(1-2/n)*180)/2*pi/180;
    sig=s*cos(otherAngs);%optitrack straight length of regular polygon
    maxAreaOpti=1/4*n*sig^2*cot(pi/n); %max optitrack convex hull area
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    filtz=0;
    pTot=[];
    vTot=[];
    for(idx=1:N)
%         for(idx=3)
                


        %         rI(1:numBods,:,idx)=[usedMovs(idx).x(1,:)',usedMovs(idx).y(1,:)'];
        %         rF(1:numBods,:,idx)=[usedMovs(idx).x(end,:)',usedMovs(idx).y(end,:)'];
        
        x=usedMovs(idx).x;
        y=usedMovs(idx).y;  
        thet=usedMovs(idx).rot;
        t=usedMovs(idx).t(:,1);
        
        x=x(t(:)<minT,:);
        y=y(t(:)<minT,:);
        thet=thet(t(:)<minT,:);
        t=t(t(:)<minT,:);
        t=t/2.5; %put in gait period form
        
        x=x-x(1);
        y=y-y(1);
        thet=thet-thet(1);
        
        if(filtz)
            %lowpass(x,5,1/diff(t(1:2)),'ImpulseResponse','iir');
            %x=lowpass(y,5,1/diff(t(1:2)));
            x=filter(fb,fa,x);  %filtered signal
            y=filter(fb,fa,y);  %filtered signal
            thet=filter(fb,fa,thet);  %filtered signal
        end
        
        %%%%%phi
        V=zeros(1,length(x));
        for i=1:length(x)
            R=[x(i,:)',y(i,:)'];
            [~,V(i)]=convhull(R(:,1),R(:,2));
        end
        phi=V;
        phi=(A*n)./phi;
        %%%%%%%%%%%
        
        
        
        dx=diff(x); dy=diff(y);dr=diff(thet);dt=diff(t);
        v=sqrt((dx./dt).^2+(dy./dt).^2);
        
        v2=v.^2;
        vr=sqrt((dr./dt).^2);
       
        ylabel('<v^2>');
        xlabel('phi');
        
%         plot(t(2:end),mean(v.^2,2),'k','linewidth',2);
%         plot(t(2:end),mean(v(:,1).^2,2));
%         rr=mean(v.^2,2)-mean(v,2).^2;
%         rr=mean(v,2).^2;
        rr=mean(v.^2,2);
        wm=movmean(rr,length(rr)/max(t));
        scatter(downsample(phi(2:end),5),downsample(wm,5),'.k');
        pTot=[pTot,phi(2:end)];
        vTot=[vTot,wm'];
    end
figText(gcf,16);


figure(123145);
c=histogram(pTot,round(sqrt(length(pTot))),'Normalization','probability','displaystyle','stairs');hold on;
% plot(c.BinEdges(2:end)-diff(c.BinEdges(1:2))/2,c.Values,'r','linewidth',2)
ylabel('P(phi)');
xlabel('phi');
figText(gcf,20);


figure(123148);
d=histogram(vTot,round(sqrt(length(vTot))),'Normalization','probability','displaystyle','stairs');hold on;
% plot(d.BinEdges(2:end)-diff(d.BinEdges(1:2))/2,d.Values,'r','linewidth',2)
ylabel('P(<v^2>');
xlabel('<v^2>');

figText(gcf,20);

end