
% s_TissuePCA_HumanDatasets

% ScholsTissueReflectances.mat
% WisotzkyTissueReflectances.mat

%% 
ieInit % clear all variables

%% 
% Schols RM, Alic L, Beets GL, Breukink SO, Wieringa FP, Stassen LP. 
% Automated Spectroscopic Tissue Classification in Colorectal Surgery. 
% Surg Innov. 2015 Dec;22(6):557-67. 
% doi: 10.1177/1553350615569076. Epub 2015 Feb 3. PMID: 25652527.

% "In vivo wide-band (wavelength range 350-1830 nm) DRS was performed during open colorectal surgery"
% 253 spectra were recorded on 53 tissue sites (including colon, adipose tissue, muscle, artery, vein, ureter).

% see peaks and troughs at 540, 560 and 580 (more so if we include data from 400 to 1800 nm
% wave = 400:10:700; % over this range, we see peaks and troughs at 
wave = 400:10:1800; % the spectra are scaled such mean reflectance is removed 
% 6 spectral samples, first 3 principle components account for 
tissue = ieReadSpectra('ScholsTissueReflectances.mat',wave);
plotReflectance(wave,tissue);

% Principal components analysis 
nDim = 3;

% tissue = U * S * V'
% U = Linear Model
% wgts = S*V'
% If you reduce the dimension, then
% We will put all this in Zheng's function

[linModel,S,V] = svd(tissue);
linModel = linModel(:,1:nDim);
wgts = S*V'; wgts = wgts(1:nDim,:);

ieNewGraphWin; plot(wave,linModel,'linewidth',2); % The linModel are the N spectral basis funtions
xaxisLine;
S = diag(S);
percentV = cumsum(S.^2)/sum(S.^2); % check to see if this is the right calculation for percent variance accounted for

% Plot the percent variance accounted for as a function of the number of basis functions
ieNewGraphWin; plot(percentV* 100,'k','linewidth',3); 
xlabel('Number of principal component');
ylabel('Percent Variance Accounted For');

% Plot measured and estimated tissue reflectance
predReflectance = linModel*wgts;
ieNewGraphWin; plot(wave,tissue,'linewidth',2);
hold on;
plot(wave,predReflectance,'--','linewidth',2);
hold off

%%
wave = 400:10:640; % the spectra are scaled such mean reflectance is removed 
% 6 spectral samples, first 3 principle components account for 
tissue = ieReadSpectra('WisotskyTissueReflectances.mat',wave);
ieNewGraphWin; plotReflectance(wave,tissue);

% Principal components analysis 
nDim = 3;

% tissue = U * S * V'
% U = Linear Model
% wgts = S*V'
% If you reduce the dimension, then
% We will put all this in Zheng's function

[linModel,S,V] = svd(tissue);
linModel = linModel(:,1:nDim);
wgts = S*V'; wgts = wgts(1:nDim,:);

ieNewGraphWin; plot(wave,linModel,'linewidth',2); % The linModel are the N spectral basis funtions
xaxisLine;
S = diag(S);
percentV = cumsum(S.^2)/sum(S.^2); % check to see if this is the right calculation for percent variance accounted for

% Plot the percent variance accounted for as a function of the number of basis functions
ieNewGraphWin; plot(percentV* 100,'k','linewidth',3); 
xlabel('Number of principal component');
ylabel('Percent Variance Accounted For');

% Plot measured and estimated tissue reflectance
predReflectance = linModel*wgts;
ieNewGraphWin; plot(wave,tissue,'linewidth',2);
hold on;
plot(wave,predReflectance,'--','linewidth',2);
hold off
