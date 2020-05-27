% streamtube_por_and_sat_function.m
function [S_s, s_core]= streamtube_por_and_sat_function(Vs, Qs, vox_size, num_phases, varargin)
% Christopher Zahasky
% 5/29/17
% This script is used to calculate porosity or saturation, depending on
% input, from streamtube flux and pore water velocity.
% streamtube_por_and_sat_calc(streamtube velocity, streamtube flux, voxel
% size (cm), 1=por or 2=sat, var 4 is 2 then this must be matrix of
% streamtube porosity, any variable that triggers plotting)

pix_area = vox_size(1)*vox_size(2);

% If single phase then this calculate porosity
if num_phases == 1
    % Streamtube porosity (Equation 6 in Zahasky and Benson, 2018)
    S_s = Qs./(pix_area.*Vs);
    % Core average porosity
    s_core = nanmean(nanmean(S_s));
% If multiphase then this calculates water saturation and streamtube
% porosity must be input (Phi_s)
elseif num_phases == 2
    Phi_s = varargin{1};
    % Streamtube saturation (Equation 10 in Zahasky and Benson, 2018)
    S_s = Qs./ (pix_area.* Vs .* Phi_s);
    % Core average saturation
    s_core = nanmean(nanmean(S_s));
else
    error('Forth variable must either be a 1 to calculate porsity or a 2 to calculate saturation')
end

% if addition variables are listed this triggers the plot
extra_var = nargin-5;
if extra_var > 0
    figure
    h3 = imagesc(S_s);
    set(h3,'alphadata',~isnan(S_s))
    if num_phases == 1
        title('Porosity', 'fontsize', 14)
        caxis([0.15 0.22])
    elseif num_phases == 2
        title('Water Saturation', 'fontsize', 14)
        caxis([0.5 1])
    end
    axis equal
    axis tight
    axis off
    colorbar
end