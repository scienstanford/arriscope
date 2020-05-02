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
% [t,w] = ieReadSpectra(sFiles{1},wave); plotReflectance(w,t(:,[3,7,8]));

% The number of samples from each of the data sets, respectively
sSamples = 11;    % 

% How many row/col spatial samples in each patch (they are square)
pSize    = 24;           % Patch size
wave     = 400:10:640;   % Whatever is in the reflectance data file
grayFlag = 0;            % Gray strip
sampling = 'no replacement';

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

%%
sensor = sensorCreate;
fov = sceneGet(scene,'fov');
sensor = sensorSetSizeToFOV(sensor,[sceneGet(scene,'hfov'),sceneGet(scene,'vfov')],scene,oi);
sensor = sensorCompute(sensor,oi);

sensorWindow(sensor);

%%
ip = ipCreate;
ip = ipCompute(ip,sensor);
ipWindow(ip);

%%
rPatch = 4;
cPatch = 3;
cp = chartCornerpoints(ip,true);
[rects,mLocs,pSize] = chartRectangles(cp,rPatch,cPatch,0.5);
rectHandles = chartRectsDraw(ip,rects);
delta = 7;
fullData = true;
data = chartPatchData(ip,mLocs,delta,fullData);
delete(rectHandles);

%% Compare the mahalanobis distance

% Each row is a separate 3D observation
X = data{2};
Y = data{3};

% Force symmetry
disp((mean(mahal(X,Y)) + mean(mahal(Y,X)))/2)


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
%{
cornerPoints = chartCornerpoints(scene,true);
rPatch = 7; cPatch = 7; sFactor = 0.5;
[rects,mLocs,pSize] = chartRectangles(cornerPoints,rPatch,cPatch,sFactor)
rectHandles = chartRectsDraw(scene,rects);
data = chartPatchData(scene,mLocs,5);

%}