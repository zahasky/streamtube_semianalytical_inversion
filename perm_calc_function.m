% perm_calc_function.m
function [K_md, kc_md, K_m2, kc_m2, Ksc_md, Kvssc_md]= perm_calc_function(...
    Vs, Phi_s, RF, Qw, dP, varargin)
% Christopher Zahasky
% 6/20/17
% This script is used to calculate streamtube permeability
% perm_calc_function(streamtube velocity, streamtube porosity, rock
% and fluid properties, flow rate, pressure drop, plots 1=direct perm
%2 =direct and flux scaled perm, 3=direct, flux, and velocity scaled)

% conversion from psi to pascals
psi2pa = 6894.76;
delta_p = dP*psi2pa;

% direct calculation (Equation 7 in Zahasky and Benson, 2018)
K_m2 = Vs .* Phi_s.* (RF.mu_w *RF.L /(delta_p *100^2));
K_md = K_m2./(9.86923E-13)*1000;
% core average direct calculation
kc_m2 = nanmean(nanmean(K_m2)); % permeability [m^2]
kc_md = nanmean(nanmean(K_md)); % permeability [mD]

% velocity scaled calculation (Equation 8 in Zahasky and Benson, 2018)
A = (RF.diameter*2.54/2)^2*pi;
Ksc_md = Vs .* Phi_s.* RF.kc .*A./(Qw./60); % permeability [mD]
% velocity scaled calculation (doesn't account for porosity variation)
Kvssc_md = Vs .*RF.kc./nanmean(nanmean(Vs));


% if addition variables are listed this triggers the plot
if varargin{1}== 1
    figure
    h3 = imagesc(K_md);
    set(h3,'alphadata',~isnan(K_md))
    title('Permeability (mD)')
    axis equal
    axis tight
    axis off
    colorbar

elseif varargin{1}== 2
    figure
    s3=subplot(1,2,1);
    h3 = imagesc(K_md);
    set(h3,'alphadata',~isnan(K_md))
    title('Direct permeability (mD)')
    axis equal
    axis tight
    axis off
    colorbar
    c_scale = caxis;
    caxis([floor(c_scale(1)), ceil(c_scale(2))])
    
    s2 = subplot(1,2,2);
    h2 = imagesc(Ksc_md);
    set(h2,'alphadata',~isnan(Ksc_md))
    title('Flux scaled permeability (mD)')
    axis equal
    axis tight
    axis off
    colorbar
    caxis([floor(c_scale(1)), ceil(c_scale(2))])

    
else
    figure
    subplot(1,3,1)
    h3 = imagesc(K_md);
    set(h3,'alphadata',~isnan(K_md))
    title('Direct permeability (mD)')
    axis equal
    axis tight
    axis off
    colorbar
    c_scale = caxis;
    caxis([floor(c_scale(1)), ceil(c_scale(2))])
    
    subplot(1,3,2)
    h2 = imagesc(Ksc_md);
    set(h2,'alphadata',~isnan(Ksc_md))
    title('Velocity scaled permeability (mD)')
    axis equal
    axis tight
    axis off
    colorbar
    caxis([floor(c_scale(1)), ceil(c_scale(2))])  
    
    subplot(1,3,3)
    h1 = imagesc(Kvssc_md);
    set(h1,'alphadata',~isnan(Kvssc_md))
    title('Velocity scaled permeability neglecting porosity variation (mD)')
    axis equal
    axis tight
    axis off
    colorbar
    caxis([floor(c_scale(1)), ceil(c_scale(2))])
end