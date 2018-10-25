m=[12 25 50.5 100]./1000;
V=[.22,.27;.48 .52;1.06 1.08;2.16 2.19];
g=9.86;
F=m*g;
% errorbar(m,mean(V,2),std(V,0,2));

% errorbar(F,mean(V,2),std(V,0,2))
c=0;
conv=2.2;
Fc=(V-c)./conv;
hold on;
errorbar(m,mean(Fc,2),std(Fc,0,2));

xlabel('mass (kg)');
ylabel('Force (N)');

mm=0:.01:.2;
plot(mm,mm*g,'-');