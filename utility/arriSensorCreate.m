function sensor = arriSensorCreate(varargin)
% Approximating a model for ARRI Alexa camera
% need more information from ArrI
%
% Syntax
%   sensor = arriSensorCreate
%
% Description:
%   The camera uses the Sony sensor parameters but we need to replace with data from ARRI.  We estimated the
%   spectral QE of the color channels using radiance measurements from the
%   MCC chart in the script s_arriSensorEstimation.  The estimate
%   includes the blocking filters and the sensor.
%
% Inputs
%  N/A
%
% Output
%   sensor - Sensor with the estimated QE as above
%
% JEF/BAW (modeled after oeCreate.m)
%

% Examples
%{
sensor = arriSensorCreate();
sensorPlot(sensor,'spectral qe');
%}
%{
% Simple test
scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
sensor = arriSensorCreate;
sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'));
sensor = sensorSet(sensor,'exp time',0.05);
sensor = sensorCompute(sensor,oi);
sensorImageWindow(sensor);
%}

%%  Set parameters for the ARRI Sensor pixel
% some of the parameters come from our calibration of the JedEye camera,
% but the CFA pattern is different
p = inputParser;
varargin = ieParamFormat(varargin);
p.addParameter('wave',400:10:640,@isvector); % read this in as a parameter
p.parse(varargin{:});

% Other parameters in the future.  For now, just the blocking filter
% parameters
wave     = p.Results.wave;

%%
sensor = sensorCreate('bayer (grbg)');
sensor = sensorSet(sensor,'wave',wave);
sensor = sensorSet(sensor,'Name','ARRI-Camera');

% We set the sensor properties using *sensorSet* and *sensorGet*
% routines.
%
% Just as the optical irradiance gives a special status to the
% optics, the sensor gives a special status to the pixel.  In
% this section we define the key pixel and sensor properties, and
% we then put the sensor and pixel back together.

% Here are some of the key pixel properties
%   voltage swing was computed using digital value conversion factor
%   voltage swing = 2^12 (dv) * 0.2224 (mV/dv)
%   well capacity is assumed based on well capacity of similar sensors
%
% Let's get these data from ARRI
voltageSwing   = 0.911;  % Volts (not sure what this should be either)?
wellCapacity   = 100000;   % Electrons % not sure what this should be but > 11000
% max number of pohtons in 1 micron pixel 30 msec exposure for the ARRI light was calculated
% to be 10^6
% Perhaps set conversion gain to 1 and calculate well capacity
% see https://clarkvision.com/imagedetail/digital.sensor.performance.summary/#full_well
conversiongain = voltageSwing/wellCapacity;   
fillfactor     = 0.99;       % assumed - we have back-illuminated pixel
pixelSize      = 8.25*1e-6;   % Meters 8.25 pixel for Alexa sensor
% darkvoltage    = 1.5*1e-4;   % Volts/sec
darkvoltage    = 0;   % Volts/sec
% readnoise      = 1.3884 *1e-3;    % Volts
readnoise      = 0;    % Volts
% setting properties corresponding to left sensor

% We set the pixel properties here.  
sensor = sensorSet(sensor,'pixel size same fill factor',[pixelSize pixelSize]);   
sensor = sensorSet(sensor,'pixel conversion gain', conversiongain);        
sensor = sensorSet(sensor,'pixel voltage swing',voltageSwing);                                             
sensor = sensorSet(sensor,'pixel dark voltage',darkvoltage) ;               
sensor = sensorSet(sensor,'pixel read noise volts',readnoise);  

%%  Set sensor properties

%  Now we set some general sensor properties
% dsnu =  0.2536*1e-3;      % Volts (dark signal non-uniformity)
% prnu = 2.2897;            % Percent (ranging between 0 and 100) photodetector response non-uniformity
dsnu =  0;      % Volts (dark signal non-uniformity)
prnu = 0;            % Percent (ranging between 0 and 100) photodetector response non-uniformity
analogGain   = 1;         % Used to adjust ISO speed
analogOffset = 0;         % Used to account for sensor black level

% This is the max, and more than we really need in any simulation
%{
rows = 1552;     % number of pixels in a row % number of rows?
cols = 2064;     % number of pixels in a column % number of columns?
%}
% how to set the row and col dimensions?


% sensor = sensorSet(sensor,'auto exposure',true);
% N.B. You could set the exposure duration explicitly using
sensor = sensorSet(sensor,'exp time',0.030);

% Some other 
% sensor = sensorSet(sensor,'rows',rows);
% sensor = sensorSet(sensor,'cols',cols);
sensor = sensorSet(sensor,'dsnu level',dsnu);  
sensor = sensorSet(sensor,'prnu level',prnu); 
sensor = sensorSet(sensor,'analog Gain',analogGain);     
sensor = sensorSet(sensor,'analog Offset',analogOffset);   

% Adjust the pixel fill factor
sensor = pixelCenterFillPD(sensor,fillfactor);

%% Color filters

% It is also possible to replace the spectral quantum efficiency curves of
% the sensor with those from a calibrated camera.  We include the
% calibration data from a very nice Nikon D100 camera as part of ISET.
% To load those data we first determine the wavelength samples for this sensor.
wave = sensorGet(sensor,'wave');

% Then we load the calibration data and attach them to the sensor structure
% fullFileName = fullfile(isetRootPath,'data','sensor','colorfilters','NikonD100.mat');
% fullFileName = fullfile(jedeyeRootPath,'data','Sensors','SensorSpectralCurves4LeftCamera.mat');
%
fullFileName = which('TLCIsensors.mat');
arriQE = ieReadColorFilter(wave,fullFileName);
sensor = sensorSet(sensor,'filter spectra',arriQE);  
% [data,filterNames] = ieReadColorFilter(wave,fullFileName); 
% 
% sensor = sensorSet(sensor,'filter spectra',data);
% sensor = sensorSet(sensor,'filter names',filterNames);

% sensorPlot(sensor,'color filters')

end

