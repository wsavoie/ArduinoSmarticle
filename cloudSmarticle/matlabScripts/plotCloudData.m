clear all;
% close all;
% load('D:\ChronoCode\chronoPkgs\Smarticles\matlabScripts\amoeba\smarticleExpVids\rmv3\movieInfo.mat');

% fold=uigetdir('A:\2DSmartData\');
% f='A:\2DSmartData\singleSmarticleTrack';
f='A:\2DSmartData\cloud\cloudTests 10-5 diamond and square gaits\';
% f='A:\2DSmartData\cloud\cloud 9-30';
% f='A:\2DSmartData\cloud\cloud 9-30\'
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
%*15. plot phi final
%************************************************************
showFigs=[ 7 15];

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
        
        [b,a]=butter(3,1/120*2,'low');
        xF=filter(b,a,x);  %filtered signal
        yF=filter(b,a,y);  %filtered signal
        rotF=filter(b,a,rot);  %filtered signal
        
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
    
    if(single)
        plot((1:length(phi{single}))./usedMovs(single).fps,(A*n)./phi{single});
        id=single;
    else
        for j=1:length(phi)
            plot((1:length(phi{j}))./usedMovs(j).fps,(A*n)./phi{j});
            meanx = mean(usedMovs(j).x(end,:));
            meany = mean(usedMovs(j).y(end,:),2);
            %                 allDistances = sqrt((usedMovs(j).x(end,:)-meanx).^2+(usedMovs(j).y-meany).^2);
        end
        id=j;
    end
    plot([0,usedMovs(id).t(end)],[n*A/maxAreaOpti,n*A/maxAreaOpti],'r--');
    xlabel('time (s)');
    ylabel('Area Fraction \phi');
    figText(gcf,16);
    
    %mean distance btween points
    
    ylim([0.1 0.5])
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
        
        xlim([0 120]);
        figText(gcf,16);
        subplot(2,1,2);
        
        hold on;
        a=wrapTo2Pi(thet-.16);
        plot(t,a,'linewidth',lw);
        %             axis([0 120 -pi-.01,pi+.01]);
        
        axis([0 120 0 2*pi]);
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
        [b,a]=butter(6,1/120*2,'low');
        x=filter(b,a,x);  %filtered signal
        y=filter(b,a,y);  %filtered signal
        thet=filter(b,a,thet);  %filtered signal
        
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
        xlim([0 120]);
        figText(gcf,16);
        subplot(2,1,2);
        
        hold on;
        
        a=wrapToPi(thet);
        set(gca,'YTickLabel',{'$-\pi$','','0','','$\pi$'},...
            'ytick',[-pi,-pi/2,0,pi/2,pi],'ticklabelinterpreter','latex');
        axis([0 120 -pi pi])
        
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
        
        [b,a]=butter(6,1/120*2,'low');
        x=filter(b,a,x);  %filtered signal
        y=filter(b,a,y);  %filtered signal
        thet=filter(b,a,thet);  %filtered signal
        
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
    plot(t,mean(GTRAll,2),'--k','linewidth',2);

    xlabel('time (s)','interpreter','latex');
    ylabel('displacement,rotation (cm,rads)','interpreter','latex');

ylim([0 180]);
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

    figure(23)
    hold on;
    plot(t(1:end-1),diff(mean(GTTAll,2))./diff(t),'linewidth',1);
    ylabel('d<S>/dt');
    xlabel('t(s)');
fps=usedMovs(1).fps;    
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
        
        [b,a]=butter(6,1/120*2,'low');
        x=filter(b,a,x);  %filtered signal
        y=filter(b,a,y);  %filtered signal
        thet=filter(b,a,thet);  %filtered signal
        
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
    
    figure(23)
    hold on;
%     h=plot(t(1:end-1),diff(mGTTAll)./diff(t),'linewidth',1);
%     plot(t(1:end-1),diff(mGTRAll)./diff(t),'--','linewidth',1);
    ylabel('d<S>/dt');
    xlabel('t(s)');
   
    x=t(100:end-1);
    y=diff(mGTTAll(100:end))./diff(t(100:end));
    f = fit(x,y,'power2');
%     yf=f.a*exp(f.b*x);
    yf=f.a*x.^f.b+f.c;
    
    figure(99);
    plot(f,x,y);
    
    figure(27);
    hold on;
%     plot(x,yf);
    
    yi=yf(end);
    idx=max(find(abs(yf-yi)>=0.66*yi));
    xv=[0 200 400 600 800 1000];
%     v=x(idx)
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

%% 15 plot final phi
xx=15;
if(showFigs(showFigs==xx))
    
    figure(xx); lw=2;
    hold on;


    single = 0; % plotting out a single run
    
    finalPhi=zeros(N,1);
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
    
    if(single)
        
        warning('cutting off runs at 2 mins or 1440 frames for 30fps');
%         finalPhi=[finalPhi,phival(end)];  
        finalPhi=[finalPhi,phival(1440)];
        
        plot((1:length(phi{single}))./usedMovs(single).fps,phival);
        id=single;
    else
        for j=1:length(phi)
            phival=(A*n)./phi{j};
            warning('cutting off runs at 2 mins or 1440 frames for 30fps');
            finalPhi(j)=phival(1440);
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
    finalPhi
    mean(finalPhi)
    xlim([0 6])
    x=[1 2 3 4 5];
    y=[mean(LDcp) mean(LDlp) mean(LScp) mean(LSlp) mean(RScp)];
    yerr=[std(LDcp) std(LDlp) std(LScp) std(LSlp) std(RScp)];
    set(gca,'xtick',[1 2 3 4 5],'xticklabel',{'LDcp','LDlp','LScp','LSlp','RScp'},'colororderindex',3);
    bar(x,y);
    errorbar(x,y,yerr,'.');

    end