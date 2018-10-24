function val = gaussC(x, y, sigma, center)

xc = center(1);
yc = center(2);
exponent = ((x-xc).^2 + (y-yc).^2)./(2*sigma);
val       = (exp(-exponent));    
% 
% 
% out=[];
% for(i=1:length(x))
%     
%     % [X,Y]=meshgrid(xplot,yplot);
%     dx=dirac(x(i)-xplot);
%     dy=dirac(y(i)-yplot);
%     
%     [X,Y]=meshgrid(dx,dy);
% %     c=normpdf(x,1,2); c=normpdf(x,1,2);
% %     gaus=1/sqrt(2*pi*sig^2)*exp(-(X-).^2+(dy).^2)/(2*(.25)^2);
%     exponent = ((x-xc).^2 + (y-yc).^2)./(2*sigma^2);
%     if(i==1)
%         out=gaus;
%     else
%         out=out+gaus;
%     end
% end
% out=out./length(x);
