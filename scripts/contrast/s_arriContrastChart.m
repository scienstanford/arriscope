%% Make a chart with tissue reflectance and calculate contrasts
%
%
%
% See also: sceneCreate, sceneReflectanceChart,
%   sceneAdjustIlluminant, s_sceneReflectanceChartBasisFunctions
%

%%
ieInit

%% lights

Lights = {'whiteARRILight.mat',  'whiteSonyLight.mat','greenSonyLight.mat',...
    'blueSonyLight.mat','redSonyLight.mat','violetSonyLight.mat'};
nLights = numel(Lights);

%% Default scene

sFiles = cell(1,1);
sFiles{1} = which('tissueReflectances.mat');
% [t,w] = ieReadSpectra(sFiles{1},wave); plotReflectance(w,t(:,[3,7,8]));

% The number of samples from each of the data sets, respectively
sSamples{1} = 1:11;    %

% How many row/col spatial samples in each patch (they are square)
pSize    = 24;           % Patch size
wave     = 400:10:640;   % Whatever is in the reflectance data file
grayFlag = 0;            % Gray strip
sampling = 'no replacement';

scene = sceneCreate('reflectance chart',pSize,sSamples,sFiles,wave,grayFlag,sampling);
scene = sceneSet(scene,'name','Pig tissues');

% sceneWindow(scene);

%% Build the oi
oi = oiCreate;
oi = oiCompute(oi,scene);

%% Build the sensor

sensor = sensorCreate;
sensor = sensorSet(sensor,'wave',wave);
fov    = sceneGet(scene,'fov');
sensor = sensorSetSizeToFOV(sensor,[sceneGet(scene,'hfov'),sceneGet(scene,'vfov')],scene,oi);

fullFileName = fullfile(arriRootPath,'data','sensor','ARRIestimatedSensors.mat');
arriQE = ieReadColorFilter(wave,fullFileName);
sensor = sensorSet(sensor,'filter spectra',arriQE);

%%  We will set the parameters

ip = ipCreate;

%%  Get the sensor data from all 6 lights

for ii=1:nLights
    
    % Set the light
    ThisLight = ieReadSpectra(Lights{ii},wave);
    % ieNewGraphWin; plot(wave,ThisLight);
    sceneThisLight = sceneAdjustIlluminant(scene,ThisLight);
    % sceneThisLight = sceneSet(sceneThisLight,'name','Reflectance Chart');
    % sceneWindow(sceneThisLight);
    
    % The chart parameters are attached to the scene object
    % sceneGet(sceneThisLight,'chart parameters')
    % sceneWindow(sceneThisLight);
    oi     = oiCompute(oi,sceneThisLight);
    sensor = sensorCompute(sensor,oi);
    ip     = ipCompute(ip,sensor);
    % ipWindow(ip);
    
    %%
    if ii==1
        rPatch = 4; cPatch = 3;
        cp = chartCornerpoints(ip,true);
        [rects,mLocs,pSize] = chartRectangles(cp,rPatch,cPatch,0.5);
        rectHandles = chartRectsDraw(ip,rects);
        delta = 7; fullData = true;
        data = cell(rPatch*cPatch,1);
        % delete(rectHandles);
    end
    
    % Get the data and assign it
    thisLightData = chartPatchData(ip,mLocs,delta,fullData);
    for pp=1:numel(thisLightData)
        data{pp} = [data{pp},thisLightData{pp}];
    end
    
end

%% Compute the reduced dimension of the sensor data

sensorLight = zeros(numel(wave),3,numel(Lights));
for ii = 1:numel(Lights)
    thisLight = ieReadSpectra(Lights{ii},wave);
    sensorLight(:,:,ii) = diag(thisLight)*arriQE;
end
x = reshape(sensorLight,numel(wave),nLights*3);

% We want the PCA for the channel responses
[u,s,v] = svd(x');
nBasis = 9;
thisBasis = u(:,1:nBasis);

%{
ieNewGraphWin; plot(wave,x);
ieNewGraphWin; plot(cumsum(diag(s))/sum(diag(s)));
ieNewGraphWin; plot(thisBasis);
%}

%% Could loop on the 11 surfaces

mahalMatrix = zeros(11,11);
for ss = 1:11
    X = data{ss}*thisBasis;
    for ii=ss:11
        Y = data{ii}*thisBasis;
        mahalMatrix(ss,ii) = log10(mean(mahal(X,Y)) + mean(mahal(Y,X)))/2;
        mahalMatrix(ii,ss) = mahalMatrix(ss,ii);
    end
end
imagesc(mahalMatrix); colormap(gray);
surf(mahalMatrix); colormap(gray);

%%
% Each row is a separate 3D observation
X = data{1}*thisBasis;
Y = data{3}*thisBasis;
    
% Force symmetry
disp((mean(mahal(X,Y)) + mean(mahal(Y,X)))/2)

%% END