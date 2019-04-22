%% s_arriGetMeanRGBvalues.m

ieInit;
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
zipArchive = 'Bone_CameraImage_ari.zip';

% Find out the filenames in the zip archive
zipInfo = thisAcq.getFileZipInfo(zipFile{1}.name);
stPrint(zipInfo.members,'path')

% Download one that will be used to determine rect (image captured with ARRI white
entryName = zipInfo.members{1}.path;
outName = fullfile(arriRootPath,'local',entryName);
thisAcq.downloadFileZipMember(zipArchive,entryName,outName);

%% Read the arri image and select the rect 

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
    outName = fullfile(arriRootPath,'local',entryName);
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



