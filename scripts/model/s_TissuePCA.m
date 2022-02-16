
% s_TissuePCA
ieInit % clear all variables

% Calculate the principal components with and without the mean removed
% Plot predicted and measured reflectances

%    {'Pig Cancellous Bone spectral reflectance data published by Stelzle et al 2014'}
%     {'Pig Cortical Bone spectral reflectance data published by Stelzle et al 2014'  }
%     {'Pig Fat spectral reflectance data published by Stelzle et al 2012'            }
%     {'Pig Hard Bone spectral reflectance data by Stelzle et al 2011'                }
%     {'Pig Mucosa spectral reflectance data published by Stelzle et al 2012'         }
%     {'Pig Muscle spectral reflectance data published by Stelzle et al 2012'         }
%     {'Pig Nerve spectral reflectance data published by Stelzle et al 2012'          }
%     {'Pig Nerve spectral reflectance data published by Stelzle et al 2014'          }
%     {'Pig Salivary Gland spectral reflectance data published by Stelzle et al 2014' }
%     {'Pig Skin spectral reflectance data by Stelzle et al 2012'                     }
%     {'Pig Soft Bone spectral reflectance data published by Stelzle et al 2011'      }


wave = 400:10:640;
tissue = ieReadSpectra('tissueReflectances.mat',wave);
plotReflectance(wave,tissue);

%% Scale the data in various ways

% Plot the tissue reflectance scaled by the area under the curve 
%{   
scale = sum(tissue);
tissueScaled = tissue*diag(1./scale);
ieNewGraphWin; plot(wave,tissueScaled,'linewidth',2);
comment = 'tissue reflectances scaled by the area under the curve';
data = tissueScaled;
% ieSaveSpectralFile(wave,data,comment);
%}   
  
  
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
nDim = 2;

% tissue = U * S * V'
% U = Linear Model
% wgts = S*V'
% If you reduce the dimension, then
% We will put all this in Zheng's function

[linModel,S,V] = svd(tissue);
linModel = linModel(:,1:nDim);
wgts = S*V'; wgts = wgts(1:nDim,:);

ieNewGraphWin; plot(wave,linModel,'linewidth',2);; % The linModel are the N spectral basis functions
xaxisLine;
S = diag(S);
percentV = cumsum(S.^2)/sum(S.^2); % check to see if this is the right calculation for percent variance accounted for

% Plot the percent variance accounted for as a function of the number of basis functions
ieNewGraphWin; plot(percentV,'k','linewidth',3); 
xlabel('Number of principal component');
ylabel('Percent Variance Accounted For');

% Plot measured and estimated tissue reflectance
predReflectance = linModel*wgts;
ieNewGraphWin; plot(wave,tissue,'linewidth',2);
hold on;
plot(wave,predReflectance,'--','linewidth',2);
hold off

%% Remove the mean  (just an exercise ... the mean is the first component above)
nDim = 2;
 meanT = mean(tissue,2);
 tissueDemeaned = tissue - meanT;
 [linModel,S,V] = svd(tissueDemeaned);
linModel = linModel(:,1:nDim);
wgts = S*V'; wgts = wgts(1:nDim,:);

ieNewGraphWin; plot(wave,linModel,'linewidth',2); % The linModel are the N spectral basis funtions
xaxisLine;
S = diag(S);
percentV = cumsum(S.^2)/sum(S.^2); % check to see if this is the right calculation for percent variance accounted for

predReflectance2 = linModel*wgts;
plotReflectance(wave,tissueDemeaned);
hold on;
plot(wave,predReflectance2,'--');
hold off

ieNewGraphWin; plot(predReflectance, tissue,'*');hold on;
plot(predReflectance2, tissueDemeaned,'*')

%%

% Plot the tissue reflectance scaled by the area under the curve 
  scale = sum(tissue);
  tissueScaled = tissue*diag(1./scale);
  ieNewGraphWin; plot(wave,tissueScaled,'linewidth',2);

  % SVD on scaled tissue reflectances
[linModel,S,V] = svd(tissueScaled);
linModel = linModel(:,1:nDim);
wgts = S*V'; wgts = wgts(1:nDim,:);

