function [t,x,y,tracks,fps varargout]=trackOptitrack(file,dec,rigidBodyName)

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
tx=data.textdata{1};
a=regexp(tx,'Export Frame Rate,(\d+)','tokens');
fps=str2double(a{1}{1});
fps=fps/dec;
if(iscell(rigidBodyName))
    i=1;
    while(1)
        ind = strfind(rigidBodyHeaders,rigidBodyName{i});
        if(ind)
            break;
        end
        i=i+1;
        if i>length(rigidBodyName)
            break;
        end
    end
    
else
    ind = strfind(rigidBodyHeaders,rigidBodyName);
end

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
    ang=ang(1:dec:end,:);
    % pts('rigid body sys');
    
    allDat=[x,y,ang];
    allDat=filloutliers(allDat,'linear','movmedian',fps);
    allDat=fillmissing(allDat,'linear');
    
%     aa=find(isnan([x,y,ang]));%find if any nans
%     while(aa)
%     for(qq=1:size(allDat,2))
%         nanidx=find(isnan(allDat(:,qq)));
%         allDat(nanidx,qq)=allDat(nanidx-1,qq);
%     end
%     aa=find(isnan(allDat));
%     end
    [x,y,ang]=separateVec(allDat,1);
%     nanIndsx=find(isnan(x));
%     while(nanIndsx)
%         x(nanIndsx)=x(nanIndsx-1);
%         nanIndsx=find(isnan(x));
%     end
%     
%     nanIndsy=find(isnan(y));
%     while(nanIndsy)
%         y(nanIndsy)=y(nanIndsy-1);
%         nanIndsy=find(isnan(y));
%     end
%     
%     nanIndsrot=find(isnan(ang));
%     while(nanIndsrot)
%         ang(nanIndsrot)=ang(nanIndsrot-1);
%         nanIndsrot=find(isnan(ang));
%     end
    
    comx=x;
    comy=y;
    varargout{1}=ang;
else
    % -repmat(data.data(1,3:3:end),[size(data.data(:,3:3:end),1),1])
    
    t = data.data(:,2);
    x = -data.data(:,ringInd:ringInd:end); %was 3:3:end
    y = data.data(:,ringInd+2:ringInd:end); %was 5:3:end
    z = data.data(:,ringInd+1:ringInd:end); %was 4:3:end
    
    %decimate by dec
    t=t(1:dec:end,:);
    x=x(1:dec:end,:);
    y=y(1:dec:end,:);
    z=z(1:dec:end,:);
    
    
%     nanIndsx=find(isnan(x));
%     nanIndsy=find(isnan(y));
%     nanIndsrot=find(isnan(ang));
%     
%     x(nanIndsx)=x(nanIndsx-1);
%     y(nanIndsy)=y(nanIndsy-1);
%     ang(nanIndsrot)=ang(nanIndsrot-1);

    allDat=[x,y];
    allDat=fillmissing(allDat,'linear');
%     aa=find(isnan([x,y,ang]));%find if any nans
%     while(aa)
%     for(qq=1:size(allDat,2))
%         nanidx=find(isnan(allDat(:,qq)));
%         allDat(nanidx,qq)=allDat(nanidx-1,qq);
%     end
%     aa=find(isnan(allDat));
%     end
    [x,y]=separateVec(allDat,1);

    comx=mean(x,2);
    comy=mean(y,2);
end


comx=comx-comx(1);
comy=comy-comy(1);

COM=[t,comx,comy];
COM(any(isnan(COM),2),:)=[];

tracks=cell(1);
tracks{1}= COM;
