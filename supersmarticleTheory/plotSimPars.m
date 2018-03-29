clear all;
%%%%%%values originally from zack%%%%%%%%%%%
its=2000;
A0=.05;
omega=6*pi;
m=.034; %mass of smarticle
gama= pi/4;
m1= (3*m)/34; %proportional mass of arm
m2= (28*m)/34; % proportional mass of mid section
g=9.81;
mu=.37;
f=3.5;
phi=pi/5;
l1=.76;


%%%Seperate area to revalue params%%%%
% gama= 2;
% f=1;
% omega=10*pi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% 1=A0,2=omega,3=m,4=gama,5=m1
%6=m2,7=g,8=mu,9=f,10=phi,11=l1
pars=[A0,omega,m,gama,m1,m2,g,mu,f,phi,l1];
names={'A_0','\omega','m','\gamma','m_1','m_2','g','\mu','f','\phi','\lambda'};
varIdx=2;
runs=5;
pars=pars.*ones(runs,1);

pars(:,varIdx)=linspace(pi,10*pi,runs);

figure(23);
hold on;
for i=1:runs  
[X,Y]=zackModelPars(its,pars(i,1),pars(i,2),pars(i,3),pars(i,4),pars(i,5),pars(i,6),...
    pars(i,7),pars(i,8),pars(i,9),pars(i,10),pars(i,11));
h(i)=plot(X(:,1),X(:,3),'--');
plot(X(:,1),X(:,2),'-','linewidth',2,'color',h(i).Color);
% plot(X(:,1),-X(:,3),'color',h.Color);   

legz(i)={[names{varIdx},'=',num2str(pars(i,varIdx),2)]};
end
xlabel('M');
ylabel('v_x');



legz(runs+1)={['exp data']};
load('expX.mat');
h(runs+1)=errorbar(expX(:,1),expX(:,2),expX(:,3),'k','linewidth',2);
legend(h,legz);
