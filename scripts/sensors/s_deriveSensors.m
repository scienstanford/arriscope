%% s_deriveSensors.m
%
% The goal of this script is to find sensor that includes QE in the NIR
% range and an NIR filter such that the multiplication of the NIR filter
% with the sensorQE produces a quantum efficiency that predicts the MCC
% data 
% 
% Background
%   We estimate the sensor QE in the ARRIscope (see s_sensorEstimation.m)
%   There many by other sensor QE functions that are "equivalent" to the
%   estimated QE in the sense that they predict the ARRIscope RGB values
%   measured for the 24 patches illuminated by the 6 spectral lights.  
%
%   We do not have an estimate of the sensor QE with an NIR filter.
%   We would like to have this estimate so that we can predict the
%   ARRIScope RGB values for spectral reflectances > 700 nm
%
%   We pick the QE functions for a Sony sensor that is popular and very
%   much like the spectral QE functions for a OnSemi sensor
%   We first scale it so that the gains match the sensor QE functions we
%   estimated for the ARRIscope (based on 24 patches illuminated by 6
%   lights)
%   Then, we apply an NIR blokcing filter that produces QE functions
%   similar to the estimated sensors
%   Then we determine how well this scaled and filtered QE function (again,
%   derived from published QE functions for a Sony sensor) predict the ARRIscope 
%   RGB values measured for the 24 patches illuminated by the 6 spectral lights.  
%
% 
% see ARRIestimatedSensorsNoNIRfilter

%% set the Matlab path
%{
cd /users/joyce/GitHub/isetcam/;
addpath(genpath(pwd));
cd /users/joyce/GitHub/arriscope/;
addpath(genpath(pwd));
%}
%% set the range of wavelengths
wave = 400:10:900;
%% created the UVandIR filter
%{
ieNewGraphWin; plot(Data019(:,1),Data019(:,2));
wavelength = Data019(:,1);
data = Data019(:,2);
comment = 'best guess at UV + NIR filter';
ieSaveSpectralFile(wavelength,data,comment);
%}
%%  load in sensors 
% see s_arriSensorEstimation) for details about how ARRIestimatedSensors was calculated

SonyIMX249SensorFname = fullfile(arriRootPath,'data','sensor','SonyIMX249.mat');
SonyIMX249 = ieReadSpectra(SonyIMX249SensorFname, wave);
ARRIestimatedFname = fullfile(arriRootPath,'data','sensor','ARRIestimatedSensors.mat');
arriQE = ieReadSpectra(ARRIestimatedFname, wave);

%% Scale the RGB gains of the Sony QE to match the RGB gains of the estimated sensor

scaledSonyR = SonyIMX249(:,1)/max(SonyIMX249(:,1)) * max(arriQE(:,1));
scaledSonyG = SonyIMX249(:,2)/max(SonyIMX249(:,2)) * max(arriQE(:,2));
scaledSonyB = SonyIMX249(:,3)/max(SonyIMX249(:,3)) * max(arriQE(:,3));
ieNewGraphWin;
plot(wave,scaledSonyR,'r'); hold on;
plot(wave,scaledSonyG,'g');
plot(wave,scaledSonyB,'b');

% perhaps we should save these as scaled Sony sensor QE functions
%{
sensor = [scaledSonyR, scaledSonyG, scaledSonyB];
comment = 'spectral QE for the SonyM249 scaled to have the same gain as the arriEstimated Sensors,  ...
we are using these as a best guess for the ARRI Sensor QE without the NIR blocking filter'
ieSaveSpectralFile(wave,sensor,comment);
%}

% These plots simply show that the On Semiconductor sensor spectral QE are
% close to the Sony Spectral QE
%{
OnSemiR = ieReadSpectra('OnSemiAR0521Red.mat',wave);
OnSemiG = ieReadSpectra('OnSemiAR0521Green.mat',wave);
OnSemiB = ieReadSpectra('OnSemiAR0521Blue.mat',wave);
scaledOnSemiR = OnSemiR/max(OnSemiR(:))* max(arriQE(:,1));
scaledOnSemiG = OnSemiG /max(OnSemiG (:))* max(arriQE(:,2));
scaledOnSemiB = OnSemiB/max(blue(:))* max(arriQE(:,3));
plot(wave,scaledOnSemiR,'r--');
plot(wave,scaledOnSemiG,'g--');
plot(wave,scaledOnSemiB,'b--');
%}

%% Filter the scaled Sony QE functions using a UVandIR filter

filter = ieReadSpectra('UVandIR.mat',wave);
filteredSonyR = scaledSonyR .* filter;
filteredSonyG = scaledSonyG .* filter;
filteredSonyB = scaledSonyB .* filter;
ieNewGraphWin;
plot(wave,filteredSonyR,'r'); hold on;
plot(wave,filteredSonyG ,'g');
plot(wave,filteredSonyB,'b');

%% Filter the scaled OnSemi QE functions using a UVandIR filter
% Perhaps we will see how well these functions do at predicting the
% ARRIscope RGB values for 24 surfaces illuminated with 6 lights
%{
filteredOnSemiR = scaledOnSemiR .* filter;
filteredOnSemiG = scaledOnSemiG .* filter;
filteredOnSemiB = scaledOnSemiB .* filter;
filteredSonyG = scaledSonyG .* filter;
filteredSonyB = scaledSonyB .* filter;
plot(wave,filteredOnSemiR,'r--'); hold on;
plot(wave,filteredOnSemiG ,'g--');
plot(wave,filteredOnSemiB,'b--');
%}

%%

% TLCI are QE functions for a standard color camera model
% We found that the scaled TLCI QE functions predict the ARRIscope RGB values (measured 
% for the 24 patches illuminated by the 6 spectral lights) just as well as
% the QE functions we estimated 
% Here we compare the scaled TLCI QE functions to the scaled and filtered
% Sony QE functions

plot(wave,TLCIQE(:,1)/max(TLCIQE(:,1))* max(arriQE(:,1)),'r--'); hold on
plot(wave,TLCIQE(:,2)/max(TLCIQE(:,2))* max(arriQE(:,2)),'g--');
plot(wave,TLCIQE(:,3)/max(TLCIQE(:,3))* max(arriQE(:,3)),'b--');

%%
% will need to clean up the many different sensor QE functions we have in
% data/sesnor
% For example 
% ARRISensorNIRoff.mat is the Sony sensor functions - not estimated
% ARRISensorNIRon.mat is the estimated ARRI sensor functions - based on

%% 
% See how well the scaled and filtered Sony QE functions do at predicting the 24 patches illuminated by the 6 spectral lights


