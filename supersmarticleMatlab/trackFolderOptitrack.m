%clear all
% fold=uigetdir('A:\2DSmartData');
fold=uigetdir('A:\2DSmartData\shortRing\redSmarts\pad_singleInactive_nolightpipe_HEAVY');
f=dir2(fullfile(fold,'*.csv'));

RIGIDBODYNAMES = true; %make true if tracking multiple things (i.e. inactive smarticles)

if RIGIDBODYNAMES
    rigidBodyName = ' ring';
    activeName= ' active';
    inactiveName=' inactive';
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
for i=1:nMovs

% for i =1:length(f)
    waitbar(i/steps,h,{['Processing: ',num2str(i),'/',num2str(length(f))],f(i).name})
%     pts(i,'/',nMovs);
%     [t,x,y,tracks]
    
    [movs(i).t,movs(i).x,movs(i).y,movs(i).data,movs(i).rot]= trackOptitrack(fullfile(fold,f(i).name),dec,rigidBodyName);
    if RIGIDBODYNAMES
%         [~,movs(i).Ax,movs(i).Ay,movs(i).Adata,movs(i).Arot]= trackOptitrack(fullfile(fold,f(i).name),dec,activeName);
        [movs(i).t,movs(i).Ix,movs(i).Iy,movs(i).Idata,movs(i).Irot]= trackOptitrack(fullfile(fold,f(i).name),dec,inactiveName);
    end
    movs(i).fname=f(i).name;
    movs(i).fps=120/dec;
    movs(i).conv=1;
    [~,vals]=parseFileNames(f(i).name);
    %%
%     spk=[0]; smart=[-90]; gait=[1]; rob=[5]; v=[nMovs];
    vals=[0 0 1 5 i];
    %%
    movs(i).pars=vals;
    
end
closeWaitbar;
save(fullfile(fold,'movieInfo.mat'),'movs','fold','nMovs','r')
