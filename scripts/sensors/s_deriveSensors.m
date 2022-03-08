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
%   We pick the QE functions for an On Semiconductor sensor (company makes
%   sensor for ARRIScope)
%   We first scale it so that the gains match the sensor QE functions we
%   estimated for the ARRIscope (based on 24 patches illuminated by 6
%   lights)
%   Then, we apply an NIR blocking filter that produces QE functions
%   similar to the estimated sensors
%   Then we determine how well this scaled and filtered QE function (again,
%   derived from published QE functions for a Sony sensor) predict the ARRIscope 
%   RGB values measured for the 24 patches illuminated by the 6 spectral lights.  
%
% 
% see ARRIestimatedSensorsNoNIRfilter
%% TODO
% will need to clean up the many different sensor QE functions we have in
% data/sesnor
% For example 
% ARRISensorNIRoff.mat is the Sony sensor functions - not estimated
% ARRISensorNIRon.mat is the estimated ARRI sensor functions - based on
%
% will need to save ScaledSony and FilteredAndScaledSony 

% redo this removing the UV light which only contributes noise - did this, no differences

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

% SonyIMX249SensorFname = fullfile(arriRootPath,'data','sensor','SonyIMX249.mat');
% SonyIMX249 = ieReadSpectra(SonyIMX249SensorFname, wave);
% ARRIestimatedFname = fullfile(arriRootPath,'data','sensor','ARRIestimatedSensors.mat');
% arriQE = ieReadSpectra(ARRIestimatedFname, wave);
 

%% Scale the RGB gains of the Sony QE to match the RGB gains of the estimated sensor
%{
scaledSonyR = SonyIMX249(:,1)/max(SonyIMX249(:,1)) * max(arriQE(:,1));
scaledSonyG = SonyIMX249(:,2)/max(SonyIMX249(:,2)) * max(arriQE(:,2));
scaledSonyB = SonyIMX249(:,3)/max(SonyIMX249(:,3)) * max(arriQE(:,3));
ieNewGraphWin;
plot(wave,scaledSonyR,'r'); hold on;
plot(wave,scaledSonyG,'g');
plot(wave,scaledSonyB,'b');
plot(wave,arriQE(:,1),'r--');
plot(wave,arriQE(:,2),'g--');
plot(wave,arriQE(:,3),'b--');

ScaledSony = [scaledSonyR,scaledSonyG,scaledSonyB]; % save this if we like it.
%}

