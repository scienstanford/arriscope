%% s_arriContrastChartResponse.m
% Purpose:
%   Quantify the discriminability between two tissue types based on the
%   difference in camera RGB values captured when illuminated by N lights
%
% Method:
%   Step One: Create a scene that represents the spectral reflectance of
%   different tissue types.  To do this, we create a spectral reflectance
%   chart that have patches (areas) of pixels, each patch with a different
%   reflectance for each of the 11 tissue types. We add a 12th patch just
%   to complete the chart, but we don't use this in our analysis
%   Note that we could (and have in the past) represented the tissues in
%   multiple patches. 
%   Illuminate the patches with a light that is uniformly or non-uniformly
%   distributed over the reflectance chart
%
%   Step Two: Calculate the predicted RGB data for the surfaces illuminated
%   by the different lights
%   Do this for a case in which exposure duration is fixed (set by the
%   maximum exposure that does not saturate the sensor with highest SNR)
%   Also do this for the case in which auto-exposure is set - 
%   
%   Step Three: Calculate the Mahalanobis distance between pairs of
%   different tissue types for the conditions we care about. 
%   While we could calculate the Euclidean distance between pairs of
%   tissues represented by N different sensor data values ... we choose to
%   use the Mahalanobis distance because it takes into account covariance
%   We first need to de-correlate the sensor data values (see explanation
%   in the script)
%   

%   Repeat and rinse
%       Calculate the Mahalonobis distance for the conditions we care about
%           6 lights
%           1 light
%           uniform, non-uniform, tissue reflectances with same mean
%           reflectance
%
% See also: sceneCreate, sceneReflectanceChart,
%   sceneAdjustIlluminant, s_sceneReflectanceChartBasisFunctions
%
% JEF/BAW
%%
ieInit % clear all variables
wave     = 400:10:640;   % Whatever is in the reflectance data file

%% Select the number of lights
% note that we do not include the NIR light for two reasons
% First, we did not have the data necessary to estimate the sensors with
% the NIR blocking filter
% Second, we do not have reflectance data for wavelengths > 640 nm 
% Both of these limitations can be corrected in the future
% 
Lights = {'whiteARRILight.mat',  'whiteSonyLight.mat','greenSonyLight.mat',...
    'blueSonyLight.mat','redSonyLight.mat','violetSonyLight.mat'};
ieNewGraphWin; 
for ii=1:numel(Lights)
    ThisLight = ieReadSpectra(Lights{ii},wave);
    plot(wave,ThisLight); hold on;
end

% Lights = {'whiteARRILight.mat',  'whiteSonyLight.mat','greenSonyLight.mat',...
%     'blueSonyLight.mat','redSonyLight.mat'};

% Lights = {'whiteARRILight.mat'};

nLights = numel(Lights);

%%  Step One: Create a scene that represents the spectral reflectance of
%   different tissue types

sFiles = cell(1,1);
sFiles{1} = which('tissueReflectances.mat');
% sFiles{1} = which('tissueScaled.mat'); % scaled such that tissue have same mean reflectance
% [t,w, comment] = ieReadSpectra(sFiles{1},wave); plotReflectance(w,t(:,[3,7,8]));
% [t,w, comment] = ieReadSpectra(sFiles{1},wave); ieNewGraphWin; plot(w,t,'linewidth',2);

% The number of samples from each of the data sets, respectively
sSamples{1} = repmat(1:11,1,1);    %
% sSamples{1} = repmat(1:11,1,8);  

% How many row/col spatial samples in each patch (they are square)
pSize    = 24;           % Patch size
grayFlag = 0;            % Gray strip
sampling = 'no replacement';

scene = sceneCreate('reflectance chart',pSize,sSamples,sFiles,wave,grayFlag,sampling);
scene = sceneSet(scene,'name','Pig tissues');
chartP = sceneGet(scene,'chart parameters');
rPatch = chartP.rowcol(1); cPatch = chartP.rowcol(2);

% sceneWindow(scene);

%% Illuminant pattern

% Inhomogeneous

%{
[X,Y] = meshgrid(-8:8,-10:10);
pattern = sqrt(X.^2 + Y.^2) + 1;
%}
%{
%%  This is an example of nonuniform illumination of one image

fname = fullfile(icalRootPath,'local','Green_arri','green_CameraImage_10.ari');
img = arriRead(fname,'image','left');
% ieNewGraphWin;
% imagescRGB(img);

pattern = img(:,:,2);
pattern = imresize(pattern,0.25);
% ieNewGraphWin; imagesc(pattern); colormap(gray);
%}

% Homogeneous lighting
pattern = [];


%% Step Two: Calculate the predicted RGB data 
% for the surfaces illuminated by the different lights

