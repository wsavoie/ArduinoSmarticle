function [x,y,thet,t] = getMovDat(usedMovsidx,filtz,gaitLen,minT,downSampBy)
%getMovDat return x,y,z,thet, and t formatted as desired
%smartProps
x=usedMovsidx.x;
y=usedMovsidx.y;
thet=usedMovsidx.rot;
thet=unwrap(thet,pi);
% plot(thet);
t=usedMovsidx.t(:,1);


x=x(t(:)<minT,:);
y=y(t(:)<minT,:);
thet=thet(t(:)<minT,:);
t=t(t(:)<minT,:);


x=x-x(1);
y=y-y(1);
thet=thet-thet(1);
t=t/gaitLen; %put in gait period form

x=downsample(x,downSampBy);
y=downsample(y,downSampBy);
thet=downsample(thet,downSampBy);
t=downsample(t,downSampBy);
if(filtz)
    %             lowpass(x,5,1/diff(t(1:2)),'ImpulseResponse','iir');
    x=lowpass(x,2,1/diff(2*t(1:2)));
    y=lowpass(y,2,1/diff(2*t(1:2)));
    thet=lowpass(thet,2,1/diff(2*t(1:2)));
    %             x=filter(fb,fa,x);  %filtered signal
    %             y=filter(fb,fa,y);  %filtered signal
    %             thet=filter(fb,fa,thet);  %filtered signal
end

end