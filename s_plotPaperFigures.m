% s_plotPaperFigures
%
% Plot the figures that we plan to use in the paper for JBO


%% set the Matlab path
%{
cd /users/joyce/GitHub/isetcam/;
addpath(genpath(pwd));
cd /users/joyce/GitHub/arriscope/;
addpath(genpath(pwd));
%}

%% Load measured RGB values
mRGBfilename = fullfile(arriRootPath,'data','macbethColorChecker','mRGB.mat');
load(mRGBfilename,'mRGB');

%% Calculate radiance (lights + surfaces)
wave = 400:10:700;
% Load the macbeth reflectances
surfaces = ieReadSpectra('MiniatureMacbethChart.mat',wave);
plotRadiance(wave,surfaces);
% For each light multiply each MCC patch to get the expected radiance
testLights = {'blueSonyLight.mat','greenSonyLight.mat',...
    'redSonyLight.mat','violetSonyLight.mat',...
    'whiteSonyLight.mat','whiteARRILight.mat'};  

radiance = [];
for ii=1:numel(testLights)
    thisLight = ieReadSpectra(testLights{ii},wave);
    radiance = [radiance, diag(thisLight(:))*surfaces];
end

%% Sensor QE and predictions for the Appendix
% First plot the estimated sensors and comparison of predicted and measured RGB

colorList1 = {'r-','g-','b-'};
colorList2 = {'ro','go','bo'};
sensorQE = ieReadSpectra('ARRIestimatedSensors.mat',wave);
% plot sensors
ieNewGraphWin;
plot(wave,sensorQE(:,1),'r','LineWidth',2); hold on;
plot(wave,sensorQE(:,2),'g','LineWidth',2);
plot(wave,sensorQE(:,3),'b','LineWidth',2);
ax = gca;
ax.FontSize=16;
grid on;
xlabel('Wavelength (nm)','FontSize',20);
ylabel('Relative Sensitivity','FontSize',20);

% plot predictions and compare to measurements
ieNewGraphWin;
estimatedFiltersRGB = sensorQE'*radiance;
estimatedFiltersRGB = estimatedFiltersRGB';
for ii=1:3
    plot(ieScale(estimatedFiltersRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList2{ii},'LineWidth',2,'MarkerSize',10);
    hold on;
end
identityLine;
ax = gca;
ax.FontSize=16;
grid on;
xlabel('Predicted RGB values','FontSize',20);
ylabel('Measured RGB values','FontSize',20);

%%
% Second, plot the scaled TLC QE functions (scaled for gain) and the
% comparison of predicted and measured RGB

TLCISensorFname = fullfile(arriRootPath,'data','sensor','TLCIsensors.mat');
TLCIQE = ieReadSpectra(TLCISensorFname, wave);
ieNewGraphWin;
TLCI_QE_red = TLCIQE(:,1)/max(TLCIQE(:,1))* max(sensorQE(:,1));
TLCI_QE_green = TLCIQE(:,2)/max(TLCIQE(:,2))* max(sensorQE(:,2));
TLCI_QE_blue = TLCIQE(:,3)/max(TLCIQE(:,3))* max(sensorQE(:,3));
plot(wave,TLCI_QE_red,'r','LineWidth',2); hold on
plot(wave,TLCI_QE_green,'g','LineWidth',2);
plot(wave,TLCI_QE_blue,'b','LineWidth',2);
TLCIsensor = [TLCI_QE_red,TLCI_QE_green,TLCI_QE_blue];
ax = gca;
ax.FontSize=16;
grid on;
xlabel('Wavelength (nm)','FontSize',20);
ylabel('Relative Sensitivity','FontSize',20);

% plot predictions and compare to measurements
ieNewGraphWin;
estimatedFiltersRGB = TLCIsensor'*radiance;
estimatedFiltersRGB = estimatedFiltersRGB';
for ii=1:3
    plot(ieScale(estimatedFiltersRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList2{ii},'LineWidth',2,'MarkerSize',10);
    hold on;
end
identityLine;
ax = gca;
ax.FontSize=16;
grid on;
xlabel('Predicted RGB values','FontSize',20);
ylabel('Measured RGB values','FontSize',20);

%% 
% Third, plot the equivalent sensor model with and without UV+NIR and the
% comparison of predicte and measured RGB

equivalentSensor = ieReadSpectra('FilteredAndScaledSonyQE.mat',wave);
% plot sensors
ieNewGraphWin;
plot(wave,equivalentSensor(:,1),'r','LineWidth',2); hold on;
plot(wave,equivalentSensor(:,2),'g','LineWidth',2);
plot(wave,equivalentSensor(:,3),'b','LineWidth',2);
ax = gca;
ax.FontSize=16;
grid on;
xlabel('Wavelength (nm)','FontSize',20);
ylabel('Relative Sensitivity','FontSize',20);

% plot predictions and compare to measurements
ieNewGraphWin;
estimatedFiltersRGB = equivalentSensor'*radiance;
estimatedFiltersRGB = estimatedFiltersRGB';
for ii=1:3
    plot(ieScale(estimatedFiltersRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList2{ii},'LineWidth',2,'MarkerSize',10);
    hold on;
end
identityLine;
ax = gca;
ax.FontSize=16;
grid on;
xlabel('Predicted RGB values','FontSize',20);
ylabel('Measured RGB values','FontSize',20);

%% plot with and without UV+NIR;
wave = 400:10:900;
equivalentSensor = ieReadSpectra('FilteredAndScaledSonyQE.mat',wave);
equivalentSensorNIR = ieReadSpectra('ScaledSony.mat',wave);
ieNewGraphWin;
plot(wave,equivalentSensor(:,1),'r','LineWidth',2); hold on;
plot(wave,equivalentSensor(:,2),'g','LineWidth',2);
plot(wave,equivalentSensor(:,3),'b','LineWidth',2);
plot(wave,equivalentSensorNIR(:,1),'r--','LineWidth',2); 
plot(wave,equivalentSensorNIR(:,2),'g--','LineWidth',2);
plot(wave,equivalentSensorNIR(:,3),'b--','LineWidth',2);
ax = gca;
ax.FontSize=16;
grid on;
xlabel('Wavelength (nm)','FontSize',20);
ylabel('Relative Sensitivity','FontSize',20);


