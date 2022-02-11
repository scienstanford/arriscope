%% s_deriveSensors.m
%
% The goal of this script is to find sensor that includes QE in the NIR
% range and an NIR filter such that the multiplication of the NIR filter
% with the sensorQE produces a quantum efficiency that predicts the MCC
% data 
% 
% Background
%   We found that there may be other sensors that predict the RGB values 
%   we captured in our calibration as well as the sensors we estimated in
%   s_sensorEstimation.m
%   We need a sensor that has QE in the NIR range
%   So, we will pick a sensor (say the Sony sensor), scale it such that it
%   has the same gain as the estimated sensors (again, see
%   s_sensorEstimation.m)
%   And then find a NIR blocking filter such that when we apply it to the
%   scaled Sony sensor will produce a sensor with QE that predicts the MCC
%   data

%
%   It appears that the estimated QE is very similar to the QE for the Sony
%   and On Semiconductor sensors
%   So, we use the Sony QE without the NIR blocking filter as the best
%   guess for the ARRI Sensors without the NIR blocking filter, after
%   accounting for the difference in sensor gain
% 
% see ARRIestimatedSensorsNoNIRfilter

cd /users/joyce/GitHub/isetcam/;
addpath(genpath(pwd));
cd /users/joyce/GitHub/arriscope/;
addpath(genpath(pwd));

wave = 400:10:900;

%% 
SonyIMX249SensorFname = fullfile(arriRootPath,'data','sensor','SonyIMX249.mat');
SonyIMX249 = ieReadSpectra(SonyIMX249SensorFname, wave);

ieNewGraphWin;
maxS = max(max(SonyIMX249))
plot(wave,SonyIMX249(:,1)/maxS,'r'); hold on;
plot(wave,SonyIMX249(:,2)/maxS,'g');
plot(wave,SonyIMX249(:,3)/maxS,'b');


ARRIestimatedFname = fullfile(arriRootPath,'data','sensor','ARRIestimatedSensors.mat');
arriQE = ieReadSpectra(ARRIestimatedFname, wave);
arriQEmax = max(max(arriQE))
plot(wave,arriQE(:,1),'r--'); hold on;
plot(wave,arriQE(:,2),'g--'); 
plot(wave,arriQE(:,3),'b--'); 


%% Scale the Sony sensor QE to match the gain in the estimated Sensor, 
% and then use the scaled Sony sensors as a best guess for the spectral QE
% without the NIR blocking filter
ieNewGraphWin;
plot(wave,arriQE(:,1),'r-'); hold on;
plot(wave,arriQE(:,2),'g-'); 
plot(wave,arriQE(:,3),'b-'); 

% 
red = SonyIMX249(:,1)/max(SonyIMX249(:,1)) * max(arriQE(:,1));
green = SonyIMX249(:,2)/max(SonyIMX249(:,2)) * max(arriQE(:,2));
blue = SonyIMX249(:,3)/max(SonyIMX249(:,3)) * max(arriQE(:,3));
plot(wave,red,'r'); hold on;
plot(wave,green,'g');
plot(wave,blue,'b');
% 
% sensor = [red, green, blue];
% comment = 'spectral QE for the SonyM249 scaled to have the same gain as the arriEstimated Sensors, we are using these as a best guess for the ARRI Sensor QE without the NIR blocking filter'
% ieSaveSpectralFile(wave,sensor,comment);

% These plots simply show that the On Semiconductor sensor spectral QE are
% close to the Sony Spectral QE

% red = ieReadSpectra('OnSemiAR0521Red.mat',wave);
% green = ieReadSpectra('OnSemiAR0521Green.mat',wave);
% blue = ieReadSpectra('OnSemiAR0521Blue.mat',wave);
% plot(wave,red/max(red(:))* max(arriQE(:,1)),'r--');
% plot(wave,green/max(green(:))* max(arriQE(:,2)),'g--');
% plot(wave,blue/max(blue(:))* max(arriQE(:,3)),'b--');



%%
% ARRISensorNIRoff.mat is the Sony sensor functions - not estimated
% ARRISensorNIRon.mat is the estimated ARRI sensor functions - based on
% image data captured when the MCC was illuminated with different lights
% and the NIR blocking filter was on.
% Unfortunately, we do not have image data captured when the MCC was illuminated with different lights
% and the NIR blocking filter was off.
% Hence, we do not have estimated ARRI sensors with NIR blocking filter off

