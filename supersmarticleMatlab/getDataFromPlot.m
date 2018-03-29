h=gcf;
axesObjs = get(h, 'Children');  %axes handles
dataObjs = get(axesObjs, 'Children'); %handles to low-level graphics objects in axes
a=dataObjs{2};
a

l1=3;
l2=1;
x1=a(l1).XData;     y1=a(l1).YData;

x2=a(l2).XData;     y2=a(l2).YData;


% plot p=1 line for SH
xdat= [10^-1:1:10^2]; ydat=xdat.^1/1e5;plot(xdat,ydat,'-.','linewidth',2)
xdat= [10^-1:1:10^2]; ydat=xdat.^2/1e7;plot(xdat,ydat,'-.','linewidth',2)


%plot p=1 and p=2 line for MR
% xdat= [10^-1:1:10^2]; ydat=xdat.^1/7e2;plot(xdat,ydat,'-.','linewidth',2)
% xdat= [10^-1:1:10^2]; ydat=xdat.^2/1e5;plot(xdat,ydat,'-.','linewidth',2)