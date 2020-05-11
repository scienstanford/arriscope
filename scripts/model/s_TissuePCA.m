
% s_TissuePCA

% Calculate the principal components with and without the mean removed
% Plot predicted and measured reflectances

% Tissue reflectances contain: 
    % Nerve_StelzleEtAl2012.mat
    % Nerve_StelzleEtAl2014.mat
    % Fat_StelzleEtAl2012.mat
    % Mucosa_StelzleEtAl2012.mat
    % CancellousBone_StelzleEtAl2014.mat
    % CorticalBone_StelzleEtAl2014.mat
    % HardBone_StelzleEtAl2011.mat
    % Skin_StelzleEtAl2012.mat
    % SalivaryGland_StelzleEtAl2012.mat
    % SoftBone_StelzleEtAl2011.mat
    % Muscle_StelzleEtAl2012.mat

wave = 400:10:640;
tissue = ieReadSpectra('tissueReflectances.mat',wave);
plotReflectance(wave,tissue);

%% Scale the data in various ways

% Plot the tissue reflectance scaled by the area under the curve 
%   scale = sum(tissue);
%   tissueScaled = tissue*diag(1./scale);
%   ieNewGraphWin; plot(wave,tissueScaled,'linewidth',2);
%   comment = 'tissue reflectances scaled by the area under the curve';
%   data = tissueScaled;
%   ieSaveSpectralFile(wave,data,comment);
  
  
%{
 meanT = mean(tissue,2);
 tissueDemeaned = tissue - meanT;
 ieNewGraphWin; plot(wave,tissueDemeaned,'linewidth',2);
%}

% Plot the tissue reflectance scaled by the maximum values
%{
  scale = max(tissue);
  tissueScaled = tissue*diag(1./scale);
  ieNewGraphWin; plot(wave,tissueScaled,'linewidth',2);
title('Scaled by Max');
%}

%% Principal components analysis 
nDim = 6;

% tissue = U * S * V'
% U = Linear Model
% wgts = S*V'
% If you reduce the dimension, then
% We will put all this in Zheng's function

[linModel,S,V] = svd(tissue);
linModel = linModel(:,1:nDim);
wgts = S*V'; wgts = wgts(1:nDim,:);

ieNewGraphWin; plot(wave,linModel,'linewidth',2);; % The linModel are the N spectral basis funtions
xaxisLine;
S = diag(S);
percentV = cumsum(S.^2)/sum(S.^2); % check to see if this is the right calculation for percent variance accounted for
%{
ieNewGraphWin; plot(percentV,'k','linewidth',3); 
xlabel('Number of principal component');
ylabel('Percent Variance Accounted For');
}%

predReflectance = linModel*wgts;

ieNewGraphWin; plot(wave,tissue,'linewidth',2);
hold on;
plot(wave,predReflectance,'--','linewidth',2);
hold off

%% Remove the mean  (just an exercise ... the mean is the first component above)
nDim = 5;
 meanT = mean(tissue,2);
 tissueDemeaned = tissue - meanT;
 [linModel,S,V] = svd(tissueDemeaned);
linModel = linModel(:,1:nDim);
wgts = S*V'; wgts = wgts(1:nDim,:);

plotReflectance(wave,linModel); % The linModel are the N spectral basis funtions
xaxisLine;
S = diag(S);
percentV = cumsum(S.^2)/sum(S.^2); % check to see if this is the right calculation for percent variance accounted for

predReflectance = linModel*wgts;

ieNewGraphWin;
n = 4;
for ii = 1:n
plot(wave,linModel(:,ii),'linewidth',3); hold on;
xlabel('Wavelength (nm)');
end

plotReflectance(wave,tissueDemeaned);
hold on;
plot(wave,predReflectance,'--');
hold off
