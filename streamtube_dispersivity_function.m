% streamtube_dispersivity_function.m
function [Alps, alpha_m]= streamtube_dispersivity_function(Xc, Sx, ...
    steady_frames, crop_strange, varargin)
% Christopher Zahasky
% 5/29/17
% This script is used to calculate streamtube longitudinal dispersivity as
% described in Section 3.8 of Zahasky and Benson, 2018
n=1;
% preallocate dispersivity matrix
dim = size(Xc);
Alps = zeros(dim(1),dim(2));

% Plotting commented out
% figure
% hold on
% ccc = jet(dim(1)*dim(2));
for i = 1:dim(1)
    for j = 1:dim(2)
        if sum(Xc(i,j,steady_frames(1:end-1))) > 0
            xc = squeeze(Xc(i,j,steady_frames(1:end)));
            sxx = squeeze(Sx(i,j,steady_frames(1:end)));
%             plot(xc, sxx, 'color', ccc(n,:))
            n=n+1;
            
            % linear regression (essentially equation 16 and 17 in Zahasky
            % and Benson, 2018)
            X = [ones(length(xc),1) xc];
            b = X\sxx;
            
            Alps(i,j) = b(2)/2;
        end
    end
end
xlabel('Center of mass')
ylabel('Second moment')

% test to see if there are negative dispersivities
neg_test = find(Alps<0);
if length(neg_test)>0
    warning(['There are ', num2str(length(neg_test)), ' negative dispersivity values'])
    if crop_strange == 1
        Alps(Alps<0)=nan;
    else
        warning('Values not cropped, set var4 = 1 to crop')
    end
end
% test to see if there are anomolysly large dispersivities (greater than 4sd)
standard_dev = nanstd(Alps(:));
anom_test = find(Alps>standard_dev*6);
if length(anom_test)>0
    warning(['There are ', num2str(length(anom_test)), ' anomalously large dispersivity values'])
    if crop_strange == 1
        Alps(Alps>standard_dev*6)=nan;
    else
        warning('Values not cropped, set var4 = 1 to crop')
    end
end
alpha_m = nanmean(nanmean(Alps));
Alps(Alps==0)=nan;
% if addition variables are listed this triggers the plot
extra_var = nargin-4;
if extra_var > 0
    figure
    h3 = imagesc(Alps);
    set(h3,'alphadata',~isnan(Alps))
    title('Dispersivity [cm]', 'fontsize', 14)
    axis equal
    axis tight
    axis off
    colorbar
  
end