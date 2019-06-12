function [lightNames, idx] = arriLights(lightName)
% These are names of the lights used in the arriScope
%
% JEF/BW

%% Useful for searching and finding light emissions.
% We try to keep the naming conventions consistent with this function.

% whitearri is the white light in the arriscope
% all the other lights are from the Sony light source.
% Some people call white whiteSony.
lightNames = {'violet','blue','green','red','white','arriwhite','ir'};

if nargout > 1
    idx = find(strcmpi(lightName,lightNames));
end

end
