function [ fpars,t,x,y,q,ycom,xcom] = analyzeSwimmer( fold,fname )
%ANALYZESWIMMER analyzes the a particular swimmer files
%fpars=[ang,dir,ver], L=0, R=1
%t = time
[a,b]=parseFileNames(fname);
fpars=[b(1),a{1}=='R',b(2)];
data = importdata(fullfile(fold,fname));
t = data.data(:,2);

x= data.data(:,[6 9 12 3]);
y= data.data(:,[8 11 14 5]);
y1av=mean(y,1);
[~,I] = sort(y1av);
x=x(:,I);
y=y(:,I);

xcom=mean([x(:,2:3)],2); %get xpos of center at all times
ycom=mean([y(:,2:3)],2); %get ypos of center at all times
xcom=xcom-xcom(1);
ycom=ycom-ycom(1);

q=([xcom(end),ycom(end)]./norm([xcom(end),ycom(end)]))*[xcom,ycom]';

