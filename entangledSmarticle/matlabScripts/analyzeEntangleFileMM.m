function [fpars,t,strain,F,L,rob,chain,dsPts vel]=analyzeEntangleFileMM(fold,fname,FTfreq)
%fpars = params from files [type,strain, sys width,del,version
%time in seconds
%strain, unitless
%F in newtons
%L in meters
%chain end pts in meters
%dsPts [time1,strain1,idx1;time2,strain2,idx2] strain start and endpts

smartWidth=5.4; %5.4 cm for center link width
%6.4 cms from back to arm tip in u-shape

% ftFreq=1000;
ft=importdata(fullfile(fold,fname));
[t_op,z_op]= getOptiDataMM(fullfile(fold,['OPTI_',fname])); 
t=[1:length(ft(:,2))]'./FTfreq;
F=-ft(:,2);%y+ is backwards

%fix timing between scripts optitrack starts slightly first
dd=t_op(end)-t(end);
dd_ind=find(dd<t_op,1,'first');
t_op=t_op(dd_ind:end)-t_op(dd_ind);
z_op=z_op(dd_ind:end,:);

%interpolate chain opti to length of FT data
chain=interp1(t_op,z_op(:,1),t,'linear','extrap');
chain(:,2)=interp1(t_op,z_op(:,2),t,'linear','extrap');

%interpolate robot opti dat to length of FT data
rob=interp1(t_op,z_op(:,3),t,'linear','extrap')/smartWidth;

%get initial length of chain
L=diff(chain,1,2);
L0=L(1);

strain=[(L-L0)/L0]';


%get parameters from file
[~,fpars]=parseFileNames(fname);
fpars(2)=fpars(2)/1000; %put strain in meters
fpars(3)=fpars(3); %put system (H) width in smart widths
figure(1000);
clf;
h=plot(t,strain);
%[strainT,strainY,~,idx]
dsPts=zeros(fpars(6)*4,3); %time1,strain1,idx1
[dsPts(:,1),dsPts(:,2),~,dsPts(:,3)]=MagnetGInput(h,fpars(6)*4,1);

if ~isempty(find(isnan(strain), 1))
    id=find(isnan(strain),1);
    prevVal=strain(id-1);
    strain(id-1:end)=prevVal;
    pts('error in:',fullfile(fold,fname));
end
 %get indices between first two points
ptSpan=dsPts(1:2,3);
d=diff(ptSpan)/4;
%get middle range of points
ptSpan=[ptSpan(1)+floor(d),ptSpan(1)+2*floor(d)];
vel=diff(strain(ptSpan))/diff(t(ptSpan));
%%%%%%%%%%%%%%%%%%%%%%%
