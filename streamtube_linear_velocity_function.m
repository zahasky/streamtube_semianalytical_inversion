% streamtube_linear_velocity_function.m
function [Vs, vm, v_std, v_std_error]= streamtube_linear_velocity_function(Xc, steady_frames, ...
    frame_length, varargin)
% Christopher Zahasky
% 5/29/2017
% This script is used to calculate pore water velocity of each streamtube,
% Vs is a matrix of the mean velocity in each streamtube and vm is the 
% core-average pore water velocity. Input is (Xc, steady_frames, 
% frame_length, varargin), where frame_length is in seconds and varargin 
% can be any number, the presence of which triggers a plot of the 
% streamtube pore water velocities.

n=1;
% preallocate velocity matrix VMat
dim = size(Xc);
VMat = zeros(dim(1),dim(2), length(steady_frames)-1);

for i = steady_frames(1)+1: steady_frames(end)
    VMat(:,:,n) = (Xc(:,:,i)-Xc(:,:,i-1))/(frame_length);
    n = n+1;
end

% unscaled streamtube velocity
Vs = mean(VMat,3);
Vs(Vs==0)=nan;
uw_nan = Vs;
uw_nan(Vs==0)=nan;
% core average streamtube velocity
vm = nanmean(nanmean(uw_nan));
% approximate measurment error
v_std = nanmean(nanmean(std(VMat,0,3)));
v_std_error = nanmean(nanmean(std(VMat,0,3)/sqrt(length(steady_frames)) ));

% if addition variables are listed this triggers the plot
if length(varargin)>=1
    if varargin{1} == 1
        figure
        h3 = imagesc(Vs);
        set(h3,'alphadata',~isnan(uw_nan))
        title('Pore water velocity [cm/s]', 'fontsize', 14)
        axis equal
        axis tight
        axis off
        colorbar
        % caxis([0 0.2])
    else
        % assume vargin is the voxel side length in cm
        a = varargin{1}^2;
        axial_flux = Vs.*a.*60;
        figure
        h3 = imagesc(axial_flux);
        set(h3,'alphadata',~isnan(uw_nan))
        title('Axial flux (mL/min)')
        axis equal
        axis tight
        axis off
        colorbar
        total_q = nansum(nansum(axial_flux));
        disp(['Total flux: ', num2str(total_q), ' mL/min'])
    end
end
