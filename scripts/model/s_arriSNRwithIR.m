
%% s_arriSNRwithIR.m
% 
% Purpose: calculate the SNR for each channel of a multispectral imaging system
%
% Background
%   A multispectral imaging system has more than 3 spectral channels.  
%   One type of multispectral imaging system creates multiple spectral channels by 
%   combining different spectrally-tuned sensors with different spectral lights. 
%   The spectral sensivitiy of each channel in a multispectral imaging system is thus defined by 
%   the spectral sensitivities of the sensor (R, G or B) and 
%   the spectral power of the illuminant.
%
% Method
%   We use the spectral sensitivity of the sensor and the spectral power of
%   the light to calculate the maximum number of photons (Y) a channel can
%   collect in a single pixel (assume 1 micron) and a single exposure
%   (assume 30 msec)
%   We then calculate channel SNR using the formula SNR = 20 * log10(Y./(Y.^0.5)) 

%   Redo this using the ScaledSony.mat and FilteredAndScaledSony.mat
%
%
%
% JEF 02/12/2022
%{
cd /users/joyce/GitHub/isetcam;
addpath(genpath(pwd));
cd /users/joyce/GitHub/arriscope;
addpath(genpath(pwd));
%}
%%
% First, calculate the spectral radiance or a white target by multiplying the R, G and
% B sensor spectral sensitivities with the light spectral energy

%% for 6 lights and RGB sensors with NIR blocking filter
wave = 400:10:900;
% load the sensor spectral sensitivities
arriSensorFname = fullfile(arriRootPath,'data','sensor','ScaledSony.mat');
arriQE = ieReadSpectra(arriSensorFname, wave);
% plotRadiance(wave,arriQE,'title','ARRI sensor quantum efficiency');
arriSensorFname = fullfile(arriRootPath,'data','sensor','FilteredAndScaledSonyQE.mat');
arriQEwithNIR = ieReadSpectra(arriSensorFname, wave);
arriQEwithNIR = max(arriQEwithNIR,0);
% plotRadiance(wave,arriQEwithIR,'title','ARRI sensor quantum efficiency with NIR blocking filter');

% Load the lights 
% TODO - delete violetSonyLight.mat ??
testLights = {'whiteARRILight.mat',  'whiteSonyLight.mat','greenSonyLight.mat',...
    'blueSonyLight.mat','redSonyLight.mat','violetSonyLight.mat'};

% Multiply sensors and lights
%sensorLight = zeros(numel(wave),3,numel(testLights));
sensorLight = zeros(numel(wave),3,7);
for ii = 1:numel(testLights)
    thisLight = ieReadSpectra(testLights{ii},wave);
    sensorLight(:,:,ii) = diag(thisLight)*arriQEwithNIR;
end

%%  for 1 light and RGB sensors with no NIR blocking filter

% Multiply sensors and lights
IRLight = ieReadSpectra('irSonyLIght.mat',wave);
IRsensorLight(:,:) = diag(IRLight)* arriQE;

%% create sensorLight to be 51x21 matrix
sensorLight(:,:,7) = IRsensorLight;
%% First, plot the lights
ieNewGraphWin;
for ii = 1:numel(testLights)
    thisLight = ieReadSpectra(testLights{ii},wave);
  plot(wave,thisLight); hold on;
end
plot(wave,IRLight);
xlabel('Wavelength (nm)');
ylabel('Energy (quanta/nm/sec/sr/m^2)');

%% Second, plot the sensors
%TODO - select sensors that predict the MCC data and have the same QE
%between 400 and 700 nm
ieNewGraphWin;
plot(wave,arriQE(:,1),'r'); hold on;
plot(wave,arriQE(:,2),'g'); hold on;
plot(wave,arriQE(:,3),'b'); hold on;
plot(wave,arriQEwithNIR(:,1),'r--'); hold on;
plot(wave,arriQEwithNIR(:,2),'g--'); hold on;
plot(wave,arriQEwithNIR(:,3),'b--'); hold on;

%% Third, plot sensor * light
ieNewGraphWin;
plot(wave,sensorLight(:,1,1),'r');hold on;
plot(wave,sensorLight(:,2,1),'g');
plot(wave,sensorLight(:,3,1),'b');
plot(wave,sensorLight(:,1,2),'r')
plot(wave,sensorLight(:,2,2),'g')
plot(wave,sensorLight(:,3,2),'b')
plot(wave,sensorLight(:,1,3),'r');
plot(wave,sensorLight(:,2,3),'g');
plot(wave,sensorLight(:,3,3),'b');
plot(wave,sensorLight(:,1,4),'r')
plot(wave,sensorLight(:,2,4),'g')
plot(wave,sensorLight(:,3,4),'b')
plot(wave,sensorLight(:,1,5),'r');
plot(wave,sensorLight(:,2,5),'g');
plot(wave,sensorLight(:,3,5),'b');
plot(wave,sensorLight(:,1,6),'r')
plot(wave,sensorLight(:,2,6),'g')
plot(wave,sensorLight(:,3,6),'b')
plot(wave,sensorLight(:,1,6),'r')
plot(wave,sensorLight(:,2,6),'g')
plot(wave,sensorLight(:,3,6),'b')
plot(wave,sensorLight(:,1,7),'r--'); 
plot(wave,sensorLight(:,2,7),'g--')
plot(wave,sensorLight(:,3,7),'b--')

