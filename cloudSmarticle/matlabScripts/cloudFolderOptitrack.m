%clear all
% fold=uigetdir('A:\2DSmartData');
fold=uigetdir('A:\2DSmartData\cloud\willData\equal delay\rigid bodies markers messup');
f=dir2(fullfile(fold,'*.csv'));

RIGIDBODYNAMES = true; %make true if tracking multiple things (i.e. inactive smarticles)
[~,pathFold,~] = fileparts(fold);
% randAmp=
a=strfind(pathFold, 'd');
randAmp=str2double(pathFold(a+1:end));
% randAmp=0; %eventually read from filename instead
if RIGIDBODYNAMES
    numBods = 6;
    %names of bodies will be "something #"
else
    %     rigidBodyName = 'rigid body 1';
    numBods= 8;
end

% r=.9525;
%^N.B. put a space in front of keywords that could occur within other keywords
%     clf;
movs=struct;
nMovs=length(f);
movs(nMovs).fname='';
dec=12; %decimate amount
%HANDEDNESS IN QUATERNIONS ISNT CHANGED?
conv=zeros(nMovs,1);

closeWaitbar;
pts(fold);
h = waitbar(0,'Please wait...');
steps = nMovs;
idx=1;
badIdx=0;
failedAttempts=struct;
minT=1e18;%choose very large number
for i=1:nMovs
    
    % for i =1:length(f)
    waitbar(i/steps,h,{['Processing: ',num2str(i),'/',num2str(length(f))],f(i).name})
    %     pts(i,'/',nMovs);
    %     [t,x,y,tracks]
    
    %     try
    if RIGIDBODYNAMES
        for jj=1:numBods
            [movs(idx).t(:,jj),movs(idx).x(:,jj),movs(idx).y(:,jj),~,movs(idx).rot(:,jj)]= cloudOptitrack(fullfile(fold,f(i).name),dec,[' ',num2str(jj)]);
        end
        XX=cell(size(movs(idx).x,1),1);YY=XX;
        
        for jj=1:size(movs(idx).x,1)
            XX{jj}=movs(idx).x(jj,:);
            YY{jj}=movs(idx).y(jj,:);
        end
        [movs(idx).x,movs(idx).y,idxs]=linkOptiTrackTimeStepsCMU(XX,YY,size(movs(idx).x,2),.03);
        movs(idx).rot=movs(idx).rot(idxs);
        
        
        movs(idx).rotdot=diff(movs(idx).rot)./diff(movs(idx).t);
    else
        %                 for jj=1:numBods
        [movs(idx).t,movs(idx).x,movs(idx).y,~] = cloudOptitrack(fullfile(fold,f(i).name),dec,'');
        %             end
        
        
        
    end
    movs(idx).fname=f(i).name;
    movs(idx).xdot=bsxfun(@rdivide,diff(movs(idx).x),diff(movs(idx).t));
    movs(idx).ydot=bsxfun(@rdivide,diff(movs(idx).x),diff(movs(idx).t));
    
    
    
    movs(idx).fps=120/dec;
    movs(idx).conv=1;
    %         [~,vals]=parseFileNames(f(i).name);
    vals=[8, randAmp];
    %         %     spk=[0]; smart=[-90]; gait=[1]; rob=[5]; v=[nMovs];
    %         movs(idx).pars=vals;
    minT=min(size(movs(idx).x,1),minT);
    idx=idx+1;
    
    %     catch err
    %         error(err);
    %         badIdx=badIdx+1;
    %         failedAttempts(badIdx).name=f(i).name;
    %     end
end
closeWaitbar;
save(fullfile(fold,'movieInfo.mat'),'movs','fold','nMovs','numBods','minT','vals')
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