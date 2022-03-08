%% s_plotMultispectralSensorChannels.m

% Assuming that there is no fluorescence in the sample, the spectral
% reflectance of the sample will be recovered by weights on 13 spectral
% channels created by lights * sensors
%   violet light x blue sensor; violet light x red sensor; violet light x blue sensor
%   blue light x blue sensor; blue light x red sensor; blue light x blue sensor
%   green light x blue sensor; green light x red sensor; green light x blue sensor
%   red light x blue sensor; red  light x red sensor; red  light x blue sensor
%   IR light x CMOS_QE
% Load spectral sensitivities of red, green and blue sensors and the CMOS QE and save as spectral files
%% Created the spectral data files
% cd '/Users/joyce/Google Drive/Projects/ARRIScope/ARRI Documentation/ARRISensors';
% load('blueARRIsensor.mat'); blue_wave = blueARRIsensor(:,1); blue_spectra = blueARRIsensor(:,2);
% comment = 'blue sensor for the Alexa sensor thought to be in the ARRIScope - data grabbed from graph';
% fullpathname = ieSaveSpectralFile(blue_wave, blue_spectra,comment);
% blueSensordata = ieReadSpectra(fullpathname,[380:4:900]);
% 
% load('redARRIsensor.mat'); red_wave = redARRIsensor(:,1); red_spectra = redARRIsensor(:,2);
% comment = 'red sensor for the Alexa sensor thought to be in the ARRIScope - data grabbed from graph';
% fullpathname = ieSaveSpectralFile(red_wave, red_spectra,comment);
% redSensordata = ieReadSpectra(fullpathname,[380:4:900]);
% 
% load('greenARRIsensor.mat'); green_wave = greenARRIsensor(:,1); green_spectra = greenARRIsensor(:,2);
% comment = 'green sensor for the Alexa sensor thought to be in the ARRIScope - data grabbed from graph';
% fullpathname = ieSaveSpectralFile(green_wave, green_spectra,comment);
% greenSensordata = ieReadSpectra(fullpathname,[380:4:900]);
% 
% cd '/Users/joyce/Google Drive/Projects/ARRIScope/ARRI Documentation/CMOS';
% load('CMOS_QE.mat'); cmos_wave = CMOS_QE(:,1); cmos_spectra = CMOS_QE(:,2)/max(CMOS_QE(:,2));
% comment = 'Typical quantum efficiency of a CMOS sensor';
% fullpathname = ieSaveSpectralFile(cmos_wave, cmos_spectra,comment);
% cmosSensordata = ieReadSpectra(fullpathname,[380:4:900]);
% 
% % read in the lights and save as spectral files 
% cd '/Users/joyce/Google Drive/Projects/ARRIScope/Multispectral Imaging Study/CalibrationMeasurments/OriginalData/Light SpectroRadiometer Measurements/20190410'
% 
% load('violet_1.mat'); violetLight_wave = result(1,:)'; violetLight_spectra = result(2,:)';
% comment = 'Spectra of the violet light in the ARRI light source';
% fullpathname = ieSaveSpectralFile(violetLight_wave, violetLight_spectra,comment);
% violetLightdata = ieReadSpectra(fullpathname,[380:4:900]);
% 
% load('blue_1.mat'); blueLight_wave = result(1,:)'; blueLight_spectra = result(2,:)';
% comment = 'Spectra of the blue light in the ARRI light source';
% fullpathname = ieSaveSpectralFile(blueLight_wave, blueLight_spectra,comment);
% blueLightdata = ieReadSpectra(fullpathname,[380:4:900]);
% 
% load('green_1.mat'); greenLight_wave = result(1,:)'; greenLight_spectra = result(2,:)';
% comment = 'Spectra of the green light in the ARRI light source';
% fullpathname = ieSaveSpectralFile(greenLight_wave, greenLight_spectra,comment);
% greenLightdata = ieReadSpectra(fullpathname,[380:4:900]);
% 
% load('red_1.mat'); redLight_wave = result(1,:)'; redLight_spectra = result(2,:)';
% comment = 'Spectra of the red light in the ARRI light source';
% fullpathname = ieSaveSpectralFile(redLight_wave, redLight_spectra,comment);
% redLightdata = ieReadSpectra(fullpathname,[380:4:900]);
%
% load('white_1.mat'); whiteLight_wave = result(1,:)'; whiteLight_spectra = result(2,:)';
% comment = 'Spectra of the white light in the Sony light source';
% fullpathname = ieSaveSpectralFile(whiteLight_wave, whiteLight_spectra,comment);
% whiteLightdata = ieReadSpectra(fullpathname,[380:4:900]);
% 
% load('IR_1.mat'); IRLight_wave = result(1,:)'; IRLight_spectra = result(2,:)';
% figure; plot(IRLight_wave, IRLight_spectra);
% comment = 'Spectra of the IR light in the ARRI light source';
% fullpathname = ieSaveSpectralFile(IRLight_wave, IRLight_spectra,comment);
% IRLightdata = ieReadSpectra(fullpathname,[380:4:900]);

% load('IR_1.mat'); IRLight_wave = result(1,:)'; IRLight_spectra = result(2,:)';
% figure; plot(IRLight_wave, IRLight_spectra);
% comment = 'Spectra of the IR light in the ARRI light source';
% fullpathname = ieSaveSpectralFile(IRLight_wave, IRLight_spectra,comment);
% IRLightdata = ieReadSpectra(fullpathname,[380:4:900]);

