function rootPath=arriRootPath()
% Return the path to the root arriscope directory
%
% This function must reside in the directory at the base of the
% Arriscope directory structure.  It is used to determine the location
% of various sub-directories.
% 
% Example:
%   fullfile(arriRootPath,'data')
%
% See also
%   isetRootPath

rootPath=which('arriRootPath');

[rootPath]=fileparts(rootPath);

end

