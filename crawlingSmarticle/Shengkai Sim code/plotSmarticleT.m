function plotSmarticleT(D0,W0,D,L,ort,arm1,arm2,x0,y0)
[x1,y1,x2a,y2a,x2b,y2b,x3a,y3a,x3b,y3b,x4,y4,x2,y2,x3,y3]=cfg2coordinateT(D0,W0,D,L,ort,arm1,arm2,x0,y0);
plot([x1 x2],[y1 y2],'linewidth',3,'Color',[0 0 0]);
hold on,plot([x3 x4],[y3 y4],'linewidth',3,'Color',[0 0 0]);
hold on,plot([x2a x2b x3b x3a x2a],[y2a y2b y3b y3a y2a],'linewidth',3,'Color',[1 0 0]);
end