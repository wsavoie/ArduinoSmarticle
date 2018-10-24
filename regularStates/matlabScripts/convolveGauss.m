function [out,xp,yp] = convolveGauss(samp,sig,pad,ws,featRed)
%CONVOLVEGAUSS Summary of this function goes here
%   Detailed explanation goes here
%needed rounding to sample size ensure we could find points in gaussian code below
x=round(featRed(:,1),abs(log10(samp)));
y=round(featRed(:,2),abs(log10(samp)));
xp=round([min(x)-pad:.01:max(x)+pad],abs(log10(samp)));
yp=round([min(y)-pad:.01:max(y)+pad],abs(log10(samp)));


out=zeros(length(yp),length(xp));
ws2=floor(ws/2);
% generate gaussian kernal, sampling is by 1 so scale sigma by our sampling
gsizeg = fspecial('gaussian', [ws,ws], sig/samp);
gsizeg= gsizeg./max(max(gsizeg));%normalize amplitude of gaussian

for(i=1:length(x))
    r=find(yp==y(i));
    c=find(xp==x(i));
    %convolving gaussian with a dirac delta function at each point is
    %the same as adding gaussians centered around each of the points, (I
    %think :) )
    out(r-ws2:r+ws2,c-ws2:c+ws2)=out(r-ws2:r+ws2,c-ws2:c+ws2)+gsizeg;
end

end

