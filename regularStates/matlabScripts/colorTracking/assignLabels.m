function [CX,CY] = assignLabels(CX,CY)
%ASSIGNLABELS input matrix of positions of dots for a single color
%assumes first dot is labeled correctly
%CX,CY are shaped such that a single time spans column, time increases with
%rows
for(i=2:size(CX,1))
    C1=[CX(i-1,:);CY(i-1,:)]';
    C2=[CX(i,:);CY(i,:)]';   
    [D,I]=pdist2(C1,C2,'euclidean','smallest',1);
    CX(i,I)=CX(i,:);
    CY(i,I)=CY(i,:);
end


