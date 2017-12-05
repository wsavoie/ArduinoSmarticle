%% combine older files
clear all
fold='A:\2DSmartData\entangledData\12-5 multimarker SAC\';
f=dir2(fold,0);
finalPars=[];
finalS=struct;
for(i=1:length(f))
    
    load(fullfile(fold,f(i).name));
    finalPars=[finalPars;allFpars];
    if(i==1)
        finalS=s;
    else
        finalS=[finalS,s];
    end
end
s=finalS;
allFpars=finalPars;
save(fullfile(fold,'dataOutAll.mat'),'s','allFpars')

%% finds any nans in strain and removes them by placing setting them equal to previous value

fold='A:\2DSmartData\entangledData\11-30 multimarker\fixing data';
f=dir2('A:\2DSmartData\entangledData\11-30 multimarker\fixing data',0);
for i=1:length(f)
    load(fullfile(fold,f(i).name));
    for(j=1:length(s))
        if(any(isnan(s(j).strain)))
            id=find(isnan(s(j).strain),1);
            gv=s(j).strain(id-1);
            s(j).strain(id-1:end)=gv;
            pts('error in:',s(j).name);
        end
    end
    save(fullfile(fold,'dataOutFixed.mat'),'s','allFpars');
end
%% this code adds the velocity calculated from strain to a mat file that doesn't already have it
clear all
fold='A:\2DSmartData\entangledData\11-30 multimarker\data files';
f='dataOut sd=40.mat';
load(fullfile(fold,f));
for i=1:length(s)
    %get indices between first two points
%     i=10;
    ptSpan=s(i).dsPts(1:2,3);
    d=diff(ptSpan)/4;
    %get middle range of points
    ptSpan=[ptSpan(1)+floor(d),ptSpan(1)+2*floor(d)];
    vel=diff(s(i).strain(ptSpan))/diff(s(i).t(ptSpan));
    s(i).vel=vel;
%     plot(s(i).strain);
%     hold on;
%     plot(ptSpan,s(i).strain(ptSpan),'o');
end
save(fullfile(fold,f),'s','allFpars')