
%% s_arriSNR.m
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
%
% JEF 04/27/2020
%%
% First, calculate the spectral radiance or a white target by multiplying the R, G and
% B sensor spectral sensitivities with the light spectral energy
wave = 400:10:700;

% load the sensor spectral sensitivities
arriSensorFname = fullfile(arriRootPath,'data','sensor','ARRIestimatedSensors.mat');
arriQE = ieReadSpectra(arriSensorFname, wave);
plotRadiance(wave,arriQE,'title','ARRI sensor quantum efficiency');

% Load the lights  

testLights = {'whiteARRILight.mat',  'whiteSonyLight.mat','greenSonyLight.mat',...
    'blueSonyLight.mat','redSonyLight.mat','violetSonyLight.mat'};

% Multiply sensors and lights
sensorLight = zeros(numel(wave),3,numel(testLights));
for ii = 1:numel(testLights)
    thisLight = ieReadSpectra(testLights{ii},wave);
    sensorLight(:,:,ii) = diag(thisLight)*arriQE;
end

%% convert radiance to quanta
x=reshape(sensorLight,31,18);
Xphotons = Energy2Quanta(wave,x);
Y = sum(Xphotons); %per square meter/sec
Y = Y*1.0e-12; % per square micron/sec (assuming a 1 micron pixel)
Y = Y * 0.030 % per square micron in 30 msecs
SNR = Y./(Y.^0.5) % mean divided by the sqrt of the mean = SNR assuming poisson distribution - i.e. photon noise
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


%% Replace this with the median values - 
% these number are just eye-balled from plotting the digital values in horizotal and verticlal lines 
% in the ARRIScope RGB images for each of the different lights
% the max values

chdir(fullfile(arriRootPath,'data','WhiteCalibration_CameraImage_ari'));

% put in the same order as the test lights to match up
rgbImages = {'WhiteCalibration_arriwhite17_fIRon.ari','WhiteCalibration_white17_fIRon.ari','WhiteCalibration_green17_fIRon.ari', ...
  'WhiteCalibration_blue17_fIRon.ari','WhiteCalibration_red17_fIRon.ari','WhiteCalibration_violet17_fIRon.ari'};

rgbNoiseImages = {'WhiteCalibration_ambient_fIRoff.ari','WhiteCalibration_ambient_fIRon.ari'};
rgbNIRimage = {'WhiteCalibration_ir7_fIRoff.ari'};

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

% area = area';
% ieNewGraphWin;
% for ii = 1:numel(rgbImages)
%     plot(area(ii,1),mRGB(ii,1),'ro');  hold on; plot(area(ii,2),mRGB(ii,2),'ro'); plot(area(ii,3),mRGB(ii,3),'ro');
% end
%% Plot the predicted number of photons captured by a 1 micron pixel in 30 msec versus mRGB
ieNewGraphWin;
plot(mRGBv,Y,'r*');

% p = polyfit(mRGBv,Y,1);
% x1 =linspace(1,3.3956e+03,100);
% y1 = polyval(p,x1);
% figure;
% plot(mRGBv,Y,'o');
% hold on;
% plot(x1,y1);
% hold off;
% xlabel('Sensor Digital Value');
% ylabel('Number of Photons/1 micron pixel/30 msec');

%% Plot SNR as function of mRGB

mRGBv=reshape(mRGB',1,18);
ieNewGraphWin;
plot(mRGBv,SNRdb,'r*');
% p = polyfit(mRGBv,SNRdb,1);
% x1 =linspace(1,3.3956e+03,100);
% y1 = polyval(p,x1)
% figure
% plot(mRGBv,SNRdb,'o')
% hold on
% plot(x1,y1)
% hold off

semilogx(mRGBv,SNRdb,'r*');

ylabel('SNR(db)');
xlabel('Digital Sensor Value (Median)');

ieNewGraphWin;
plot(mRGBv,Y,'b*');


%% 18 channels (Sensor * Light) can be expressed as 9 independent channel (99% of the variance)
x=reshape(sensorLight,31,18);
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
% Channels_9 = [x(:,1),x(:,2), x(:,3),x(:,1),x(:,2),x(:,3),x(:,8),x(:,12),x(:,13)];
% wave = 400:10:700;
% [u,s,v] = svd(Channels_9);
% ieNewGraphWin; plot(cumsum(diag(s))/sum(diag(s)));
% ieNewGraphWin; plot(wave,u(:,1:6));
%%
% Ordered by importance
% ChannelWeights = [
% 0.900139520329970,
% 0.527211334257650,
% 0.517690492274477,
% 0.064133134089122,
% 0.058752771282927,
% 0.032720150026183,
% 0.019016733291279,
% 0.018588081146993,
% 0.012956116616509, 
% 0.008471819128116, 
% 0.004361067924349, 
% 0.002455802813958,
% 0.002326910168862,
% 0.000461380910664,
% 0.000307125166778,
% 0.000202755072111,
% 0.000129388743710, 
% 0.000092629885304];
% 
% ieNewGraphWin; bar(ChannelWeights);
% SummedEnergy = [3400,2000,1900,225,200,160,70,70,65,25,10,10,10,10,10,10,10,10];
% ieNewGraphWin; plot(ChannelWeights, SummedEnergy,'*');
