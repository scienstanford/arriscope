
%% s_totalEnergyPerSpectralChannel
% First, calculate the total energy per channel by multiplying the R, G and
% B sensor spectral sensitivities with the light spectral energy

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
    sensorLight(:,:,ii) = diag(thisLight)*estimatedFilters;
end

% Integrate the energy per channel
ieNewGraphWin;
area = zeros(3,numel(testLights));
for ii=1:numel(testLights)
    plot(wave,sensorLight(:,:,ii))
    hold on;
%     testLights(ii)
    area(:,ii) = sum(sensorLight(:,:,ii))';
end


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

area = area';

ieNewGraphWin;
for ii = 1:numel(rgbImages)
    plot(area(ii,1),mRGB(ii,1),'ro');  hold on; plot(area(ii,2),mRGB(ii,2),'ro'); plot(area(ii,3),mRGB(ii,3),'ro');
end

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
