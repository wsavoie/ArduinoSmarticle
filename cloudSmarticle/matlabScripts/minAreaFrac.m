% each smarticle is 14cm in length
%with honeycomb packing and 7 smarticles the minimum packing without
%touching is
% http://mathworld.wolfram.com/CirclePacking.html
phi=1/6*pi*sqrt(3);
smartArea=pi*(.14/2)^2;
%true total area
minArea=(7*smartArea)/phi

%max area is
% max volume fraction (max with minimum touching) is same as a shape
% with maximum area and minimum perimeter.

% in general this is a circle, but with n vertices, the shape is
% actually regular an n-gon,

% Max area is an n-gon with sidelength 14 cm (smarticle length)
% A=1/4*n*s^2*cot(pi/n);
%for n=7 and s=14:
n=7;
s=.14;
% %must add the halfcircle area outside of each side
% if mod(n,2)==0 %if even
%     circAreaExtra=(360-(1-2/n)*180)/360;
%     maxArea=1/4*n*s^2*cot(pi/n)+n*smartArea*circAreaExtra*1/phi
%     
% else
%     maxArea=1/4*n*s^2*cot(pi/n)+n*smartArea/2
% end

maxArea=1/4*n*s^2*cot(pi/n)

otherAngs=(180-(1-2/n)*180)/2;
% sig=s*cos(otherAngs);
sig=s*cos(otherAngs*pi/180);
maxAreaOpti=1/4*n*sig^2*cot(pi/n)
 