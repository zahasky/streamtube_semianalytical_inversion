% streamtube_flow_function.m
function [Qs, q_std, q_std_error]= streamtube_flow_function(M0, steady_frames, qw, varargin)
% Christopher Zahasky
% 5/29/17
% This script is used to calculate streamtube flow given zero moments and
% total injection rate. Flow can be calculated in a few ways: 
% 1) calculating the slope of the rate of increase in zero moment, 
% 2) by dividing the zero moment at once complete pulse has been injected
% and dividing by the injection time, or
% 3) scaling the known volumetric flow rate by the variation in zero moment
% in each streamtube

% Note that this volumetric flow is termed a 'flux' in Zahasky and Benson,
% 2018 and is the wrong word to use because volumetric flux
% would imply units of m/s when Qs actually has units of m^3/s

% Single phase zero moment velocity calculation, scaled by total flow rate
change_mass = M0(:,:,steady_frames(1));
% add up total activity
sum_change_mass_sing = sum(sum(change_mass));
% scale activity by injection rate to convert from radioactivity to volume
mass_scale_sing = qw./sum_change_mass_sing;
% streamtube flow rate [cm^3/s]
Qs = change_mass.*mass_scale_sing;

% approximate standard deviation
q_std = nanmean(nanmean(std(M0(:,:,steady_frames).*mass_scale_sing,0,3)));
% approximate standard error
q_std_error = nanmean(nanmean(std(M0(:,:,steady_frames).*mass_scale_sing,0,3)/ ...
    sqrt(length(steady_frames))));

% Switch zeros to nans
qw_nan = Qs;
qw_nan(Qs==0)=nan;

% if addition variables are listed this triggers the plot
extra_var = nargin-3;
if extra_var > 0
    figure
    h3 = imagesc(qw_nan);
    set(h3,'alphadata',~isnan(qw_nan))
    title('Water Flow Rate [mL/s]', 'fontsize', 14)
    axis equal
    axis tight
    axis off
    colorbar
end