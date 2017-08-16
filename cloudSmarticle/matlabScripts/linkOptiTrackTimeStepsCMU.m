function [xMat,zMat] = linkOptiTrackTimeStepsCMU(X,Z,numMarkers,distanceThreshold)

% these are parameters for tracking (may need to be changed a bit).
% the code will find the closest match for each marker given that 
% the distance from the previous time to current time is less than 
% distanceThreshold away and that closer in index than timeThreshold.
 

timeThreshold = 700; %index

if nargin < 3 || isempty(numMarkers)
    numMarkers = 18;
end

if nargin < 4 || isempty(distanceThreshold)
    distanceThreshold = 0.10;
end

len = zeros(length(X),1);
for i = 1:length(X)
    len(i) = length(X{i});
end

% sometimes fewer markers in i = 1 data, so find first set where number of
% markers is correct

firstFrame = find(len == numMarkers,1,'first'); %%% modify this to back-track markers (particularly the head) to first frame

% link information based on proximity of points in previous frame and
% current frame

xMat = zeros(numMarkers,length(X)-firstFrame);
zMat = zeros(numMarkers,length(X)-firstFrame);

xMat(:,1) = X{firstFrame};
zMat(:,1) = Z{firstFrame};


for i = 2:size(xMat,2)
    
    if mod(i,1000) == 1
        fprintf(1,'working on frame %3i out of %3i. \n',i,size(xMat,2));
        
    end
    xt = X{firstFrame+i-1}';
    zt = Z{firstFrame+i-1}';
    xtMinus1 =  xMat(:,i-1);
    ztMinus1 =  zMat(:,i-1);
    
    % if marker was dropped, value should be NaN.  If that happens,
    % attempt to link with last non-NaN timestep within the timeThreshold

    for j = 1:numMarkers
        if isnan(xtMinus1(j)) || isnan(ztMinus1(j))
            index = find(~isnan(xMat(j,1:i-1)),1,'last');
            if (i-1)-index < timeThreshold
                xtMinus1(j) = xMat(j,index);
                ztMinus1(j) = zMat(j,index);
            end
        end
    end
    

    % D should be numMarkers x numPointsAtT, so find the new points that
    % are closest to the old markers
    D = zeros(length(xtMinus1),length(xt));
    
    for m = 1:length(xtMinus1)
        for n = 1:length(xt)
            D(m,n) = sqrt((xtMinus1(m)-xt(n)).^2 + (ztMinus1(m)-zt(n)).^2);
        end
    end
    
    
    
    unmatched = 1:numMarkers;
    
   
    
    while ~isempty(find(D<distanceThreshold))
        
        [ii,jj] = find(D == min(min(D)) & D < distanceThreshold);
        if ~isempty(ii)
            for k = 1:length(ii)
                xMat(ii(k),i) = xt(jj(k));
                zMat(ii(k),i) = zt(jj(k));
                
                % effectively remove assigned marker so that it is not double-counted
                D(ii(k),:) = inf;
                D(:,jj(k)) = inf;
            end
            
            
            unmatched = setdiff(unmatched,ii);
        end
        
    end
    
    xMat(unmatched,i) = NaN;
    zMat(unmatched,i) = NaN;
    
end