% we saved this as ScaledSony
%{
sensor = [scaledSonyR, scaledSonyG, scaledSonyB];
comment = 'spectral QE for the SonyM249 scaled to have the same gain as the arriEstimated Sensors,we are using these as a best guess for the ARRI Sensor QE without the NIR blocking filter'
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
%{
filter = ieReadSpectra('UVandIR.mat',wave);
filteredSonyR = scaledSonyR .* filter;
filteredSonyG = scaledSonyG .* filter;
filteredSonyB = scaledSonyB .* filter;
ieNewGraphWin;
plot(wave,filteredSonyR,'r'); hold on;
plot(wave,filteredSonyG ,'g');
plot(wave,filteredSonyB,'b');
FilteredAndScaledSony = [filteredSonyR,filteredSonyG,filteredSonyB];
%}
% we saved this as FilteredAndScaledSony.mat
%{
wavelength = 400:10:900;
data = FilteredAndScaledSony;
comment = 'These are the QE functions that have been scaled to match the RGB gains estimated for the ARRIscope (see s_arriSensorEstimation.m) and filtered using the UVandIR filter that we think is a good fit for the ARRIscope filter'
ieSaveSpectralFile(wavelength,data,comment);
%}

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
% See how well the scaled and filtered Sony QE functions do at predicting the 24 patches illuminated by the 6 spectral lights
%% measured RGB values saves as mRGB.mat
mRGBfilename = fullfile(arriRootPath,'data','macbethColorChecker','mRGB.mat');
load(mRGBfilename,'mRGB');
% Get the mean RGB values for the MCC chart illuminated by 6 lights
% Display the raw camera images captured by the ARRIScope camera with the
% NIR filter on for each of the 6 lights
% Then grab the mean R, G and B values for each of the 24 patches captured
% under each of the 6 lights
% Notice that the raw camera image captured under violet17 has very little
% signal and is, therefore, noisy
% just do this once and store results
%{
chdir(fullfile(arriRootPath,'data','macbethColorChecker','MacbethIRON'));
rgbImages = {'MacbethCc_blue17_fIRon.ari','MacbethCc_green17_fIRon.ari', ...
    'MacbethCc_red17_fIRon.ari', 'MacbethCc_violet17_fIRon.ari', ...
    'MacbethCc_white17_fIRon.ari','MacbethCc_arriwhite20_fIRon.ari'};
ip = ipCreate;
ip = ipSet(ip,'correction method illuminant','none');
ip = ipSet(ip,'conversion method sensor','none');

 img = arriRead(rgbImages{end},'image','left');
 ieNewGraphWin;
 imagescRGB(img);
%}
%{
% Make the display look right for the blue case.  What's going on?
 img = arriRead(rgbImages{end},'image','left');
 img = imresize(img,1/4);
 ip = ipSet(ip,'result',img);
 ipWindow(ip);
 showSelection = true;
 fullData = false;
 [thisRGB,~,~,cornerPoints] = macbethSelect(ip,showSelection,fullData);
%}

%{
showSelection = true;   % Do or do not bring up the window
fullData      = false;  % Just returns the mean in each patch
cornerPoints = [
    79   291;
   490   292;
   489    19;
    79    22];

mRGB = [];
for ii=1:numel(rgbImages)
    img = arriRead(rgbImages{ii},'image','left');
    img = imresize(img,1/4);
    ip  = ipSet(ip,'result',img); 
    thisRGB = macbethSelect(ip,showSelection,fullData,cornerPoints);
    mRGB = [mRGB; thisRGB];
end

mRGBfilename = fullfile(arriRootPath,'data','macbethColorChecker','mRGB.mat');
save(mRGBfilename,'mRGB');

%}

%% Predicted RGB values
wave = 400:10:700;
% Load the macbeth reflectances
surfaces = ieReadSpectra('MiniatureMacbethChart.mat',wave);
plotRadiance(wave,surfaces);
% For each light multiply each MCC patch to get the expected radiance
testLights = {'blueSonyLight.mat','greenSonyLight.mat',...
    'redSonyLight.mat','violetSonyLight.mat',...
    'whiteSonyLight.mat','whiteARRILight.mat'};  

radiance = [];
for ii=1:numel(testLights)
    thisLight = ieReadSpectra(testLights{ii},wave);
    radiance = [radiance, diag(thisLight(:))*surfaces];
end

%{
plotRadiance(wave,radiance);
title('MCC under 6 different lights')
%}
colorList1 = {'r-','g-','b-'};
colorList2 = {'ro','go','bo'};
sensorQE = ieReadSpectra('FilteredAndScaledSonyQE.mat',wave);
ieNewGraphWin;
estimatedFiltersRGB = sensorQE'*radiance;
estimatedFiltersRGB = estimatedFiltersRGB';
for ii=1:3
    plot(ieScale(estimatedFiltersRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList2{ii});
    hold on;
end
identityLine;
xlabel('RGB values predicted by the scaled and Filtered Sony QE');
ylabel('RGB values measured by ARRI sensors');

%% Compare to the scaled TLC QE functions
% TLCI are QE functions for a standard color camera model
% We found that the scaled TLCI QE functions predict the ARRIscope RGB values (measured 
% for the 24 patches illuminated by the 6 spectral lights) just as well as
% the QE functions we estimated 
% Here we compare the scaled TLCI QE functions to the scaled and filtered
% Sony QE functions
% TLCISensorFname = fullfile(arriRootPath,'data','sensor','TLCIsensors.mat');
% TLCIQE = ieReadSpectra(TLCISensorFname, wave);
% ScaledTLCIr = TLCIQE(:,1)/max(TLCIQE(:,1))* max(arriQE(:,1));
% ScaledTLCIg = TLCIQE(:,2)/max(TLCIQE(:,2))* max(arriQE(:,2));
% ScaledTLCIb = TLCIQE(:,3)/max(TLCIQE(:,3))* max(arriQE(:,3));
%{
ieNewGraphWin;
plot(wave,ScaledTLCIr,'r--'); hold on
plot(wave,ScaledTLCIg,'g--');
plot(wave,ScaledTLCIb,'b--');
%}
%{
wavelength = 400:10:700;
data = [ScaledTLCIr,ScaledTLCIg,ScaledTLCIb];
comment = 'TLCI QE functions scaled to the RGB gains estimated for the ARRIScope';
ieSaveSpectralFile(wavelength, data, comment);
%}

sensorQE = ieReadSpectra('ScaledTLCIsensors.mat',wave);
ieNewGraphWin;
estimatedFiltersRGB = sensorQE'*radiance;
estimatedFiltersRGB = estimatedFiltersRGB';
for ii=1:3
    plot(ieScale(estimatedFiltersRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList2{ii});
    hold on;
end
identityLine;
xlabel('RGB values predicted by the scaled TLCI sensors');
ylabel('RGB values measured by ARRI sensors');

%% Compare to the estimated Sensors
estimatedFilters = ieReadSpectra('ARRIestimatedSensors.mat')
ieNewGraphWin;
estimatedFiltersRGB = estimatedFilters'*radiance;
estimatedFiltersRGB = estimatedFiltersRGB';
for ii=1:3
    plot(ieScale(estimatedFiltersRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList2{ii});
    hold on;
end
identityLine;
xlabel('RGB values predicted by the estimated sensors');
ylabel('RGB values measured by ARRI sensors');


