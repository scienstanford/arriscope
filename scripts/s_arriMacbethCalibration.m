%% s_arriMacbethCalibration
%
% 

%% Set up the actors

% Load the sensor
wave = 400:5:700;
sensor = ieReadSpectra('arriSensorNIRon.mat',wave);

% Read the light
% greenSonyLight
% blueSonyLight
% whiteSonyLight.mat
% redSonyLight.mat
% greenSonyLight.mat
% whiteARRILight.mat
light = ieReadSpectra('whiteARRILight.mat',wave);

% Load the macbeth reflectances
surfaces = ieReadSpectra('MiniatureMacbethChart.mat',wave);

% Predicted RGB
rgbPred = sensor'*diag(light)*surfaces;
rgbPred = rgbPred';

imgPred = XW2RGBFormat(rgbPred,4,6);
imgPred = imageIncreaseImageRGBSize(imgPred,50);

ieNewGraphWin;
imagescRGB(imgPred);

%%  Compare some of the lights above with the MCC as expected

scene = sceneCreate;
sceneWindow(scene);

%%  Now go get the raw data and compare that to the predicted RGB

st = scitran('stanfordlabs');
st.verify;

% Work in this project
project     = st.lookup('arriscope/ARRIScope Calibration'); 
thisSession = project.sessions.findOne('label="20190612"');
thisAcq = thisSession.acquisitions.findOne('label=MacbethIRON');

%% We removed the spaces from the file names

files    = thisAcq.files;
zipFile = stSelect(files,'name','MacbethIRON_ari.zip');
zipArchive = 'MacbethIRON_ari.zip';

% Find out the filenames in the zip archive
zipInfo = thisAcq.getFileZipInfo(zipFile{1}.name);
stPrint(zipInfo.members,'path')

chdir(fullfile(arriRootPath,'local'));
arriZipFile = thisAcq.getFile(zipArchive);
arriZipFile.download(zipArchive);
unzip(zipArchive,thisAcq.label);
disp('Downloaded and unzipped arri image data');

%% For the light
% 'MacbethCc_green17_fIRon.ari'
% 'MacbethCc_blue17_fIRon.ari'
% 'MacbethCc_white17_fIRon.ari'
% 'MacbethCc_red17_fIRon.ari'
% 'MacbethCc_green17_fIRon.ari'
img = arriRead('MacbethCc_arriwhite20_fIRon.ari','image','left');
ieNewGraphWin;
imagescRGB(img);

img = imresize(img,1/4);
img = img/max(img(:));

imagescRGB(img);

ip = ipCreate;
ip = ipSet(ip,'correction method illuminant','none');
ip = ipSet(ip,'conversion method sensor','none');
ip = ipSet(ip,'display output',img);
ipWindow(ip);

showSelection = true;
fullData = false;
[mRGB, mLocs, pSize, cornerPoints] = ...
    macbethSelect(ip,showSelection,fullData);

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

