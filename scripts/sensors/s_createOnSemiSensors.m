% s_createOnSemiSensors.m
%
% Purpose: create sensors from ON Semiconductor datasheets
%           then decide which to use for estimated sensor with no NIR
%           blocking filter

%%
cd /users/joyce/GitHub/isetcam/;
addpath(genpath(pwd));
cd /users/joyce/GitHub/arriscope/;
addpath(genpath(pwd));



%% Compare the On Semiconductor sensors with Sony
wave = 400:10:1000;
SensorFname = fullfile(arriRootPath,'data','sensor','OnSemiAR0130.mat');
OnSemiAR0130 = ieReadSpectra(SensorFname, wave);

ieNewGraphWin;
maxS = max(max(OnSemiAR0130))
plot(wave,OnSemiAR0130(:,1)/maxS,'r'); hold on;
plot(wave,OnSemiAR0130(:,2)/maxS,'g');
plot(wave,OnSemiAR0130(:,3)/maxS,'b');

SensorFname = fullfile(arriRootPath,'data','sensor','OnSemiAR0134.mat');
OnSemiAR0134 = ieReadSpectra(SensorFname, wave);
maxS = max(max(OnSemiAR0134))
plot(wave,OnSemiAR0134(:,1)/maxS,'r--'); hold on;
plot(wave,OnSemiAR0134(:,2)/maxS,'g--');
plot(wave,OnSemiAR0134(:,3)/maxS,'b--');

SensorFname = fullfile(arriRootPath,'data','sensor','OnSemiAR0220.mat');
OnSemiAR0220 = ieReadSpectra(SensorFname, wave);
maxS = max(max(OnSemiAR0220))
plot(wave,OnSemiAR0220(:,1)/maxS,'r*'); hold on;
plot(wave,OnSemiAR0220(:,2)/maxS,'g*');
plot(wave,OnSemiAR0220(:,3)/maxS,'b*');


SensorFname = fullfile(arriRootPath,'data','sensor','OnSemiAR0238.mat');
OnSemiAR0238 = ieReadSpectra(SensorFname, wave);
maxS = max(max(OnSemiAR0238))
plot(wave,OnSemiAR0238(:,1)/maxS,'ro'); hold on;
plot(wave,OnSemiAR0238(:,2)/maxS,'go');
plot(wave,OnSemiAR0238(:,3)/maxS,'bo');


SonyIMX249SensorFname = fullfile(arriRootPath,'data','sensor','SonyIMX249.mat');
SonyIMX249 = ieReadSpectra(SonyIMX249SensorFname, wave);

maxS = max(max(SonyIMX249))
plot(wave,SonyIMX249(:,1)/maxS,'rd'); hold on;
plot(wave,SonyIMX249(:,2)/maxS,'gd');
plot(wave,SonyIMX249(:,3)/maxS,'bd');

%% pick OnSemiAR0130.mat and scale to match estimated sensors
wave = 400:10:900;


SensorFname = fullfile(arriRootPath,'data','sensor','ARRIestimatedSensors.mat');
ARRIest = ieReadSpectra(SensorFname, wave);
ieNewGraphWin;
plot(wave,ARRIest(:,1),'r'); hold on;
plot(wave,ARRIest(:,2),'g');
plot(wave,ARRIest(:,3),'b');

SensorFname = fullfile(arriRootPath,'data','sensor','OnSemiAR0130.mat');
OnSemiAR0130 = ieReadSpectra(SensorFname, wave);

% maxS = max(max(OnSemiAR0130))
% plot(wave,OnSemiAR0130(:,1)/maxS,'r'); hold on;
% plot(wave,OnSemiAR0130(:,2)/maxS,'g');
% plot(wave,OnSemiAR0130(:,3)/maxS,'b');


red = OnSemiAR0130(:,1)/max(OnSemiAR0130(:,1)) * max(ARRIest(:,1));
green = OnSemiAR0130(:,2)/max(OnSemiAR0130(:,2)) * max(ARRIest(:,2));
blue = OnSemiAR0130(:,3)/max(OnSemiAR0130(:,3)) * max(ARRIest(:,3));
plot(wave,red,'r--'); hold on;
plot(wave,green,'g--');
plot(wave,blue,'b--');
% save as ScaledOnSemi
%{
fname = fullfile(arriRootPath,'data','sensor','ScaledOnSemi.mat');
wavelength = 400:10:900;
data = [red,green,blue];
comment = 'These are the QE functions that have been scaled to match the RGB gains estimated for the ARRIscope (see s_arriSensorEstimation.m)';
ieSaveSpectralFile(wavelength,data,comment,fname);
%}


%% filter with UV + IR sensor

filter = ieReadSpectra('UVandIR.mat',wave);
filteredOnSemiR = red .* filter;
filteredOnSemiG = green .* filter;
filteredOnSemiB= blue .* filter;
plot(wave,filteredOnSemiR,'r'); hold on;
plot(wave,filteredOnSemiG ,'g');
plot(wave,filteredOnSemiB,'b');


% save as FilteredAndScaledOnSemi 
%{
fname = fullfile(arriRootPath,'data','sensor','ScaledAndFilteredOnSemi.mat');
wavelength = 400:10:900;
data = [filteredOnSemiR,filteredOnSemiG,filteredOnSemiB];
comment = 'These are the QE functions that have been scaled to match the RGB gains estimated for the ARRIscope (see s_arriSensorEstimation.m) and filtered using the UVandIR filter that we think is a good fit for the ARRIscope filter'
ieSaveSpectralFile(wavelength,data,comment,fname);
%}

%% see how well the filter with UV + IR sensor predicts measured RGB
mRGBfilename = fullfile(arriRootPath,'data','macbethColorChecker','mRGB.mat');
load(mRGBfilename,'mRGB');

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
sensorQE = ieReadSpectra('ScaledAndFilteredOnSemi.mat',wave);
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

%%

colorList1 = {'r-','g-','b-'};
colorList2 = {'ro','go','bo'};
sensorQE = ieReadSpectra('ARRIestimatedSensors.mat',wave);
ieNewGraphWin;
plot(wave,sensorQE(:,1),'r'); hold on;
plot(wave,sensorQE(:,2),'g');
plot(wave,sensorQE(:,3),'b');

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

%%
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

