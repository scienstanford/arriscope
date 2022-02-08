% s_plotWitsozky
%
% Note that his data on spectral reflectance estimate are not goog
% not sure if we should waste any time figuring out why
% he is one of the few people who measure spectral IMAGES, rather than
% spots.  This could point out the challenges of calibration of light over
% regions


%% Find the files
chdir(fullfile(arriRootPath,'data','tissue','HumanInVivo','Wisotsky'));
matFiles = dir('*.mat');
nFiles = numel(matFiles);

%% Build the data
outFile = 'WisotskyTissueReflectances';
wave = 400:10:640;
tissueNames = cell(nFiles,1);
comments = cell(nFiles,1);
data = zeros(numel(wave),nFiles);
for ii=1:nFiles
    tissueNames{ii} = matFiles(ii).name;
    [data(:,ii),~,comments{ii}] = ieReadSpectra(matFiles(ii).name,wave);
end
% plotReflectance(wave,data);
data = data*100;
%% Save the reflectance data
ieSaveSpectralFile(wave,data,comments,fullfile(pwd,outFile));

%% Test reading
tissue = ieReadSpectra(outFile,wave);
plotReflectance(wave,tissue);
    