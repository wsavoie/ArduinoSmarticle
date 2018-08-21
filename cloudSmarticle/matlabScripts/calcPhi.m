function [phi] = calcPhi(x,y,smartArea,n)
%CALCPHI calculates phi for a single usedMov index
%smartProps
V=ones(size(x,1),1);
for i=1:length(x)
        R=[x(i,:)',y(i,:)'];
        [~,V(i)]=convhull(R(:,2),R(:,1));
end
    phi=n*smartArea./V;

