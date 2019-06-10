%% Converts the sensor data Joyce got into ISET spectral curve format
%
% Joyce found these data on the web at location:
%
% Then she used grabit to sample the values and produce the file
% Arrisensors.
%
% These are for alexa, the sensor that is supposed to be in the Arriscope
% with the NIR.
%
% We hope to figure out what the curves look like when there is no NIR
% filter.
%
% JEF/BW

%%
chdir(fullfile(arriRootPath,'data','sensor'))

load('arriMeasurements','blueARRIsensor')
wave = 380:1:700;
blue = interp1(blueARRIsensor(:,1),blueARRIsensor(:,2),wave);
blue = ieClip(blue,0,1);
ieNewGraphWin;
plot(wave,blue);

load('arriMeasurements','greenARRIsensor')
wave = 380:1:700;
green = interp1(greenARRIsensor(:,1),greenARRIsensor(:,2),wave);
green = ieClip(green,0,1);
ieNewGraphWin;
plot(wave,green);

load('arriMeasurements','redARRIsensor')
wave = 380:1:700;
red = interp1(redARRIsensor(:,1),redARRIsensor(:,2),wave);
red = ieClip(red,0,1);
ieNewGraphWin;
plot(wave,red);

%% Save the ARRI sensor with the NIR filter

inData.wavelength = wave;
inData.data = [red(:), green(:), blue(:)];
inData.comment = 'Scanned from web definition of alexa sensor by JEF.  These have the NIR filter.';
inData.filterNames = {'rArri','gArri','bArri'};
arriSensorFile = fullfile(arriRootPath,'data','sensor','arriSensor.mat');
ieSaveColorFilter(inData,arriSensorFile)

%% END