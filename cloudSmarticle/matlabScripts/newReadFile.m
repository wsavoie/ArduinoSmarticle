SAVEOUTMOVIE=1;

tic
hh=figure(1000);
hh.Position=[0 0 1280 720];
[filename,fold]=uigetfile(fullfile('A:\SmarticleAreaFractionData','*.avi;*.mp4'));
V = VideoReader(fullfile(fold,filename));
fps=V.framerate;
N = round(V.duration*fps);

%define the vol frac and hull area vars
solidity=zeros(N,1);
areaNorm=zeros(N,1);
hull=cell(N,1);

%create waitbar
closeWaitbar;
h = waitbar(0,'Please wait...');
movegui(h,[2300,500]);

%code for saving out to a movie
if(SAVEOUTMOVIE)
    filenameOut=[filename(1:end-4),'Outs'];
    vid = VideoWriter(['A:\SmarticleAreaFractionData\',filenameOut,'.avi'],'Motion JPEG AVI');
    open(vid);
end
marker='-';
% while hasFrame(V)
%for long videos parfor is better for this initial serial loop
I=cell(N,1);
c=zeros(1,N);
p(N)=patch;
a1(N)=axes;
% c(N)=imshow(image);
figure(10);
clf;
hold on;
for(i=1:N)
     I(i)={readFrame(V)};
end
parfor i=1:N
%     I(i) = readFrame(V);

    
    [hull{i},solidity(i), ~,~]=GetHull(I{i});
    areaNorm(i)=polyarea([hull{i}(:,2)],[hull{i}(:,1)])/(V.Width*V.Height);
    p(i)=patch([hull{i}(:,2)],[hull{i}(:,1)],'r','FaceAlpha',0.2,'visible','off');
%     c=image(I{i},'border','tight','initialMagnification','fit');
%     c(i)=image(I{i},'visible','off');
    
end


% parfor i=1:N
figure(1000);
hold off
if(SAVEOUTMOVIE)
  for i=1:N  
%     gca;
%     set(c(i),'Parent',hh.CurrentAxes,'visible','on');
    imshow(I{i},'border','tight','initialMagnification','fit');
    set(p(i),'Parent',hh.CurrentAxes,'visible','on');
    writeVideo(vid,getframe(gcf));
%     clf;
    waitbar(i/N,h,{['Processing frame: ',num2str(i),'/',num2str(N)]});
  end
end
%     p(i).Parent=hh.CurrentAxes;
%     clf(hh);
%     hh=figure(1000);
%     
%     subplot(2,2,1);
%     imshow(I,'border','tight');
%     p=patch([cHull{1}(:,2)],[cHull{1}(:,1)],'r');
%     set(p,'FaceAlpha',0.2);
%     subplot(2,2,3);
%     hold on;
% %     imshow(CH);
%     imshow(BW,'border','tight');
%     
%     
%     waitbar(i/N,h,{['Processing frame: ',num2str(i),'/',num2str(N)]});
% %     subplot(2,2,[2,4]);
%     subplot(2,2,[2]);
%     hold on;
% %        plot((1:i)./fps,solidity(1:i)',marker,'linewidth',2,'markerfacecolor','w');
%     plot((1:i)./fps,solidity(1:i)',marker,'linewidth',1);
% %     axis([0 N./fps 0.4 0.7]);
%     axis([0 N./fps .1 .6])
%     set(gca,'ytick',[.1:.05:.6],'yticklabel',{'0.1','','0.2','','0.3','','0.4','','0.5','','0.6',})
%     xlabel('time (s)');
%     ylabel('Area Fraction \phi');
%     
%     subplot(2,2,4);
% %     plot((1:i)./fps,areaNorm(1:i),marker,'linewidth',2,'markerfacecolor','w');
%     plot((1:i)./fps,areaNorm(1:i),marker,'linewidth',1);
%     axis([0 N./fps .1 .6])
%     set(gca,'ytick',[.1:.05:.6],'yticklabel',{'0.1','','0.2','','0.3','','0.4','','0.5','','0.6',})
%     xlabel('time(s)');
%     ylabel('Normalized Area')
%     figText(gcf,18);
% %     i=i+1;
%     if(SAVEOUTMOVIE)
%        
%         
%     end
% end

closeWaitbar;

% plot((1:N)./fps,solidity,'linewidth',2);
% 
% 
% xlabel('time (s)');
% ylabel('\phi');

if(SAVEOUTMOVIE)
    close(vid);
end
close
toc