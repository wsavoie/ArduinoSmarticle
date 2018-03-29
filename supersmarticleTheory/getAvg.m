function [avg,stdz]=getAvg(R,r,P,p,D1,D0,d1,d0,f,l1)
    l2=1-l1;
    
    AvgX=sum(f.*l1.*R.*r.*d1 + f.*l2.*R.*r.*d0);
    VarX=sum(l1.*R.*(f.*d1.*r-AvgX).^2+l2.*R.*(f.*d0.*r-AvgX).^2);
    stx=sqrt(VarX);
    
    AvgY=sum(f.*P.*p.*sum(l1.*D1+l2.*D0));
    VarY=sum(l1.*P.*(f.*D1.*p-AvgY).^2+l2.*P.*(f.*D0.*p-AvgY).^2);
    sty=sqrt(VarY);
    
    avg=[AvgX,AvgY];
    stdz=[stx,sty];
end