Fname = fullfile(arriRootPath,'data','sensor','ARRISensorNIRoff.mat');
arriQE_NIRoff = ieReadSpectra(Fname, wave);

Fname = fullfile(arriRootPath,'data','sensor','ARRISensorNIRon.mat');
arriQE_NIRon = ieReadSpectra(Fname, wave);

ieNewGraphWin;
plot(wave,arriQE_NIRoff(:,1),'r'); hold on;
plot(wave,arriQE_NIRoff(:,2),'g');
plot(wave,arriQE_NIRoff(:,3),'b'); 

plot(wave,arriQE_NIRon(:,1),'r--'); 
plot(wave,arriQE_NIRon(:,2),'g--');
plot(wave,arriQE_NIRon(:,3),'b--'); 

plot(wave,arriQE(:,1),'r'); hold on;
plot(wave,arriQE(:,2),'g'); 
plot(wave,arriQE(:,3),'b'); 

%%

arriQE_NIRoff_r_scaled = ieScale(arriQE_NIRoff(:,1))*max(arriQE(:,1))
plot(wave, arriQE_NIRoff_r_scaled,'r--'); 

arriQE_NIRoff_g_scaled = ieScale(arriQE_NIRoff(:,2))*max(arriQE(:,2))
plot(wave, arriQE_NIRoff_g_scaled,'g--');

arriQE_NIRoff_b_scaled = ieScale(arriQE_NIRoff(:,3))*max(arriQE(:,3))
plot(wave,arriQE_NIRoff_b_scaled,'b--'); 

data = [arriQE_NIRoff_r_scaled,arriQE_NIRoff_g_scaled,arriQE_NIRoff_b_scaled];
comment = "This is the arriQE_NIRoff sensor scaled to have the same gain as the estimated ARRI sensors";
ieSaveSpectralFile(wave,data,comment);


%% TODO - find an NIR filter than maps scaled TLCIQE into ARRIestimatedSensorsNoNIRfilter.mat
% if the scaled TLCI sensors do as well as the estimated ARRI sensors at predicting the MCC data, then
% use the scaled TLCI sensors - since the color crosstalk is less and
% comparable to the scaled Sony QE (i.e.
% ARRIestimatedSensorsNoNIRfilter.mat)
% then, find an NIR filter that when applied to the
% ARRIestimatedSensorsNoNIRfilter.mat we get something close to the scaled
% TLCI sensors 
% Finally, test whether the scaled Sony QE * NIR filer predicts the MCC
% data as well as the estimated ARRI Sensors
TLCISensorFname = fullfile(arriRootPath,'data','sensor','TLCIsensors.mat');
TLCIQE = ieReadSpectra(TLCISensorFname, wave);
ieNewGraphWin;
plot(wave,TLCIQE(:,1)/max(TLCIQE(:,1))* max(arriQE(:,1)),'r--'); hold on
plot(wave,TLCIQE(:,2)/max(TLCIQE(:,2))* max(arriQE(:,2)),'g--');
plot(wave,TLCIQE(:,3)/max(TLCIQE(:,3))* max(arriQE(:,3)),'b--');

arriSensorFname = fullfile(arriRootPath,'data','sensor','ARRIestimatedSensorsNoNIRfilter.mat');
arriQEwithIR = ieReadSpectra(arriSensorFname, wave);
plot(wave,arriQEwithIR(:,1),'r'); 
plot(wave,arriQEwithIR(:,2),'g');
plot(wave,arriQEwithIR(:,3),'b');


%%
ieNewGraphWin;
plot(wave,TLCIQE(:,1)/max(TLCIQE(:,1))* max(arriQE(:,1)),'r--'); hold on
plot(wave,TLCIQE(:,2)/max(TLCIQE(:,2))* max(arriQE(:,2)),'g--');
plot(wave,TLCIQE(:,3)/max(TLCIQE(:,3))* max(arriQE(:,3)),'b--');
plot(wave,arriQE(:,1),'r'); 
plot(wave,arriQE(:,2),'g');
plot(wave,arriQE(:,3),'b');