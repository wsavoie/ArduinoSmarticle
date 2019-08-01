% http://arindambose.com/?p=597
%% Initialization

%instructions:
%set color intensity to max on camera
%turn off autofocus
%zoom in max and tilt to center ring


colorMat={'red','green','blue'};
col=['r' 'g' 'b'];
nFrame = 0; % Frame number initialization


if(exist('v','var'))
    clear('v'); % Release all memory and buffer used
end
v=webcam('Logitech HD Pro Webcam C920','Resolution','1920x1080','Zoom',500,'Focus',0);

hblob = vision.BlobAnalysis('AreaOutputPort', true, ... % Set blob analysis handling
    'CentroidOutputPort', true, ...
    'BoundingBoxOutputPort', true', ...
    'MinimumBlobArea', 240, ...  %uncomment minBlobAr to find
    'MaximumBlobArea', 3000, ... %uncomment maxBlobAr to find
    'MaximumCount', 12);

se = strel('disk',4);
thresh = [180/255,180/255,210/255];
mult=[2.5 4.3 2.4]; 
% mult=[1 1 1]; 
%to find set all to 1 and view uncommented subplots
%find lower limit of color and 1/num
for(i=1:10)
fr=snapshot(v);
pause(.001);
end
while(nFrame < 300)
    fr = snapshot(v);
    fr = flip(fr,2);
    nfr = mult(1)*imsubtract(fr(:,:,1), rgb2gray(fr)); % Get color
    nfg = mult(2)*imsubtract(fr(:,:,2), rgb2gray(fr)); 
    nfb = mult(3)*imsubtract(fr(:,:,3), rgb2gray(fr)); 
    % nfg= medfilt2(nfg, [3 3]);
    nnfr=imdilate(nfr,se);
    nnfg=imdilate(nfg,se);
    nnfb=imdilate(nfb,se);
% nfr= medfilt2(nfr, [6 6]); % Filter out the noise by using median filter

% nfb= medfilt2(nfb, [6 6]);
figure(1) 
hold off;
%put breakpoint on binarize lines when finding mult
subplot(2,3,1); imshow(nfr);
hold on;
subplot(2,3,2); imshow(nfg);
subplot(2,3,3); imshow(nfb);
subplot(2,3,4); imshow(nnfr);
subplot(2,3,5); imshow(nnfg);
subplot(2,3,6); imshow(nnfb);

nfr = imbinarize(nnfr, thresh(1)); % Convert the image into binary with color as white
nfg = imbinarize(nnfg, thresh(2)); 
nfb = imbinarize(nnfb, thresh(3)); 

% [area,cr, boxR]=step(hblob, nfr); % Get the centroids and bounding boxes of the colored blobs
[ar,cr, boxR]=step(hblob, nfr); % Get the centroids and bounding boxes of the colored blobs
[ag,cg, boxG]=step(hblob, nfg);  
[ab,cb, boxB]=step(hblob, nfb);

minBlobAr=min(min([ar,ag,ab]))/1.5
maxBlobAr=max(max([ar,ag,ab]))*1.5

cr = round(cr); % Convert the centroids into Integer for further steps
cg = round(cg);
cb = round(cb);
figure(2);

%     if(PLOTON)
hold off;
    fr=insertShape(fr,'filledRectangle',boxR,'color','red','opacity',.4);
    hold on;
    fr=insertShape(fr,'filledRectangle',boxG,'color','green','opacity',.4);
    fr=insertShape(fr,'filledRectangle',boxB,'color','blue','opacity',.4);
%     imshow(fr,'InitialMagnification','fit');
%     end
    
    objs=size(boxR,1)+size(boxG,1)+size(boxB,1);
%     ix={objs,1}; iy={objs,1};
%     str=cells{objs,1};
%     cellfun(@(x) x-6,ix)
%     cellfun(@(x) x-9,iy)
    allBoxes=[boxR;boxG;boxB];
    cAll=[cr;cg;cb];
    cAllPos=cAll;
    cAllPos(:,1)=cAll(:,1)-40;
    cAllPos(:,2)=cAll(:,2)-30;
    str=cell(1,1);
    for object = 1:1:length(allBoxes(:,1)) % Write the corresponding centroids for blue
%         centX{object} = cAll(object,1); centY{object} = cAll(object,2);
        str{object}=sprintf('X:%4d\nY:%4d',cAll(object,1),cAll(object,2)); 
        
    end
        fr=insertText(fr,cAllPos,str,'BoxOpacity',0,'textColor','yellow','FontSize',18);
        hold off;
        imagesc(fr);
        hold on;
        
    if(nFrame>1)
%         imshow(fr);
%         CX=[cbPrev(:,1),cb(:,1)]';
%         CY=[cbPrev(:,2),cb(:,2)]';
%         [cx,cy]=assignLabels(CX,CY);
%         plot(cx(end,:),cy(end,:),'o-','linewidth',2)
%         plot(CX(end,:),CY(end,:),'o-','linewidth',2)
    end
    crPrev=cr;
    cgPrev=cg;
    cbPrev=cb;
    nFrame=nFrame+1;
        
end
%% Clearing Memory
clear('v');
clear all;
clc;