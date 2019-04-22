%% s_arriGetMeanRGBvalues.m

% Purpose: Jared made measurements stored in Arriscope Tissue from
% cadaver data.  This routine 
%
%   Specifies a Session and Acquisition
%   Specifies a rect (see s_arriROISelect)
%   Reads the relevant Arri camera files
%   Returns the ARRI RGB raw camera values for the specimen illuminated under the different lights 
%       white (Specimen_white20_fIRon.ari) 
%       blue (Specimen_blue17_fIRon.ari)
%       green (Specimen_green17_fIRon.ari)
%       IR (Specimen_ir7_fIRoff.ari) 
%           note that this has NIR blocking filter off (i.e. fiRoff)
%       red (Specimen_red17_fIRon.ari)
%       violet (Specimen_violet17_fIRon.ari)
%       white (Specimen_white17_fIRon.ari)
%       whitemix (Specimen_whitemix17_fIRon.ari) 
%  
%
% Background:
%
% IN THIS SCRIPT we
%   1. Download the data for one specimen type under N lights from the Flywheel database
%   2. unzip the data into a local directory
%   3. Select a rectangular region of pixels from one camera image (rect)
%   4. Use that rect to select and calculate the mean R, G and B raw camera
%   pixel values for all camera images (i.e. corresponding pixels for
%   specimen under all N lights)
%
% JEF  SCIENSTANFORD, 2019
%
% See also s_arriROISelect.m
%
% TODO:
%   create a warning for saturated pixel values
%   save a file with matrix containing 
%       metadata and data
%       name of camera image, rect, mean and sdev of pixel values
%   improve histogram plots

%% initialize
ieInit;
% the first time you connect to Flywheel 
%       see https://github.com/vistalab/scitran/wiki/Connecting-and-Authentication 
%           if you have done this and cannot run the section below
%               try getting out of Matlab and opening again
%% Open up to the data on Flywheel
st = scitran('stanfordlabs');
st.verify;

% Work in this project
project      = st.lookup('arriscope/ARRIScope Tissue'); 

%% Choose a session and acquisition 

% Keep the double quotes or else Flywheel will read the string as a number.
thisSession  = project.sessions.findOne('label="20190412"');
thisAcq      = thisSession.acquisitions.findOne('label=Bone');
disp(thisAcq.label); 

% Choose the ari zip file with the images
files    = thisAcq.files;
zipFile = stSelect(files,'name','Bone_CameraImage_ari.zip');
zipArchive = 'Bone_CameraImage_ari.zip';

% Find out the filenames in the zip archive
zipInfo = thisAcq.getFileZipInfo(zipFile{1}.name);
stPrint(zipInfo.members,'path')

%% Unzip all the files
chdir(fullfile(arriRootPath,'local'));
arriZipFile = thisAcq.getFile(zipArchive);
arriZipFile.download(zipArchive);
unzip(zipArchive,thisAcq.label);
disp('Downloaded and unzipped spd data');

%%

% Select the file that will be used to determine rect (image captured with ARRI white
entryName = zipInfo.members{1}.path;
outName = fullfile(arriRootPath,'local',thisAcq.label,entryName);
% thisAcq.downloadFileZipMember(zipArchive,entryName,outName);


%% Read the arri image and select the rect 
% This rect should have pixels that are not saturated 
% The rect will be used to grab pixels in all other images of the same
% specimen under different lighting conditions

arriRGB = arriRead(outName);
ip = ipCreate;
ip = ipSet(ip,'display output',arriRGB);
ipWindow(ip);

% Pick a region to use to get the other values - 
% select a region that has no saturated pixel values
[~,rect] = ieROISelect(ip);

disp(rect)

%% Use rect for selecting the mean RGB values 
% We selected a region (rect) that does not have saturated pixel values
% We assume that this area will not be saturated for the same specimen under different lights

meanRGB = zeros(8,3);
for ii = 1: length(zipInfo.members)
    entryName = zipInfo.members{ii}.path;
    outName = fullfile(arriRootPath,'local',thisAcq.label,entryName);
    thisAcq.downloadFileZipMember(zipArchive,entryName,outName);
    arriRGB = arriRead(outName);
    ip = ipCreate;
    ip = ipSet(ip,'display output',arriRGB);
    ipWindow(ip);
    roiData = imcrop(arriRGB,rect);
    rgbData = RGB2XWFormat(roiData);
    ieNewGraphWin;
    c = {'r','g','b'};
    for jj=1:3
        histogram(RGB2XWFormat(rgbData(:,jj)),500,'FaceColor',c{jj});
        hold on
    end
    % display the rectangular region
    [shapeHandle,ax] = ieROIDraw('ip','shape','rect','shape data',rect);
%     delete(shapeHandle);
    meanRGB(ii,:) = mean(RGB2XWFormat(roiData))';
end



