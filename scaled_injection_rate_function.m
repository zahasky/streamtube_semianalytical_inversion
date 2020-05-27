% scaled_injection_rate_function.m
function [qw, a_disc] = scaled_injection_rate_function(Qw, M0, vox_size, diameter)
% Christopher Zahasky
% 5/29/2017
% This script is used to calculate the injection rate scaled by the amount
% cropped off the edges

m0 = M0(:,:,1);
m0 = m0(:);
number_tubes = length(find(m0>0));
a_disc = number_tubes*vox_size(1)*vox_size(2);
% convert diameter in inches to cm and calculate cross-sectional area
A = (diameter*2.54/2)^2*pi; %[cm^2]
qw = Qw/60*a_disc/A; %[cm^3/s]