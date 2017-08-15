% testPlotDrag
% clc
clear
% close all
co=get(groot,'defaultAxesColorOrder');

%% DIRECTORY
IS_THIS_DIRECTORY = 0;
% data_directory = 'data';
% data_directory=uigetdir('A:\SmarticleRobotArmDrag data\2017-08-01-smarticleChainPull');
data_directory='A:\SmarticleRobotArmDrag data\2017-08-01-smarticleChainPull\confined-09.5cm\allRuns';
%% FILE INFORMATION
force_file_suffix = 'FRC';
position_file_suffix = 'POS';


% SENSOR ANGLE
SENSOR_ANGLE = 10;%-57; %-60; %-55.8;

if(~IS_THIS_DIRECTORY)
    force_files = dir([data_directory filesep '*' force_file_suffix '.txt']);
    position_files = dir([data_directory filesep '*' position_file_suffix '.txt']);
else
    force_files = dir(['*' force_file_suffix '.txt']);
    position_files = dir(['*' position_file_suffix '.txt']);
end





NUM_FORCE_FILES = numel(force_files);
NUM_POSITION_FILES = numel(position_files);

NUM_FILES = NUM_FORCE_FILES;


disp(['Directory: "' data_directory '" found containing ' num2str(NUM_FILES) ' trials.'])


%% COUNTING FILES
count_base_intrusions = 0;

%% SAMPLING INFORMATION
% force_dt = 0.0002; % Sampling rate for force data (s)
force_dt = 0.001; % Sampling rate for force data (s)
% master_dt = 0.001; % Final sampling rate after processing (s)


%% AVERAGING WINDOW
avg_window = [11 24]%[13, 18];
avg_window_indices = avg_window(1)/force_dt:avg_window(2)/force_dt;

angle_vec = zeros(NUM_FILES,1);
fx_vec = zeros(NUM_FILES,1);
fy_vec = zeros(NUM_FILES,1);

for file_iter = 1:NUM_FILES
    
    
    
    disp([num2str(file_iter) '/' num2str(NUM_FILES)])
    
    current_force_filename = force_files(file_iter).name;
    current_position_filename = position_files(file_iter).name;
    
    
    
    % extract trial parameters
    underscore_indices = find(current_force_filename == '_');
    drag_speed_cmd = str2double(current_force_filename(1:3));
    drag_depth_cmd = str2double(current_force_filename((underscore_indices(1)+1):(underscore_indices(1)+2)));
    tool_angle_cmd = str2double(current_force_filename((underscore_indices(2)+1):(underscore_indices(3)-4)));
    
    
    % Load data
    if(~IS_THIS_DIRECTORY)
        p_data = dlmread([data_directory filesep current_position_filename]);
        f_data = dlmread([data_directory filesep current_force_filename]);
    else
        p_data = dlmread(current_position_filename);
        f_data = dlmread(current_force_filename);
    end
    
    force_vec_raw = f_data(:,1:6);
    
    pos_vec_raw = p_data(:,2:7);
    
    time_force = (1:numel(force_vec_raw(:,1)))*force_dt;
    time_pos = p_data(:,1)-p_data(1,1);
    
    
    zeroing_indices = 1:(1.5/force_dt);
    zeroing_levels = mean(f_data(zeroing_indices,:));
    
    force_zeroed = force_vec_raw - ones(numel(force_vec_raw(:,1)),1)*zeroing_levels;
    force_drag = sqrt(force_zeroed(:,1).^2+force_zeroed(:,2).^2);
    
    mean_force = mean(force_zeroed(avg_window_indices,:));
    mean_drag_force = mean(force_drag(avg_window_indices));
    
    
    angle_vec(file_iter) = tool_angle_cmd;
    fx_vec(file_iter) = mean_force(1);
    fy_vec(file_iter) = mean_force(2);
    % % %
    % % %     subplot(1,2,1)
    % % %
    % % % %     plot(...
    % % % %         time_force, force_zeroed(:,1), 'r-', ...
    % % % %         time_force, force_zeroed(:,2), 'g-', ...
    % % % %         time_force, force_zeroed(:,3), 'b-' ...
    % % % %         )
    % % %     plot(...
    % % %         time_force, force_zeroed(:,1), 'r-', ...
    % % %         time_force, force_zeroed(:,2), 'g-' ...
    % % %         )
    % % %
    % % %     ylimits = get(gca,'ylim');
    % % %     hold on
    % % %     plot([avg_window(1) avg_window(1)], [ylimits(1) ylimits(2)], 'k--')
    % % %     plot([avg_window(2) avg_window(2)], [ylimits(1) ylimits(2)], 'k--')
    % % %     hold off
    % % %     legend('Fx','Fy','Averaging Window')
    % % %     %         time_force, force_drag, 'm-' ...
    % % % %     title([num2str(tool_angle_cmd) ' deg'])
    % % %     set(gca,'ylim',[-0.5 0.5])
    % % %
    % % %     subplot(1,2,2)
    % % %     hold on
    % % %     %     plot(...
    % % %     %         tool_angle_cmd, mean_drag_force, 'k.' ...
    % % %     %         )
    % % %     plot(...
    % % %         tool_angle_cmd, mean_force(1), 'r.', ...
    % % %         tool_angle_cmd, mean_force(2), 'g.' ...
    % % %         )
    % % %     h = legend('$\bar{F}_X$','$\bar{F}_Y$');
    % % %     set(h,'interpreter','latex')
    % % %     %     mean_force(1)
    % % %     set(gca,'ylim',[-0.5 0.5])
    % % %     hold off
    % % %     drawnow
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     figure(22);
    %
    %     plot(...
    %         time_force, force_zeroed(:,1), 'r-', ...
    %         time_force, force_zeroed(:,2), 'g-' ...
    %         )
    %
    %     ylimits = get(gca,'ylim');
    %     hold on
    %     plot([avg_window(1) avg_window(1)], [ylimits(1) ylimits(2)], 'k--')
    %     plot([avg_window(2) avg_window(2)], [ylimits(1) ylimits(2)], 'k--')
    %     hold off
    %     legend('Fx','Fy','Avg. Wind.')
    %     %         time_force, force_drag, 'm-' ...
    % %     title([num2str(tool_angle_cmd) ' deg'])
    %     set(gca,'ylim',[-0.5 0.5])
    %     ylabel('Force(N)');
    %     xlabel('time(s)');
    %     figText(gcf,16);
    %%%%%%%%%%%%%%%%%%%%%%
    %     pause
    figure(4);
    hold on
    fnorms=sqrt(sum(abs(force_zeroed(:,1:2)).^2,2));
    t0=5;
    tend=17;
    inds=(time_force>t0&time_force<tend);
    if(file_iter==1)
        s=length(inds);
        fout=zeros(NUM_FILES,length(fnorms(inds)));
    end
    fout(file_iter,:)=fnorms(inds);
    plot(time_force(inds),fnorms(inds),'linewidth',1.1);    
    ylabel('force (N)');
    xlabel('time (s)');
    figText(gcf,16);
    axis tight
   
