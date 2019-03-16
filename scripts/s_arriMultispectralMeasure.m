%% s_arriMultiSpectralMeasure.m
%
% Purpose: Jared made measurements stored in Arriscope Tissue from
% cadaver data.  This routine specifies a Session and Acquisition,
% reads the relevant Arri data files, and returns a set of 18 values
% for the RGB sensors under the 5 lights and the 
%   Red, Green, Blue, violet, white (with NIR filter on)
%       and infrared (with NIR filter off)
%
% Background:
%
% IN THIS SCRIPT we
%   1. Download the data from the Flywheel database
%   2. unzip the data into a local directory
%   3. 
% Download and estimate homogeneity (linearity with respect to intensity)
% Documentation and results of this analysis are in 
% https://docs.google.com/document/d/1O_KHnzWTAt7flg8k9T0OvyRQ-bFjVbCBAMM4wdbU1O0/edit#heading=h.ows9qdbadce7

% BW/JEF  SCIENSTANFORD, 2019

%% Set root path for Matlab
% 
%      set(groot,'defaultAxesColorOrder',co)

%% Open up to the data on Flywheel
st = scitran('stanfordlabs');
st.verify;

% Find the project and the first calibration session
project = st.lookup('arriscope/ARRIScope Tissue'); 
thisSession  = project.sessions.findOne('label="20190222"');
A = thisSession.acquisitions();

%{
zipArchive = 'Bone_CameraImage_ari.zip';
zipInfo = A{1}.getFileZipInfo(zipArchive);
stPrint(zipInfo.members,'path')

entryName = zipInfo.members{1}.path;
entryName = zipInfo.members{6}.path;
outName = fullfile(arriRootPath,'local',entryName);
A{1}.downloadFileZipMember(zipArchive,entryName,outName);
%}

% Download the whole zip file of data, unzip it.
zipArchive = 'Bone_CameraImage_ari.zip';
arriZipFile = A{1}.getFile(zipArchive);
arriZipFile.download(zipArchive);
unzip(zipArchive);
disp('Downloaded and unzipped spd data');

%%  Get the rect somehow
%{
% If you read an arriRGB, you can get the rect this way
ip = ipCreate;
ip = ipSet(ip,'display output',arriRGB);
ipWindow(ip);
% Pick a little region to use to get the other values
[~,rect] = ieROISelect(ip);
%}

rect = [158   332   205   215];

%%
% Working directory
chdir(fullfile(arriRootPath,'local'));
localFiles = dir('Bone*.ari');
nFiles = length(localFiles);
% These are the set of possible lights defined in the function


lightNames = arriLights;
nLights = length(lightNames);
rgbRectImages = zeros(nLights,rect(4)+1,rect(3)+1,3);
lightNames  = cell(nFiles,1);
lightLevels = cell(nFiles,1);
rgbRectMeans = zeros(nLights,3);

for ii=1:length(localFiles)
    [lightNames{ii}, lightLevels{ii}] = arriLightLevel(localFiles(ii).name);
    arriRGB = arriRead(localFiles(ii).name);
    [~,idx] = arriLights(lightNames{ii});
    tmp = imcrop(arriRGB,rect);
    rgbRectImages(idx,:,:,:) = tmp;
    rgbRectMeans(idx,:) = mean(RGB2XWFormat(tmp))';
end

%% Put the arriRaw into a sensor structure
sensor = sensorCreate;

[~, arriRaw] = arriRead(localFiles(ii).name);
arriRaw = ieScale(double(arriRaw),0,1);
sensor = sensorSet(sensor,'volts',arriRaw);
sensorWindow(sensor);
ip = ipCreate;
ip = ipCompute(ip,sensor);
ipWindow(ip);





roiData = imcrop(arriRGB,rect);
rgbData = RGB2XWFormat(roiData);
ieNewGraphWin; 
c = {'r','g','b'};
for ii=1:3
   histogram(RGB2XWFormat(rgbData(:,ii)),500,'FaceColor',c{ii});
   hold on
end
   
meanRGB = mean(RGB2XWFormat(roiData))';

%% Get data from an acquisition for one of the channels
% Select the light with spectra and camera images that we want to analyze


channel = 'Red';   % 'Red','Green','Blue','UV','White', 'Infrared'
str     = sprintf('label=%s',channel);
Acquisition = thisSession.acquisitions.findOne(str);


