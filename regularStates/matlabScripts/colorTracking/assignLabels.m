function [CX,CY] = assignLabels(CX,CY)
%ASSIGNLABELS input matrix of positions of dots for a single color
%assumes first dot is labeled correctly
%CX,CY are shaped such that a single time spans column, time increases with
%rows
CXX=CX;
CYY=CY;
R=[diff(CX(1,:))',diff(CY(1,:))'];
R=sqrt(sum(R.^2,2));
tol=max(max(R)-R)*.3;
[~,ord]=sort(R);
for(i=2:size(CX,1))
    C1=[CX(i-1,:);CY(i-1,:)]';
    C2=[CX(i,:);CY(i,:)]';
    dist=pdist2(C1,C2);
    
    N=size(C1,1);
    matchC1toC2=NaN(N,1);
    [~,matchC1toC2(1)]=min(dist(1,:));
    for ii=2:N
       dist(:,matchC1toC2(ii-1))=Inf;
       [~,matchC1toC2(ii)]=min(dist(ii,:));
    end
   

    CX(i,:)=CXX(i,matchC1toC2);
    CY(i,:)=CYY(i,matchC1toC2);
    checkAD= sqrt(sum([diff(CX(i,:))',diff(CY(i,:))'].^2,2));
    [~,ind]=sort(checkAD);
%     if(any(abs(R-checkAD)>tol))
    if(ind~=ord)
        warning(['error frame ',num2str(i)]);
%         CX(i,:)=sort(CX(i,:));
%         CY(i,:)=sort(CY(i,:));
    end
end

