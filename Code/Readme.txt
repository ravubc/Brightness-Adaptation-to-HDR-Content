Project Title: Brightness Adaptation for HDR Content

This project is to adjust the brightness of the HDR Video content base on human visual contrast sensitivity. The target of this project is changing video's luminance as surrounding brightness and keep the contrast the same: "HVS = LHDR/(LHDR + Ladaptation)"

Notes: This function should be used for HDR video contents that have brightness lower than 1000nits. 

Software needed: MATLAB

Function Created:
	- BrightnessAdaptation

Syntax: BrightnessAdaptation(oldLum, newLum, inputFilePath, outputFilePath, BitDepth, Width, Height, startFrameNumber, endFrameNumber)

Inputs:
	- oldLum: Original Surrounding Luminance
	- newLum: Updated Surrounding Luminance
	- inputFilePath: Input file path for the HDR video, format as .yuv 
	- outputFilePath: Output file path for the HDR video, format as .yuv 
	- BitDepth: Number of bit of the input video
	- Width: Width of each frame in video
	- Height: Height of each frame in video
	- startFrameNumber: The start frame number for video
	- endFrameNumber: The end frame number for video

Outputs:
	- None

Example:
	BrightnessAdaptation(16, 84, 'D:\KDR\UBC courses\2019_Spring\EECE541\FirstSet_DML_HDR_3840x2160_24Hz_10bit_P420.yuv', 'FirstSet_DML_HDR_3840x2160_24Hz_10bit_P420_16_to_84.yuv', 10, 3840, 2160, 1, 5)

Other m-files required: To run this code, the following files should be included in the same folder
	- ReadYUVFrame.m
	- ScaleImage2BitDepth.m
	- RGB2YCbCr.m
	- SMPTE_ST_2084.m
	- ChromaDownSampling.m
	- ChromaUpSampling.m
	- WriteFramePlanar.m
	- ClampImg.m

Authors:
	- Xuemeng Li
	- Ravneet Kaur
	- Anupreet Mahrok
	- Hans Zhang
Date: April 2019

Acknowledgement:
	Dr. Mahsa Pourazad
	Dr. Panos Nasiopoulos
	Pedram Mohammadi
	Maryam Azimi
	Digital Multedia lab