% ieNewGraphWin; plot(wave,linModel,'linewidth',2);; % The linModel are the N spectral basis funtions
% xaxisLine;
% S = diag(S);
% percentV = cumsum(S.^2)/sum(S.^2); % check to see if this is the right calculation for percent variance accounted for

% Plot the percent variance accounted for as a function of the number of basis functions
ieNewGraphWin; plot(percentV,'k','linewidth',3); 
xlabel('Number of principal component');
ylabel('Percent Variance Accounted For');

% Plot measured and estimated tissue reflectance
predReflectance = linModel*wgts;
ieNewGraphWin; plot(wave,tissueScaled,'linewidth',2);
hold on;
plot(wave,predReflectance,'--','linewidth',2);
hold off

%%
%    {'Pig Cancellous Bone spectral reflectance data published by Stelzle et al 2014'}
%     {'Pig Cortical Bone spectral reflectance data published by Stelzle et al 2014'  }
%     {'Pig Fat spectral reflectance data published by Stelzle et al 2012'            }
%     {'Pig Hard Bone spectral reflectance data by Stelzle et al 2011'                }
%     {'Pig Mucosa spectral reflectance data published by Stelzle et al 2012'         }
%     {'Pig Muscle spectral reflectance data published by Stelzle et al 2012'         }
%     {'Pig Nerve spectral reflectance data published by Stelzle et al 2012'          }
%     {'Pig Nerve spectral reflectance data published by Stelzle et al 2014'          }
%     {'Pig Salivary Gland spectral reflectance data published by Stelzle et al 2014' }
%     {'Pig Skin spectral reflectance data by Stelzle et al 2012'                     }
%     {'Pig Soft Bone spectral reflectance data published by Stelzle et al 2011'      }

tissueType = {'nerve (2012)','nerve (2014)','fat (2012)', 'mucosa (2012)','muscle (2012)', 'salivary gland (2014)', 'skin (2012)', 'hard bone (2011)', 'soft bone (2011)', 'cancellous bone (2014)', 'cortical bone (2014)'};
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
    ieNewGraphWin;
    plot(wave,tissueScaled(:,7),'r-','linewidth',2);hold on; % nerve
    plot(wave,tissueScaled(:,8),'r--','linewidth',2); % nerve
    plot(wave,tissueScaled(:,3),'b-','linewidth',2); % fat
    plot(wave,tissueScaled(:,5),'g-','linewidth',2); % mucosa
    plot(wave,tissueScaled(:,6),'k-','linewidth',2); % muscle
    plot(wave,tissueScaled(:,9),'c-','linewidth',2); % salivary gland
    plot(wave,tissueScaled(:,10),'m-','linewidth',2); % skin
    plot(wave,tissueScaled(:,4),'k-+','linewidth',2); % hard bone
    plot(wave,tissueScaled(:,11),'k-*','linewidth',2); % soft bone
    plot(wave,tissueScaled(:,1),'k-s','linewidth',2); % cancellous bone
    plot(wave,tissueScaled(:,2),'k-d','linewidth',2); % cortical bone
    xlabel('Wavelength(nm');
    ax = gca;
    ax.FontSize = 16;
     ylim([0,0.1]);
    legend(tissueType,'FontSize',14);
    
   %% 
   
   ieNewGraphWin;
     plot(wave,tissue(:,7),'r-','linewidth',2);hold on; % nerve
    plot(wave,tissue(:,8),'r--','linewidth',2); % nerve
    plot(wave,tissue(:,3),'b-','linewidth',2); % fat
    plot(wave,tissue(:,5),'g-','linewidth',2); % mucosa
    plot(wave,tissue(:,6),'k-','linewidth',2); % muscle
    plot(wave,tissue(:,9),'c-','linewidth',2); % salivary gland
    plot(wave,tissue(:,10),'m-','linewidth',2); % skin
    plot(wave,tissue(:,4),'k-+','linewidth',2); % hard bone
    plot(wave,tissue(:,11),'k-*','linewidth',2); % soft bone
    plot(wave,tissue(:,1),'k-s','linewidth',2); % cancellous bone
    plot(wave,tissue(:,2),'k-d','linewidth',2); % cortical bone
   xlabel('Wavelength (nm','fontsize',18);
   ylabel('Reflectance (%/100)','fontsize',18);
   ylim([0,1]);
   ax = gca;
   ax.FontSize = 16;
   legend(tissueType,'FontSize',14);