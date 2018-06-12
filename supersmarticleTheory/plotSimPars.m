clear all
%%%%%%values originally from zack%%%%%%%%%%%
its=8000;
A0=.05;
omega=6*pi;
m=.03478; %mass of smarticle
gama= pi/4;
m1= .00358; %proportional mass of arm
m2= m-2*m1; % proportional mass of mid section
g=9.81;
mu=.37;
f=5;
%tau=2.5 secs= 1 gait period
%1/(tau/8)<f<4/(tau/8) for 
phi=pi/3.8;
l1=.86;
load('expX.mat');
MandT=expX(:,[1,5]);
%expX=
%[massRat, meanX,stdX,varX,trial length,ymean ystd]

%%%Seperate area to revalue params%%%%
% gama= 2;
% f=1;
% omega=10*pi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% 1=A0,2=omega,3=m,4=gama,5=m1
%6=m2,7=g,8=mu,9=f,10=phi,11=l1
pars=[A0,omega,m,gama,m1,m2,g,mu,f,phi,l1];
names={'A_0','\omega','m','\gamma','m_1','m_2','g','\mu','f','\phi','\lambda'};
varIdx=11;
runs=1;
pars=pars.*ones(runs,1);

% pars(:,varIdx)=linspace(pi,10*pi,runs);
pars(:,varIdx)=linspace(.86,.86,runs);
figure(1);
hold on;
% stdxx=zeros(expX(:,1),1);
% stdyy=zeros(expX(:,1),1);

[stdxx,stdyy]=deal(zeros(length(expX(:,1)),3));
legz=cell(1,runs);
h=zeros(1,runs);
for i=1:runs  

[XX,YY,stdz]=zackModelPars(its,pars(i,1),pars(i,2),pars(i,3),pars(i,4),pars(i,5),pars(i,6),...
    pars(i,7),pars(i,8),pars(i,9),pars(i,10),pars(i,11),expX);
    for j=1:length(expX(:,1))
    [stdxx(j,:),stdyy(j,:)]=calcStd(pars(i,1),pars(i,2),pars(i,3),pars(i,4),pars(i,5),pars(i,6),...
        pars(i,7),pars(i,8),pars(i,9),pars(i,10),pars(i,11),expX(j,:));
    end
% h(i)=errorbar(stdx(:,1),stdx(:,2),stdx(:,3),'.');
figure(1);
hold on;
h(i)=errorbar(stdxx(:,1),stdxx(:,2),stdxx(:,3),'r.','linewidth',2);
plot(XX(:,1),XX(:,2),'-','linewidth',2,'color','r');

figure(2)
hold on;
errorbar(stdyy(:,1),stdyy(:,2),stdyy(:,3),'.','color','r','linewidth',2);
% h(i)=plot(XX(:,1),XX(:,3),'--');
plot(YY(:,1),YY(:,2),'-','linewidth',2,'color','r');
% plot(X(:,1),-X(:,3),'color',h.Color);   

legz(i)={[names{varIdx},'=',num2str(pars(i,varIdx),2)]};
end
xlabel('M');
ylabel('V_{x,y}');



legz(runs+1)={'exp data X'};
legz(runs+2)={'exp data Y'};
figure(1);
h(runs+1)=errorbar(expX(:,1),expX(:,2),expX(:,3),'k.','linewidth',2,'markersize',15);
figText(gcf,16);
ylim([-0.0014,0.0033])

figure(2);
h(runs+2)=errorbar(expX(:,1),expX(:,6),expX(:,7),'k.','linewidth',2,'markersize',15);
% legend(h,legz);
% plot(xlim,[0,0],'k','linewidth',2);
figText(gcf,16);
ylim([-0.0014,0.0033])
axis tight