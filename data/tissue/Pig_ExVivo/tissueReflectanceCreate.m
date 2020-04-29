%% Make the combined tissue samples from the Pig data
%
%
% See also
%

%% Find the files
chdir(fullfile(arriRootPath,'data','tissue','Pig_ExVivo'));
matFiles = dir('*.mat');
nFiles = numel(matFiles);

%% Build the data
outFile = 'tissueReflectances';
wave = 400:10:640;
tissueNames = cell(nFiles,1);
comments = cell(nFiles,1);
data = zeros(numel(wave),nFiles);
for ii=1:nFiles
    tissueNames{ii} = matFiles(ii).name;
    [data(:,ii),~,comments{ii}] = ieReadSpectra(matFiles(ii).name,wave);
end
% plotReflectance(wave,data);

%% Save the reflectance data
ieSaveSpectralFile(wave,data,comments,fullfile(pwd,outFile));

%% Test reading
tissue = ieReadSpectra(outFile,wave);
plotReflectance(wave,tissue);


    