function [lightName,lightLevel] =arriLightLevel(fileName)
% Figure out which light and which level from the file name
%
% JEF/Wandell
%
% See also
%   s_arriFilesMetadataCreate
%

% Get the possible light names
lightNames = arriLights();

fileDescription = split(fileName,'_');

% The second one has the name of the level and the level
for ii=1:length(lightNames)
    nLetters = length(lightNames{ii});
    if strncmp(lightNames{ii},fileDescription{2},nLetters)
        lightName = lightNames{ii};
        lightLevel = fileDescription{2}((nLetters+1):end);
        break
    end
end

end