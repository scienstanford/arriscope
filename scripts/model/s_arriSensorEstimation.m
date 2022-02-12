%% s_arriSensorEstimation
%
% 

%% Set up the actors
% make sure that isetcam and arriscope is on your Matlab path
ieInit % clear all variables

% Spectral radiance of the stimuli
wave = 400:10:700;

% Load the macbeth reflectances
surfaces = ieReadSpectra('MiniatureMacbethChart.mat',wave);
plotRadiance(wave,surfaces);


% For each light multiply each MCC patch to get the expected radiance
testLights = {'blueSonyLight.mat','greenSonyLight.mat',...
    'redSonyLight.mat','violetSonyLight.mat',...
    'whiteSonyLight.mat','whiteARRILight.mat'};  

% Note that in the spring of 2019, I sent the PR715 to be calibrated by PhotoResearch.
% When it was returned, I compared the spectrophotometric measurements of the PR715 and the PF670 in our lab
% The numbers were off by a factor of 5.
% So I compared the PR670 measurements with a second PR670 that
% PhotoResearch insisted was calibrated. Since these two units gave the
% same number, I deduced that the PR 715 was not calibrated correctly.
% I argued with PhotoResearch for over a year about this, refusing to pay
% their bill for an incorrect calibration. 
% After I told them that I would publish my results on the web, they
% relented and told me to send the PR715 back for recalibration.
% In the meantime, we need to correct the PR715 in order to get numbers
% that are on the same scale as the PR670.
% Hence, this long explanation and the empirical correction below to get
% the numbers right (jf)


ieNewGraphWin;
for ii = 1:numel(testLights)
    thisLight = ieReadSpectra(testLights{ii},wave);
    plot(wave,log(thisLight * 5.453933991449514 -0.000976427089295)); hold on;
    
