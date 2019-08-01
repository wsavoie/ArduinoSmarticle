% function []=trackVidColors(fpath)
% clear all
%fpath='A:\Dropbox\smartmovies\pavel-smartVariousVidsAndPics\PavelTrip2\tracking\RGT10.mp4';
% fpath='A:\Dropbox\smartmovies\Characterizing Gliders\Tracking Arms\Random Gait Correlated\T9.mp4';
fpath='A:\Dropbox\smartmovies\Characterizing Gliders\Tracking Arms\Random Gait Correlated\GoodVideos\T8.mp4';
PLOTON=0;
tic
matlab.video.read.UseHardwareAcceleration('on');

fps=30;
diam=19.2; %cm

v = VideoReader(fpath);

colorMat={'red','green','blue'};
col=['r' 'g' 'b'];
totFrames=floor(v.duration/(1/v.frameRate));
blobsPerSmart=4;
numSmarts=3;
blobCX=NaN(totFrames,blobsPerSmart*numSmarts);
blobCY=blobCX;
figure(1);
% imshow(fr)

hblob = vision.BlobAnalysis('AreaOutputPort', true, ... % Set blob analysis handling
    'CentroidOutputPort', true, ...
    'BoundingBoxOutputPort', true, ...
    'MinimumBlobArea', 200, ...  %uncomment minBlobAr to find
    'MaximumBlobArea', 2400, ... %uncomment maxBlobAr to find
    'MaximumCount', 12);

se = strel('disk',4);
% thresh = [180/255,165/255,190/255];
% mult=[3.0 5.30 3.15]; 
thresh = [180/255,160/255,180/255];
% thresh = [180/255,170/255,220/255];
mult=[3.0 6.3 3.15]; 
%mult=[3 15 5.4]; 
t=[1:totFrames]';
t=t*1/fps;
pause(.25)
for(i=1:totFrames)
    fr=v.readFrame;
    fr=flip(fr,2);
    if(i==1)
        imshow(fr);
        calibFactor=calibrateDistance(diam);
    end   
    for j=1:numSmarts
        
        nff = mult(j)*imsubtract(fr(:,:,j), rgb2gray(fr)); % Get color
%         nf=imdilate(nf,se);
%         nff=imopen(nff,se);
        nf = imbinarize(nff, thresh(j)); % Convert the image into binary with color as white
        [~,C]=step(hblob, nf); % Get the centroids and bounding boxes of the colored blobs
%         if(i==2083)
%             pts('hi');
%         end
        
%         disp(['areas of ', colormat{j}]);
%         A
        
        
        C = round(C); % Convert the centroids into Integer for further steps
        
        if(size(C,1)<blobsPerSmart)
            pts('only found ', size(C,1), ' ',colorMat{j}, ' markers at frame:', i);
            hold off;
            imagesc(fr);
            title('click lost marker');
            hold on;
            plot(C(:,1),C(:,2),'o-','linewidth',2,'color',col(j))
            [x,y]=ginput(blobsPerSmart-size(C,1));
            C=[C;round([x,y])];
%             pause
        end
        
        if(size(C,1)>blobsPerSmart)
            error(['finding too many markers in ',colorMat{j}, ' channel']);
        end
        
%         if(PLOTON)
%             cAllPos=C;
%             cAllPos(:,1)=C(:,1)-40;
%             cAllPos(:,2)=C(:,2)-30;
%             clear('str');
%             str=cell(1,1);
%             fr=insertShape(fr,'filledRectangle',boxC,'color',colorMat{j},'opacity',.4);
%             for object = 1:1:length(boxC(:,1)) % Write the corresponding centroids for blue
%                 %                 centX{object} = C(object,1); centY{object} = C(object,2);
%                 str{object}=sprintf('X:%4d\nY:%4d',C(object,1),C(object,2));
%             end
%             fr=insertText(fr,cAllPos,str,'BoxOpacity',0,'textColor','yellow','FontSize',18);
%             
%         end
        
        startInd=(j-1)*blobsPerSmart+1;
        
        blobCX(i,startInd:startInd+size(C,1)-1)=C(:,1)';
        blobCY(i,startInd:startInd+size(C,1)-1)=C(:,2)';
        

        
    end
    
         
     if(~mod(i,500))
         t=toc;
         tic;
         
         pts('frame: ',i, '/',totFrames,' ', t, ' secs');
     end
        
    if(i==1)
        hold off;
        imagesc(fr);
        axis([0,1920,0,1080]);
        hold on;
        title('click marker colors in order R G B');
        [x,y]=ginput(blobsPerSmart*numSmarts);
        [D,I]=pdist2([x,y],[blobCX(1,:);blobCY(1,:)]','seuclidean','smallest',1);
        blobCX(1,I)=blobCX(1,:);
        blobCY(1,I)=blobCY(1,:);
        for(qq=1:numSmarts)

            si=(qq-1)*blobsPerSmart+1;
            ei=si+blobsPerSmart-1;
            plot(blobCX(1,si:ei),blobCY(1,si:ei),'o-','linewidth',2,'color',col(qq));
%             
        end
        hold off;
    end
    if(PLOTON)
        hold off
        imagesc(fr,'InitialMagnification','fit');
    end
end
%%
%fix labels
%save('rawMarkerDat.mat','blobCY','blobCX','movs','calibFactor');
for(i=1:numSmarts)
    si=(i-1)*blobsPerSmart+1;
    ei=si+blobsPerSmart-1;
    [blobCX(:,si:ei),blobCY(:,si:ei)]=assignLabels3(blobCX(:,si:ei),blobCY(:,si:ei));
end
blobCX=calibFactor*blobCX;
blobCY=calibFactor*blobCY;
% [ind,x]=max(abs(diff(blobCX(:,4))))

movs=struct;
movs.t=t;
movs.x=blobCX;
movs.y=blobCY;
movs.fps=fps;
movs.fname=v.Name;

save('markerDat2.mat','blobCY','blobCX','movs','calibFactor');
% end
% matlab.video.read.UseHardwareAcceleration('off')
% end

