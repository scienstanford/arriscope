%% s_ARRImodelPredictions.m
%
% Purpose:  
%   Use the raw ARRI RGB sensor values captured under 6 different
%   lights to estimate surface reflectance.  We illustrate with MCC.
%   (ultimately, we wish to estimate reflectances for tissue.
%
%   We will use measured tissue reflectances, although it is also possible
%   to predict tissue reflectances if we know the absorbance and scattering
%   properties
%   
% Method:
%   1. Select a collection of surface reflectances (e.g. reflectances for different tissue types)
%   2. Predict the raw ARRI RGB sensor values for each of the measured tissue reflectances
%   3. Calculate the principal components for a set of measured
%   reflectances such that you can describe reflectances by a weighted
%   combination of the principal components 
%       each surface is then described by weights on the principal
%       components
%       Select N basis functions that account for 99% of the variance in
%       the surface reflectances and where N < number of sensor values
%       Do not remove the mean, since some types of tissue (cancer versus
%       non-cancer) differ by the mean (note that in the future, we need to
%       normalize the sensor values such that they are relatively invariant
%       to non-uniform distribution of illumination
%
% Example:
%   We used the MCC surfaces to illustrate and validate the method (see
%   s_ARRImodelPredictions4MCC.m)
%   Here we replace the MCC surfaces with the Stelzle et al published reflectances for different tissue types.
%% 1. Selection of surface reflectances

wave = 400:10:640; % unfortunately, the data only go to 640 nm

% Load the macbeth reflectances
surfaces = ieReadSpectra('tissueReflectances.mat',wave);
plotReflectance(wave,surfaces);

% Principal components analysis
% How many principal components do we need to describe the spectral reflectances?
% nDim = 6;
% nDim = 1; % Let's try 1
nDim = 2; % Let's try 2 
% If we only need two principal components to predict tissue reflectances,
% then how many sensors do we need to estimate the weights on the principal components ?
% nDim = 4; 
[linModel,S,V] = svd(surfaces);
linModel = linModel(:,1:nDim);
plotReflectance(wave,linModel); % The linModel are the N spectral basis funtions
xaxisLine;
S = diag(S);
percentV = cumsum(S.^2)/sum(S.^2); % check to see if this is the right calculation for percent variance accounted for

%% 2. Predicted Sensor values -
% read in the sensor QE and multiply by the lights to get 18 sensors

% Load sensor
arriSensorFname = fullfile(arriRootPath,'data','sensor','ARRIestimatedSensors.mat');
arriQE = ieReadSpectra(arriSensorFname, wave);
plotRadiance(wave,arriQE,'title','ARRI sensor quantum efficiency');

% Load the lights and multiply with sensor QE 
testLights = {'blueSonyLight.mat','greenSonyLight.mat',...
    'redSonyLight.mat','violetSonyLight.mat',...
    'whiteSonyLight.mat','whiteARRILight.mat'};

% Consider using fewer lights and see how this affects our ability to
% predict tissue reflectances
%{
testLights = {'whiteARRILight.mat'};
%}

sensor = zeros(length(wave),numel(testLights)*3);
kk = 0;
for ii = 1:numel(testLights)
    for jj = 1:3
        kk = kk +1;
        thisLight = ieReadSpectra(testLights{ii},wave);
        thisSensor = arriQE(:,jj) .* thisLight;
        sensor(:,kk)= thisSensor(:);
    end
end
plotRadiance(wave,sensor,'title','ARRI QE * Light Spectral Energy');
% set(gca,'yscale','log');

% Predict sensor values for reflectances
predSensorValues = sensor' * surfaces;
numel(predSensorValues)

%% 4. Find a N x B matrix that maps N sensor values into B weights 
% Find the weights that are the LS solution to
%    measured = sensor*linModel*wgts
%    measured = A w (A = sensor*linModel)
%    w = measured \ A
A = sensor'*linModel;
wgts = pinv(A)*predSensorValues;
predLowDim = sensor'*linModel*wgts; % replace surfaces with a low dimensional model where each surface is represented by wgts * basis (LinModel)

% plot the sensor RGB values predicted by the low-dimensional spectral representation of the surfaces against 
%      the sensor RGB values predicted by the full-dimensional spectral representation of the surfaces
% There is a loss of information mapping the surfaces (31 wavelengths x 24 surfaces) onto the sensors (31x18) 
% Note also that some of the sensors cannot detect the surface spectral energy, so they don't matter

% This is how well we can predict the sensor values, given reduced representation of the tissue reflectances
ieNewGraphWin;
scatter(predLowDim(:),predSensorValues(:));
identityLine; grid on; xlabel('Sensor values predicted by the full linear model');ylabel('Sensor values predicted by reduced dim');
title(['Number of Dimensions = ',num2str(nDim)]);


%%  5.  Predicted reflectance comparisons

% Unlike the MCC, which require 6 spectral basis functions to
% represent the 24 surface reflectances (see s_ARRImodelPredictions4MCC.m)
% we only need 2 spectral basis functions to represent the 11 different
% tissue types provided by Stelzle et al 

% The question we can ask, however, is how many spectral lights (spectral
% channels) do we need in order to predict the weights on the 2 spectral
% basis functions.  
% Do we do as well with 1 light as with 6 lights?
% To determine this, rerun the analysis using nDim = 2, but 1 light
% compare this to the case where nDim = 2, but 6 lights
% Note that 1 light (ARRIlight) does as well as 6 lights 
% Note, however, that this is for the fixed exposure condition 

% This is how well we can predict the spectral reflectances given N sensor
% values
% N = 33 for 1 light and 11 surfaces
% N = 198 for 6 lights and 11 surfaces

plotReflectance(wave,surfaces);
hold on;
predReflectance = linModel*wgts;
plot(wave,predReflectance,'--');
hold off

ieNewGraphWin;
scatter(surfaces(:),predReflectance(:));
identityLine; grid on; xlabel('reflectance');ylabel('predicted reflectance');

%% Get the real sensor values and compare to the predicted sensor values
%  We can only do this for the MCC, because we have both the spectral
%  reflectance and the ARRI RGB values for the 24 surfaces (see s_ARRImodelPredictions4MCC.m) 


