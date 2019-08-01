function [CX,CY] = assignLabels3(CX,CY)
%ASSIGNLABELS input matrix of positions of dots for a single color
%assumes first dot is labeled correctly
%CX,CY are shaped such that a single time spans column, time increases with
%rows

%based on
% https://www.mathworks.com/help/vision/ref/assigndetectionstotracks.html

predictions= [CX(1,:)',CY(1,:)'];
detections = [CX(1,:)',CY(1,:)'];
cost = zeros(size(predictions,1),size(detections,1));
for j = 2:size(CX,1)
    predictions=[CX(j-1,:)',CY(j-1,:)'];
    detections = [CX(j,:)',CY(j,:)'];
    for i = 1:size(predictions, 1)
          diff = detections - repmat(predictions(i,:),[size(detections,1),1]);
          cost(i, :) = sqrt(sum(diff .^ 2,2)); 
          %current cost matrix is only based on distance, but we could
          %weight it with something else too, but we would have to relabel
          %earlier in the code
    end
    [assignment,unassignedTracks,unassignedDetections] = ...
            assignDetectionsToTracks(cost,10000);
    if  ~isempty(unassignedTracks)||~isempty(unassignedDetections)
        warning(['unassigned track at frame ', num2str(j)]);
    end
    CX(j,assignment(:,1))=CX(j,assignment(:,2));
    CY(j,assignment(:,1))=CY(j,assignment(:,2));
end

%ind=10928;plot(blobCX(ind,1:4),blobCY(ind,1:4),'o-');axis equal;hold on
