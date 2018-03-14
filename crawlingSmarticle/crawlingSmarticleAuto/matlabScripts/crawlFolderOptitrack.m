% function [ output_args ] = crawlFolderOptitrack( input_args )
%CRAWLFOLDEROPTITRACK Summary of this function goes here
%   Detailed explanation goes here
% fold=uigetdir('A:\2DSmartData\crawl');
fold=uigetdir('A:\Dropbox\Smarticles\Shengkai''s Summaries\gaitTestData');
f=dir2(fullfile(fold,'*.csv'));

RIGIDBODYNAMES = false; %make true if tracking multiple things (i.e. inactive smarticles)
clearvars walkerName
if RIGIDBODYNAMES
    walkerName{1} = ' walker';
    walkerName{2} = ' crawler';
else
    walkerName{1} = 'rigid body 1';
    rigidBodyName=walkerName{1};
end

% r=.9525;
%^N.B. put a space in front of keywords that could occur within other keywords
%     clf;
movs=struct;
nMovs=length(f);
movs(nMovs).fname='';
dec=1; %decimate amount
%HANDEDNESS IN QUATERNIONS ISNT CHANGED?
conv=zeros(nMovs,1);
closeWaitbar;
pts('folder name: ',fold);
h = waitbar(0,'Please wait...');
steps = nMovs;
idx=0;
badIdx=0;
failedAttempts=struct;
for i=1:nMovs
    
    % for i =1:length(f)
    waitbar(i/steps,h,{['Processing: ',num2str(i),'/',num2str(length(f))],f(i).name})
    %     pts(i,'/',nMovs);
    %     [t,x,y,tracks]
    
    if RIGIDBODYNAMES
        %         [~,movs(i).Ax,movs(i).Ay,movs(i).Adata,movs(i).Arot]= trackOptitrack(fullfile(fold,f(i).name),dec,activeName);
        try
            idx=idx+1;
            [movs(idx).t,movs(idx).x,movs(idx).y,movs(idx).z,movs(idx).data,movs(idx).rot]= trackOptitrack(fullfile(fold,f(i).name),dec,walkerName);
            movs(idx).fname=f(i).name;
            movs(idx).fps=120/dec;
            [p,v]=parseFileNames(f(i).name);
            vals=v(3:5);
            %vals=D R V    %%
            movs(idx).pars=vals;
            
        catch ME
            badIdx=badIdx+1;
            failedAttempts(badIdx).name=f(i).name;
            continue;
        end
    else
%         error('no rotation');
                 [movs(i).t,movs(i).x,movs(i).y,movs(i).data]= trackOptitrack(fullfile(fold,f(i).name),dec,rigidBodyName);
    end
    
end
closeWaitbar;
nMovs=idx;
save(fullfile(fold,'movieInfo.mat'),'movs','fold','nMovs')
if(badIdx)
    pts(' ');
    warning([num2str(badIdx),' failed runs']);
    msg=cell(1,badIdx);
    for i=1:badIdx
%         msg{i}=failedAttempts(i).name;
        pts(failedAttempts(i).name);
    end
%     h=msgbox(msg,'errors');
end

% end

