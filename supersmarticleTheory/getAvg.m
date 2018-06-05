function [avg]=getAvg(X,x,Y,y,D1,D0,d1,d0,f,l1)

l2=1-l1;
    AvgX=sum(f.*l1.*X.*x.*d1 + f.*l2.*X.*x.*d0);
    %what I thought variance should be
%     VarX=sum(l1.*X.*(f.*d1.*x-AvgX).^2+l2.*X.*(f.*d0.*x-AvgX).^2);
   
%     VarX
%     stx=sqrt(VarX);
    
    AvgY=sum(f.*Y.*y.*sum(l1.*D1+l2.*D0));
%     VarY=sum(l1.*Y.*(f.*D1.*y-AvgY).^2+l2.*Y.*(f.*D0.*y-AvgY).^2);
%     sty=sqrt(VarY);
    
    avg=[AvgX,AvgY];
%     stdz=[stx,sty];
end