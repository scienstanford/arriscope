function [lightNames, idx] = arriLights(lightName)
%

% Important to keep whitemix before white in the list.  This matters for
% testing purposes.
lightNames = {'violet','blue','green','red','whitemix','white','IR'};

if nargout > 1
    idx = find(strcmp(lightName,lightNames));
end

end
