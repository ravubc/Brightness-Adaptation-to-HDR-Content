function Img = ReadYUVFrame( FileName, ChromaSampling, NbBits, Width, Height, NbFrame, FilterSampling)
%ReadYUVFrame - load images from a YUV file
%
% Syntax:  Img = ReadYUVFrame( FileName, ChromaSampling, NbBits, Width, Height, NbFrame, FilterSampling)
%
% Inputs:
%    -FileName: Name of the file
%    -ChromaSampling: mode of sampling for Chroma
%    -NbBits: nb bit of image
%    -FileName: Name of the file
%    -Width: width of image
%    -Height: height of image
%    -NbFrame: frame to read
%
% Outputs:
%    -Img: read frame and process to full resolution
%
% Example:
%    Img = ReadYUVFrame( 'test.yuv', '420', 8, 1920, 1080, 53, 'MPEG')
%
% Other m-files required: ChromaUpSampling.m
% Subfunctions: none
% MAT-files required: none
%
% See also: 
% Author: Ronan Boitard
% University of British Columbia, Vancouver, Canada
% email: rboitard.w@gmail.com
% Website: http://http://www.ece.ubc.ca/~rboitard/
% Created: 28-Oct-2015; Last revision: 28-Oct-2015

%---------------------------- BEGIN CODE ----------------------------------

if(~exist('ChromaSampling'))
    ChromaSampling = 0;
end
if(~exist('FilterSampling'))
    FilterSampling = 'lanczos3';
end
if strcmp(ChromaSampling, '420')
    YSamples  = Width * Height;
    ChSubSpl = [2, 2];
    subSampleMat = [1, 1; 1, 1];
elseif strcmp(ChromaSampling, '422')
    YSamples  = Width * Height;
    ChSubSpl = [1, 2];
    subSampleMat = [1, 1];
elseif strcmp(ChromaSampling, '444')
    YSamples  = Width * Height;
    ChSubSpl = [1, 1];
    subSampleMat = 1;    
else
    disp('Wrong Value for Gamut, it must either be 0 (4:2:0), 2 (4:2:2) or 4 (4:4:4)');
    throw(err);
end  
UVSamples = Width / ChSubSpl(1) * Height / ChSubSpl(2);
if NbBits == 8
    Type = 'uint8';
    sizeFrame = YSamples + 2* UVSamples;
else
    Type = 'uint16';
    sizeFrame = (YSamples + 2* UVSamples) * 2;
end

fileId = fopen(FileName, 'r');
% search position
fseek(fileId, (NbFrame - 1) * sizeFrame, 'bof');
    
% read Y component
buf = fread(fileId, YSamples, Type);
Luma = reshape(buf, Width, Height).'; % reshape

% read U component
ChromaA = fread(fileId, UVSamples, Type);
% read V component
ChromaB = fread(fileId, UVSamples, Type);
fclose(fileId);
ChromaA = double(reshape(ChromaA, Width / ChSubSpl(1), Height / ChSubSpl(2)))';
ChromaB = double(reshape(ChromaB, Width / ChSubSpl(1), Height / ChSubSpl(2)))';
Img = ChromaUpSampling( Luma, ChromaA, ChromaB, ChromaSampling, FilterSampling);
end
%--------------------------- END OF CODE ----------------------------------
% Header generated using two templates:
% - 4908-m-file-header-template
% - 27865-creating-function-files-with-a-header-template