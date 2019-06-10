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
whiteSony = ieReadSpectra('whiteSonyLight',wave);
whiteARRI = ieReadSpectra('whiteARRILight',wave);
ir        = ieReadSpectra('irSonyLight',wave);

%%
lights = [red(:),green(:),blue(:),violet(:),whiteSony(:),whiteARRI(:),ir(:)];
comment = 'Light order:  red, green, blue, violet, whiteSony, whiteARRI, IR. ';
comment = addText(comment,'Measured with the PR 715 and need to be corrected.');
lightFileName = fullfile(arriRootPath,'data','lights','arriLights.mat');
ieSaveSpectralFile(wave,lights,comment,lightFileName);

ieNewGraphWin;
plot(wave,lights);
legend({'red','green','blue','violet','whiteSony','whiteARRI','IR'});
xlabel('Wavelength (nm)');
ylabel('Energy (watts/sr/nm/m^2');
grid on

%% END