end
 
    figure(5);
    hold on;
    shadedErrorBar(time_force(inds),mean(fout),std(fout),{'-'},.45);
    ylabel('force (N)');
    xlabel('time (s)');
    figText(gcf,16);
    axis tight

%%
% figure(2)
% hold on
% plot(...
%     angle_vec, fx_vec, 'r.', ...
%     angle_vec, fy_vec, 'g.' ...
%     )
% plot(angle_vec,sqrt(fx_vec.^2+fy_vec.^2),'m.')
% h = legend('$\bar{F}_X$','$\bar{F}_Y$');
% set(h,'interpreter','latex')
%
% set(gca,'ylim',[-0.2 0.2])
% grid on
% hold off
%
% NUM_REPEATED_TRIALS = length(fx_vec);
%
% mean_drag_force = sqrt(fx_vec.^2+fy_vec.^2);
% force_drag_reshape = reshape(mean_drag_force,[NUM_REPEATED_TRIALS,numel(mean_drag_force)/NUM_REPEATED_TRIALS]);
% force_x_reshape = reshape(fx_vec,[NUM_REPEATED_TRIALS,numel(mean_drag_force)/NUM_REPEATED_TRIALS]);
% force_y_reshape = reshape(fy_vec,[NUM_REPEATED_TRIALS,numel(mean_drag_force)/NUM_REPEATED_TRIALS]);
%
% angleList = angle_vec(1:NUM_REPEATED_TRIALS:end);
% FdragMat = force_drag_reshape;
% FxMat = force_x_reshape;
% FyMat = force_y_reshape;
%
% FdragMean = mean(FdragMat);
% FxMean = mean(FxMat);
% FyMean = mean(FyMat);
%
% FdragStd = std(FdragMat);
% FxStd = std(FxMat);
% FyStd = std(FyMat);
%
% FTangMat = FxMat*cos(SENSOR_ANGLE)-FyMat*sin(SENSOR_ANGLE);
% FNormMat = FxMat*sin(SENSOR_ANGLE)+FyMat*cos(SENSOR_ANGLE);
% aniMat = FNormMat./FTangMat;
%
% FTangMean = mean(FTangMat);
% FNormMean = mean(FNormMat)
% aniMean = mean(aniMat);
%
% FTangStd = std(FTangMat);
% FNormStd = std(FNormMat)
% aniStd = std(aniMat);
%
% figure(3)
% subplot(1,2,1)
% hold on
% errorbar(angleList, FNormMean, FNormStd)
% errorbar(angleList, FTangMean, FTangStd)
% lh = legend('$F_\perp$','$F_\parallel$');
% set(lh,'interpreter','latex')
% hold off
% subplot(1,2,2)
% errorbar(angleList, aniMean, aniStd)
% lh = legend('$\frac{F_\perp}{F_\parallel}$');
% set(lh,'interpreter','latex')
% % hold on
% % plot(FNormMat,'ro')
% %
% % plot(FTangMat,'bo')
% %
% % plot([1 numel(FNormMat)],[FNormMean FNormMean],'r-')
% % plot([1 numel(FNormMat)],[FNormMean+FNormStd FNormMean+FNormStd],'r--')
% % plot([1 numel(FNormMat)],[FNormMean-FNormStd FNormMean-FNormStd],'r--')
% %
% % plot([1 numel(FTangMat)],[FTangMean FTangMean],'b-')
% % plot([1 numel(FTangMat)],[FTangMean+FTangStd FTangMean+FTangStd],'b--')
% % plot([1 numel(FTangMat)],[FTangMean-FTangStd FTangMean-FTangStd],'b--')
% %
% % lhandle = legend('$F_\perp$','$F_\parallel$');
% % set(lhandle,'interpreter','latex')
% %
% % title('"Plow" drag tests')
% % ylabel('Force (N)')
% % xlabel('Trial #')
% %  data_directory=uigetdir(
% save('summaryData.mat', ...
%     'angleList','FdragMat','FxMat','FyMat', ...
%     'FdragMean','FxMean','FyMean', ...
%     'FdragStd','FxStd','FyStd');