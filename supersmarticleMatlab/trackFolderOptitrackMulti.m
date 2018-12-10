%clear all
% fold=uigetdir('A:\2DSmartData');
% fold=uigetdir('A:\2DSmartData\LightSystem\rossSmarts\mediumring');
% fold=uigetdir('A:\2DSmartData\shortRing\redSmarts\');
% fold=uigetdir('A:\2DSmartData\chordRing');
fold=uigetdir('A:\2DSmartData\mediumRing\redSmarts\');
f=dir2(fullfile(fold,'*.csv'));

RIGIDBODYNAMES = true; %make true if tracking multiple things (i.e. inactive smarticles)
clearvars rigidBodyName
if RIGIDBODYNAMES
%     inactiveName=' inactive';
    frameName=' frame';
    numBods = 5;
else
    rigidBodyName = 'rigid body 1';
end

% r=.9525;
%^N.B. put a space in front of keywords that could occur within other keywords
%     clf;
movs=struct;
nMovs=length(f);
movs(nMovs).fname='';
r=.09525;%radius of boundary in meters
dec=1; %decimate amount
%HANDEDNESS IN QUATERNIONS ISNT CHANGED?
conv=zeros(nMovs,1);

closeWaitbar;
fold
h = waitbar(0,'Please wait...');
steps = nMovs;
idx=1;
badIdx=0;
failedAttempts=struct;
warning(['number of smarticles to track is set to ', num2str(numBods)])

for i=1:nMovs
    
    % for i =1:length(f)
    waitbar(i/steps,h,{['Processing: ',num2str(i),'/',num2str(length(f))],f(i).name})
    %     pts(i,'/',nMovs);
    %     [t,x,y,tracks]
    
    try
        for jj=1:numBods
            [movs(idx).t,movs(idx).Ax(:,jj),movs(idx).Ay(:,jj),~,fps,movs(idx).Arot(:,jj)]= trackOptitrack(fullfile(fold,f(i).name),dec,[' ',num2str(jj)]);
        end
        if exist('frameName','var')
            [~,movs(idx).x,movs(idx).y,movs(idx).data,movs(idx).fps, movs(idx).rot]= trackOptitrack(fullfile(fold,f(i).name),dec,frameName);
        end
        if exist('inactiveName','var')
            [~,movs(idx).Ix,movs(idx).Iy,movs(idx).Idata,movs(idx).fps, movs(idx).Irot]= trackOptitrack(fullfile(fold,f(i).name),dec,inactiveName);
        end
        movs(idx).fname=f(i).name;
        movs(idx).conv=1;
        [~,vals]=parseFileNames(f(i).name);
        vals=[0 0 1 5 i];
        %     spk=[0]; smart=[-90]; gait=[1]; rob=[5]; v=[nMovs];
        movs(idx).pars=vals;
        idx=idx+1;
    catch
        badIdx=badIdx+1;
        failedAttempts(badIdx).name=f(i).name;
        
    end
end
closeWaitbar;
save(fullfile(fold,'movieInfo.mat'),'movs','fold','nMovs','r')
if(badIdx>0)
    pts(' ');
    warning([num2str(badIdx),' failed runs']);
    msg=cell(1,badIdx);
    for i=1:badIdx
        %         msg{yi}=failedAttempts(i).name;
        pts(failedAttempts(i).name);
    end
    %     h=msgbox(msg,'errors');
end
beep;