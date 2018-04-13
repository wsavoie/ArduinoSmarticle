function [fpars,t,strain,F,L,rob,chain,dsPts, vel]=analyzeEntangleFileMM(fold,fname,FTfreq)
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
F=ft(:,3);%y+ is backwards

%fix timing between scripts optitrack starts slightly first
dd=t_op(end)-t(end);

%old way of doing this
% dd_ind=find(dd<t_op,1,'first');
% t_op=t_op(dd_ind:end)-t_op(dd_ind);
% z_op=z_op(dd_ind:end,:);


% %fix timing between scripts optitrack starts slightly first
% dd=t_op(end)-t(end);
% if dd>0 %op runs longer
% %cut beginning off op
% dd_ind=find(abs(dd)<t_op,1,'first');
% t_op=t_op(dd_ind:end)-t_op(dd_ind);
% z_op=z_op(dd_ind:end)-z_op(dd_ind);
% else %ft runs longer
% dd_ind=find(abs(dd)<t,1,'first');
% t=t(dd_ind:end)-t(dd_ind);
% F=F(dd_ind:end)-F(dd_ind);
% end


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
hold on;
h=plot(t,strain);
%[strainT,strainY,~,idx]
dsPts=zeros(fpars(6)*2,3); %time1,strain1,idx1
% [dsPts(:,1),dsPts(:,2),~,dsPts(:,3)]=MagnetGInput(h,fpars(6)*2,1);

np=fpars(6)*2;
x=linspace(0,1,length(t));

totalPts=fpars(6)*2;
pys=strain.*exp(1-x); % fpars(6)/2
pye=strain.*exp(x);%fpars(6)/2

ns=strain-nanmean(strain);
mys=-ns.*exp(1-x);%fpars(6)/2+1
mye=-ns.*exp(x);%fpars(6)*2-(fpars(6)*3/2+1) mye(10

[~,dsPts(2:4:np,3)]=findpeaks(pys,'npeaks',fpars(6)/2,'minpeakdistance',length(t)/fpars(6)*1.05);
[~,dsPts(3:4:np,3)]=findpeaks(pye,'npeaks',fpars(6)/2,'minpeakdistance',length(t)/fpars(6)*1.05);
[~,dsPts([1,4:4:12],3)]=findpeaks(mys,'minpeakheight',mye(1)*1.05,'npeaks',fpars(6)/2+1,'minpeakdistance',length(t)/fpars(6)*1.05);
if(np>4)
    [~,dsPts(5:4:(np-1),3)]=findpeaks(mye,'minpeakheight',mye(1)*1.05,'npeaks',fpars(6)*2-(fpars(6)*3/2+1),'minpeakdistance',length(t)/fpars(6)*1.05);
end

dsPts(:,2)=strain(dsPts(:,3));
dsPts(:,1)=t(dsPts(:,3));


plot(dsPts(:,1),dsPts(:,2),'.','r');
pause;
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
