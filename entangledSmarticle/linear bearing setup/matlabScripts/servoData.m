hold on;
xx=[49.2854,5e-5;...
    36.3108,6.8368e-5;...
    31.6556,7.8572e-5;...
    28.0584,8.8776e-5;...
    25.2143,9.898e-5;...
    22.8833,1.09184e-4;...
    20.938,1.19388e-4;...
    19.3087,1.29592e-4;...
    17.9953,1.39161e-4;...
    16.9262,1.47959e-4;...
    13.3529 1.87907e-4;...
    12.0788,2.07845e-4;...
    10.1771,2.46943e-4;...
    8.9823,2.79967e-4]; 
plot(xx(:,1),xx(:,2));
% f=fit(xx(:,1),xx(:,2),'exp1');
%         text(.1, 0.25,['ae^{bx}',newline,'a=',num2str(f.a,'%.3f'),newline,'b=',num2str(f.b,'%.3f')],'fontsize',16,'units','normalized')
%         yf=f.a*exp(f.b*x);
%    plot(f,xx(:,1),xx(:,2))


ff=fit(xx(:,1),xx(:,2),'power1');
yf=ff.a*xx.^ff.b;
plot(ff,xx(:,1),xx(:,2))



pulse=1e-6*[3.13 4 4.25 4.5 5 5.5 6 7 9 11 14 18 22 30 40 60 100];

speed=[49.3827 38.7597 36.523 34.5185 31.0945 28.3286 25.9875 22.3115 17.2652 14.1563 11.1582 8.69716 7.12555 5.21268 3.91543 2.59875 1.56617];

f=fit(speed',pulse','power1');
yf=f.a*speed.^f.b;
plot(f,speed,pulse)

[f.a f.b]

