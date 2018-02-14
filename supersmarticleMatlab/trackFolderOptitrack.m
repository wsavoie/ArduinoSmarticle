%clear all
% fold=uigetdir('A:\2DSmartData');
% fold=uigetdir('A:\2DSmartData\LightSystem\rossSmarts\mediumring');
% fold=uigetdir('A:\2DSmartData\shortRing\redSmarts\');
% fold=uigetdir('A:\2DSmartData\chordRing');
fold=uigetdir('A:\2DSmartData\mediumRing\redSmarts\metal_allActive\all');
f=dir2(fullfile(fold,'*.csv'));

RIGIDBODYNAMES = true; %make true if tracking multiple things (i.e. inactive smarticles)
clearvars rigidBodyName
if RIGIDBODYNAMES
    rigidBodyName{1} = ' ring';
    rigidBodyName{2} = ' frame';
    chordFlat=' flat';
    activeName= ' active';
    inactiveName=' inactive';
    
    otherName=inactiveName;
    
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
dec=12; %decimate amount
%HANDEDNESS IN QUATERNIONS ISNT CHANGED?
conv=zeros(nMovs,1);

closeWaitbar;
fold
h = waitbar(0,'Please wait...');
steps = nMovs;
idx=1;
badIdx=0;
failedAttempts=struct;
warning(['may want to change last argument in RIGIDBODYNAMES current name is ',otherName])
for i=1:nMovs
    
    % for i =1:length(f)
    waitbar(i/steps,h,{['Processing: ',num2str(i),'/',num2str(length(f))],f(i).name})
    %     pts(i,'/',nMovs);
    %     [t,x,y,tracks]
    
    try
        [movs(idx).t,movs(idx).x,movs(idx).y,movs(idx).data,movs(idx).fps, movs(idx).rot]= trackOptitrack(fullfile(fold,f(i).name),dec,rigidBodyName);
        if RIGIDBODYNAMES
            %         [~,movs(idx).Ax,movs(idx).Ay,movs(idx).Adata,movs(idx).Arot]= trackOptitrack(fullfile(fold,f(i).name),dec,activeName);
            [movs(idx).t,movs(idx).Ix,movs(idx).Iy,movs(idx).Idata,movs(idx).fps, movs(idx).Irot]= trackOptitrack(fullfile(fold,f(i).name),dec,otherName);
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