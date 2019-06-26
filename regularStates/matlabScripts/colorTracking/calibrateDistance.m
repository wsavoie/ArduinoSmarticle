function [calibFactor] = calibrateDistance(trueDist)
%CALIBRATEDISTANCE draw line on image to calibrate distance

%   CALIBRATEDISTANCE(trueDist) draw a line on the current image with a
%   specified distance trueDist to get the calibration conversion factor
%   back.

title(['click top inner edge of circle at two points 1 diameter away ',...
    'on the ring']);
x=zeros(2,1);
y=zeros(2,1);
[x(1),y(1)]=ginput(1);
hold on;
plot(x(1),y(1),'ro-','linewidth',2);
[x(2),y(2)]=ginput(1);


pixDistance=pdist([x,y]);
calibFactor=trueDist/pixDistance;
end
