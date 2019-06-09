function ImgUp = ChromaUpSampling( Luma, ChromaA, ChromaB, Sampling, Filter)
%ChromaUpSampling - upsample chroma channel to 4:4:4
%
% Syntax:  Img = ChromaUpSampling( Luma, ChromaA, ChromaB, Sampling, Filter)
%
% Inputs:
%    -Luma: Luma channel
%    -ChromaA: Chroma channel 1
%    -ChromaB: Chroma channel 2
%    -Sampling: input sampling type
%    -Filter: used filter
%
% Outputs:
%    -ImgUp: Upsampled image
%
% Example:
%    ImgUp = ChromaUpsampling( Luma, ChromaA, ChromaB, '420', 'MPEG')
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
% Created: 28-Oct-2015; Last revision: 28-Oct-2015

%---------------------------- BEGIN CODE ----------------------------------
ImgUp = repmat(Luma, [1 1 3]);
if strcmp(Sampling, '420')
%     YSamples  = Width * Height;
%     ChSubSpl = [2, 2];
    subSampleMat = [1, 1; 1, 1];
elseif strcmp(Sampling, '422')
%     YSamples  = Width * Height;
%     ChSubSpl = [1, 2];
    subSampleMat = [1, 1];
elseif strcmp(Sampling, '444')
%     YSamples  = Width * Height;
%     ChSubSpl = [1, 1];
    subSampleMat = 1;    
end
if strcmp(Sampling, '420')
    if strfind(Filter, 'MPEG')
        % see CfE section B.1.5.6
        % A. Luthra, E. Francois, and W. Husak, “Call for
        % Evidence (CfE) for HDR and WCG Video Coding,” in ISO/IEC
        % JTC1/SC29/WG11 MPEG2014/N15083, 2015.
        if strfind( Filter, 'CfE')
            D_0 = [-2 16 54 -4]';
            D_1 = [-4 54 16 -2]';
            C_0 = [1];
            C_1 = [-4 36 36 -4];
            offset_1 = 32;
            shift_1  = 6;
            shift_2  = 12;
            offset_2 = 2048;
        elseif strfind( Filter, 'SuperAnchor')
            % taken from HDRtools, all value can be divided by 4
            D_0 = [256]';
            D_1 = [-16 144 144 -16]';
            C_0 = [256];
            C_1 = [-16 144 144 -16];
            offset_1 = 32768;
            shift_1  = 16;
            shift_2  = 16;
            offset_2 = 32768;
        end
            
        for ChrIdx = 2 : 3
            if ChrIdx == 2
                s      = ChromaA;
            else
                s      = ChromaB;
            end
            f      = zeros([size(s,1)*2 size(s,2)]);
            r      = zeros(size(s)*2);
            % Horizontal filtering
            f(1:2:end, :) = imfilter(s, D_0, 'replicate');
            f(2:2:end, :) = imfilter(s, D_1, 'replicate');

            if strfind(Filter, 'Float')
                r(:, 1:2:end) = (imfilter(f, C_0, 'replicate') + offset_1) / 2^shift_1;
                r(:, 2:2:end) = (imfilter(f, C_1, 'replicate') + offset_2) / 2^shift_2;
                ImgUp(:, :, ChrIdx)  = r;
            else
                r(:, 1:2:end) = double(bitshift(uint32(imfilter(f, C_0, 'replicate')+ offset_1), -shift_2));
                r(:, 2:2:end) = double(bitshift(uint32(imfilter(f, C_1, 'replicate')+ offset_2), -shift_2));
                ImgUp(:, :, ChrIdx)  = r;
            end
        end
    else
        ImgUp(:, :, 2) = kron(ChromaA, subSampleMat); 
        ImgUp(:, :, 3) = kron(ChromaB, subSampleMat);
    end
else
%     if strcmp(Sampling, '422')
    ImgUp(:, :, 2) = kron(ChromaA, subSampleMat); 
    ImgUp(:, :, 3) = kron(ChromaB, subSampleMat);
end
end
%--------------------------- END OF CODE ----------------------------------
% Header generated using two templates:
% - 4908-m-file-header-template
% - 27865-creating-function-files-with-a-header-template