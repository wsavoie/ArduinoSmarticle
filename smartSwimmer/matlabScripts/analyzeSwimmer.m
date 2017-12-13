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

    [row,col]=find(isnan(x));
    for i=1:length(row)
        x(row(i),col(i))=x(row(i)-1,col(i));
    end
	[row,col]=find(isnan(y));
    for i=1:length(row)
        y(row(i),col(i))=y(row(i)-1,col(i));
    end

y1av=mean(y,1);
[~,I] = sort(y1av);
x=x(:,I);
y=y(:,I);

xcom=mean([x(:,2:3)],2); %get xpos of center at all times
ycom=mean([y(:,2:3)],2); %get ypos of center at all times
xcom=xcom-xcom(1);
ycom=ycom-ycom(1);


nB=[diff(x(:,[2:3]),1,2),diff(y(:,[2:3]),1,2)];
nB=nB/norm(nB);
nB0=mean(nB);
q=nB0/norm(nB0)*[xcom,ycom]';


% q=([xcom(end),ycom(end)]./norm([xcom(end),ycom(end)]))*[xcom,ycom]';

