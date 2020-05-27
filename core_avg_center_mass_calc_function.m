% core_avg_moment_calc_function
function [M0C, Xcore, steady_frames]= core_avg_center_mass_calc_function(...
    PET_4D_cc, vox_size, steady_thresh, varargin)
% Christopher Zahasky
% 5/29/2017
% This script is used to calculate the 3D center of mass give the pet data
% 'PET_4D_cc'. The variable length input list is used when you want to
% plot the moment results as well.

% Recommended call function looks like this:
% [M0C, Xcore, steady_frames]= core_avg_center_mass_calc_function(...
%       PET_4D_cc, vox_size, 2, 1);
% Which will find the frames with change less than 2 percent and plot the
% center of mass calculations (last number can be anything).

% check that voxel size is the correct dimension
if length(vox_size) ~=3
    error('Vox size must contain length of voxel in x, y, and z direction')
end

% provide feedback on selected steady frame threshold
if steady_thresh ~= 0
    if steady_thresh > 3 || steady_thresh < 0.1
        warning('Recommended steady_thresh is between 0.1 and 2 percent')
    end
end

PET_dim = size(PET_4D_cc);
PET_4D_cc(isnan(PET_4D_cc)) = 0;
% Sum of all tracer in core (zero moment)
M0C = squeeze(sum(sum(sum(PET_4D_cc))));
% preallocate first moment matrix
Xcore = zeros(PET_dim(4),1);
% preallocate second moment matrix (not yet enabled)
% Sx = zeros(PET_dim(4),1);

for t = 1:PET_dim(4)
    % Loop through x,y,z dimensions
    for ii = 1:3
        shp = ones(1,3);
        shp(ii) = PET_dim(ii);
        rep = PET_dim(1:3);
        rep(ii) = 1;
        % integer length dimension matrix
        ind = repmat(reshape(1:PET_dim(ii),shp),rep);
        PET_frame = squeeze(PET_4D_cc(:,:,:,t));
        Xcore(t,ii) = sum(ind(:).*PET_frame(:))./M0C(t).*vox_size(ii);
    end
end

if steady_thresh ~= 0
    % calculate normalized total core activity
    norm_tracer = M0C./max(M0C);
    % find frame with maximum tracer
    max_tracer_frame = find(norm_tracer == max(norm_tracer));
    % change in norm tracer
    change_tracer = abs(diff(norm_tracer)./1);
    % steady frames (less than two percent change)
    steady_frames = find(change_tracer < (steady_thresh/100));
    % find steady frame equal to max tracer
    frame_check = unique(reshape([steady_frames;steady_frames+1], 1, []))';
    max_steady_frame = find(frame_check==max_tracer_frame);
    if isempty(max_steady_frame)
        warning('Max tracer does not correspond with steady flow')
        steady_frames = 0;
    end
    % find end of first steady frames
    steady_end_frame = find(diff(steady_frames)>1);
    if length(steady_end_frame)==1 || steady_end_frame(1)>2
        steady_frames = steady_frames(1):steady_frames(steady_end_frame)+1;
    elseif length(steady_end_frame)>1
        index_less_frames = find(steady_end_frame<max_steady_frame);
        index_end_frame = find(steady_end_frame>=max_steady_frame);
        if isempty(index_less_frames)
            steady_frames = steady_frames(1)...
                :steady_frames(steady_end_frame(index_end_frame(1)))+1;
        else
            steady_frames = steady_frames(steady_end_frame(index_less_frames(end))+1) ...
                :steady_frames(steady_end_frame(index_end_frame(1)))+1;
        end
    end
    
    % if addition variables are listed this triggers the plot
    if length(varargin)>=1
        figure
        if varargin{1} == 3
            
            % plot total activity as a function of time
            time_frame = [1:PET_dim(4)];
            plot(time_frame, M0C, '-ok')
            hold on
            if isempty(max_steady_frame)==0
                plot(steady_frames, M0C(steady_frames), '-or')
            end
            xlabel('Time frame')
            ylabel('Total activity')
            title('"steady_ frames" indicated in red, when all tracer is in core')
            box on
            
        elseif varargin{1} == 1
            % plot normalized total core activity as a function of time
            time_frame = [1:PET_dim(4)];
            plot(time_frame, norm_tracer, '-ok')
            hold on
            if isempty(max_steady_frame)==0
                plot(steady_frames, norm_tracer(steady_frames), '-or')
            end
            xlabel('Time frame')
            ylabel('Normalized total activity')
            title('"steady_ frames" indicated in red, when all tracer is in core')
            box on
            
        elseif varargin{1} == 2
            % plot of 3D center of mass with time
            subplot(1,2,1)
            scatter(Xcore(steady_frames,1), Xcore(steady_frames,2), 40, steady_frames, 'filled')
            xlabel('Location of center of mass in x plane (cm) ')
            ylabel('Location of center of mass in y plane (cm)')
            axis equal, box on
            subplot(1,2,2)
            scatter(Xcore(steady_frames,3), Xcore(steady_frames,2), 40, steady_frames, 'filled')
            xlabel('Location of center of mass in z plane (cm) ')
            ylabel('Location of center of mass in y plane (cm)')
            axis equal, box on
        end
    end
else
    steady_frames=[];
end