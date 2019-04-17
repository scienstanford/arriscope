%% Download a single arriRGB image and choose an ROI
%
% We will then use this ROI to select out data from all the other images in
% another script.
%
% JEF
%
% See also
%  s_arriMultispectralMeasure
%

%% Open up to the data on Flywheel
st = scitran('stanfordlabs');
st.verify;

% Work in this project
project      = st.lookup('arriscope/ARRIScope Tissue'); 

%% Choose a session and acquisition 

% Keep the double quotes or else Flywheel will read the string as a number.
thisSession  = project.sessions.findOne('label="20190412"');
thisAcq      = thisSession.acquisitions.findOne('label=Bone');
disp(thisAcq.label)

% Choose the ari zip file with the images
files    = thisAcq.files;
zipFile = stSelect(files,'name','Bone_CameraImage_ari.zip');

% Find out the filenames in the zip archive
zipInfo = thisAcq.getFileZipInfo(zipFile{1}.name);
stPrint(zipInfo.members,'path')

% Download one that you like
entryName = zipInfo.members{1}.path;
outName = fullfile(arriRootPath,'local',entryName);
thisAcq.downloadFileZipMember(zipArchive,entryName,outName);

%% Read the arri image and select the rect 

arriRGB = arriRead(outName);
ip = ipCreate;
ip = ipSet(ip,'display output',arriRGB);
ipWindow(ip);

% Pick a region to use to get the other values
[~,rect] = ieROISelect(ip);

disp(rect)

%%