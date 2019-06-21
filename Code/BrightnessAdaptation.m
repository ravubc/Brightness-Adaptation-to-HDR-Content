function BrightnessAdaptation(oldLum, newLum, inputFilePath, outputFilePath, BitDepth, Width, Height, startFrameNumber, endFrameNumber)
%BrightnessAdaptation - adapt the HDR video content to surrounding luminance, in PQ domain
%        Notes: This function should be used for HDR video contents that have
%        brightness lower than 1000nits.
%
% Syntax: BrightnessAdaptation(oldLum, newLum, inputFilePath, outputFilePath, BitDepth, Width, Height, startFrameNumber, endFrameNumber)
%
% Inputs:
%	- oldLum: Original Surrounding Luminance
%	- newLum: Updated Surrounding Luminance
%	- inputFilePath: Input file path for the HDR video, format as .yuv
%	- outputFilePath: Output file path for the HDR video, format as .yuv
%	- BitDepth: Number of bit of the input video
%	- Width: Width of each frame in video
%	- Height: Height of each frame in video
%	- startFrameNumber: The start frame number for video
%	- endFrameNumber: The end frame number for video
%
% Outputs:
%	- None
%
% Example:
%	BrightnessAdaptation(16, 84, 'D:\FirstSet_DML_HDR_3840x2160_24Hz_10bit_P420.yuv', 'FirstSet_DML_HDR_3840x2160_24Hz_10bit_P420_16_to_84.yuv', 10, 3840, 2160, 1, 5)
%
% Other m-files required:
%   To run this code, the following files should be included in the folder
%	- ReadYUVFrame.m
%	- ScaleImage2BitDepth.m
%	- RGB2YCbCr.m
%	- SMPTE_ST_2084.m
%	- ChromaDownSampling.m
%   - ChromaUpSampling.m
%	- WriteFramePlanar.m
%   - ClampImg.m
%
% Subfunctions: none
% MAT-files required: none
%
% University of British Columbia, Vancouver, Canada
% Created: April 2019
%
%
%------------------------ BEGIN OF CODE ----------------------------------------------------
for FrameN = startFrameNumber:endFrameNumber
    ImgIn = ReadYUVFrame( inputFilePath , '420' , BitDepth , Width , Height , FrameN ) ;
    ImgIn_Scaled = ScaleImage2BitDepth( ImgIn , 0 , 1 , BitDepth , 'YCbCr' ) ;
    ImgIn_Scaled_RGB = RGB2YCbCr( ImgIn_Scaled , 0 , 'BT.2020' , 1 ) ;
    ImgIn_Scaled_RGB( ImgIn_Scaled_RGB > 1 ) = 1 ;
    ImgIn_Scaled_RGB( ImgIn_Scaled_RGB < 0 ) = 0 ;
    R_PQ_Old = ImgIn_Scaled_RGB( : , : , 1 ) ;
    G_PQ_Old = ImgIn_Scaled_RGB( : , : , 2 ) ;
    B_PQ_Old = ImgIn_Scaled_RGB( : , : , 3 ) ;
    Y_PQ_Old = ImgIn_Scaled( : , : , 1 ) ;
    Y_PQ_Old( Y_PQ_Old <= 0.0215 ) = 0.0215 ;
    Y_PQ_Old( Y_PQ_Old >= 0.7518 ) = 0.7518 ;

    L_Adaptation_Old = oldLum ;
    L_Adaptation_New = newLum ;

    L_Adaptation_Old_PQ = SMPTE_ST_2084( L_Adaptation_Old , 1 , 10000 ) ;
    L_Adaptation_New_PQ = SMPTE_ST_2084( L_Adaptation_New , 1 , 10000 ) ;

    HVS_PQ = Y_PQ_Old ./(Y_PQ_Old + L_Adaptation_Old_PQ);
    Y_PQ_New = (HVS_PQ .* L_Adaptation_New_PQ) ./(1 - HVS_PQ);

    L_Ratio_PQ = Y_PQ_New ./ Y_PQ_Old;

    R_PQ_New = L_Ratio_PQ .* R_PQ_Old ;
    G_PQ_New = L_Ratio_PQ .* G_PQ_Old ;
    B_PQ_New = L_Ratio_PQ .* B_PQ_Old ;

	R_PQ_New( R_PQ_New >= 0.7518 ) = 0.7518 ;
	R_PQ_New( R_PQ_New <= 0.0215 ) = 0.0215 ;
	G_PQ_New( G_PQ_New >= 0.7518 ) = 0.7518 ;
	G_PQ_New( G_PQ_New <= 0.0215 ) = 0.0215 ;
	B_PQ_New( B_PQ_New >= 0.7518 ) = 0.7518 ;
	B_PQ_New( B_PQ_New <= 0.0215 ) = 0.0215 ;

    Img_PQ_New( : , : , 1 ) = R_PQ_New ;
    Img_PQ_New( : , : , 2 ) = G_PQ_New ;
    Img_PQ_New( : , : , 3 ) = B_PQ_New ;

    ImgOut_PQ_YUV = RGB2YCbCr( Img_PQ_New , 1 , 'BT.2020' , 1 ) ;
    ImgOut_Scaled = ScaleImage2BitDepth( ImgOut_PQ_YUV , 1 , 1 , BitDepth , 'YCbCr' ) ;
    [ ChromaA , ChromaB ] = ChromaDownSampling( ImgOut_Scaled , '420' , 'MPEG' ) ;
    WriteFramePlanar( ImgOut_Scaled( : , : , 1 ) , ChromaA , ChromaB , outputFilePath , 2 , BitDepth ) ;
end
end

%------------------------ END OF CODE ----------------------------------------------------
