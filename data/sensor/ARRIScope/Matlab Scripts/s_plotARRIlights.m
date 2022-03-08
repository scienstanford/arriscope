% s_plotARRIlights.m
%

%%
thisDir = '/Users/joyce/Google Drive/Projects/ARRIScope/Multispectral Imaging Study/CalibrationMeasurments/OriginalData/Light SpectroRadiometer Measurements/20190410'
srch = fullfile(thisDir,'*.mat');
fileStructList = dir(srch);
dataFileNames = cell(1,length(fileStructList));
for ii=1:length(fileStructList)
    dataFileNames{ii} = fullfile(thisDir,fileStructList(ii).name);
end

Nfiles = length(dataFileNames);

ieNewGraphWin;
for ii = 1:Nfiles
     fullFileName = dataFileNames{ii};
    load(fullFileName);
    plot(result(1,:),result(2,:),'b');
    hold on
end


%%
cd '/Users/joyce/Google Drive/Projects/ARRIScope/Multispectral Imaging Study/CalibrationMeasurments/OriginalData/Light SpectroRadiometer Measurements/20190410'
figure;
% load('ambient_1.mat')
% plot(result(1,:),result(2,:),'k');
hold on;
load('arri_white_1.mat');
plot(result(1,:),result(2,:),'k-');
load('blue_1.mat');
plot(result(1,:),result(2,:),'b');
load('green_1.mat');
plot(result(1,:),result(2,:),'g');
load('red_1.mat');
plot(result(1,:),result(2,:),'r');
load('violet_1.mat');
plot(result(1,:),result(2,:),'m');
load('white_1.mat');
plot(result(1,:),result(2,:),'k');
load('IR_1.mat')
plot(result(1,:),result(2,:),'k:');
% load('white_mix_1.mat');
% plot(result(1,:),result(2,:),'k.');

%%
thisDir = '/Users/joyce/Google Drive/Projects/ARRIScope/Calibration/02082019/Light SpectroRadiometer Measurements/aperture0.5/green';

% Create a list of all *.mat files
srch = fullfile(thisDir,'*.mat');
fileStructList = dir(srch);
dataFileNames = cell(1,length(fileStructList));
for ii=1:length(fileStructList)
    dataFileNames{ii} = fullfile(thisDir,fileStructList(ii).name);
end

Nfiles = length(dataFileNames);

for ii = 1:Nfiles
     fullFileName = dataFileNames{ii};
    load(fullFileName);
    plot(result(1,:),result(2,:),'g');
    hold on
end

%%
thisDir = '/Users/joyce/Google Drive/Projects/ARRIScope/Calibration/02082019/Light SpectroRadiometer Measurements/aperture0.5/red';

% Create a list of all *.mat files
srch = fullfile(thisDir,'*.mat');
fileStructList = dir(srch);
dataFileNames = cell(1,length(fileStructList));
for ii=1:length(fileStructList)
    dataFileNames{ii} = fullfile(thisDir,fileStructList(ii).name);
end

Nfiles = length(dataFileNames);

for ii = 1:Nfiles
     fullFileName = dataFileNames{ii};
    load(fullFileName);
    plot(result(1,:),result(2,:),'r');
    hold on
end

%%
thisDir = '/Users/joyce/Google Drive/Projects/ARRIScope/Calibration/02082019/Light SpectroRadiometer Measurements/aperture0.5/UV';

% Create a list of all *.mat files
srch = fullfile(thisDir,'*.mat');
fileStructList = dir(srch);
dataFileNames = cell(1,length(fileStructList));
for ii=1:length(fileStructList)
    dataFileNames{ii} = fullfile(thisDir,fileStructList(ii).name);
end

Nfiles = length(dataFileNames);

for ii = 1:Nfiles
     fullFileName = dataFileNames{ii};
    load(fullFileName);
    plot(result(1,:),result(2,:),'m');
    hold on
end
%%
thisDir = '/Users/joyce/Google Drive/Projects/ARRIScope/Calibration/02082019/Light SpectroRadiometer Measurements/aperture0.5/infrared';

% Create a list of all *.mat files
srch = fullfile(thisDir,'*.mat');
fileStructList = dir(srch);
dataFileNames = cell(1,length(fileStructList));
for ii=1:length(fileStructList)
    dataFileNames{ii} = fullfile(thisDir,fileStructList(ii).name);
