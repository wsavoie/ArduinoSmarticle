function [arm1,arm2]=generalGait1(t,T,A1,A2)
% N=length(A1)-1;
t=mod(t,T); t=t/T;
dA1=diff(A1);
dA2=diff(A2);
L=sqrt(dA1.*dA1+dA2.*dA2);
L=L/sum(L);

id=1;
tt=L(id);
while t>tt
    id=id+1;
    tt=tt+L(id);
end

A1i=A1(id); A1f=A1(id+1);
A2i=A2(id); A2f=A2(id+1);

p=(tt-t)/L(id);
arm1=p*A1i+(1-p)*A1f;
arm2=p*A2i+(1-p)*A2f;

end