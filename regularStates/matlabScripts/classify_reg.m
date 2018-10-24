%Smarticles experimental data processing
%classifying regular states
% clear all;
%---------------------------------
%Choices:
%setup: nPrd,
%sym: relative or absolute orientations? ref. r to ring instead of c.o.m.? deal with mod at this stage?
%split: measure the exact freq?
%FT: normalize phase or just leave as is? include IR & intermed freq?
%Perm-inv: many choices of functions. Normalize somehow?
%% Fixing stuff:
% tTot=0;
% for iMov=1:length(movs)
%     tTot=tTot+length(movs(iMov).t(:,1));
% end
% tTot
%%
% if ~exist('pprocDat','var')
% load('180821preprocDat.mat');
% end
DSix=1; %index of the data-set loaded
featVecAll=[]; crdDatAll=[]; piDatAll=[]; relDatAll=[]; relDat1All=[]; tAll=[]; fnameAll=[]; ringAll=[];
rng(1); iMov=1;
waveletsFl=true;
nPrd=2; %number of periods in a snippet
global A B tRes; B=1; A=0.8; %smarticle size
windSize=19.2/5.2; %relative ring size
Nsm=length(movs(1).x(1,:)); tRes=1/movs(1).fps; %time resolution
stRes=round(movs(1).fps/10); %store 10 points per second
nMovs=length(movs);
%%
for iMov=1:nMovs
    t=movs(iMov).t(:,1); tLen=length(t);
    crdDat=[];
    crdDat(:,1,:)=permute(movs(iMov).x,[2,3,1])*100/5.2; %in units of smarticle size
    crdDat(:,2,:)=permute(movs(iMov).y,[2,3,1])*100/5.2;
    crdShift=mean(mean(crdDat(:,1:2,:)),3);
    crdDat(:,1,:)=crdDat(:,1,:)-crdShift(1);
    crdDat(:,2,:)=crdDat(:,2,:)-crdShift(2);
    crdDat(:,3,:)=permute(movs(iMov).rot,[2,3,1])+pi/2;
    if(isfield(movs(iMov),'FRx')) %ring is tracked
        ring=[movs(iMov).FRx*100/5.2-crdShift(1),movs(iMov).FRy*100/5.2-crdShift(2),movs(iMov).FRrot];
        if(false) %is it D-ring? requires additional calibration:
            vecC=ring(:,1:2)-squeeze(mean(crdDat(:,1:2,:)))'; vecP=[];
            [vecP(:,2),vecP(:,1)]=cart2pol(vecC(:,1),vecC(:,2));
            angErr=wrapToPi(vecP(:,2)-ring(:,3));
            if(max(abs(angErr))>pi*2/3); angErr=wrapTo2Pi(angErr); end
            ring(:,3)=ring(:,3)+mean(angErr);
            ring(:,1:2)=ring(:,1:2)-windSize/2.5*[cos(ring(:,3)),sin(ring(:,3))];
        end
    else; ring=zeros(tLen,3); %ring not tracked
    end
    %%
    stIx=find(max(crdDat(:,1,2:end)-crdDat(:,1,1:end-1))/tRes > 0.4,1)-round(movs(1).fps/5); %a bit before bodies start moving
    plot(squeeze(crdDat(:,3,:))')
    tAll=[tAll; [t(1:stRes:end),[iMov,DSix].*ones(ceil(tLen/stRes),1)]];
    fnameAll=[fnameAll; {movs(iMov).fname, DSix}];
    ringAll=[ringAll; ring(1:stRes:end,:)];
    % continue;
    %% Base frequency and estimate arm locations
    FTth=fft(squeeze(crdDat(:,3,:))')'; lenf=length(FTth(1,:));
    FTthM=abs(FTth(:,1:lenf/2+1)/lenf); FTthPh=0*angle(FTth(:,1:lenf/2+1)/lenf);
    wdat=2*pi/tRes*(0:lenf/2)/lenf; wi=find(wdat>10,1);
    ftSt=20;
    % plot(wdat(20:wi),FTthM(:,ftSt:wi))%,wdat(20:wi),FTthPh(:,20:wi)/50);
    [~,freqIx]=max(FTthM(:,ftSt:wi),[],2); freqIx=freqIx+ftSt-1;
    freqList=1.00*wdat(freqIx)'; phaseList=FTthPh(repmat(1:lenf/2+1,Nsm,1)==freqIx);
    % freqList=ones(Nsm,1)*mean(freqList);
    prd=2*pi/mean(freqList)/tRes;
    plot(squeeze(crdDat(1,1,:))'); hold on %check periodicity
    plot(1:prd:length(t), squeeze(crdDat(1,1,1:prd:end))','.')
    if(std(phaseList)>1); phaseList=mod(phaseList,2*pi); end
    phaseList=phaseList-mean(phaseList)-pi/4;
    % gates = @(t) [cos(freqList*t+phaseList),sin(freqList*t+phaseList)]*pi/2; %variable frequency circle gate
    gates = @(t) -[smoothSq(freqList*t+phaseList),smoothSq(freqList*t+pi/2+phaseList)]*pi/2; %var freq smooth square gate
    % for ti=1:length(t)
    %     if(ti>stIx)
    %         crdDat(:,4:5,ti)=gates(t(ti-stIx));
    %     else; crdDat(:,4:5,ti)=gates(0);
    %     end
    % end
    crdDatAll=cat(3,crdDatAll,crdDat(:,:,1:stRes:end));
    %% Symmetrize data
    %relative coordinates to account for rotation and translation invariance:
    %------sm2 in ref.frame of sm1; sm3 in ref.frame of sm2; etc...-----
    relDat=[crdDat(2:end,1:3,:);crdDat(1,1:3,:)]-crdDat(:,1:3,:);
    relDat(:,3,:)=mod(relDat(:,3,:)+pi,2*pi)-pi;
    for si=1:Nsm %rotate crd into the reference frames of prev sm.
        cth=cos(crdDat(si,3,:)); sth=sin(crdDat(si,3,:));
        for ti=1:length(t)
            relDat(si,1:2,ti)=relDat(si,1:2,ti)*[[cth(:,:,ti), -sth(:,:,ti)]; [sth(:,:,ti),cth(:,:,ti)]];
        end
    end %problem: translational d.o.f. are dominated by angular
    relDatAll=cat(3,relDatAll,relDat(:,1:2,1:stRes:end));
    %-----rotate crd into relative polar:--------
    relDat1=crdDat(:,1:3,:);
    relDat1(:,1:2,:)=relDat1(:,1:2,:)-mean(relDat1(:,1:2,:));
    [relDat1(:,2,:),relDat1(:,1,:)]=cart2pol(relDat1(:,1,:),relDat1(:,2,:)); %[theta,rho]
    relDat1(:,2,:)=mod([relDat1(2:end,2,:);relDat1(1,2,:)]-relDat1(:,2,:),2*pi); %make angles relative
    relDat1All=cat(3,relDat1All,relDat1(:,1:3,1:stRes:end));
    % mvMn=movmean(std(relDat1(:,3,:)),prd,3); %relDat(:,2:3,:)=mod(relDat(:,2:3,:)+mvMn,2*pi)-mvMn;
    subplot(311);plot(squeeze(relDat1(:,1,:))')
    subplot(312);plot(squeeze(relDat1(:,2,:))')
    subplot(313);plot(squeeze(relDat1(:,3,:))')
    % return
    %% Permutation-invariant observables - central moments
    clear piDat;
    % relDat=relDat1; relDat(:,2:3,:)=exp(1i.*  relDat(:,2:3,:));
    piDat(1,:,:)=mean(relDat);%-mean(mean(relDat),3);
    piDat(2,:,:)=(moment(relDat,2)); piDat(2,:,:)=sign(piDat(2,:,:)).*abs(piDat(2,:,:)).^(1/2);
    piDat(3,:,:)=(moment(relDat,3)); piDat(3,:,:)=sign(piDat(3,:,:)).*abs(piDat(3,:,:)).^(1/3);
    % piDat(:,2:3,:)=abs(piDat(:,2:3,:));
    % piDat=fft(piDat,[],3); upCut=7150; botCut=0; %Bandpass filter
    % piDat(:,:,1+tLen/2-upCut:tLen/2+upCut)=0; piDat(:,:,2:botCut)=0; piDat(:,:,end-botCut+2:end)=0;
    % piDat=(ifft(piDat,[],3));
    subplot(311);plot(squeeze(piDat(:,1,:))')
    subplot(312);plot(squeeze(piDat(:,2,:))')
    subplot(313);plot(squeeze(piDat(:,3,:))')
    hold on; anPts=1:prd/4:length(t); scatter(anPts,zeros(1,length(anPts)),[],anPts);
    piDatAll=cat(3,piDatAll,piDat(:,1:2,1:stRes:end));
    % return
    %% Wavelet transform
    if(waveletsFl) %use wavelet transform
        wavDat=[];%zeros(Nsm,2,67,length(t));
        for mi=1:Nsm %over moments
            wavDat(mi,1,:,:)=cwt(squeeze(piDat(mi,1,:)),prd,'FrequencyLimits',[0.2,2],'VoicesPerOctave',20);
            wavDat(mi,2,:,:)=cwt(squeeze(piDat(mi,2,:)),prd,'FrequencyLimits',[0.2,2],'VoicesPerOctave',20);
            %     wavDat(mi,3,:,:)=cwt(squeeze(piDat(mi,3,:)),'FrequencyLimits',[0.001,0.006],'VoicesPerOctave',20);
        end
        wavDat=movmean(wavDat,prd/2,4);
        %%
        % cwtFB=cwtfilterbank('FrequencyLimits',[0,1]);
        % wavDat(1,1,:,:)
        % cwt(squeeze(piDat(3,1,:)),prd)
        % tmp=cwt(squeeze(piDat(2,1,:)),prd,'FrequencyLimits',[0.2,2],'VoicesPerOctave',20);
        % % tmp=movmean(tmp,prd/2,2);
        % surf(squeeze((abs(tmp))),'EdgeColor','none'); view([0,0,1]);
        %% Construct feature-vector
        % can also try UMAP
        % rng(1);
        % wavDatAll=cat(4,wavDatAll,wavDat);
        featVec=abs(wavDat(:,:,:,:));%.*permute(1:67,[1,3,2]);
        featVec=reshape(featVec,[],length(t));
        featVec=featVec./sum(featVec); %normalize
        % featRes=121;%prd/2;
        featVecAll=[featVecAll; featVec(:,1:stRes:end)'];
        % featResAll=[featResAll,ones(1,lenght(1:stRes:tLen)).*featRes];
    else %Cut up into snippets and FT
        for iiiTmp=1
            %% Split up the series into periods:
            plSm=3; %prd=1.01*2*pi/mean(freqList)/tRes;
            plot(squeeze(crdDat(plSm,3,:))'); hold on %check periodicity
            plot(1:prd:length(t), squeeze(crdDat(plSm,3,1:prd:end))','.')
            %
            snips=zeros(Nsm,2,floor(nPrd*prd),floor(length(t)/prd-nPrd+1));
            for si=0:length(t)/prd-nPrd
                snips(:,:,:,si+1)=piDat(:,1:2,1+si*prd:(si+nPrd)*prd);
            end
            
            %% Fourier Transform the snippets
            snipsFT=fft(snips,[],3); lenf=floor(nPrd*prd);
            snipsM=abs(snipsFT(:,:,2:lenf/2+1,:)/lenf); snipsPh=angle(snipsFT(:,:,2:lenf/2+1,:)/lenf);
            wdat=2*pi/tRes*(1:lenf/2)/lenf; wi=find(wdat>50,1);
            snipsPh=mod(snipsPh-(snipsPh(1,1,nPrd,:)).*permute(1:lenf/2,[1,3,2])/nPrd+pi,2*pi)-pi; %reference phases to main freq of r
            sTst=15; plSm=3; plCrd=2;%reconstruction test for phase-normalization
            snipsRec=squeeze(snipsM(plSm,plCrd,:,sTst).*exp(1i*snipsPh(plSm,plCrd,:,sTst))); snipsRec=ifft([0;snipsRec;conj(flip(snipsRec))]);
            clf; subplot(211),plot(squeeze(snips(:,plCrd,:,sTst))'); subplot(212),plot((snipsRec));
            cla; plot(wdat(nPrd:wi),(squeeze(snipsM(:,plCrd,nPrd:wi,sTst))));
            snipsCmx=snipsM(:,:,nPrd:nPrd:wi,:).*exp(1i*snipsPh(:,:,nPrd:nPrd:wi,:));%...
            %     ./mean(mean(snipsM(:,:,nPrd,:))); %output a complex feature vector
            cla; plot(squeeze(real(snipsCmx(:,plCrd,:,sTst)))');
            % return
            %% Embedding feature-vectors
            rng(1)
            featVec=reshape(snipsCmx,[],length(snips(1,1,1,:)))';
            % featVec=[real(featVec),imag(featVec)];
            featVec=abs(featVec); featVec=featVec./sum(featVec,2);
            
            featVecAll=[featVecAll;featVec(1:end,:)];
        end
    end
    iMov
end
pprocDat=struct;
pprocDat.crdDat=crdDatAll;
datSet=cell(1,1);
datSets{1}='movieInfoInterrupt.mat';
pprocDat.datSets=datSet;
pprocDat.relDat=relDatAll;
pprocDat.ring=ringAll;
% fname=cell(size(movs,2),2);
% for i =1:size(movs,2)
%     fname(i,1)=movs(i).fname;
%     fname(i,2)=1;
% end
pprocDat.fname=fnameAll;
pprocDat.featVec=featVecAll;
pprocDat.t=tAll;
fmt=['dd-mmm-yyyy HH-MM-SS'];
ddate=datestr(now,fmt);
save(['preprocdat',ddate,'.mat'],'pprocDat')
return
%% Dimensional reduction
% close all;
% figure(1);
% loadOld=true;
% % tAll=pprocDat.t
% if(loadOld)
%     featVecAll=pprocDat.featVec; tAll=pprocDat.t; ringAll=pprocDat.ring;
% end
% rng(1);
% KLdiv=@(vi,vj) sum((vi-vj).*log(vi./vj),2); %symmetrized K-L divergence
% % sum averaging which is why subtraction
% smpRes=96; %points per period
% % select=tAll(:,3)==1 | tAll(:,3)==5; %show only these points
% select=tAll(:,3)== 1;%show only these points
% featVecS=featVecAll(select,:); tS=tAll(select,:); ringS=ringAll(select,:);
% featVecS=reshape(featVecS',3,2,67,[]); featVecS=featVecS(:,:,15:35,:); %cut down spectrum of the data
% featVecS=reshape(featVecS,[],sum(select))';
% featRed=tsne((featVecS(1+smpRes:smpRes:end,:)),'Distance','euclidean','Exaggeration',10);%,'Standardize',true);
% %%Fancy GUI plot--------
load('clusterThis.mat');
close; stFig=figure(5); %figure to show Smcle state
colDat=1:length(featRed(:,1)); %color = time
% colormap fire
% colDat=tS(1+smpRes:smpRes:end,3); %color = experiment index
% ringV=diff(ringS(:,3))./diff(tS(:,1)); ringV=movmean(ringV,smpRes);
% colDat=log(vecnorm(ringV(1+smpRes:smpRes:end,:),2,2)); %color = ring speed
% colDat=(ringV(1+smpRes:smpRes:end,:)); colDat(abs(colDat)>mean(abs(colDat))*3)=0; %ring angular speed

ws=1251;%window size for gaussian to be implemented in
ws2=floor(ws/2);
samp=.01; 
sig=3.5;

%needed rounding to sample size ensure we could find points in gaussian code below
x=round(featRed(:,1),abs(log10(samp)));
y=round(featRed(:,2),abs(log10(samp))); 
xp=round([min(x)-ws2*samp:samp:max(x)+ws2*samp],2);
yp=round([min(y)-ws2*samp:samp:max(y)+ws2*samp],2);


out=zeros(length(yp),length(xp));

% generate gaussian kernal, sampling is by 1 so scale sigma by our sampling
gsizeg = fspecial('gaussian', [ws,ws], sig*1/samp);
gsizeg= gsizeg./max(max(gsizeg));%normalize amplitude of gaussian
for(i=1:length(x))
    r=find(yp==y(i));
    c=find(xp==x(i));
    %convolving gaussian with a dirac delta function at each point is 
    %the same as adding gaussians centered around each of the points, (I
    %think :) )
    out(r-ws2:r+ws2,c-ws2:c+ws2)=out(r-ws2:r+ws2,c-ws2:c+ws2)+gsizeg;
end
out3=out;
disp('gauss computed');
%% plot out watershed
figure(2); clf; hold on;
subplot(1,2,1);
scatter(featRed(:,1),featRed(:,2),[],colDat);

subplot(1,2,2);
title(['convolution with gaussian \sig=',num2str(sig)]);
out=out3./max(max(out3));
% contour(xp,yp,out);

% D=single(out);
D=out;
im=imbinarize(D);

figure(1);
subplot(1,3,1);
title('original output');
imagesc(D);
subplot(1,3,2);
title('binarized output');
imagesc(im);
subplot(1,3,3);
D(~im)=0;
title('original with removed borders');
imagesc(D);

figure(42);
D=~D;
D(~im)=Inf;

imshow(D);
title('complement');

figure(3);
L=watershed(D);
L(~im)=0;
imagesc(L)
lrgb = label2rgb(L,'fire',[.5 .5 .5]);

figure(5);
subplot(1,2,1);
h=imagesc([min(x-ws2*samp) max(x+ws2*samp)], [min(y-ws2*samp) max(y+ws2*samp)], lrgb);
ax=gca;
% ax.YDir='reverse'
axis tight
axis equal
h.AlphaData = 1;
hold on;
SCAT=scatter(x,y,[],colDat,'Parent',h.Parent,'marker','o');
set(SCAT.Parent, 'YDir', 'reverse')
set(gcf,'Position',[229 483 1533 395])
title('watershed');
disp('ready to click!');

clear stateDat;
stateDat.smpRes=smpRes;
stateDat.featVec=featVecS; stateDat.t=tS;
if(loadOld)
    stateDat.crdDat=pprocDat.crdDat(:,:,select); stateDat.relDat=pprocDat.relDat(:,:,select);
    stateDat.ring=pprocDat.ring(select,:); stateDat.fname=pprocDat.fname; %structure with all the data to show state
else
    pprocDat.crdDat=crdDatAll; pprocDat.relDat=relDat1All; pprocDat.ring=ringAll;
    pprocDat.fname=fnameAll; pprocDat.featVec=featVecAll; pprocDat.t=tAll; %structure with all the data to show state
end
figure(stFig.Number);
axis equal
subplot(1,2,2);
set(SCAT, 'ButtonDownFcn', @(src,evt) showSmState(src,evt,stateDat,stFig,3));
%last arg - flag:0-plots,1-vids no arms, 2-vids w arms, 3-recorded vids
return
%% Show smarticle motion---------
clf; hold on;
th=0:0.01:2*pi; tiSp=find(t>52,1);
for ti=1:round(movs(1).fps/10):length(t)-1
    crd=smcle2coord(crdDat(:,:,ti));
    clf; hold on; axis([-0.5,0.5,-0.5,0.5]*(windSize+B)*1.5); axis square;
    plot(crd(:,1:2:7)',crd(:,2:2:8)','-','LineWidth',2)%,'Color',[1,1,1]*0.9);
    %     cla; plot(crd(:,3:2:5)',crd(:,4:2:6)','-','LineWidth',1);
    plot(crdDat(:,1,ti),crdDat(:,2,ti),'k.','MarkerSize',15);
    %     plot(crdDat(11:end,1,ti),crdDat(11:end,2,ti),'r.','MarkerSize',15);
    plot(windSize*cos(th)/2,windSize*sin(th)/2);  %plot circle
    plot(ring(ti,1)+windSize*cos(0.6+0.8*th+ring(ti,3))/2,ring(ti,2)+windSize*sin(0.6+0.8*th+ring(ti,3))/2);  %plot circle
    %     plot(ring(ti,1),ring(ti,2),'r.','MarkerSize',35);
    title(round(t(ti),2));
    pause(0.1)
end

