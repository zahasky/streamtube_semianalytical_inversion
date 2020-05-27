% streamtube_perm_calculation_clean.m
% Christopher Zahasky
% Originally written: 4/22/2017, Cleaned and commented: 11/20/2019

% This script uses PET imaging data and expressions derived in Zahasky and
% Benson, (2018) 'Micro-Positron Emission Tomography for Measuring Sub-core
% Scale Single and Multiphase Transport Parameters in Porous Media'
% (https://doi.org/10.1016/j.advwatres.2018.03.002) to calculate sub-core
% permeability. Using a linear streamtube discretization and spatial moment
% analysis of pulse injection experiments, tracer injection rate and pore water
% velocity are calculated in each streamtube and used to estimate 
% streamtube permeability using Darcy's law.
%
% These codes include an example dataset from pulse injection experiments
% in a 2 inch diameter Berea sandstone core.

close all, clear all
set(0,'DefaultAxesFontSize',14, 'defaultlinelinewidth', 2,...
    'DefaultAxesTitleFontWeight', 'normal')

%% %%% INPUT %%%%
% File name input
filename = 'BSS_c1_2ml_PET_data';
% Steady state pressure drop across the core during injection [psi]
dP = 11.12;
% Experimental volumentric flow/injection rate [mL/min]
qw = 2;
% Length of PET scan timeframe (as written must be constant) [seconds]
frame_length = 60;
% PET image voxel size [cm]
vox_size = [0.2329, 0.2329, 0.2388];

%%% Rock and Fluid Properties %%%%
% Viscosity (pa.s)
RF.mu_w = 0.001;
% Core average permeability (measured during flow through experiments)
RF.kc = 23.3; % [mD]
% Core diameter
RF.diameter = 2; % [inches]
% Core length
RF.L = 10; % [cm]

%%% Calculation input %%%%
% This variable is used to determine when all the tracer is in the core to
% calculate the 'steady_frames'. When the total tracer is below
% 1-steady_thresh/100 then the core either has tracer coming into or out of
% core. Typically this should be set between 1 and 2 (it's input as a
% percent).
steady_thresh = 1.1;

% The dataset provided is a single phase dataset (fully water saturated)
num_phases = 1; % 1=single phase, 2 = multiphase

%%%%%% END INPUT %%%%%%
%% Load Data
load(filename)

%% Step 1: Find the timeframes when all tracer pulse is in core
% Find PET scan frames when tracer is in the core (indicated by red points
% in plot if last input variable is set equal to 1)
% Recommended call function looks like this:
% [M0C, Xcore, steady_frames]= core_avg_center_mass_calc_function(...
%       PET_4D_cc, vox_size, 2, 1);
% This will find the frames with change less than 1.1 percent (or whatever
% 'steady_thresh' is set to) and plot the
% center of mass calculations (last number can be anything).
% The red points in the plot highlight the steady frames
[M0C, Xcore, steady_frames]= core_avg_center_mass_calc_function(PET_4D_coarse, vox_size, steady_thresh,1);

%% Step 2: Calculate moments in each streamtube
% Calculate the zero, first, and second moment in each streamtube of the 
% core. As writen, the streamtubes are linear and parallel to the axis of 
% the core
% Option to plot change in zero moment in each streamtube
% [M0, Xc, Sx]= streamtube_moment_calc_function(PET_4D_coarse, vox_size(3), steady_frames);
% Option without plot
[M0, Xc, Sx]= streamtube_moment_calc_function(PET_4D_coarse, vox_size(3));

%% Step 3: Calculate pore water velocity of each streamtube
% Vs is a matrix of the mean velocity in each streamtube and vm is the 
% core-average pore water velocity. Input is (Xc, steady_frames, 
% frame_length, varargin), where frame_length is in seconds and varargin 
% can be any number, the presence of which triggers a plot of the 
% streamtube pore water velocities.
[Vs, vm, v_std, v_std_error] = streamtube_linear_velocity_function(Xc, steady_frames, frame_length, 1);

%% Step 4: Calculate the scaled injection rate
% The experimental injection rate is given by qw. However because
% inevitably some of the image is cropped during image processing, the
% total flow rate into the imaged part of the core is smaller and must be
% corrected.
[qws] = scaled_injection_rate_function(qw, M0, vox_size, RF.diameter);

%% Step 5: Calculate tracer volumetric flow into each streamtube
[Qs, q_std, q_std_error]= streamtube_flow_function(M0, steady_frames, qws);

%% Step 6: Calculate streamtube porosity
% streamtube_por_and_sat_calc(streamtube velocity, streamtube flow rate, 
% voxel size (cm), number of fluid phases (1 for single phase and 2 for 
% multiphase--if 2 then the next variable must be matrix of streamtube 
% porosity, any variable that triggers plotting)
[Phi_s, phi_core] = streamtube_por_and_sat_function(Vs, Qs, vox_size, num_phases, 1);

%% Step 7: Calculate streamtube permeability
% perm_calc_function(streamtube velocity, streamtube porosity, rock
% and fluid properties, flow rate, pressure drop, plots 1=direct perm
%2=direct and velocity scaled perm, 3=direct, velocity, and velocity/neglecting porosity)
[K_md, kc_md, K_m2]= perm_calc_function(Vs, Phi_s, RF, qw, dP, 2);

%% Option for calculating longitudinal dispersion   
% [Alps, alpha_m] = streamtube_dispersivity_function(Xc, Sx, steady_frames, 0, 1);

