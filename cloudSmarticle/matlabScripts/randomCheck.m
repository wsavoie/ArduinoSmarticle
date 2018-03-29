%proof that 4 smaller randoms have different std value than a single large
%one
figure(1)
hold on;
n=1000000;
R=[0:200:1000];
% R=[0:5];
div=4;
del=400;
res=zeros(n,length(R));
res4=zeros(n,length(R));
for(i=1:length(R))
res(:,i) = (1000+randi([-R(i) R(i)],n,1))+4*del;
res4(:,i) = 1600+sum((1000+randi([-R(i) R(i)],n,4))./4,2);
% sum((1000+randi([-R(i) R(i)],n,div))./div+del,2);
stdR(i)=sqrt(sum(([-R(i):1:R(i)]).^2./(2*R(i)+1)));
stdR4(i)=sqrt(div*sum(([-R(i)/div:1:R(i)/div].^2)./(2*R(i)/div+1)));
% 
% sqrt(4*sum([-2:1:2].^2./(2*2+1)))

end

resm=mean(res); rese=std(res);
res4m=mean(res4); res4e=std(res4);

errorbar(R,resm,rese);
errorbar(R,res4m,res4e);
% xlim([0,1100]);

%%
figure(2);
hold on;

n=10000000;
Rv=100;

x  = sum(randi([-Rv/4,Rv/4],n,4),2);
x2 = 4*randi([-Rv/4,Rv/4],n,1);
% x3 = randi([-Rv,Rv],n,1)./2;
% x3= x3+x3;

nn=100;
x4  = sum(randi([-Rv/nn,Rv/nn],n,nn),2);


% histogram(x4,Rv*2+1);
histogram(x,Rv*2+1);
histogram(x2,Rv*2+1);

% histogram(x3,Rv*2+1);
%%
figure(3);
hold on;
rr=1;
n=1e7;
x  = sum(randi([-50,50],n,4),2);
x2  = sum(randi([-200,200],n,1),2);

errorbar(2,mean(x),std(x));
errorbar(2.5,mean(x2),std(x2));
xlim([1 3]);
