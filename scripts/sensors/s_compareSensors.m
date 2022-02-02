%% s_compareSensors.m
%
% 


cd /users/joyce/GitHub/arriscope/;
addpath(genpath(pwd));

wave = 400:10:900;

 
SonyIMX249SensorFname = fullfile(arriRootPath,'data','sensor','SonyIMX249.mat');
SonyIMX249 = ieReadSpectra(SonyIMX249SensorFname, wave);

ieNewGraphWin;
maxS = max(max(SonyIMX249))
plot(wave,SonyIMX249(:,1)/maxS,'r'); hold on;
plot(wave,SonyIMX249(:,2)/maxS,'g');
plot(wave,SonyIMX249(:,3)/maxS,'b');

arriQEmax = max(max(arriQE))
plot(wave,arriQE(:,1),'r--'); hold on;
plot(wave,arriQE(:,2),'g--'); 
plot(wave,arriQE(:,3),'b--'); 

%%
% not sure where I got the NIR sensor estimates from
% but they are close to the estimated ARRI sensors, except for a difference
% in gain
% so we scale the arriQE_NIRoff so that the max RGB is the same as the max
% RGB in the estimated ARRI sensors
%

arriSensorFname = fullfile(arriRootPath,'data','sensor','ARRIestimatedSensors.mat');
arriQE = ieReadSpectra(arriSensorFname, wave);

arriSensorFname = fullfile(arriRootPath,'data','sensor','ARRISensorNIRoff.mat');
arriQE_NIRoff = ieReadSpectra(arriSensorFname, wave);

arriSensorFname = fullfile(arriRootPath,'data','sensor','ARRISensorNIRon.mat');
arriQE_NIRon = ieReadSpectra(arriSensorFname, wave);

ieNewGraphWin;
plot(wave,arriQE_NIRoff(:,1),'r'); hold on;
plot(wave,arriQE_NIRoff(:,2),'g');
plot(wave,arriQE_NIRoff(:,3),'b'); 

plot(wave,arriQE_NIRon(:,1),'r--'); 
plot(wave,arriQE_NIRon(:,2),'g--');
plot(wave,arriQE_NIRon(:,3),'b--'); 

ieNewGraphWin;
plot(wave,arriQE(:,1),'r'); hold on;
plot(wave,arriQE(:,2),'g'); 
plot(wave,arriQE(:,3),'b'); 

arriQE_NIRoff_r_scaled = ieScale(arriQE_NIRoff(:,1))*max(arriQE(:,1))
plot(wave, arriQE_NIRoff_r_scaled,'r--'); 

arriQE_NIRoff_g_scaled = ieScale(arriQE_NIRoff(:,2))*max(arriQE(:,2))
plot(wave, arriQE_NIRoff_g_scaled,'g--');

arriQE_NIRoff_b_scaled = ieScale(arriQE_NIRoff(:,3))*max(arriQE(:,3))
plot(wave,arriQE_NIRoff_b_scaled,'b--'); 

data = [arriQE_NIRoff_r_scaled,arriQE_NIRoff_g_scaled,arriQE_NIRoff_b_scaled];
comment = "This is the arriQE_NIRoff sensor scaled to have the same gain as the estimated ARRI sensors";
ieSaveSpectralFile(wave,data,comment);


%% compare estimated ARRI sensors with ARRIQE_NIRon (not sure where we got these data)
% notice that they are similar with the exception of gain and crosstalk
% (see bumps)
ieNewGraphWin;
plot(wave,arriQE(:,1),'r'); hold on;
plot(wave,arriQE(:,2),'g'); 
plot(wave,arriQE(:,3),'b'); 

arriQE_NIRon_r_scaled = ieScale(arriQE_NIRon(:,1))*max(arriQE(:,1))
plot(wave, arriQE_NIRon_r_scaled,'r--'); 

arriQE_NIRon_g_scaled = ieScale(arriQE_NIRon(:,2))*max(arriQE(:,2))
plot(wave, arriQE_NIRon_g_scaled,'g--');

arriQE_NIRon_b_scaled = ieScale(arriQE_NIRon(:,3))*max(arriQE(:,3))
plot(wave,arriQE_NIRon_b_scaled,'b--'); 

data = [arriQE_NIRon_r_scaled,arriQE_NIRon_g_scaled,arriQE_NIRon_b_scaled];
comment = "This is the arriQE_NIRon sensor scaled to have the same gain as the estimated ARRI sensors";
ieSaveSpectralFile(wave,data,comment);

%%
TLCISensorFname = fullfile(arriRootPath,'data','sensor','TLCIsensors.mat');
TLCIQE = ieReadSpectra(TLCISensorFname, wave);

plot(wave,TLCIQE(:,1),'r--'); 
plot(wave,TLCIQE(:,2),'g--');
plot(wave,TLCIQE(:,3),'b--'); 

ieNewGraphWin;
plot(wave,TLCIQE(:,1),'r--');  hold on;
plot(wave,TLCIQE(:,2),'g--');
plot(wave,TLCIQE(:,3),'b--'); 
plot(wave,arriQE_NIRoff(:,1),'r');
plot(wave,arriQE_NIRoff(:,2),'g');
plot(wave,arriQE_NIRoff(:,3),'b');


