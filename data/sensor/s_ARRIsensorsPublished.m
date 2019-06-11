%% s_ARRIsensorsPublished.m

% Wisotzky et al 2019 published spectral sensitivities of the red, green
% and blue sensors, so we used grabit to get the data and create a sensor
% called arriSensorNIRon.mat for the ARRI Sensor with NIR blocking filter on

chdir(fullfile(arriRootPath,'data','sensor')) 

load('arriPublishedSensors','BlueARRIsensor')
wave = 380:1:700;
blue = interp1(BlueARRIsensor(:,1),BlueARRIsensor(:,2),wave);
blue = ieClip(blue,0,1);
ieNewGraphWin;
plot(wave,blue);

load('arriPublishedSensors','GreenARRIsensor')
wave = 380:1:700;
green = interp1(GreenARRIsensor(:,1),GreenARRIsensor(:,2),wave);
green = ieClip(green,0,1);
ieNewGraphWin;
plot(wave,green);

load('arriPublishedSensors','RedARRIsensor')
wave = 380:1:700;
red = interp1(RedARRIsensor(:,1),RedARRIsensor(:,2),wave);
red = ieClip(red,0,1);
ieNewGraphWin;
plot(wave,red);

%% Save the ARRI sensor with the NIR filter
chdir(fullfile(arriRootPath,'data','sensor')) 
inData.wavelength = wave;
inData.data = [red(:), green(:), blue(:)];
inData.comment = 'Scanned from paper by Wistosky Et al 2019 titled Interactive and Multimodal-based Augmented Reality for Remote Assistance using a Digital Surgical Microscope(Figure 5) by JEF.  These have the NIR filter.';
inData.filterNames = {'rArri','gArri','bArri'};
arriSensorFile = fullfile(arriRootPath,'data','sensor','arriSensorNIRon.mat');
ieSaveColorFilter(inData,arriSensorFile)

%%
% We do not have the spectral sensitivities of the red, green and blue
% sensors without the NIR blocking filter.  However, the general shape of
% the spectral sensitivities of the curves published by Wisotsky et l 2019
% look very much like the SONY Exmor IMX224 Color CMOS sensor with gain adjustments
% So we will use the spectral curves of the SONY Exmor IMX224 without NIR
% blocking filter as a good approximation, and just apply a gain to do the
% fit to the curves published by Wisotsky et al - and we will call the
% sensor arriSensorNIRoff.mat for the arriSensor with NIR off
% JEF used grabit to get the data for the spectral curves for a SONY Exmor
% IMX224 without NIR from
%   https://www.altairastro.com/Altair-GPCAMV2-IMX224-Colour-Guide-Planetary-Camera.html

load('SonyExmorIMX224','Blue_AS1224MC')
wave = 400:1:1000;
blue = interp1(Blue_AS1224MC(:,1),Blue_AS1224MC(:,2),wave);
blue = ieClip(blue,0,1);
ieNewGraphWin;
plot(wave,blue);

load('SonyExmorIMX224','Green_AS1224MC')
wave = 400:1:1000;
green = interp1(Green_AS1224MC(:,1),Green_AS1224MC(:,2),wave);
green = ieClip(green,0,1);
ieNewGraphWin;
plot(wave,green);

load('SonyExmorIMX224','Red_AS1224MC')
wave = 400:1:1000;
red = interp1(Red_AS1224MC(:,1),Red_AS1224MC(:,2),wave);
red = ieClip(red,0,1);
ieNewGraphWin;
plot(wave,red);

%% Save the ARRI sensor with the NIR filter
chdir(fullfile(arriRootPath,'data','sensor')) 
inData.wavelength = wave;
inData.data = [red(:), green(:), blue(:)];
inData.comment = 'Curves for SONY Exmor IMX224 on the web and scanned by JEF. These data do not have an NIR';
inData.filterNames = {'rArri','gArri','bArri'};
arriSensorFile = fullfile(arriRootPath,'data','sensor','arriSensorNIRoff.mat');
ieSaveColorFilter(inData,arriSensorFile)