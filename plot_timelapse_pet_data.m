% plot_timelapse_pet_data.m
% Christopher Zahasky
% 11/2/2018
clear all
close all
% This is the Matlab script for plotting PET data
set(0,'DefaultAxesFontSize',15, 'defaultlinelinewidth', 2,...
    'DefaultAxesTitleFontWeight', 'normal')

% Load data
load('BSS_c1_2ml_PET_data')
% Calculate the size of the PET dataset
s = size(PET_4D_coarse);
% Calculate the maximum slice average activity used to normalize the
% activity maps
max_activity = max(max(nanmean(nanmean(PET_4D_coarse))));

% voxel size [cm]
vox_size = [0.2329 0.2329 0.2388];
% Define PET image grid
gridX = ([1:s(1)].*vox_size(1) - vox_size(1)/2);
gridY = ([1:s(2)].*vox_size(2) - vox_size(2)/2);
gridZ = ([1:s(3)].*vox_size(3) - vox_size(3)/2);

% Set create custom colormap
greys = ones(4,3).*0.85;
light_jet = jet(40);
grey_blue = [[0.85:-0.1:0]', [0.85:-0.1:0]', ones(9,1).*0.85];
white_jet = [greys; grey_blue; light_jet(3:end,:)];
clim = [0.05 1];

% Now loop through timesteps and plot concentration at different timesteps
figure
for i=[2:round(s(4)/2)]
    % Format data to show half-core image with injection from left to right
    slice_plane = squeeze(PET_4D_coarse(:,:,:, i))./max_activity;
    slice_plane(1:end,11:end,:) = nan;
    slice_plane = flip(slice_plane);
    slice_plane = flip(slice_plane,2);
    slice_plane = permute(slice_plane,[3 2 1]);
    
    % Call plotting function
    PATCH_3Darray(slice_plane, gridZ, gridY, gridX, white_jet, clim, 'col')
    
    % Format and label plot 
    title(['^{18}FDG radiotracer pulse ', num2str(i), ' min'])
    h = colorbar;
    ylabel(h, 'Normalized concentration')
    axis([0 max(gridZ) 0 max(gridY) 0 max(gridX)])
    grid on
    xlabel('Distance from inlet [cm]')
    axis equal
    axis tight
    set(gca,'YTickLabel',[]);
    view(-15,32)
    set(gca,'color','none')
    drawnow
    pause(0.5)
end

