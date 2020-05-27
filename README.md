# streamtube_semianalytical_inversion
Matlab codes for streamtube analysis with permeability and dispersion calculation. See the following link for publication: https://doi.org/10.1016/j.advwatres.2018.03.002

The PET data example is 'BSS_c1_2ml_PET_data.mat'.

To plot the PET data use the script called 'plot_timelapse_pet_data.m'. This script utilizes a plotting function called 'PATCH_3Darray' from Matlab exchange (https://www.mathworks.com/matlabcentral/fileexchange/28497-plot-a-3d-array-using-patch).

The main script for calculating streamtube permeability is 'streamtube_perm_calculation_clean.m'. The remainder of the files are functions called by the main script and all names end in '_function.m' for clarity.

For a qualitative comparison, notice the faster advection in the bottom of the core in the 3D plots as compared with the pore water velocity streamtube calculations. This is driven by the higher permeability lamina in the bottom of the core.
