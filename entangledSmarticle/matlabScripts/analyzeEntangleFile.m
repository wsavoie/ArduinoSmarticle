function [fpars,t,strain,F]=analyzeEntangleFile(fold,fname,chainLen,FTfreq)
%fpars = params from files [type,strain, sys width,del,version
%time in seconds
%strain, unitless
%F in newtons


% fold='A:\2DSmartData\entangledData\StretchON';
% fname='Stretch_1_SD_65_H_10.5_del_4_v_1.csv';

% ftFreq=1000;
ft=importdata(fullfile(fold,fname));
[t_op,q_op]= getOptiData(fullfile(fold,['OPTI_',fname]));
 
t=[1:length(ft(:,2))]./FTfreq;
F=-ft(:,2);%y+ is backwards

%fix timing between scripts optitrack starts slightly first
dd=t_op(end)-t(end);
dd_ind=find(dd<t_op,1,'first');
t_op=t_op(dd_ind:end)-t_op(dd_ind);
q_op=q_op(dd_ind:end);

%interpolate opti data to length of FT data
q1=interp1(t_op,q_op,t,'linear','extrap');
strain=[q1/chainLen]';

%get parameters from file
[~,fpars]=parseFileNames(fname);
fpars(2)=fpars(2)/1000; %put strain in meters
fpars(3)=fpars(3)/100; %put height in meters


%%%%%%%%%%%%%%%%%%%%%%%
