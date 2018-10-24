function showSmState(src, evt,stateDat,stFig,vidFl)

crdDat=stateDat.crdDat; relDat=stateDat.relDat; ring=stateDat.ring;
setappdata(src, 'CallbackRun', 0); %to prevent continuing after interruption
t=stateDat.t; fnames=stateDat.fname; ix2dat=stateDat.smpRes;
[~,selIx]=min(abs([src.XData', src.YData']-evt.IntersectionPoint(1:2)));
if(selIx(1)~=selIx(2)); warning('cannot find the point'); return; end
datIx=selIx(1)*ix2dat+1;
set(0,'CurrentFigure',stFig);
subplot(1,2,2); %**ADDED**
cla;
ax=gca;

if(~vidFl) %show data plots
    subplot(311);plot(squeeze(relDat(:,1,datIx-ix2dat:datIx+ix2dat))') %tAll(datIx-ix2dat:datIx+ix2dat,2),
    title(['movie: ',fnames(t(datIx,2)),'  time: ',...
        num2str(t(datIx-ix2dat,1)),' : ',num2str(t(datIx+ix2dat,1))]);
    subplot(312);plot(squeeze(relDat(:,2,datIx-ix2dat:datIx+ix2dat))')
    subplot(313);plot(squeeze(relDat(:,3,datIx-ix2dat:datIx+ix2dat))')
elseif(vidFl==1 || vidFl==2) %show simulated videos
    hold on; windSize=19.2/5.2;
    th=0:0.01:2*pi; %tiSp=find(t>52,1);
    fnms=fnames(cell2mat(fnames(:,2))==t(datIx,3));
    crdDat(:,1:2,datIx-ix2dat:datIx+ix2dat)=crdDat(:,1:2,datIx-ix2dat:datIx+ix2dat)... %center them
        -mean(mean(crdDat(:,1:2,datIx-ix2dat:datIx+ix2dat)),3);
    for ti=round(datIx-ix2dat):datIx+ix2dat
        if (getappdata(src, 'CallbackRun') == 1); return; end %cut out if returning after interrupt
        crd=smcle2coord(crdDat(:,:,ti));
        clf; hold on; axis([-0.5,0.5,-0.5,0.5]*(windSize)*1.5); axis square;
        if(vidFl==1);plot(crd(:,3:2:5)',crd(:,4:2:6)','-','LineWidth',2,'Color',[0,1,1]*0.7);
        else; plot(crd(:,1:2:7)',crd(:,2:2:8)','-','LineWidth',2,'Color',[0,1,1]*0.7);
        end
        %     cla; plot(crd(:,3:2:5)',crd(:,4:2:6)','-','LineWidth',1);
        plot(crdDat(:,1,ti)+0.05*cos(crdDat(:,3,ti)),crdDat(:,2,ti)+0.05*sin(crdDat(:,3,ti)),'k.','MarkerSize',15);
        %     plot(crdDat(11:end,1,ti),crdDat(11:end,2,ti),'r.','MarkerSize',15);
        plot(windSize*cos(th)/2,windSize*sin(th)/2);  %plot circle
        %             plot(ring(ti,1)+windSize*cos(0.6+0.8*th+ring(ti,3))/2,ring(ti,2)+windSize*sin(0.6+0.8*th+ring(ti,3))/2);  %plot circle
        title([num2str(t(datIx,3)),'movie: ',fnms(t(datIx,2),:),'  time: ',num2str(t(ti,1))]);
        pause(0.01)
    end
else %open actual videos
    %         eval(['! open /Applications/vlc.app "/Users/pchvykov/Documents/notGD/Smarticle_videos/',fnames(t(datIx,2),1:end-3),...
    %             'mp4"  --args --start-time=',num2str(t(datIx-ix2dat,1))]);
    fnms=fnames(cell2mat(fnames(:,2))==t(datIx,3));
    % % %         v = VideoWriter('v6','Motion JPEG AVI');
    % % %         open(v);
    ['D:\vids\',fnms{t(datIx,2)}(1:end-3),'mp4']
    vid=VideoReader(['D:\vids\',fnms{t(datIx,2)}(1:end-3),'mp4'],'CurrentTime',t(datIx-ix2dat,1));
    
    
    
    for vi=1:vid.FrameRate*(t(datIx+ix2dat,1)-t(datIx-ix2dat,1))
        if (getappdata(src, 'CallbackRun') == 1); return; end %cut out if returning after interrupt
        frame=readFrame(vid);
        
        
        %******added**********
        byPeriod=1;
        if byPeriod
            if ~mod(vi,floor(244))
                image(frame,'Parent',ax);
            else
                image(frame,'Parent',ax);
            end
        end
        axis off %**ADDED**
        set(gca,'PlotBoxAspectRatio',[1,1/(1920/1080),1]); %**ADDED**
        %******added**********
        
        
        pause(1/vid.FrameRate/2);
        % % %                 writeVideo(v,frame);
        
    end
    %             close(v);
end
setappdata(src, 'CallbackRun', 1);
% set(ObjH, 'Color', rand(1, 3));
% AxesH = ancestor(src, 'axes');
% disp(get(AxesH, 'CurrentPoint'));
end