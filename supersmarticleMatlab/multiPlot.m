%% Figures to Plot
showFigs = [1 2];
%************************************************************
%* Fig numbers:
%* 1. Plot average speed vs. degree
%* 2. Position vs. time
%************************************************************

%% Get movieInfo.mat Files from Multiple Folders
fold=uigetdir('A:\2DSmartData\crawl'); disp(fold);
files = dir(fold);
dirNames = {};
for k = 1:length(files)
    if files(k).isdir && ~isequal(files(k).name,'.') && ~isequal(files(k).name,'..')
        dirNames = [dirNames, files(k).name];
    end
end
matFiles = {};
for k = 1:length(dirNames)
    curFold = [fold, '\', dirNames{k}];
    curMatFile = load(fullfile(curFold, 'movieInfo.mat'));
    matFiles = [matFiles, curMatFile];
end

%% 1. Plot Average Speed vs. Degree
curFig = 1;
if showFigs(showFigs == curFig)
    %figure
    avgSpeeds = [];
    stdSpeeds = [];
    degrees = [];
    for k = 1:length(matFiles)
        speed = [];
        for j = 1:length(matFiles{k}.movs)
            movs = matFiles{k}.movs;
            speed = [speed,(movs(j).x(end) - movs(j).x(1))/(movs(j).t(end) - movs(j).t(1))];
        end
        speed = abs(speed);
        avgSpeeds = [avgSpeeds, mean(speed)];
        stdSpeeds = [stdSpeeds, std(speed)];
        degrees = [degrees, str2num(matFiles{k}.fold(end-1:end))];
    end
    %plot(degrees,avgSpeeds,'o-');
    errorbar(degrees,avgSpeeds,stdSpeeds,'o-'); grid on;
    title('Average Speed vs. Gait Angle')
    %axis([0 100 0 0.012]);
    axis([0 100 0 0.015]);
    xlabel('Angle (degrees)');
    ylabel('Speed (m/s)');
end


%% 2. Plot Position vs. Time
curFig = 2;
if showFigs(showFigs == curFig)
    figure
    cols = 1;
    rows = ceil(length(matFiles)/cols);
    degrees = [];
    for n = 1:length(matFiles)
        movs = matFiles{n}.movs;
        speed=[];
        subplot(rows,cols,n); grid on;
        hold on;
        for k = 1:length(movs)
            offsetPos = movs(k).x(1);  %correct for different starting positions
            plot(movs(k).t, abs(movs(k).x - offsetPos));
            speed = [speed,(movs(k).x(end) - movs(k).x(1))/(movs(k).t(end) - movs(k).t(1))];
            %polyfit polyval
            %TODO: shift so that all start at position 0
        end
        speed = abs(speed);
        avgSpeed=mean(speed);
        stdSpeed=std(speed);
        degrees = [degrees, str2num(matFiles{n}.fold(end-1:end))];
        title(['Gait Angle: ' num2str(degrees(n)) 176]);
        %axis([0 150 -0.2 0.6]);
        axis([0 120 -0.05 0.5]);
        xlabel('Time (s)');
        ylabel('Position (m)');
        hold off
    end
end
