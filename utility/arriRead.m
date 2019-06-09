function [ariRGB, ariRaw] = arriRead( fileName, varargin )
% Read an ARRIScope file (.ari) and convert into various RGB and RAW formats
% 
% Syntax:
%   [ariRGB, ariRaw] = arriRead(FILENAME) 
%
% Brief description:
%   This is an interface to the low level reading routine for the ARRI
%   image data.  The default reads out both the left and right images as a
%   single RGB image.  The images are left/right in the image, but the
%   orientation of the images does not match the left/right disparity  of
%   the stereo cameras in the microscope.
%
%   Using the 'image' switch the user can have the images returned so that
%   the left and right images are oriented with horizontal disparity shown
%   correctly.  You can request either the stereo pair in a returned
%   struct, or just the left or right image.
%
% Inputs
%  FILENAME - string
%
% Optional key/value pairs
%  'crop'  -  Crop the images with the specified rectangle.  
%             Matlab image rect is [xmin, ymin, width, height], which is
%             the same as [smallestCol, smallestRow, nCols, nRows]
%
%  'image' - Specify type of returned image.  
%     'raw'             - the combined left/right raw image (default)
%     'left' or 'right' - one of the stereo images
%     'stereo'          - struct with both the left and right images.
%
% Outputs
%   ariRGB  - Combined RGB data into a single image, or if 'pair' is set to
%             true then a struct, ariRGB.left and ariRGB.right;
%   ariRaw  - Output from imReadASAri, which reads the .ari file and packs
%             the 12 bit data in that file into 16 bit values
%
% Based on importASAri.m from ARRI folks
%    Julian Klabes - 04/21/2017
%
% NOTE:
%   The histogram showing the number of pixels at different response levels
%   is irregular, with certain values containing a lot of pixels and
%   adjacent values containing none. We think this because the read routine
%   packs 12-bit data into 16 bit bins, and thus certain values never
%   arise.
%
% See also
%    Scripts with s_arri*
%

%% Check the file exists
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('fileName',@(x)(exist(x,'file')));

vFunc = @(x)(ismember(x,{'stereo','left','right','raw'}));
p.addParameter('image','raw',vFunc);    % Specify return image type
p.addParameter('crop',[],@isvector);
p.parse(fileName,varargin{:});

% Check that the file is an arriscope file
[~,~,e] = fileparts(fileName);
if ~strcmp(e,'.ari')
    error('File with .ari extension expected.  Extension is %s\n',e);
end

%% Call the functions below    
[R,G,B,ariRaw] = ari2RGB(fileName);

% This is the left right data in a single RGB images
ariRGB = cat(3,R,G,B);
cols = size(ariRGB,2);

returnType = p.Results.image;

% User wants the data in left/right stereo pair format
switch ieParamFormat(returnType)
    case 'stereo'
        % User wants the left and right images aligned and separated
        left  = imrotate(ariRGB(:, 1:(cols/2), :),-90);
        right = imrotate(ariRGB(:, ((cols/2)+1):end, :),90);
        clear ariRGB;
        ariRGB.left  = left;
        ariRGB.right = right;
    case 'left'
        ariRGB  = imrotate(ariRGB(:, 1:(cols/2), :), -90);
    case 'right'
        ariRGB = imrotate(ariRGB(:, ((cols/2)+1):end, :), 90);
    case 'raw'
        % Do nothing
end

% User sent in a rect for cropping
if ~isempty(p.Results.crop)
    rect = p.Results.crop;
    if isstruct(ariRGB)
        ariRGB.left = imcrop(ariRGB.left,rect);
        ariRGB.right = imcrop(ariRGB.right,rect);
    else
        ariRGB = imcrop(ariRGB,rect);
    end
end


end


% --------- Main functions ------------
function [R,G,B,ariRaw] = ari2RGB(fn)
    ariRaw = imReadASAri(fn);
    offset = 256;
    ariRaw = ariRaw - offset;
    ariRaw(ariRaw<0)=0;
    
    % GRGRGR...
    % BGBGBG...
    R = NaN(size(ariRaw));
    G = R;
    B = R;
    nrow = size(ariRaw,1);
    ncol = size(ariRaw,2);
    assert((mod(nrow,2) + mod(ncol,2)) == 0,'rows & cols must be even');
    % prepare odd rows
    for i = 1:2:nrow
        % row = ariRaw(i,:);
        R(i,2:2:end) = ariRaw(i,2:2:end);
        R(i,1) = ariRaw(i,2);
        R(i,3:2:(end-1)) = 0.5*(ariRaw(i,2:2:(end-2)) + ariRaw(i,4:2:end));
        G(i,1:2:end) = ariRaw(i,1:2:end);
        G(i,end) = ariRaw(i,end-1);
        G(i,2:2:(end-1)) = 0.5*(ariRaw(i,1:2:(end-2)) + ariRaw(i,3:2:end));
    end
    % prepare even rows
    for i = 2:2:nrow
        % row = ariRaw(i,:);
        G(i,2:2:end) = ariRaw(i,2:2:end);
        G(i,1) = ariRaw(i,2);
        G(i,3:2:(end-1)) = 0.5*(ariRaw(i,2:2:(end-2)) + ariRaw(i,4:2:end));
        B(i,1:2:end) = ariRaw(i,1:2:end);
        B(i,2:2:(end-1)) = 0.5*(ariRaw(i,1:2:(end-2)) + ariRaw(i,3:2:end));
        B(i,end) = ariRaw(i,end-1);
    end
    
    % The G image is adjusted by averaging across the rows, making the G
    % resolution comparable to the R and B resolution.  Not sure we should
    % do this, really, but that's what Arri shipped us.  We could put a
    % flag here to stop the blurring.
    % fill odd rows
    B(1,:) = B(2,:);
    tmpG = G;
    for i = 3:2:nrow
        B(i,:) = 0.5*(B(i-1,:) + B(i+1,:));
        G(i,:) = 0.25*(tmpG(i-1,:) + 2* tmpG(i,:) + tmpG(i+1,:));
    end
    % fill even rows
    R(end,:) = R(end-1,:);
    for i = 2:2:(nrow-2)
        R(i,:) = 0.5*(R(i-1,:) + R(i+1,:));
        G(i,:) = 0.25*(tmpG(i-1,:) + 2* tmpG(i,:) + tmpG(i+1,:));
    end