% Calculate an optical image (see assumptions about the optics in oiCreate;
oi = oiCreate;
oi = oiCompute(oi,scene);
oiWindow(oi);
%% Build the sensor 

sensor = arriSensorCreate;
fov    = sceneGet(scene,'fov');
sensor = sensorSetSizeToFOV(sensor,[sceneGet(scene,'hfov'),sceneGet(scene,'vfov')],oi);
% For the white light the sensor is saturated at 3 ms 
% Selected this exposure duration so that the RGB image captured under the ARRI White light would not saturate
    % sensor = sensorSet(sensor,'exp time',0.003); 
    % sensor = sensorSet(sensor,'exp time',0.035); % Exposure for the scaled tissue
    % sensor = sensorSet(sensor,'exp time',0.0003); % Exposure for non-uniform illumination
% Set auto-exposure
sensor = sensorSet(sensor,'auto exposure',1);
%{
 sensor = sensorCreate;
 sensor = sensorSet(sensor,'wave',wave);
 fov    = sceneGet(scene,'fov');
 sensor = sensorSetSizeToFOV(sensor,[sceneGet(scene,'hfov'),sceneGet(scene,'vfov')],scene,oi); % guessing at the exposure duration because we do not know it - not in the ARRI header

% need to ask ARRI for confirmation
% sensor = sensorSet(sensor,'exp time',0.030); 
% 
 fullFileName = fullfile(arriRootPath,'data','sensor','TLCIsensors.mat');
 arriQE = ieReadColorFilter(wave,fullFileName);
 sensor = sensorSet(sensor,'filter spectra',arriQE); 
%}

%  Image Processing parameters
ip = ipCreate;


%%  Get the sensor data from all nlights

% Needed so that illuminant levels are not changed by sceneAdjustIlluminant
preserveMean = false;

for ii=1:nLights

    % Set the light
    ThisLight = ieReadSpectra(Lights{ii},wave);
    % ieNewGraphWin; plot(wave,ThisLight);
    sceneThisLight = sceneAdjustIlluminant(scene,ThisLight,preserveMean);
    % sceneThisLight = sceneSet(sceneThisLight,'name','Reflectance Chart');
    % sceneWindow(sceneThisLight);
    
    % Put a spatial pattern on the illuminant.
    sceneThisLight = sceneIlluminantSS(sceneThisLight,pattern);
    
    % The chart parameters are attached to the scene object
    % sceneGet(sceneThisLight,'chart parameters')
    % sceneWindow(sceneThisLight);
    fprintf('Light %d, %s, exp time %f\n',ii,Lights{ii}, autoExposure(oi,sensor));
    oi     = oiCompute(oi,sceneThisLight);
    sensor = sensorCompute(sensor,oi);
    sensorWindow(sensor); % plot any horizontal line in units of electrons
    % and see that the sensor does not saturate
    ip     = ipCompute(ip,sensor);
    %%
    ipWindow(ip); % why does this have NaN?
    %%

    if ii==1
        cp = chartCornerpoints(ip,true);
        [rects,mLocs,pSize] = chartRectangles(cp,rPatch,cPatch,0.5);
        ipWindow(ip);
        rectHandles = chartRectsDraw(ip,rects);
        fullData = true;
        data = cell(rPatch*cPatch,1);
        % delete(rectHandles);
    end
    
    % Get the data and assign it
    thisLightData = chartPatchData(ip,mLocs,(pSize(1)/2),fullData);
    for pp=1:numel(thisLightData)
        data{pp} = [data{pp},thisLightData{pp}];
    end
    
end

%% Step Three: Calculate the Mahalanobis distance between tissues 

%  We could calculate the Euclidean distance, but the Mahalanobis distance
%  is better because it takes data covariance into
%  account when calculating the distance between two points

%  The sensor data values are not independent of one another.  
%   We use the SVD to both decorrelate the sensor data and also to only use
%   sensor data that accounts for most of the variance.
%   [U, S, V] = svd(data);
%   U is referred to as the basis set or linear model or set of principal
%   components.  The columns of U contains the principal components
%   The data for each tissue can then be re-expressed as data*U (de-correlated)
%   We can use fewer basis (let's say 3), then the tissue data can be
%   re-expressed as data*U(:,1:3) 

% we take the first 11 patches which represent the 11 tissue types
% There are multiple pixels per tissue type which is why sensorData is N x 18 
% where N/11 is the number of pixels per tissue type and 18 are the different sensor responses
sensorData = [];
for ii=1:11
    sensorData = [sensorData; data{ii}];
end

[U, S, V] = svd(sensorData','econ');
S = diag(S);
% plot(S)

percentV = cumsum(S.^2)/sum(S.^2)* 100;
ieNewGraphWin; plot(percentV,'k', 'linewidth', 3) ; 
xlabel('Number of principal components'); ylabel('Percent Variance Accounted For');

%% Plot the weights/channel(principal component * the spectral responsivity/channel
fullFileName = which('TLCIsensors.mat');
arriQE = ieReadColorFilter(wave,fullFileName);
sensorLight = zeros(numel(wave),3,numel(Lights));
for ii = 1:numel(Lights)
    thisLight = ieReadSpectra(Lights{ii},wave);
    sensorLight(:,:,ii) = diag(thisLight)*arriQE;
end
SpectralChannels = reshape(sensorLight,numel(wave),nLights*3);
ieNewGraphWin;
plot(wave,SpectralChannels);

%%
ieNewGraphWin;  
plot(wave,SpectralChannels*U(:,1:3)*diag([-1 -1 -1]),'linewidth',3); xaxisLine;
% plot(wave,SpectralChannels*U(:,1:3)*diag([1 1 1]),'linewidth',3); xaxisLine;
% multiplied by -1 so that the 1st principal component is positive
% The first principal component represents the effect of the mean tissue reflectance 
% The second principal component is a B+G/R opponent channel where R are
% wavelengths> 550 nm 
% The third principal component is an R/B+G opponent channel where R are wavelengths >600 nm
% plot(wave,-1*SpectralChannels*U(:,1:3)); xaxisLine;


%%
% U are the weights on the spectral channels
% 3 principal components account for 99.97% of the variance
% The weights on the first 3 principal components 
nBasis = 3;
U(:,1:nBasis); % this shows the weights on each of the 18 sensors for the first 3 principal components
% Notice that some of the sensors are given a weight of 0, even when auto-exposure is on,  indicating that
% no matter what the exposure duration, all the tissues have the same (low) number and hence do not contribute to
% tissue discriminability - i.e. this sensor provides no information about the different tissue types
% The sensors that produce no useful information about the tissue types are:
%       R sensor + 525 nm ("green") light
%       R sensor + 445 ("blue") light
%       G sensor + 445 ("blue") light
%       G sensors + 638 ("red")
%       R sensor + 404 ("uv") light
% It is interesting to note that the G sensor + uv light could provide
% information ... this makes sense when you look at the G sensor

thisBasis = U(:,1:3);
% ieNewGraphWin; surf(abs(thisBasis));colormap(gray);
imagesc(abs(thisBasis)); colormap(gray); set(gca,'ColorScale','log'); axis image; colorbar;
ChannelName = {'R ARRI white','G ARRI white','B ARRI white', ...
    'R Sony white', 'G Sony white', 'B Sony white', ...
    'R Sony 525nm', 'G Sony 525nm', 'B Sony 525nm', ...
    'R Sony 445nm', 'G Sony 445nm', 'B Sony 445nm', ...
    'R Sony 638nm', 'G Sony 638nm', 'B Sony 638nm', ...
    'R Sony 405nm', 'G Sony 405nm', 'B Sony 405nm'};

t = array2table(thisBasis);
f=figure;
uit = uitable(f,'Data',table2cell(t));
uit.RowName = ChannelName;
title('PC 6 lights spatially uniform');

%% 
% We use the svd to re-express the pixel values as a linear combination of the
% 18 original pixel values - mapping correlated original pixel values into
% new pixel values that are not correlated
% original pixel values = data
% new pixel values = data*linBasis

%% Here we fill up the matrix to represent pairwise comparisons of all the tissues
% Could loop on the 11 surfaces
% Note that if we set nBases to 1, the distance between two different
% tissue types is >0, i.e. we can discriminate on the basis of mean
% reflectance
% Nonetheless, increasing the bases does increase the distance

nBases = 3;
linBasis = U(:,1:nBases);
mahalMatrix = zeros(11,11);
for ss = 1:11
    % This calculates the new pixel values (weights) in the response-based SVD representation.
    % We put the new pixel values in the columns of the X matrix.
    X = (data{ss}*linBasis);
    for tt=(ss+1):11
        % This is the same calculation.  We put the new pixel values for
        % this one in the columns of Y.
        Y = (data{tt}*linBasis);
        
        % Calculate the symmetric log10 mahalanobis value.
        mahalMatrix(ss,tt) = log10(mean(mahal(X,Y)) + mean(mahal(Y,X))/2);
        mahalMatrix(tt,ss) = mahalMatrix(ss,tt);
    end
end
mahalMatrix

%%
ieNewGraphWin;
imagesc(mahalMatrix); colormap(gray);
% surf(mahalMatrix); colormap(gray);

% fig = uifigure;
% uit=uitable(fig,'Data',mahalMatrix);

TissueType = {'Cancellous Bone','Cortical Bone','Fat','Hard Bone','Mucosa','Muscle','Nerve','Nerve','Salivary Gland','Skin','Soft Bone'};
% fig = uifigure;
% uit = uitable(fig,'Data',mahalMatrix,'ColumnName',TissueType,'RowName',TissueType);
t = array2table(mahalMatrix)
f=figure;
uit = uitable(f,'Data',table2cell(t));
uit.ColumnName = {TissueType{:}};
uit.RowName = TissueType;
% saveas(f,'MahalMatrix_AllLights_NonUniformLighting.png');

%% Distance from nerve
% ieNewGraphWin;
% plot(mahalMatrix(:,7)); hold on;
% plot(mahalMatrix(:,8));

%% END