end
% Sonywhite = ieReadSpectra(testLights{5},wave);
% ARRIwhite = ieReadSpectra(testLights{6},wave);
% ieNewGraphWin;
% plot(ARRIwhite');hold on;
% plot(Sonywhite');


radiance = [];
for ii=1:numel(testLights)
    thisLight = ieReadSpectra(testLights{ii},wave);
    radiance = [radiance, diag(thisLight(:))*surfaces];
end

%{
plotRadiance(wave,radiance);
title('MCC under 6 different lights')
%}


%%  Now go get the raw data and compare that to the predicted RGB
% We only need to run this once if we store the data in the local directory
% download data from Flywheel
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
zipArchive = fullfile(arriRootPath,'local','MacbethIRON_ari.zip');
st.fileDownload(zipFile{1},'destination',zipArchive);

% It was a zip file and here we unzip it
unzip(zipArchive,thisAcq.label);
disp('Downloaded and unzipped arri image data');
%}

%% RGB data
% Display the raw camera images captured by the ARRIScope camera with the
% NIR filter on for each of the 6 lights
% Then grab the mean R, G and B values for each of the 24 patches captured
% under each of the 6 lights
% Notice that the raw camera image captured under violet17 has very little
% signal and is, therefore, noisy

chdir(fullfile(arriRootPath,'data','macbethColorChecker','MacbethIRON'));

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


%% Have a look at the mRGB data (no saturated pixels)
ieNewGraphWin;
plot(mRGB);

%% Perform the ridge regression
% This did not produce a good result
%{
k = 1e-3:1e-1:5e-1;
redSensor = ridge(red(:),radiance',k);
ieNewGraphWin;
plot(wave,redSensor);
%}

% colorList1 = {'r-','g-','b-'};
% colorList2 = {'ro','go','bo'};
% for ii=1:3
%     ieNewGraphWin([],'tall');
%     theseData = mRGB(:,ii);
%     [thisSensor, err, res] = lsqnonneg(radiance',theseData(:));
%     pred = thisSensor'*radiance;
%     subplot(2,1,1); plot(wave,thisSensor,colorList1{ii});
%     subplot(2,1,2); plot(pred(:),theseData(:),colorList2{ii})
%     identityLine;
% end

%% Set up a set of low frequency basis functions for the sensor

% Gaussian type:
cfType = 'gaussian'; 
wavelength = 400:10:700; 
cPos       = 400:50:700; 
width      = ones(size(cPos))*30;

cFilters = sensorColorFilter(cfType, wavelength, cPos, width);
%{
ieNewGraphWin;
plot(wavelength,cFilters,'linewidth',3);
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
colorList3 = {'r*','g*','b*'};
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
figure; plot(wave, estimatedFilters(:,1),'r')
hold on; plot(wave, estimatedFilters(:,2),'g')
plot(wave, estimatedFilters(:,3),'b')
comment = 'ARRI sensors estimated by the script s_arriSensorEstimation.m';
fname = fullfile(arriRootPath,'data','sensor','ARRIestimatedSensors');
ieSaveSpectralFile(wave,estimatedFilters,comment,fname);

%% Predictions by the curves published by Wisotsky
% Read in the sensor data for the sensor curves published by Wisotsky Et Al
% and compare to the predicted data
WisotskySensor = ieReadSpectra('WisotskySensorNIRon.mat',wave);
ieNewGraphWin;
WisotskySensor = ieScale(WisotskySensor,1);
plot(wave,WisotskySensor,'--',wave,estimatedFilters,'-');
legend({'Wisotsky','Wisotsky','Wisotsky','estimated','estimated','estimated'})

WitsotskyPredRGB = WisotskySensor'*radiance;
WitsotskyPredRGB = WitsotskyPredRGB';
ieNewGraphWin;
for ii=1:3
    plot(ieScale(WitsotskyPredRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList3{ii});
    hold on;
end
identityLine;
xlabel('RGB values predicted by the sensor data published by Wisotsky');
ylabel('RGB values measured by ARRI sensors');
% hold on;

ieNewGraphWin;
estimatedFiltersRGB = estimatedFilters'*radiance;
estimatedFiltersRGB = estimatedFiltersRGB';
for ii=1:3
    plot(ieScale(estimatedFiltersRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList2{ii});
    hold on;
end
identityLine;
xlabel('RGB values predicted by the estimated sensors');
ylabel('RGB values measured by ARRI sensors');

% WE can probably do better ...

%% Read in the sensor data for the TLCI Standard Camera Model
% and compare to the predicted data
% This is just for curiousity ..
TLCISensor = ieReadSpectra('arriSensorNIRon.mat',wave);
ieNewGraphWin;
TLCISensor = ieScale(TLCISensor,1);
plot(wave,TLCISensor,'--',wave,estimatedFilters,'-');
legend({'TLCI','TLCI','TLCI','estimated','estimated','estimated'})
title('TLCI is the Standard Camera Model')

ieNewGraphWin;
plot(wave,TLCISensor(:,1),'r','linewidth',3); hold on;
plot(wave,TLCISensor(:,2),'g','linewidth',3); 
plot(wave,TLCISensor(:,3),'b','linewidth',3); 
plot(wave,estimatedFilters(:,1),'r--','linewidth',3); 
plot(wave,estimatedFilters(:,2),'g--','linewidth',3); 
plot(wave,estimatedFilters(:,3),'b--','linewidth',3); 
legend({'TLCI','TLCI','TLCI','estimated','estimated','estimated'})

% ieNewGraphWin;
% plot(arriSensor(:,1),estimatedFilters(:,1),'ro'); hold on;
% plot(arriSensor(:,2),estimatedFilters(:,2),'go'); 
% plot(arriSensor(:,3),estimatedFilters(:,3),'bo'); 
% identityLine;
%% Leave the green alone but make red and blue max relative to red
% arriMax = max(arriSensor);
% estMax = max(estimatedFilters);
% arriSensorScaled = arriSensor*diag([estMax(1)/arriMax(1),1,estMax(3)/arriMax(3)]);
% ieNewGraphWin;
% plot(wave,arriSensorScaled);
% 
% 
% arriScaledPredRGB = arriSensorScaled'*radiance;
% arriScaledPredRGB = arriScaledPredRGB';
% ieNewGraphWin;
% for ii=1:3
%     plot(ieScale(arriScaledPredRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList2{ii});
%     hold on;
% end
% identityLine;

TLCIPredRGB = TLCISensor'*radiance;
TLCIPredRGB = TLCIPredRGB';
ieNewGraphWin;
for ii=1:3
    plot(ieScale(TLCIPredRGB(:,ii),1),ieScale(mRGB(:,ii),1),colorList3{ii});
    hold on;
end
identityLine;
xlabel('RGB values predicted by the Standard (TLCI) Camera Model');
ylabel('RGB values measured by ARRI sensors');
% hold on;

% The Standard TLCI Camera model seems to be a very good fit for the data.


%%
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
% img = XW2RGBFormat(mRGB,4,6);
% img = imageIncreaseImageRGBSize(img,50);
% ieNewGraphWin;
% imagescRGB(img)
% 
% %%
% ieNewGraphWin;
% 
% rgbPredScaled = rgbPred/max(rgbPred(:));
% mRGBScaled = mRGB/max(mRGB(:));
% 
% symbolList = {'ro','gx','bs'};
% for ii=1:3
%     thisSymbol = symbolList{ii};
%     plot(mRGBScaled(:,ii),rgbPredScaled(:,ii),thisSymbol);
%     hold on;
% end
% 
% grid on;
% title('ARRI MCC image data captured under White light (ARRI)')
% xlabel('Measured');
% ylabel('Predicted');
% %% plot data for the "Alexa" sensor similar to that published by Karge 
% % see https://www.hdm-stuttgart.de/open-film-tools/english/publications/ProjectSummary.pdf
% 
% load('arriSensorDocumentation.mat');
% ieNewGraphWin;
% plot(blueARRIsensor(:,1), blueARRIsensor(:,2), 'b-');
% hold on;
% plot(greenARRIsensor(:,1), greenARRIsensor(:,2), 'g-');
% plot(redARRIsensor(:,1), redARRIsensor(:,2), 'r-');
% 
% 
% 
