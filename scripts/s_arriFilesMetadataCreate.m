%% Download a set of arri RGB from FLywheel, creates Matlab files with metadata
%
% The files are then uploaded back to the Flywheel acquisition.
%
% This script unpacks arri RGB data from the zip file into Matlab and puts
% the data back into its acquisition on Flywheel.  The upload includes some
% both the Matlab files and metadata about the light name and light level
% of those files.
%
% You only need to do this once.
%
% JEF
%
% See also
%   s_arriROISelect, s_arriMultispectralMeasure
%

%% Open up to the data on Flywheel
st = scitran('stanfordlabs');
st.verify;

% Work in this project
project = st.lookup('arriscope/ARRIScope Tissue'); 

%% Find the session and acquisition of interest

thisSession  = project.sessions.findOne('label="20190412"');
thisAcq      = thisSession.acquisitions.findOne('label=Bone');

%% Convert ARRI files to Matlab files with metadata in them

% Working directory
chdir(fullfile(arriRootPath,'local',thisAcq.label));

% dir
localFiles = dir('*.ari');
nFiles = length(localFiles);

% These are the set of possible lights defined in the function
% lightNames = arriLights;
for ii=1:nFiles
    % For each file we extract some information
    [lightName, lightLevel] = arriLightLevel(localFiles(ii).name);
    arriRGB = arriRead(localFiles(ii).name);
    % [~,idx] = arriLights(lightNames{ii});
    
    % Build up a data structure for this light and sample
    light = lightName;
    rgb   = arriRGB;
    acqID = thisAcq.id;
    fname = fullfile(pwd,[lightName,'.mat']);
    tissueName = thisAcq.label;
    save(fname,'arriRGB','lightName','lightLevel','acqID','tissueName');
    
    %{
     % Check the RGB image, if you like
     data = load(fname);
     load(fname,'arriRGB'); 
     ieNewGraphWin; imagescRGB(arriRGB.^0.3);
    %}
    
    % [id,oType] = st.objectParse(thisAcq);
    st.fileUpload(fname,thisAcq.id,'acquisition');
end
