%% Make a chart with tissue reflectance and calculate contrasts
%
%
%
% See also: sceneCreate, sceneReflectanceChart,
%   sceneAdjustIlluminant, s_sceneReflectanceChartBasisFunctions
%

%%
ieInit

%% Default usage with sceneCreate

scene = sceneCreate('reflectance chart');
sceneWindow(scene);

%% Create your own chart 

% The files containing the reflectances are in ISET format, readable by 
% s = ieReadSpectra(sFiles{1});
sFiles = cell(1,1);
sFiles{1} = which('tissueReflectances.mat');
% [t,w] = ieReadSpectra(sFiles{1},wave); plotReflectance(w,t);

% The number of samples from each of the data sets, respectively
sSamples = 48;    % 

% How many row/col spatial samples in each patch (they are square)
pSize    = 24;           % Patch size
wave     = 400:10:640;   % Whatever is in the reflectance data file
grayFlag = 0;            % No gray strip
sampling = 'replacement';

scene = sceneCreate('reflectance chart',pSize,sSamples,sFiles,wave,grayFlag,sampling);
scene = sceneSet(scene,'name','Pig tissues');
scene = sceneAdjustIlluminant(scene,'D65');

% The chart parameters are attached to the scene object
sceneGet(scene,'chart parameters')

% Show it on the screen
sceneWindow(scene);

%%
oi = oiCreate;
oi = oiCompute(oi,scene);
sensor = sensorCreate;
fov = sceneGet(scene,'fov');
sensor = sensorSetSizeToFOV(sensor,[fov,fov],scene,oi);
sensor = sensorCompute(sensor,oi);

sensorWindow(sensor);

%% Change the illumination from the default illuminant (equal energy) to D65

wave = sceneGet(scene,'wave');  d65 = ieReadSpectra('D65',wave);
sceneD65 = sceneAdjustIlluminant(scene,d65);
sceneD65 = sceneSet(sceneD65,'name','Reflectance Chart D65');
ieAddObject(sceneD65); sceneWindow;

%% Add a gray strip column

grayStrip = 1;
sceneGray = sceneReflectanceChart(sFiles,sSamples,pSize,wave,grayStrip);
sceneGray = sceneSet(sceneGray,'name','Reflectance Chart EE Gray Strip');

ieAddObject(sceneGray); sceneWindow;

%% Store the parameters needed to make exactly the same chart

[sceneOriginal, storedSamples] = sceneReflectanceChart(sFiles,sSamples,pSize);
sceneOriginal = sceneSet(sceneOriginal,'name','Original');
ieAddObject(sceneOriginal); sceneWindow;

sceneReplica = sceneReflectanceChart(sFiles,storedSamples,pSize);
sceneReplica = sceneSet(sceneReplica,'name','Replica');
ieAddObject(sceneReplica); sceneWindow;

%%

