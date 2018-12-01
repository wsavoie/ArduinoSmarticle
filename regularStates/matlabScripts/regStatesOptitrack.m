function [t,x,y,tracks,fps, varargout]=regStatesOptitrack(file,dec,rigidBodyName)

% figure(1);clf;

% files = dir([folder '*.csv']);
% tMod = [files(:).datenum];

% [~,ind] = max(tMod);
%rx = rigid body
%frame, time, qx, qy, qz, qw, rigX, rigY, rigZ
data = importdata(file);
%recorded frame->desired frame
%x->-x
%z->y
%y->z


%Get data for the ring specifically (rigid body MUST be named with "ring")
rigidBodyHeaders = lower(data.textdata{3,1}); %single line of text with csv
ind = strfind(rigidBodyHeaders,rigidBodyName);
tx=data.textdata{1};
a=strfind(tx,'Frame Rate,');
fps=str2double(tx(a(1)+11:a(1)+11+6));
%TEMPORARY (if inactive particle wasn't labeled 'inactive' in optitrack,
%assume first rigid body is inactive)
if isempty(ind)
    rigidBodyName = 'rigid body 1';
    ind = strfind(rigidBodyHeaders,rigidBodyName);
end

[r,c] = find(strcmp(data.textdata, 'Frame')); %row with 'W' in it

if ~isempty(ind) || data.textdata{r,6}=='W' %has ring rigid body
    if isempty(ind)  %one rigid body without 'ring' in name
        ringInd = 3;
    else
        count = 1;
        for k = 1:ind
            if rigidBodyHeaders(k) == ','
                count = count + 1;
            end
        end
        ringInd = count;
    end
    q = [data.data(:,ringInd+3) data.data(:,ringInd) data.data(:,ringInd+2) data.data(:,ringInd+1)];
    
    %QUATERNION X DATA MIGHT NEED TO BE FLIPPED!!
    %Old hard-coded way to get ring data
    %if (data.textdata{7,6}=='W') %system has a rigid body
    %q=[data.data(:,6) data.data(:,3) data.data(:,5) data.data(:,4)]; %wxzy
    
    q=quaternion(q'); %I need to transpose it before setting to quat for matrix
    angles = EulerAngles(q,'123');
    ang=reshape(angles(3,1,:),[size(angles,3),1]);
    
    %decimate by dec
    t = data.data(:,2);
    t=t(1:dec:end,:);
    x = -data.data(1:dec:end,ringInd+4); %was 7
    y = data.data(1:dec:end,ringInd+6); %was 9
    z = data.data(1:dec:end,ringInd+5); %was 8
    
    
    
    comx=x;
    comy=y;
    comz=z;
    ang=ang(1:dec:end,:);
    
    allDat=[x,y,ang];
%     allDat=fillmissing(allDat,'linear');
    

    a=diff(allDat);
    [r,~]=find(a(:,1:2)>1e-3);
    count=0;
%     while(r)
%         allDat(r,1:2)=allDat(r-1,1:2);
%         a=diff(allDat);
%         [r,~]=find(abs(a(:,1:2))>1e-3);
%         count=count+1;
%         if(count>1000)
%             warning('stuck');
%         end
%     end
    
    allDat=fillmissing(allDat,'linear');
    [x,y,ang]=separateVec(allDat,1);
    comx=x;
    comy=y;
    varargout{1}=ang;
else

    t = data.data(:,2);
    x = -data.data(:,3:3:end); %was 3:3:end
    y = data.data(:,3+2:3:end); %was 5:3:end
    z = data.data(:,3+1:3:end); %was 4:3:end
    
    %decimate by dec
    t=t(1:dec:end,:);
    x=x(1:dec:end,:);
    y=y(1:dec:end,:);
    z=z(1:dec:end,:);
    
    allDat=[x,y];
    allDat=fillmissing(allDat,'spline');
    [x,y]=separateVec(allDat,1);

    comx=mean(x,2);
    comy=mean(y,2);
end


comx=comx-comx(1);
comy=comy-comy(1);

COM=[t,comx,comy];
tracks=cell(1);
tracks{1}= COM;
