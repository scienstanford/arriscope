% s_arriFindExposureSetting
% 
% find an exposure setting that does not saturate sensor with the ARRI light
% revise this script so that we use the MCC and the data we actually
% collected
% is it possible to find the actual exposure setting?

% for now, I am trying to find an exposure setting that does not saturate
% the sensor, but gets the maximum output for the ARRI light

ieInit

%% Select the number of lights
% note that we do not include the NIR light for two reasons
% First, we did not have the data necessary to estimate the sensors with
% the NIR blocking filter
% Second, we do not have reflectance data for wavelengths > 640 nm 
% Both of these limitations can be corrected in the future
% 
Lights = {'whiteARRILight.mat',  'whiteSonyLight.mat','greenSonyLight.mat',...
    'blueSonyLight.mat','redSonyLight.mat','violetSonyLight.mat'};

% Lights = {'whiteARRILight.mat',  'whiteSonyLight.mat','greenSonyLight.mat',...
%     'blueSonyLight.mat','redSonyLight.mat'};

% Lights = {'whiteARRILight.mat'};

nLights = numel(Lights);

%%  Step One: Create a scene that represents the spectral reflectance of
%   different tissue types

sFiles = cell(1,1);
sFiles{1} = which('tissueReflectances.mat');
% sFiles{1} = which('tissueScaled.mat');
% [t,w, comment] = ieReadSpectra(sFiles{1},wave); plotReflectance(w,t(:,[3,7,8]));

% The number of samples from each of the data sets, respectively
sSamples{1} = repmat(1:11,1,1);    %
% sSamples{1} = repmat(1:11,1,8);  

% How many row/col spatial samples in each patch (they are square)
pSize    = 24;           % Patch size
wave     = 400:10:640;   % Whatever is in the reflectance data file
grayFlag = 0;            % Gray strip
sampling = 'no replacement';

scene = sceneCreate('reflectance chart',pSize,sSamples,sFiles,wave,grayFlag,sampling);
scene = sceneSet(scene,'name','Pig tissues');
chartP = sceneGet(scene,'chart parameters');
rPatch = chartP.rowcol(1); cPatch = chartP.rowcol(2);

% sceneWindow(scene);


%% Step Two: Calculate the predicted RGB data 
% for the surfaces illuminated by the different lights

% Calculate an optical image (see assumptions about the optics in oiCreate;
oi = oiCreate;
oi = oiCompute(oi,scene);

sensor = arriSensorCreate;
fov    = sceneGet(scene,'fov');
sensor = sensorSetSizeToFOV(sensor,[sceneGet(scene,'hfov'),sceneGet(scene,'vfov')],scene,oi);
% Don't know what the exposure time is, pick one that does not saturate the
% pixels for the ARRI light
sensor = sensorSet(sensor,'exp time',0.06);
% Set the light
ThisLight = ieReadSpectra(Lights{1},wave);
% ieNewGraphWin; plot(wave,ThisLight);
sceneThisLight = sceneAdjustIlluminant(scene,ThisLight);
% sceneThisLight = sceneSet(sceneThisLight,'name','Reflectance Chart');
% sceneWindow(sceneThisLight);
oi     = oiCompute(oi,sceneThisLight);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);
ip = ipCreate;
ip = ipCompute(ip,sensor);
ipWindow(ip);
    
 
    

