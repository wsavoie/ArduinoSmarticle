function [V] = calcGranTemp(x,y,thet,t,L,withR)
%CALCGRANTEMP calcs granular temperature for a single usedMov index
dx=diff(x); dy=diff(y);dr=diff(thet);dt=diff(t);
v=sqrt((dx./dt).^2+(dy./dt).^2);
vr=sqrt((dr./dt).^2)*L;

if(withR)
   v=v+vr;
end
    
V=mean(v.^2,2)-mean(v,2).^2;