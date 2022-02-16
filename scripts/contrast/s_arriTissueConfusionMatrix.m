%% s_arriTissueConfusionMatrix.m 
%
%

% TODO: run this script for case where there is only the ARRI white light
% (RGB only)
%
% Purpose:
%   Quantify the discriminability between two tissue types based on the
%   difference in camera RGB values captured when illuminated by N lights
%
%   We use tissue spectral reflectances that were published by Stezle et al
%   It would interesting to repeat this analysis for tissue reflectances
%   that have spectral measurements > 640 nm, but these data are not
%   available. So, for now, we cannot consider the effect of IR
%   
%       Stelzle et al (2011)
%       Optical Nerve Detection by Diffuse Reflectance Spectroscopy for Feedback Controlled Oral and Maxillofacial Laser Surgery. 
%       J Transl Med 9, 20 (2011). https://doi.org/10.1186/1479-5876-9-20
% 
%       Stelzle et al (2012). 
%       In Vivo Optical Tissue Differentiation by Diffuse Reflectance Spectroscopy: 
%       Preliminary Results for Tissue-Specific Laser Surgery. Surgical innovation. 19. 10.1177/1553350611429692. 

%       Stelzle et al. (2014)
%       Optical nerve identification in head and neck surgery after Er:YAG laser ablation. 
%        Lasers Med Sci. 2014 Sep;29(5):1641-8. doi: 10.1007/s10103-014-1569-5. Epub 2014 Apr 3. PMID: 24696381.

%       see Stelzle et al (2010) for PCA
%       Diffuse Reflectance Spectroscopy for Optical Soft Tissue Differentiation as Remote Feedback Control for 
%       Tissue-Specific Laser Surgery. Lasers in surgery and medicine. 42. 319-25. 10.1002/lsm.20909. 
%
% Method:
%   Step One: Create a scene that represents the spectral reflectance of
%   different tissue types.  

%   Step Two: Create a set of spectral channels by multiplying the spectral
%   sensitivities of the 3 RGB sensors with the spectral energy in the N
%   spectral lights.  We have up to six lights so up to 18 channels. 
%
%   Step Three:  The sensor-light channels are not independent of one
%   another.  So we reduce the sensor data to a small number of variables
%   that preserve the independent channels.  These are virtual channels
%   that can be described by weighted sums of the sensor light channels.
%   Check to see if the 3 basis functions are the RGB sensors, since the
%   lights only serve to modulate the SNR
%
%   Step Four: The analysis in Step Three lets us look at which spectral
%   channels are most important for predicting the sensor values. Although
%   we can predict the spectral responsivities of the M spectral channels
%   by a weighted combination of M basis functions (aka principal
%   components),we might not need all M basis functions. It could be that
%   we need fewer basis functions. Look at how many basis functions we need
%   to predict the spectral responsivities of the M spectral channels.
%   Plot % variance accounted for as a function of the number of basis
%   functions Let's say that we find that we only need B basis functions,
%   where B<M Notice that the M weights on the B basis functions tell us
%   how important each of the original M spectral channels are.
%
%   Be sure to set exposure duration to constant (we don't know what it is,
%   but it is constant)
%
%   Step Five: Calculate the Mahalanobis distance between pairs of
%   different tissue types for the conditions we care about.  These are
%   simulations with all N = 6 lights (multispectral) and N = 1 lights (not
%   considered multispectral).  (We calculate the Mahalanobis distance on
%   the virtual channels).
%
%   Step Six: Validate the assumption that we only need B basis functions
%   by comparing the Mahalanobis distance between tissues based on M basis
%   functions versus the Mahalanobis distance between tissues based on B
%   basis functions

%
% JEF 02/16/2022
%{
cd /users/joyce/GitHub/isetcam;
addpath(genpath(pwd));
cd /users/joyce/GitHub/arriscope;
addpath(genpath(pwd));
%}
%%
ieInit;

%% Select the number of lights
% note that we do not include the NIR light for two reasons
% First, we did not have the data necessary to estimate the sensors with
% the NIR blocking filter
% Second, we do not have reflectance data for wavelengths > 640 nm 
% Both of these limitations can be corrected in the future
% 
Lights = {'whiteARRILight.mat',  'whiteSonyLight.mat','greenSonyLight.mat',...
    'blueSonyLight.mat','redSonyLight.mat','violetSonyLight.mat'};

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

%% Illuminant pattern

% Homogeneous lighting
pattern = [];

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
pattern = imresize(pattern1,0.25);
% ieNewGraphWin; imagesc(pattern); colormap(gray);
%}

%% Build the oi
oi = oiCreate;
oi = oiCompute(oi,scene);

%% Build the sensor - with an NIR blocking filter

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
    
    ipWindow(ip); 
    
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

%% Compute the reduced dimension of the sensor data
% By combining 3 sensors and 6 lights, we produce, in theory, 18 different spectral channels
% However, these spectral channels are correlated (i.e. not orthogonal)
% In order to quantify tissue discriminability using the Mahalanobis
% distance metric, we need to map the spectral channels into an orthogonal
% basis set.  

