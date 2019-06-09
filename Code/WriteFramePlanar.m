function WriteFramePlanar(Luma, ChromaA, ChromaB, FileName, Mode, BitDepth)
%WriteFramePlanar - save any image in planar format.
%
% Syntax:  WriteFramePlanar(Luma, ChromaA, ChromaB, FileName, Mode, BitDepth)
%
% Inputs:
%    -Luma: Luma plane
%    -ChromaA: Chroma plane 1
%    -ChromaB: Chroma plane 1
%    -FileName: Name of the file
%    -Mode: Erase and new file or update
%    -BitDepth: number of bit of the input image
%
% Outputs:
%    -None
%
% Example:
%    WriteFramePlanar(Y, Cb, Cr, 'test.yuv', 2, 10)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: 
% Author: Ronan Boitard
% University of British Columbia, Vancouver, Canada
% email: rboitard.w@gmail.com
% Website: http://http://www.ece.ubc.ca/~rboitard/
% Created: 28-Oct-2015; Last revision: 1-Nov-2015

%---------------------------- BEGIN CODE ----------------------------------
switch Mode
	case 1 % create file
		FileId = fopen(FileName, 'w');
        fclose(FileId);
        return;
	case 2 % append to file
		if exist(FileName, 'file')
            FileId = fopen(FileName, 'a');
        else % create file
            FileId = fopen(FileName, 'w');
        end
    otherwise
        % create file
		FileId = fopen(FileName, 'w');
end

if BitDepth <= 8
    Luma = uint8(Luma);
    ChromaA = uint8(ChromaA);
    ChromaB = uint8(ChromaB);
elseif BitDepth <= 16
    Luma = uint16(Luma);
    ChromaA = uint16(ChromaA);
    ChromaB = uint16(ChromaB);
else
    Luma = uint32(Luma);
    ChromaA = uint32(ChromaA);
    ChromaB = uint32(ChromaB);
end
% write Y component, reshaped
Luma    = reshape(Luma.'   , [], 1);
ChromaA = reshape(ChromaA.', [], 1);
ChromaB = reshape(ChromaB.', [], 1);

if BitDepth <= 8
    fwrite(FileId, Luma   , 'uint8');
    fwrite(FileId, ChromaA, 'uint8');
    fwrite(FileId, ChromaB, 'uint8');
elseif BitDepth <= 16
    fwrite(FileId, Luma   , 'uint16');
    fwrite(FileId, ChromaA, 'uint16');
    fwrite(FileId, ChromaB, 'uint16');
elseif BitDepth <= 32
    fwrite(FileId, Luma   , 'uint32');
    fwrite(FileId, ChromaA, 'uint32');
    fwrite(FileId, ChromaB, 'uint32');    
end

fclose(FileId);
end
%--------------------------- END OF CODE ----------------------------------
% Header generated using two templates:
% - 4908-m-file-header-template
% - 27865-creating-function-files-with-a-header-template
