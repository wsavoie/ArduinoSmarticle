% f= 120;
% tt = 0:.01:500;
% yy = sin(f/(2*pi)*tt);


% tt=0:.01:1;
% freq = 50;
% yy=100*sin(freq/pi*tt)+20*sin(20/pi*tt);
% freqout=sum(abs(diff(yy>0)))
%code is used to understand how the frequency algorithm above works
%this algorithm was used in the ATtiny85 3/12/15 to pick out frequencies on
%a chip without the capability to perform floating point division
% soundsc(yy)
len = 2000;
freq=180;
val2 = 0;
tt = linspace(0,8,len);
data = zeros(len,1);
data2 = zeros(len-1,1);
rF = 200*rand(len,1);
rA = 50*rand(len,1)-25;
rA1 =90+50*rand(len,1);
val = rA1(1)*sin(freq/pi*tt(1))+rA(1)*sin(rF(1)/pi*tt(1));
yy(1) = val;
data(1)=val;
for i = 2:len
%%%%%%%%%%%%%%%%unnecess for ard
val = rA1(i)*sin(freq/pi*tt(i))+rA(i)*sin(rF(i)/pi*tt(i));
yy(i) = val;
%%%%%%%%%%%%%%%%unnecess for ard
data(i)=val;
data2(i-1)=(data(i)>0) - (data(i-1)>0);
data2(i-1)= abs(data2(i-1));
val2 = val2+data2(i-1);

end
data3 = abs(diff(yy>0))';
freqout = sum(data3);
val2;
pts('freqout:',freqout,' val2:',val2);