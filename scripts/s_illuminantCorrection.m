chdir(fullfile(arriRootPath,'local'));

% White paper illuminated by red light
whitePaper_AmbientLight = arriRead(fullfile('WhitePaper_CameraImage_ari','WhitePaper_ambient_fIRon.ari'));
imagescRGB(whitePaper_AmbientLight)

% White paper illuminated by red light
whitePaper_RedLight = arriRead(fullfile('WhitePaper_CameraImage_ari','WhitePaper_red17_fIRon.ari'));
imagescRGB(whitePaper_RedLight);

pureRedLight = whitePaper_RedLight - whitePaper_AmbientLight;
imagescRGB(whitePaper_RedLight);

% Fit a low order polynomial to the ambient light?
% Deal with the saturated pixels and specularity in someway
% Deal with the fact that we have two images.  Can automate splitting
% them into left and right.

%% Divide out the light from the Bone image

bone_RedLight = arriRead(fullfile('Bone_CameraImage_ari','Bone_red17_fIRon.ari'));

[r,c,~] = size(bone_RedLight);

rect = [r/2 - 200, c/2 - 200, 400 , 400]

clear BoneRedLightCorrected
for ii=1:3
    BoneRedLightCorrected(:,:,ii) = imcrop(bone_RedLight(:,:,ii),rect) ./ imcrop(whitePaper_RedLight(:,:,ii),rect);
end

imagescRGB(BoneRedLightCorrected);

mesh(BoneRedLightCorrected(:,:,2))