%% convert radiance to quanta
x=reshape(sensorLight,51,21);
Xphotons = Energy2Quanta(wave,x);
Y = sum(Xphotons); %per square meter/sec
Y = Y*1.0e-12; % per square micron/sec (assuming a 1 micron pixel)
Y = Y * 0.030 % per square micron in 30 msecs
SNR = Y./(Y.^0.5); % mean divided by the sqrt of the mean = SNR assuming poisson distribution - i.e. photon noise
SNRdb = 20 * log10(SNR);

% Integrate the energy per channel - reolaced with SNR calculation above
% only for documentation purposes
% ieNewGraphWin;
% area = zeros(3,numel(testLights));
% for ii=1:numel(testLights)
%     plot(wave,sensorLight(:,:,ii))
%     hold on;
% %     testLights(ii)
%     area(:,ii) = sum(sensorLight(:,:,ii))';
% end

%% calculate the median RGB values for white target illuminated with lights
% added WhiteCalibration_ir7_fIRoff.ari c

chdir(fullfile(arriRootPath,'data','WhiteCalibration_CameraImage_ari'));

% put in the same order as the test lights to match up
rgbImages = {'WhiteCalibration_arriwhite17_fIRon.ari','WhiteCalibration_white17_fIRon.ari','WhiteCalibration_green17_fIRon.ari', ...
  'WhiteCalibration_blue17_fIRon.ari','WhiteCalibration_red17_fIRon.ari','WhiteCalibration_violet17_fIRon.ari','WhiteCalibration_ir7_fIRoff.ari'};

% not sure why we calculate this
% rgbNoiseImages = {'WhiteCalibration_ambient_fIRoff.ari','WhiteCalibration_ambient_fIRon.ari'};
% rgbNIRimage = {'WhiteCalibration_ir7_fIRoff.ari'}

ip = ipCreate;
ip = ipSet(ip,'correction method illuminant','none');
ip = ipSet(ip,'conversion method sensor','none');

 img = arriRead(rgbImages{1},'image','left');
 img = imresize(img,1/4);
 ip = ipSet(ip,'result',img);
 ipWindow(ip); 
%  [roiLocs,rect]=ieROISelect(ip);
 rect = [165 35 228 224];
roiLocs=ieRect2Locs(rect);

mRGB = [];
for ii=1:numel(rgbImages)
    img = arriRead(rgbImages{ii},'image','left');
    img = imresize(img,1/4);
    ip  = ipSet(ip,'result',img); 
    thisRGB = median(vcGetROIData(ip,roiLocs,'result'));
    mRGB = [mRGB; thisRGB];
end

%{
area = area';
ieNewGraphWin;
 for ii = 1:numel(rgbImages)
     plot(area(ii,1),mRGB(ii,1),'ro');  hold on; plot(area(ii,2),mRGB(ii,2),'ro'); plot(area(ii,3),mRGB(ii,3),'ro');
end
%}
%% Plot the predicted number of photons captured by a 1 micron pixel in 30 msec versus mRGB
% The number of photons are linearly related to digital values 
%{
ieNewGraphWin;
p = polyfit(mRGBv,Y,1);
x1 =linspace(1,3.3956e+03,100);
y1 = polyval(p,x1);
plot(mRGBv,Y,'o'); hold on;
plot(x1,y1);
hold off;
xlabel('Sensor Digital Value');
ylabel('Number of Photons/1 micron pixel/30 msec');
%}

% make a plot that shows that Digital values increase linearly with the function of number of photons


%% Plot SNR as function of mRGB
% note that this figure looks different if I do not include the IR condition
mRGBv=reshape(mRGB',1,21);
ieNewGraphWin;
plot(mRGBv,SNRdb,'r*');
xlabel('Sensor Digital Value')
ylabel('SNR (db)')
%{
 p = polyfit(mRGBv,SNRdb,1);
 x1 =linspace(1,3.3956e+03,100);
 y1 = polyval(p,x1);
 figure;
 plot(mRGBv,SNRdb,'o');
 hold on;
plot(x1,y1)
 hold off
%}

semilogx(mRGBv,SNRdb,'r*');
ylabel('SNR(db)');
xlabel('Digital Sensor Value (Median)');
ieNewGraphWin;
plot(mRGBv,Y,'b*');

%% 21 channels (Sensor * Light) can be expressed as 9 independent channel (99% of the variance)
x=reshape(sensorLight,51,21);
ieNewGraphWin; plot(wave,x);
[u,s,v] = svd(x);
ieNewGraphWin; plot(cumsum(diag(s))/sum(diag(s)));
ieNewGraphWin; plot(wave,u(:,1:9));
%% Remove the spectral channels that we consider to be noise
% Retain 9 spectral channels
%   R, G and B sensors * ARRI white     x(:,1), x(:,2), x(:,3)
%   R, G and B sensors * Sony white     x(:,1), x(:,2), x(:,3)
%   G sensor * Sony green               x(:,8)
%   B sensor * Sony blue                x(:,12)
%   R sensor * Sony red                 x(:,13)
%   B sensor * Sony green               x(:,9)
%{
 Channels_9 = [x(:,1),x(:,2), x(:,3),x(:,1),x(:,2),x(:,3),x(:,8),x(:,12),x(:,13)];
 wave = 400:10:700;
 [u,s,v] = svd(Channels_9);
 ieNewGraphWin; plot(cumsum(diag(s))/sum(diag(s)));
 ieNewGraphWin; plot(wave,u(:,1:6));
%}

