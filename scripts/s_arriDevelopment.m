%%  Developing ideas here.
%
% Then moving them to separate functions and scripts
%
%

%% Downloaded some stuff into local to test this.


%%
chdir(fullfile(arriRootPath,'local'));

% White paper illuminated by red light
whitePaper_AmbientLight = arriRead(fullfile('WhitePaper_CameraImage_ari','WhitePaper_ambient_fIRon.ari'));
imagescRGB(whitePaper_AmbientLight)

% White paper illuminated by red light
whitePaper_RedLight = arriRead(fullfile('WhitePaper_CameraImage_ari','WhitePaper_red17_fIRon.ari'));
imagescRGB(whitePaper_RedLight);
size(whitePaper_RedLight)
leftImage = whitePaper_RedLight(:,1:2496/2,:);
rightImage = whitePaper_RedLight(:,(2496/2+1:end),:);

imagescRGB(leftImage)
imagescRGB(rightImage)

pureRedLight = whitePaper_RedLight - whitePaper_AmbientLight;
imagescRGB(whitePaper_RedLight);

% Fit a low order polynomial to the ambient light?
% Deal with the saturated pixels and specularity in someway
% Deal with the fact that we have two images.  Can automate splitting
% them into left and right.

%% Divide out the light from the Bone image

%% Read a left/right stereo pair 

rect = [200,200,1000,800];
bone_RedLight = arriRead(fullfile('Bone_CameraImage_ari','Bone_red17_fIRon.ari'),...
    'image','stereo', ...
    'crop',rect);
bone_RedLight.left = ieClip(bone_RedLight.left,0,30);
bone_RedLight.right = ieClip(bone_RedLight.right,0,30);

for ii=1:10
    imagescRGB(bone_RedLight.right); pause(1);
    imagescRGB(bone_RedLight.left); pause(1);
end

%% Loop through the different colors in a region of the left image

rect = [500,200,200,200];
img = arriRead(fullfile('Bone_CameraImage_ari','Bone_red17_fIRon.ari'),...
    'image','left', ...
    'crop',rect);
img = ieClip(img,0,30);
imagescRGB(img);


%% Blur and subsample because we don't trust these very spatial resolutions

h = fspecial('average',3);
leftImageB = imfilter(leftImage,h);
leftImageBS = leftImage(2:2:end,2:2:end,:);
imagescRGB(leftImageBS);
hdl = histogram(leftImageBS(:,:,1),60);
size(leftImageBS)

h = fspecial('average',3);
rightImageB = imfilter(rightImage,h);
rightImageBS = rightImageB(2:2:end,2:2:end,:);
imagescRGB(rightImageBS);
% hdl = histogram(leftImageBS(:,:,1),60);
size(rightImageBS)

redRatio = leftImageBS(:,:,1) ./ rightImageBS(:,:,1);
mesh(log10(redRatio))

h = fspecial('average',5);
leftImageB = imfilter(leftImage,h);
leftImageBS = leftImage(3:3:end,3:3:end,:);
imagescRGB(leftImageBS);
histogram(leftImageBS(:,:,1));
size(leftImageBS)

%% Example of registration commands from toolbox

[opt,met] = imregconfig('monomodal');
leftRegistered = imregister(bone_RedLight.left(:,:,1),bone_RedLight.right(:,:,1),'rigid',opt,met);
imshowpair(bone_RedLight.right(:,:,1),leftRegistered);
imshowpair(bone_RedLight.right(:,:,1),bone_RedLight.left(:,:,1));
imshowpair(bone_RedLight.right(:,:,1),bone_RedLight.right(:,:,1));


%%  Remember arriLights and arriLightLevel

%%  Make a 3x7 matrix out of the data

nCols = 200;
nRows = 200;
rect = [500,200,nCols,nRows];
chdir(fullfile(arriRootPath,'local','Bone_CameraImage_ari'));
files = dir('*.ari');
nFiles = numel(files);
multispecData = zeros(nCols+1,nRows+1,3,nFiles);

for ii=1:nFiles
    img = arriRead(files(ii).name,...
        'image','left', ...
        'crop',rect);
    figure; imagescRGB(img);
    title(sprintf('%s',files(ii).name));
    multispecData(:,:,:,ii) = img; 
end
imagescRGB(multispecData(:,:,:,2));

% This should make an RGB image as if illuminated by all of the lights at
% once
rgb = sum(multispecData,4);
ieNewGraphWin;
imagescRGB(rgb);