%%  Download the spectra.  Not very big.

spdZipFile = sprintf('%s_LightSpectra_mat.zip',channel);
spdFile = Acquisition.getFile(spdZipFile);
spdZip = sprintf('%s_spd.zip',channel);
spdFile.download(spdZip);
spdDir = sprintf('%s_spd',channel);
unzip(spdZip,spdDir);
disp('Downloaded and unzipped spd data');

%{
% Programming note
% If you want to see the files inside a ZIP file, you can do this
zipInfo    = Acquisition.getFileZipInfo(zipFile);
thisZip{1} = zipInfo; stPrint(thisZip,'members','path')

entryName = zipInfo.members{1}.path;
outPath = fullfile('/tmp', entryName);
acquisition.downloadFileZipMember('my-archive.zip', entryName, outPath);
%}

%% Download the arri images.  These are pretty big

arriZipFile = sprintf('%s_CameraImage_ari.zip',channel);
arriFile = Acquisition.getFile(arriZipFile);
arriZip = sprintf('%s_arri.zip',channel);
arriFile.download(arriZip)
arriDir = sprintf('%s_arri',channel);
unzip(arriZip,arriDir);
disp('Downloaded and unzipped ari data');

%% Read the spectra, figure out the code and intensity levels

chdir(fullfile(icalRootPath,'local',spdDir));

spdFiles = dir('*_LightSpectra*.mat');
nFiles = numel(spdFiles);
load(spdFiles(1).name,'result');
wave = result(1,:);

spectra = zeros(length(wave),nFiles);
code = zeros(1,nFiles);

for ii=1:length(spdFiles)
    a = split(spdFiles(ii).name,'level'); 
    a = split(a{2},'_');
    code(ii) = str2double(a{1});
    load(spdFiles(ii).name,'result');
    spectra(:,ii) = result(2,:)';
end

%{
% In case you want to check that the spd have the same shape

semilogy(wave,spectra);
set(gca,'ylim',[1e-3 1]);
mx = max(spectra);
spectra = spectra*diag(1./mx);
%}

% This plots the first principle component (mean) of the spectral energy
[U,S,V] = svd(spectra);
ieNewGraphWin;
[~,idx] = max(abs(U(:,1)));
if U(idx,1) < 0, pc1 = -1*U(:,1);
else, pc1 = U(:,1);
end
plot(wave,pc1)
title(sprintf('Channel %s\n',channel));

%% Compute Levels 

% These are the projection on the first principal component, scaled so
% that the brightest is 1
levels = pc1'*spectra;
% levels = levels/max(levels(:));

% Compare with 'code'
ieNewGraphWin;
% plot(code/max(code),levels,'o');
plot(code,levels,'o');
% plot(code,levels,'o');
% grid on; xlabel('Scaled file code'); ylabel('SPD level');
grid on; xlabel('Level file code'); ylabel('SPD level');
% set(gca,'ylim',[0 1.1]); 
% identityLine;
title(sprintf('Channel %s\n',channel));

%% Find the mean values in the region of the ARRI images

chdir(fullfile(icalRootPath,'local',arriDir));

arriFiles = dir('*_CameraImage*.ari');
nFiles = numel(arriFiles);
arriMean = zeros(3,nFiles);
code = zeros(1,nFiles);

% Seemed like a good spatial region of the raw image to use
% [~,rect] = imcrop(arriRGB);
rect = [431 375 127 127]; 

for ii=1:nFiles
    a = split(arriFiles(ii).name,'_');
    a = split(a{3},'.');
    code(ii) = str2double(a{1});
    arriRGB = arriRead(arriFiles(ii).name);
    % imagescRGB(arriRGB);
    arriCrop = imcrop(arriRGB,rect);
    arriMean(:,ii) = mean(RGB2XWFormat(arriCrop))';
end

% 
ieNewGraphWin;
plot(code,arriMean(1,:),'ro', code,arriMean(2,:),'go',code,arriMean(3,:),'bo');
% set(gca,'xlim',[0 11]);
xlabel('Code level','FontSize',24); ylabel('Channel mean','FontSize',24);
grid on; legend({'R','G','B'});
title(sprintf('Channel %s\n',channel),'FontSize',24,'FontWeight','normal');

%%
chdir(fullfile(icalRootPath,'local'));


%%