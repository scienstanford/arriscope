%% s_arriCreate.m
%
% Wisotzky et al 2019 published spectral sensitivities of the red, green
% and blue sensors. We used grabit to get the data and create a sensor
% called arriSensorNIRon.mat for the ARRI Sensor with NIR blocking filter
% on
%E. L. Wisotzky, J.-C. Rosenthal, P. Eisert, A. Hilsmann, F. Schmid, M. Bauer, A. Schneider, F. C. Uecker,
%Interactive and Multimodal-based Augmented Reality for Remote Assistance using a Digital Surgical Microscope,
%IEEE VR Workshop on Applied VR for Enhanced Healthcare (AVEH), Osaka, Japan, 2019.

%% Read in the TLCI sensor
% The European Broadcast Union (EBU) created a "Standard Camera Model" as part of their TLCI-2012 (Television Lighting Consistency Index)
% see https://www.ibc.org/download?ac=3920
%%
ieInit % clear all variables
% 
% read the grabit data 
chdir(fullfile(arriRootPath,'data','sensor')) 
wave = 380:1:700;
load('grabit/arriSensorTLCI-2012' ,'blueARRIsensor');
% Make sure the values are unique
[thisW,ia] = unique(blueARRIsensor(:,1));
thisS = blueARRIsensor(ia,2);
blue = interp1(thisW,thisS,wave,'pchip',0);
blue = ieClip(blue,0,1);
ieNewGraphWin;
plot(wave,blue,'b'); grid on;
hold on;

load('grabit/arriSensorTLCI-2012','greenARRIsensor')
[thisW,ia] = unique(greenARRIsensor(:,1));
thisS = greenARRIsensor(ia,2);
green = interp1(thisW,thisS,wave,'pchip',0);
green = ieClip(green,0,1);
plot(wave,green,'g');

load('grabit/arriSensorTLCI-2012','redARRIsensor')
[thisW,ia] = unique(redARRIsensor(:,1));
thisS = redARRIsensor(ia,2);
red = interp1(thisW,thisS,wave,'pchip',0);
red = ieClip(red,0,1);
plot(wave,red,'r');

%% Save the ARRI sensor with the NIR filter included
%
chdir(fullfile(arriRootPath,'data','sensor')) 
inData.wavelength = wave;
inData.data = [red(:), green(:), blue(:)];
inData.comment = 'Scanned from documentation for the TLCI-2012 model of a Standard Camera.  These have the NIR filter.';
inData.filterNames = {'rArri','gArri','bArri'};
arriSensorFile = fullfile(arriRootPath,'data','sensor','arriSensorNIRon.mat');
ieSaveColorFilter(inData,arriSensorFile)


%% Read the grabit data from the Wisotzky data
% We see that the arriWisotzsky sensor does not predict the RGB values we
% captured for the MCC under different lights.
% chdir(fullfile(arriRootPath,'data','sensor')) 
% wave = 380:1:700;
% 
% load('grabit/arriWisotzsky','BlueARRIsensor')
% % Make sure the values are unique
% [thisW,ia] = unique(BlueARRIsensor(:,1));
% thisS = BlueARRIsensor(ia,2);
% blue = interp1(thisW,thisS,wave,'pchip',0);
% blue = ieClip(blue,0,1);
% ieNewGraphWin;
% plot(wave,blue,'b'); grid on;
% hold on;
% % 
% load('grabit/arriWisotzsky','GreenARRIsensor')
% [thisW,ia] = unique(GreenARRIsensor(:,1));
% thisS = GreenARRIsensor(ia,2);
% green = interp1(thisW,thisS,wave,'pchip',0);
% green = ieClip(green,0,1);
% plot(wave,green,'g');
% % 
% load('grabit/arriWisotzsky','RedARRIsensor')
% [thisW,ia] = unique(RedARRIsensor(:,1));
% thisS = RedARRIsensor(ia,2);
% red = interp1(thisW,thisS,wave,'pchip',0);
% red = ieClip(red,0,1);
% plot(wave,red,'r');

% Save the Wisotsky ARRI sensor with the NIR filter included
% 
% chdir(fullfile(arriRootPath,'data','sensor')) 
% inData.wavelength = wave;
% inData.data = [red(:), green(:), blue(:)];
% inData.comment = 'Scanned from paper by Wistosky Et al 2019 titled Interactive and Multimodal-based Augmented Reality for Remote Assistance using a Digital Surgical Microscope(Figure 5) by JEF.  These have the NIR filter.';
% inData.filterNames = {'rArri','gArri','bArri'};
% arriSensorFile = fullfile(arriRootPath,'data','sensor','WisotskySensorNIRon.mat');
% ieSaveColorFilter(inData,arriSensorFile)



%{
wave = 400:10:700;
channels = ieReadSpectra(arriSensorFile,wave);
ieNewGraphWin; plot(wave,channels);
%}

%% Estimate the ARRI without the NIR filter
%
% We do not have the spectral sensitivities of the red, green and blue
% sensors without the NIR blocking filter.  However, the general shape of
% the spectral sensitivities of the curves published by Wisotsky et l 2019
% look very much like the SONY Exmor IMX224 Color CMOS sensor with gain
% adjustments.
%
%
%   https://www.altairastro.com/Altair-GPCAMV2-IMX224-Colour-Guide-Planetary-Camera.html
%
% We use the spectral curves of the SONY Exmor IMX224 without NIR blocking
% filter as an approximation. The sensor gains may have to be fit to the
% curves published by Wisotsky et al - and we will call the sensor
% arriSensorNIRoff.mat for the arriSensor with NIR off JEF used grabit to
% get the data for the spectral curves for a SONY Exmor IMX224 without NIR
% from the link, above.

% Read the grabit data
wave = 400:1:1000;
load('grabit/SonyExmorIMX224','Blue_AS1224MC')
[thisW,ia] = unique(Blue_AS1224MC(:,1));
thisS = Blue_AS1224MC(ia,2);
blue = interp1(thisW,thisS,wave,'pchip',0);
blue = ieClip(blue,0,1);
ieNewGraphWin; plot(wave,blue);

load('grabit/SonyExmorIMX224','Green_AS1224MC')
[thisW,ia] = unique(Green_AS1224MC(:,1));
thisS = Green_AS1224MC(ia,2);
green = interp1(thisW,thisS,wave,'pchip',0);
green = ieClip(green,0,1);

ieNewGraphWin; plot(wave,green);

load('grabit/SonyExmorIMX224','Red_AS1224MC')
[thisW,ia] = unique(Red_AS1224MC(:,1));
thisS = Red_AS1224MC(ia,2);
red = interp1(thisW,thisS,wave,'pchip',0);
red = ieClip(red,0,1);
ieNewGraphWin; plot(wave,red);

%% Save the ARRI sensor without the NIR filter

chdir(fullfile(arriRootPath,'data','sensor')) 
inData.wavelength = wave;
inData.data = [red(:), green(:), blue(:)];
inData.comment = 'Curves for SONY Exmor IMX224 on the web and scanned by JEF. These data do not have an NIR';
inData.filterNames = {'rArri','gArri','bArri'};
arriSensorFile = fullfile(arriRootPath,'data','sensor','arriSensorNIRoff.mat');
ieSaveColorFilter(inData,arriSensorFile)

%{
wave = 400:10:900;
channels = ieReadSpectra(arriSensorFile,wave);
ieNewGraphWin; plot(wave,channels);
%}
%% END