dat=struct;
datName=movs; %
for(i=1:length(movs))
    dat(i).fname    = datName(i).fname;
    dat(i).t        = datName(i).t(:,1);
    dat(i).as.x     = datName(i).Ax;
    dat(i).as.y     = datName(i).Ay;
    dat(i).as.rot   = datName(i).Arot;
%     dat(i).is.x     = datName(i).ix;
%     dat(i).is.y     = datName(i).iy;
%     dat(i).is.rot   = datName(i).irot;
    dat(i).ring.x   = datName(i).x;
    dat(i).ring.y   = datName(i).y;
    dat(i).ring.rot = datName(i).rot;
    dat(i).fps      = datName(i).fps;
end


% for i=1:length(usedMovs)
%     % dpos=diff(pos);
%     p1=[dat(i).ring.x(1),dat(i).ring.y(1)];
%     ringpos = [dat(i).ring.x-p1(1), dat(i).ring.y-p1(2)];
%     apos = [dat(i).as.x-p1(1),dat(i).as.y-p1(2)];
%     iapos = [dat(i).is.x-p1(1),dat(i).is.y-p1(2)];
%     
%     r1=dat(i).ring.rot(1);
%     ringr = dat(i).ring.rot-r1;
%     ar = dat(i).as.rot-r1;
%     ir = dat(i).is.rot-r1;
%     
%     ringpos=fillmissing(ringpos,'linear');
%     apos=fillmissing(apos,'linear');
%     ispos=fillmissing(iapos,'linear');
%     
%     ringr=fillmissing(ringr,'linear');
%     ar=fillmissing(ar,'linear');
%     ir=fillmissing(ir,'linear');
%     
%     newpos=zeros(size(ringpos));
%     sz=size(ringpos);
%     [newRing,newar,newir]=deal(zeros(sz(1),sz(2)+1));
%     
%     for j=2:size(newpos,1)
%         % Get the change in the ring position in the world frame
%         deltaR = ringpos(j, :) - ringpos(j-1, :);
%         deltaA = apos(j,:) - apos(j,:);
%         deltaI = ipos(j,:) - ipos(j,:);
%         
%         % Get the vec1, tor from the ring COG to the inactive smarticle
%         rs = iapos(j-1, :) - rpos(j-1, :);  %HAD ERROR
%         if(norm(rs))
%             rs = rs./norm(rs);
%         end
%         ns=[-rs(2) rs(1)]; %a vec perpendicular vector to rs
%         newThet= atan2(ns(2),ns(1)];
%         
%         
%         %             ns=-ns;%this gets direction of perpendicular movement correct
%         %             deltay = ((rs*deltaR')/norm(rs)^2)*rs;
%         %             deltax = deltaR - deltay;
%         newpos(j, :) =[deltaR*ns',deltaR*rs'];
%         %       newpos(j, :) = [sign((rs./norm(rs))*(deltax'./norm(deltax)))*norm(deltax),...
%         %                           sign((rs./norm(rs))*(deltay'./norm(deltay)))*norm(deltay)];
%         
%     end
%     %         newpos=cumsum(newpos,2);
%     newpos=cumsum(newpos);
%     if newpos(end,2)>0
%         correctDir=correctDir+1;
%     end
%     plot(newpos(:,1),newpos(:,2));
%     %                 plot(ones(1,length(newpos(:,2)))*.025*i-length(usedMovs)/2*.025,newpos(:,2));
%     h=plot(newpos(end,1),newpos(end,2),'ko','markersize',4,'MarkerFaceColor','r');
%     set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%     endPos(i)=newpos(end,2);
%     nn(i)=newpos(end,2)./usedMovs(i).t(end);
%     rotPos{i}=newpos;
% end