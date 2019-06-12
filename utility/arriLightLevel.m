function [lightName,lightLevel,irStatus] =arriLightLevel(fileName)
% Figure out which light, the light level, and the ir filter status from the file name
%
% Syntax
%   [lightName,lightLevel,irStatus] =arriLightLevel(fileName)
%
% Input
%  filename:  Light emission file name
%
% Output
%   lightName
%   lightLevel
%   irStatus
%
% JEF/Wandell
%
% See also
%   s_arriFilesMetadataCreate
%

% Get the possible light names
lightNames = arriLights();

% Divide the file name by the underscore character
fileDescription = split(fileName,'_');

% The second one has the name of the level and the level
% The third cell entry has the IR status
for ii=1:length(lightNames)
    nLetters = length(lightNames{ii});
    if strncmp(lightNames{ii},fileDescription{2},nLetters)
        lightName = lightNames{ii};
        lightLevel = fileDescription{2}((nLetters+1):end);
        irStatus = 'off';
        if strcmp(fileDescription{3},'fIRon.ari')
            irStatus = 'on';
        end 
        break
    end
end

end