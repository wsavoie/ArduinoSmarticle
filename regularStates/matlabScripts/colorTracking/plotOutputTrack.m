numSmarts=3;
blobsPerSmart=4;
col=['r' 'g' 'b'];
hh=figure(1);
plotz=0;
c=2;
fileName=['Arms Tracked',num2str(c)];

for(i=1:4)
    plot(blobCX(:,i))
end
if plotz
    aviobj = VideoWriter(fileName);
    open(aviobj);
end
for j=1:size(blobCX,1)
    hold off;
for(i=1:numSmarts)

    si=(i-1)*blobsPerSmart+1;
    ei=si+blobsPerSmart-1;
  
 %  axis([0,1920,0,1080]*0.0221);
    plot(blobCX(j,si:ei),blobCY(j,si:ei),'o-','linewidth',2,'color',col(i));

    hold on;
end

title(['frame:',num2str(j)]);
axis([0,1920,0,1080]*calibFactor);
drawnow limitrate

    if plotz
        MM=getframe(gcf);
        writeVideo(aviobj,MM);
    end
%     clf;
end
if plotz
        close(aviobj);
end
   