end

function rv = isodd(ii)
    rv = (mod(ii,2) == 1);
end

function ariRaw = imReadASAri(fileName)
% imReadASAri. Read an ARI file from the ARRISCOPE.
%   IMG = imReadASAri(FILENAME) reads the ARI file specified by the string
%   FILENAME.
% Original: Dr. Stefano Andriani - 20/03/2012
% Change for ARRISCOPE: Julian Klabes - 04/20/2017

mFid = fopen(fileName,'rb');
if (mFid < 3)
    error('imReadAri: Cannot open the input file\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Root Information Header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fseek(mFid,8,'bof');
headerSize    = fread(mFid,1,'uint32');
versionNumber = fread(mFid,1,'uint32');
if ((versionNumber ~= 3) && (versionNumber ~= 1))
    error('imReadAri: The input file is not a ARIv3 file\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the size of the image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (versionNumber == 3)
    fseek(mFid,20,'bof');
    ariRawWidth  = fread(mFid,1,'uint32');
    ariRawHeight = fread(mFid,1,'uint32');
else
    ariRawWidth  = 2880;
    ariRawHeight = 1620;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the 12-data and pack into 16-bit words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pixelNumber = ariRawWidth * ariRawHeight;
dataSize = pixelNumber * 1.5;
fseek(mFid,headerSize,'bof');
data = fread(mFid,[1,dataSize],'*ubit12'); 
fclose(mFid);
%ariRaw=zeros(ariRawWidth,ariRawHeight,'uint16');
lut    = uint16(qlut(12, 16));
ariRaw = lut((data)+1); %"+1" to get values betweet 1 and 2^16

ariRaw = reshape(ariRaw, ariRawWidth, ariRawHeight)';
end


function lut = qlut(inbits, outbits)
% qlut QLut compression and expansion
% lut = qlut(16, 12) compute a 16 bit LUT for compression into 12 bit
% lut = qlut(12, 16) compute a 12 bit LUT for expansion into 16 bit 
%                    (the inverse function)
%
% Parameters:
%   inbits - the bit depth of the input values (size of the LUT)
%   outbits - the bit depth of the output values (range of LUT values)
%
% Returns:
%   An array of length 2^inbits
%
% Description: 
% The compression is done by increased bit shifting. The breaks are powers 
% of 2. 
%
hibits = max(inbits, outbits);
lobits = min(inbits, outbits);
if hibits == inbits
    mode ='pack';
else
    mode = 'unpack';
end

lut = bitPacking(hibits, lobits-3, mode);
end

function lut = bitPacking(inbits, mantissa, mode)
% bitPacking Bit compression and expansion
% lut = qlut(16, 9, 'pack') compute a 16 bit LUT for encoding with 9 bit mantissa 
% lut = qlut(16, 9, 'unpack') compute the LUT for the inverse function
%                  
% Parameters:
%  inbits - the bit depth of the input values (size of the LUT)
%  mantissa - the bit depth of the mantissa in the encoding
%  mode - 'pack' or 'unpack'
%
% Returns:
% For 'pack' mode:   an array of 2^inbits elements
% For 'unpack' mode: the length depends on the encoding
%
% Description: 
%  The compression is done by increased bit shifting. The breaks are powers 
%  of 2. At each break one more bit is shifted.
%

lobits = mantissa + 1;
l = [0, 2 .^ (lobits:inbits)];
s = [0, cumsum(diff(l) ./ 2 .^ (0:length(l)-2))];
lut = [];

if strcmp(mode, 'pack')
    for i=2:length(l)
        x = 0:l(i) - l(i-1) - 1;
        lut = [lut bitshift(x, 2-i) + s(i-1)];
    end
elseif strcmp(mode, 'unpack')
    for i=2:length(l)
        x = 0:s(i) - s(i-1) - 1;
        lut = [lut bitshift(x, i-2) + (bitshift(1, max(0, i-3)) - 1 + l(i-1))];
    end
else
    error('Unknown mode')
end

end
