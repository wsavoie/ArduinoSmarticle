% figure(234);
n=1000000;
R=[0:200:1000];
% R=[0:5];
div=4;
del=400;
res=zeros(n,length(R));
res4=zeros(n,length(R));
for(i=1:length(R))
    stdR(i)=sqrt(sum(([-R(i):1:R(i)]).^2./(2*R(i)+1)));
    stdR4(i)=sqrt(div*sum(([-R(i)/div:1:R(i)/div].^2)./(2*R(i)/div+1)));
end

includeOld=0; %set to 1 to include old data
stdR4(1)=[];%dont include 0 from old data

load('GTfilt.mat');
for i=1:length(gtT)
    yvalsN(i)=gtT{i}(find(t{i}>120,1));
    yvals2N(i)=gtR{i}(find(t{i}>120,1));
    yerrN(i)=egtT{i}(find(t{i}>120,1));
    yerr2N(i)=egtR{i}(find(t{i}>120,1));
end

if(includeOld)
    load('GTold.mat');
    for i=2:length(gtT) %dont include zero from old data
        yvalsO(i-1)=gtT{i}(end);
        yvals2O(i-1)=gtR{i}(end);
        yerrO(i-1)=egtT{i}(end);
        yerr2O(i-1)=egtR{i}(end);
    end
    [xAll ord]=sort([stdR,stdR4]);
    yAll=[yvalsN,yvalsO];
    eAll=[yerrN,yerrO];
    
    eRAll=[yerr2N,yerr2O];
    yRAll=[yvals2N,yvals2O];
else
    [xAll ord]=sort(stdR);
    yAll=yvalsN;
    eAll=yerrN;

    
    eRAll=yerr2N;
    yRAll=yvals2N;

end
    yAll=yAll(ord);
    eAll=eAll(ord);
    yRAll=yRAll(ord);
    eRAll=eRAll(ord);
hold on;

figure(1);

errorbar(xAll.^2/(1e3)^2,yAll,eAll,'linewidth',2)



xlabel('Random amplitude variance $\xi$ (s)','interpreter','latex');
ylabel('$G_t$ (cm)','interpreter','latex');

figText(gcf,16);
figure(2);
hold on;
errorbar(xAll.^2/(1e3)^2,yRAll,eRAll,'linewidth',2)

xlabel('Random amplitude variance $\xi$ (s)','interpreter','latex');
ylabel('$G_r$ (rads)','interpreter','latex');
figText(gcf,16);

figure(3);
hold on;
errorbar(xAll.^2/(1e3)^2,yAll,eAll,'linewidth',2)
errorbar(xAll.^2/(1e3)^2,yRAll,eRAll,'--','linewidth',2)
ylabel('$G_t$ (cm),$G_r$ (rads)','interpreter','latex');
xlabel('Random amplitude variance $\xi$ (s)','interpreter','latex');
figText(gcf,16);
xlim([-0.05,0.4])
