%% Converts the light calibration data into ISET spectral format
%
% Joyce measured these.
%
% JEF/BW

%%
chdir(fullfile(arriRootPath,'data','lights'))
wave = 400:1:900;

blue      = ieReadSpectra('blueSonyLight',wave);
violet    = ieReadSpectra('violetSonyLight',wave);
green     = ieReadSpectra('greenSonyLight',wave);
red       = ieReadSpectra('redSonyLight',wave);
white     = ieReadSpectra('whiteSonyLight',wave);
arriwhite = ieReadSpectra('whiteARRILight',wave);
ir        = ieReadSpectra('irSonyLight',wave);

%% whiteSony and whitemix are the same

lightSpectra = [violet(:),blue(:),green(:),red(:),white(:),arriwhite(:),ir(:)];

% A list of all the lights
comment.lightNames = arriLights;
comment.description = 'Measured with the PR 715 and need to be corrected.';
lightFileName = fullfile(arriRootPath,'data','lights','arriLights.mat');
ieSaveSpectralFile(wave,lightSpectra,comment,lightFileName);

ieNewGraphWin;
plot(wave,lightSpectra);
legend(arriLights);
xlabel('Wavelength (nm)'); ylabel('Energy (watts/sr/nm/m^2'); grid on

%% END