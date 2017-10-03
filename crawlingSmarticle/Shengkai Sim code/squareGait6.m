function [arm1,arm2]=squareGait6(t,T,MSpeed,gR,ccw)
g=mod(floor(t/(T/4))+1,4);
p=mod(t,T/4);
ti=T;
te=T-.100;
switch g
    case 1
        arm1=gR;
        
        arm2=max(gR-MSpeed*p,-gR);
    case 2
        arm1=max(gR-MSpeed*p,-gR);
        arm2=-gR;
    case 3
        arm1=-gR;
        arm2=min(-gR+MSpeed*p,gR);
    case 0
        arm1=min(-gR+MSpeed*p,gR);
        arm2=gR;
end
if ccw
    arm2=-arm2;
end
end