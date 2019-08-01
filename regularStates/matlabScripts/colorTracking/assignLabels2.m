function [CX,CY] = assignLabels(CX,CY)
%ASSIGNLABELS input matrix of positions of dots for a single color
%assumes first dot is labeled correctly
%CX,CY are shaped such that a single time spans column, time increases with
%rows

for(i=2:size(CX,2))
x1 = CX(i-1,:);
x2 = CX(i,:);
y1 = CY(i-1,:);
y2 = CY(i,:);
I=zeros(4,1);
for(j=1:size(x1,2))
   x=x1(j);
   y=y1(j);
   distances=sqrt((x-x2).^2+(y-y2).^2);
   [~,I(j)]=min(distances);
   y2(I(j))=100000;
   x2(I(j))=100000;
end
    CX(i,I)=CX(i,:);
    CY(i,I)=CY(i,:);
end


