%% s_arriSensorEstimation
%
% 

%% Set up the actors

% Load the sensor
wave = 400:10:700;

% Load the macbeth reflectances
surfaces = ieReadSpectra('MiniatureMacbethChart.mat',wave);


% For each light multiply each MCC patch to get the expected radiance
testLights = {'blueSonyLight.mat','greenSonyLight.mat',...
    'redSonyLight.mat','violetSonyLight.mat',...
    'whiteSonyLight.mat','whiteARRILight.mat'};  

radiance = [];
for ii=1:numel(testLights)
    thisLight = ieReadSpectra(testLights{ii},wave);
    radiance = [radiance, diag(thisLight(:))*surfaces];
end

%{
ieNewGraphWin;
plot(wave,radiance);
xlabel('Wave');
%}

%%  Compare some of the lights above with the MCC as expected
%{
scene = sceneCreate;
sceneWindow(scene);
%}

%%  Now go get the raw data and compare that to the predicted RGB

%{
st = scitran('stanfordlabs');
st.verify;

% Work in this project
project     = st.lookup('arriscope/ARRIScope Calibration'); 
thisSession = project.sessions.findOne('label="20190612"');
thisAcq = thisSession.acquisitions.findOne('label=MacbethIRON');
files   = thisAcq.files;
%% We removed the spaces from the file names

% Not necessary for the download.  We just want to be here.
chdir(fullfile(arriRootPath,'local'));

% Select the file you want to download
zipFile = stSelect(files,'name','MacbethIRON_ari.zip');

% Download the file
st.fileDownload(zipFile{1},'destination',fullfile(arriRootPath,'local','MacbethIRON_ari.zip'));

% It was a zip file and here we unzip it
unzip(zipArchive,thisAcq.label);
disp('Downloaded and unzipped arri image data');
%}

%% RGB data

chdir(fullfile(arriRootPath,'local','MacbethIRON'));

rgbImages = {'MacbethCc_blue17_fIRon.ari','MacbethCc_green17_fIRon.ari', ...
    'MacbethCc_red17_fIRon.ari', 'MacbethCc_violet17_fIRon.ari', ...
    'MacbethCc_white17_fIRon.ari','MacbethCc_arriwhite20_fIRon.ari'};

ip = ipCreate;
ip = ipSet(ip,'correction method illuminant','none');
ip = ipSet(ip,'conversion method sensor','none');

%{
 img = arriRead(rgbImages{end},'image','left');
 ieNewGraphWin;
 imagescRGB(img);
%}

%{
% Make the display look right for the blue case.  What's going on?
 img = arriRead(rgbImages{end},'image','left');
 img = imresize(img,1/4);
 ip = ipSet(ip,'result',img);
 ipWindow(ip);
 showSelection = true;
 fullData = false;
 [thisRGB,~,~,cornerPoints] = macbethSelect(ip,showSelection,fullData);
%}


showSelection = true;   % Do or do not bring up the window
fullData      = false;  % Just returns the mean in each patch
cornerPoints = [
    79   291;
   490   292;
   489    19;
    79    22];

mRGB = [];
for ii=1:numel(rgbImages)
    img = arriRead(rgbImages{ii},'image','left');
    img = imresize(img,1/4);
    ip  = ipSet(ip,'result',img); 
    thisRGB = macbethSelect(ip,showSelection,fullData,cornerPoints);
    mRGB = [mRGB; thisRGB];
end

%% Have a look at the mRGB data
ieNewGraphWin;
plot(mRGB);

%% Perform the ridge regression

