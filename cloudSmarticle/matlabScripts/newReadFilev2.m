% close(V)
clear all
close all;
SAVEOUTMOVIE=1;
numBods=7;


[filename,fold]=uigetfile(fullfile('A:\2DSmartData\cloud\trueGranTempCloud','*.avi;*.mp4'));
V = VideoReader(fullfile(fold,filename));
fps=V.framerate;
N = round(V.duration*fps);

%define the vol frac and hull area vars
area=zeros(N,1);

%code for saving out to a movie
if(SAVEOUTMOVIE)
    filenameOut=[filename(1:end-4),'Outs'];
    vid = VideoWriter(fullfile(fold,'out',[filenameOut,'.avi']),'Motion JPEG AVI');
    open(vid);
end
marker='-';
% while hasFrame(V)
%for long videos parfor is better for this initial serial loop
% p(N)=patch;

% a1(N)=axes;
% c(N)=imshow(image);
figure(10);
clf;
a=readFrame(V);
imshow(a);
hold on;
rect=round(getrect);
I(1)={a(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),:)};
figure(1231)
imshow(I{1});
figure(10);
p=cell(N,1);
%pic
%define measurements in mm
bodSize=[53.5 21.25]; %bodyL,bodyW
armSize=[3.25 42.25]; %armL, armW

%convert mm to pix, create line in pic to measure a known smart length
[a]=imline; %get length of first click left then click right
f = warndlg('Click ok after finished sizing line to a single smarticle body length.', 'A Warning Dialog');
waitfor(f);
b=a.getPosition;
dist=norm(diff(b),2);
conv=dist/bodSize(1); %pix/mm conversion
smartArea=prod(conv*bodSize)+2*prod(conv*armSize);
totSmartArea=smartArea*numBods;
tic
h=figure(55);
close(10);
close(1231);

loopSize=500;
parLen=0;
cc=2;
while(cc<N)
    if (N-cc)>loopSize
        parLen=loopSize;
    else
        parLen=N-cc;
    end
    I=cell(1,parLen);
    for i=1:parLen
        a=readFrame(V);
        I{i}=a(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),:);
    end
    tarea=zeros(1,parLen);
    parfor(i=1:parLen)
        [~,tarea(i),p{i}]=processImage(I{i},h);
        
    end
    area(cc:cc+parLen-1)=tarea;
    cc=cc+parLen;
    %         [hull,solidity(i), ~,~]=GetHull(I,h);
    %     area(i)=polyarea([hull(:,2)],[hull(:,1)]);
    %     p(i)={[hull(:,2),hull(:,1)]};
    if(SAVEOUTMOVIE)
        for(i=1:parLen)
            
            %             figure(15);
            imshow(I{i},'border','tight','initialMagnification','fit');
            patch(p{i}(:,1),p{i}(:,2),'r','FaceAlpha',.3);
            writeVideo(vid,getframe(gcf));
            clf;
        end
    end
        pts(cc,'/',N);
end

phi=totSmartArea./area;
phi(1)=phi(2);
phi(end)=phi(end-1);
% parfor i=1:N2

hh=figure(1000);
hh.Position=[0 0 1280 720];

if(SAVEOUTMOVIE)
    close(vid);
    %     close(V);
end
close
figure(28);
plot(phi);
save([fold,filenameOut,'.mat'],'phi','dist');
toc