end

Nfiles = length(dataFileNames);

for ii = 1:Nfiles
     fullFileName = dataFileNames{ii};
    load(fullFileName);
    plot(result(1,:),result(2,:),'k:');
    hold on
end

%%
thisDir = '/Users/joyce/Google Drive/Projects/ARRIScope/Calibration/02082019/Light SpectroRadiometer Measurements/aperture0.5/white';

% Create a list of all *.mat files
srch = fullfile(thisDir,'*.mat');
fileStructList = dir(srch);
dataFileNames = cell(1,length(fileStructList));
for ii=1:length(fileStructList)
    dataFileNames{ii} = fullfile(thisDir,fileStructList(ii).name);
end

Nfiles = length(dataFileNames);

for ii = 1:Nfiles
     fullFileName = dataFileNames{ii};
    load(fullFileName);
    plot(result(1,:),result(2,:),'k--');
    hold on
end

%%
thisDir = '/Users/joyce/Google Drive/Projects/ARRIScope/Calibration/02082019/Light SpectroRadiometer Measurements/aperture0.5/ambient';

% Create a list of all *.mat files
srch = fullfile(thisDir,'*.mat');
fileStructList = dir(srch);
dataFileNames = cell(1,length(fileStructList));
for ii=1:length(fileStructList)
    dataFileNames{ii} = fullfile(thisDir,fileStructList(ii).name);
end

Nfiles = length(dataFileNames);
figure;
for ii = 1:Nfiles
     fullFileName = dataFileNames{ii};
    load(fullFileName);
    plot(result(1,:),result(2,:),'k');
    hold on
end

%% Plot ambient with and without the black curtain
% no difference between the two cases

thisDir = '/Users/joyce/Google Drive/Projects/ARRIScope/Calibration/02082019/Light SpectroRadiometer Measurements/lightsnotblocked/Ambient';
figure 
% Create a list of all *.mat files
srch = fullfile(thisDir,'*.mat');
fileStructList = dir(srch);
dataFileNames = cell(1,length(fileStructList));
for ii=1:length(fileStructList)
    dataFileNames{ii} = fullfile(thisDir,fileStructList(ii).name);
end

Nfiles = length(dataFileNames);
for ii = 1:Nfiles
     fullFileName = dataFileNames{ii};
    load(fullFileName);
    plot(result(1,:),result(2,:),'r');
    hold on
end

thisDir = '/Users/joyce/Google Drive/Projects/ARRIScope/Calibration/02082019/Light SpectroRadiometer Measurements/blackout/Ambient';
% Create a list of all *.mat files
srch = fullfile(thisDir,'*.mat');
fileStructList = dir(srch);
dataFileNames = cell(1,length(fileStructList));
for ii=1:length(fileStructList)
    dataFileNames{ii} = fullfile(thisDir,fileStructList(ii).name);
end

Nfiles = length(dataFileNames);
figure 
for ii = 1:Nfiles
     fullFileName = dataFileNames{ii};
    load(fullFileName);
    plot(result(1,:),result(2,:),'k');
    hold on
end

%%
% cd '/Users/joyce/Google Drive/Projects/ARRIScope/LEDs/ARRISensors/'
% load('ARRIsensors.mat');
% figure; plot(blueARRIsensor(:,1),blueARRIsensor(:,2),'b');
% hold on;
% plot(greenARRIsensor(:,1),greenARRIsensor(:,2),'g');
% plot(redARRIsensor(:,1),redARRIsensor(:,2),'r');
% oxyH1(1,1) = 540;
% oxyH1(1,2) = 0;
% oxyH1(2,1) = 540;
% oxyH1(2,2) = 1.4;
% oxyH2(1,1) = 575;
% oxyH2(1,2) = 0;
% oxyH2(2,1) = 575;
% oxyH2(2,2) = 1.4;
% deoxyH(1,1) = 555;
% deoxyH(1,2) = 0;
% deoxyH(2,1) = 555;
% deoxyH(2,2) = 1.4;
% plot(oxyH1(:,1),oxyH1(:,2),'r');
% plot(oxyH2(:,1),oxyH2(:,2),'r');
% plot(deoxyH(:,1),deoxyH(:,2),'b');