%{
k = 1e-3:1e-1:5e-1;
redSensor = ridge(red(:),radiance',k);
ieNewGraphWin;
plot(wave,redSensor);
%}

colorList1 = {'r-','g-','b-'};
colorList2 = {'ro','go','bo'};
for ii=1:3
    ieNewGraphWin([],'tall');
    theseData = mRGB(:,ii);
    [thisSensor, err, res] = lsqnonneg(radiance',theseData(:));
    pred = thisSensor'*radiance;
    subplot(2,1,1); plot(wave,thisSensor,colorList1{ii});
    subplot(2,1,2); plot(pred(:),theseData(:),colorList2{ii})
    identityLine;
end

%% Set up a set of low frequency basis functions for the sensor

% Gaussian type:
cfType = 'gaussian'; 
wavelength = 400:10:700; 
cPos       = 400:50:700; 
width      = ones(size(cPos))*30;

cFilters = sensorColorFilter(cfType, wavelength, cPos, width);
%{
ieNewGraphWin;
plot(wavelength,cFilters);
%}

% Basic equation
% 
%   wgts*cFilters'*radiance = mRGB(:,ii)'
%   theseData = mRGB(:,ii)';
%   projectedData = cFilters'*radiance;
%
%   wgts = theseData\projectedData
%   thisFilter = wgts*cFilters'
%
% So

estimatedFilters = zeros(length(wave),3);
colorList1 = {'r-','g-','b-'};
colorList2 = {'ro','go','bo'};
for ii = 1:3
    ieNewGraphWin([],'tall');
    theseData = mRGB(:,ii)';
    projectedData = cFilters'*radiance;
    wgts = theseData/projectedData;
    thisFilter = wgts*cFilters';
    thisFilter = ieClip(thisFilter,0,[]);  % Force positive
    pred = thisFilter*radiance;
    subplot(2,1,1); plot(wave,thisFilter,colorList1{ii});
    subplot(2,1,2); plot(pred(:),theseData(:),colorList2{ii})
    identityLine;
    estimatedFilters(:,ii) = thisFilter(:);
end
estimatedFilters = ieScale(estimatedFilters,1);

%%
arriSensor = ieReadSpectra('arriSensorNIRon.mat',wave);
ieNewGraphWin;
arriSensor = ieScale(arriSensor,1);
plot(wave,arriSensor,'--',wave,estimatedFilters,'-');
legend({'web','web','web','estimated','estimated','estimated'})

%% Leave the red alone but make green and blue max relative to red
arriMax = max(arriSensor);
estMax = max(estimatedFilters);
arriSensorScaled = arriSensor*diag([1,estMax(2)/arriMax(2),estMax(3)/arriMax(3)]);
ieNewGraphWin;
plot(wave,arriSensorScaled);

arriScaledPredRGB = arriSensorScaled'*radiance;
arriScaledPredRGB = arriScaledPredRGB';
ieNewGraphWin;
for ii=1:3
    plot(ieScale(arriScaledPredRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList2{ii});
    hold on;
end
identityLine;

%%
estimatedFiltersRGB = estimatedFilters'*radiance;
estimatedFiltersRGB = estimatedFiltersRGB';
ieNewGraphWin;
for ii=1:3
    plot(ieScale(estimatedFiltersRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList2{ii});
    hold on;
end
identityLine;

%% CVX format
%
% Ask Henryk for some help with this.
%
%{
nWave = numel(wave);
% Differentiator for forcing a smooth solution
Z = - eye(nWave);
for ii = 1 : nWave-1, Z(ii, ii + 1) = 1; end
Z = Z(1:end-1,:);

n = nWave;

ii = 1;

cvx_begin quiet
  variable w(n)
  minimize(norm(Z*w, 2))
  subject to
    w' * radiance == mRGB(:,ii)'
cvx_end
%}

%%
img = XW2RGBFormat(mRGB,4,6);
img = imageIncreaseImageRGBSize(img,50);
ieNewGraphWin;
imagescRGB(img)

%%
ieNewGraphWin;

rgbPredScaled = rgbPred/max(rgbPred(:));
mRGBScaled = mRGB/max(mRGB(:));

symbolList = {'ro','gx','bs'};
for ii=1:3
    thisSymbol = symbolList{ii};
    plot(mRGBScaled(:,ii),rgbPredScaled(:,ii),thisSymbol);
    hold on;
end

grid on;
title('ARRI MCC image data captured under White light (ARRI)')
xlabel('Measured');
ylabel('Predicted');
%%

