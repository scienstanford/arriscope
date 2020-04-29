%% s_arriTissueContrast
%
% Purpose:
%   Measure the tissue signals expected from the arri microscope model
%   (sensor and lights).  See how discriminable the different tissues might
%   be.
%
%   We create a chart with the tissues as reflectance entries.  We then
%   illuminate with the 6 different lights and get a series of 6  RGB
%   images.  Then we see how discriminable the types are by calculating,
%   say, the d' separation between each pair of tissue types.  For d' we
%   will really calculate the Mahalanobis distance.  
%
%   The Mahalanobis distance means fit each tissue with a multivariate
%   Gaussian.  FInd the sd for that Gaussian in the direction of the mean
%   differences.  Count how many standard deviations separate the two
%   tissue types.
%
% JEF/BW