% load('arri_white_1.mat'); arriWhite_wave = result(1,:)'; arriWhite_spectra = result(2,:)';
% figure; plot(arriWhite_wave, arriWhite_spectra);
% comment = 'Spectra of the ARRI white light';
% fullpathname = ieSaveSpectralFile(arriWhite_wave, arriWhite_spectra,comment);
% arriWhiteLightdata = ieReadSpectra(fullpathname,[380:4:900]);

%% Read in the spectral data files we need to calculate the channels 
cd '/Users/joyce/Google Drive/Projects/ARRIScope/ARRI Documentation/ARRISensors';
blueSensordata = ieReadSpectra('blueARRIsensorFile',[380:4:900]);
greenSensordata = ieReadSpectra('greenARRIsensorFile',[380:4:900]);
redSensordata = ieReadSpectra('redARRIsensorFile',[380:4:900]);
cmosSensordata = ieReadSpectra('cmosSensorFile',[380:4:900]);
violetLightdata = ieReadSpectra('violetSonyLight',[380:4:900]);
blueLightdata = ieReadSpectra('blueSonyLight',[380:4:900]);
greenLightdata = ieReadSpectra('greenSonyLight',[380:4:900]);
redLightdata = ieReadSpectra('redSonyLight',[380:4:900]);
IRLightdata = ieReadSpectra('irSonyLight',[380:4:900]);
whiteLightdata = ieReadSpectra('whiteSonyLight',[380:4:900]);
arriWhiteLightdata = ieReadSpectra('whiteARRILight',[380:4:900]);

wave = [380:4:900]
%% Create redNIR, greenNIR and blueNIR



%% Calculate the channels

Channel_1 = blueSensordata .* violetLightdata;
Channel_2 = redSensordata .* violetLightdata;
Channel_3 = greenSensordata .* violetLightdata;
Channel_4 = blueSensordata .* blueLightdata;
Channel_5 = redSensordata .* blueLightdata;
Channel_6 = greenSensordata .* blueLightdata;
Channel_7 = blueSensordata .* greenLightdata;
Channel_8 = redSensordata .* greenLightdata;
Channel_9 = greenSensordata .* greenLightdata;
Channel_10 = blueSensordata .* redLightdata;
Channel_11 = redSensordata .* redLightdata;
Channel_12 = greenSensordata .* redLightdata;
Channel_13 = blueSensordata .* whiteLightdata;
Channel_14 = redSensordata  .* whiteLightdata;
Channel_15 = greenSensordata .* whiteLightdata;
Channel_16 = cmosSensordata .* IRLightdata;
Channel_17 = blueSensordata .* arriWhiteLightdata;
Channel_18 = redSensordata .* arriWhiteLightdata;
Channel_19 = greenSensordata .* arriWhiteLightdata;


Channel_20 = blueSensordata .* arriWhiteLightdata;

%% plot the sensors
for ii = 1:length(wave)
    shiftedWave(ii) = wave(ii) + 35;
end

figure; plot(wave,greenSensordata,'g','LineWidth',2); hold on;
plot(wave,redSensordata,'r','LineWidth',2); plot(wave,blueSensordata,'b','LineWidth',2);
title('ARRI Sensor Spectral Sensitivities (IR channel not shown)');

plot(shiftedWave,cmosSensordata,'k','LineWidth',2); 

%% plot the lights
figure; plot(wave,violetLightdata,'Color',[0.5, 0.0, 0.5],'LineWidth',2); hold on;
plot(wave,blueLightdata,'b','LineWidth',2);
plot(wave,greenLightdata,'g','LineWidth',2);
plot(wave,redLightdata,'r','LineWidth',2);
plot(wave,whiteLightdata,'k:','LineWidth',2);
plot(wave,IRLightdata,'k','LineWidth',2);
title('Spectral power in the Sony lights');

%% Plot the spectral channels created by the dot product of the sensors and light spectra
% with r for red sensor, g for green sensor and b for blue sensor, for each of the different lights
figure; 
plot(wave,Channel_1,'b','LineWidth',2); hold on; % blueSensordata .* violetLightdata;
plot(wave,Channel_2,'r','LineWidth',2); % redSensordata .* violetLightdata;
plot(wave,Channel_3,'g','LineWidth',2); % greenSensordata .* violetLightdata;
plot(wave,Channel_4,'b','LineWidth',2); % blueSensordata .* blueLightdata;
plot(wave,Channel_5,'r','LineWidth',2); % redSensordata .* blueLightdata;
plot(wave,Channel_6,'g','LineWidth',2); % greenSensordata .* blueLightdata;
plot(wave,Channel_7,'b','LineWidth',2); % blueSensordata .* greenLightdata;
plot(wave,Channel_8,'r','LineWidth',2); % redSensordata .* greenLightdata;
plot(wave,Channel_9,'g','LineWidth',2); % greenSensordata .* greenLightdata;
plot(wave,Channel_10,'b','LineWidth',2);% blueSensordata .* redLightdata;
plot(wave,Channel_11,'r','LineWidth',2);% redSensordata .* redLightdata;
plot(wave,Channel_12,'g','LineWidth',2);% greenSensordata .* redLightdata;
plot(wave,Channel_13,'b:','LineWidth',2);% blueSensordata .* whiteLightdata;
plot(wave,Channel_14,'r:','LineWidth',2);% redSensordata  .* whiteLightdata;
plot(wave,Channel_15,'g:','LineWidth',2);% greenSensordata .* whiteLightdata;
plot(wave,Channel_16,'k','LineWidth',2); % cmosSensordata .* IRLightdata;
title('Spectral channels (sensor QE .* light spectral)');

%% plot the sensors