% We can use the singular value decomposition to find a set of orthogonal
% sensors such that each of the 18 channels can be described by a weighted
% combination of the smaller set of orthogonal sensors 
% 
sensorLight = zeros(numel(wave),3,numel(Lights));
arriQE = ieReadSpectra('FilteredAndScaledSonyQE.mat',wave);
for ii = 1:numel(Lights)
    thisLight = ieReadSpectra(Lights{ii},wave);
    sensorLight(:,:,ii) = diag(thisLight)*arriQE;
end
SpectralChannels = reshape(sensorLight,numel(wave),nLights*3);

[U,S,V] = svd(SpectralChannels');

% plot the percent variance accounted for as a function of number of basis functions
S = diag(S);
percentV = cumsum(S.^2)/sum(S.^2)* 100;
ieNewGraphWin; plot(percentV,'k', 'linewidth', 3) ; xlabel('Number of spectral basis functions'); ylabel('Percent Variance Accounted For');

% Let's look at the weights on the 18 spectral channels to see which ones
% are used and which ones have weights of 0
% select the number of basis functions to use
nBasis = 9; % for the multispectral case, 9 basis functions account for 100% of the variance
% nBasis = 3;

thisBasis = U(:,1:nBasis);
% ieNewGraphWin; surf(abs(thisBasis));colormap(gray);
imagesc(abs(thisBasis)); colormap(gray); set(gca,'ColorScale','log'); axis image; colorbar;
ChannelName = {'R ARRI white','G ARRI white','B ARRI white', ...
    'R Sony white', 'G Sony white', 'B Sony white', ...
    'R Sony 525nm', 'G Sony 525nm', 'B Sony 525nm', ...
    'R Sony 445nm', 'G Sony 445nm', 'B Sony 445nm', ...
    'R Sony 638nm', 'G Sony 638nm', 'B Sony 638nm', ...
    'R Sony 405nm', 'G Sony 405nm', 'B Sony 405nm'};

t = array2table(abs(thisBasis))
f=figure;
uit = uitable(f,'Data',table2cell(t));
uit.RowName = ChannelName;


%%

%{ 
ChannelName = {'R ARRI white','G ARRI white','B ARRI white', ...
    'R Sony white', 'G Sony white', 'B Sony white', ...
    'R Sony 525nm', 'G Sony 525nm', 'B Sony 525nm', ...
    'R Sony 445nm', 'G Sony 445nm', 'B Sony 445nm', ...
    'R Sony 638nm', 'G Sony 638nm', 'B Sony 638nm', ...
    'R Sony 405nm', 'G Sony 405nm', 'B Sony 405nm'};
ieNewGraphWin;
    plot(wave,x(:,1),'r--','linewidth',2); % ARRI white light R sensor
    hold on;
plot(wave,x(:,2),'g--','linewidth',2); % ARRI white light G sensor
plot(wave,x(:,3),'b--','linewidth',2); % ARRI white light B sensor
plot(wave,x(:,4),'r-','linewidth',2); % Sony white light R sensor
plot(wave,x(:,5),'g-','linewidth',2); % Sony white light G sensor
plot(wave,x(:,6),'b-','linewidth',2); % Sony white light B sensor
plot(wave,x(:,7),'r-o','linewidth',2); % Sony 525nm light R sensor % Green light R sensor (noise)
plot(wave,x(:,8),'g-o','linewidth',2); % Sony 525nm light G sensor
plot(wave,x(:,9),'b-o','linewidth',2); % Sony 525nm light B sensor
plot(wave,x(:,10),'r-s','linewidth',2); % Sony 445nm light R sensor % Blue light R sensor (small response)
plot(wave,x(:,11),'g-s','linewidth',2); % Sony 445nm light G sensor % Blue light G response (small response)
plot(wave,x(:,12),'b-s','linewidth',2); % Sony 445nm light B sensor
plot(wave,x(:,13),'r-d','linewidth',2); % Sony 638nm light R sensor 
plot(wave,x(:,14),'g-d','linewidth',2); % Sony 638nm light G sensor  % Red light G response
plot(wave,x(:,15),'b-d','linewidth',2); % Sony 638nm light B sensor  % Red light B response
plot(wave,x(:,16),'r-*','linewidth',2); % Sony 405nm light R sensor % noise
plot(wave,x(:,17),'g-*','linewidth',2); % Sony 405nm light G sensor % noise
plot(wave,x(:,18),'b-*','linewidth',2); % Sony 405nm light B sensor % nois
legend(ChannelName);
xlabel('Wavelength (nm)');
%}

%% Could loop on the 11 surfaces

% Now with the new "virtual sensors" we predict the RGB values 

mahalMatrix = zeros(11,11);
for ss = 1:11
    these = find(sSamples{1} == ss);
    X = []; for tt=1:length(these), X = [X;data{these(tt)}];end
    X = X*thisBasis;
    for ii=ss:11
        these = find(sSamples{1} == ii);
        Y = []; 
        for tt=1:length(these), Y = [Y;data{these(tt)}];end
        Y = Y*thisBasis;
        mahalMatrix(ss,ii) = log10(mean(mahal(X,Y)) + mean(mahal(Y,X)))/2;
        mahalMatrix(ii,ss) = mahalMatrix(ss,ii);
    end
end

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
ieNewGraphWin;
plot(mahalMatrix(:,7)); hold on;
plot(mahalMatrix(:,8));

%% END