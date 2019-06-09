function ImgOut = RGB2YCbCr(ImgIn, Encode, Gamut, MPEG)
%RGB2YCbCr - encode R'G'B' values into Y'CbCr values or decode Y'CbCr into R'G'B'.
%
% Syntax:  ImgOut = RGB2YCbCr(ImgIn, Encode, Gamut)
%
% Inputs:
%    -ImgIn: input image, if Encode = 1 : R'G'B' image, otherwise Y'CbCr
%    -Encode: Encoding or decoding the values
%    -BitDepth: bit-depth considered
%    -Gamut: gamut of the RGB values
%    -MPEG: use the MPEG approximate matrix
%
% Outputs:
%    -ImgOut: output image, if Encode = 1 : Y'CbCr image, otherwise R'G'B'
%
% Example:
%    ImgOut = RGB2YCbCr(ImgIn, true, 0, 'BT.2020', true)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: 
% References:
%    -International Telecommunication Union, “Parameter Values for the HDTV
%    Standard for Production and International Programme Exchange,” in
%    Recommendation ITU-R BT.709, 1998.
%    -International Telecommunication Union, “Parameter values for
%    ultra-high definition television systems for production and
%    international programme exchange,” in Recommendation ITU-R BT.2020,
%    2012.
%    -Society of Motion Picture & Television Engineers, RP 431-2:2011 :
%    D-Cinema Quality — Reference Projector and Environment, vol. 10607,
%    no. 914. The Society of Motion Picture and Television Engineers, 2011.
%    -A. Luthra, E. Francois, and W. Husak, “Call for Evidence (CfE) for
%    HDR and WCG Video Coding,” in ISO/IEC JTC1/SC29/WG11 MPEG2014/N15083,
%    2015.
%
% Author: Ronan Boitard
% University of British Columbia, Vancouver, Canada
% email: rboitard.w@gmail.com
% Website: http://http://www.ece.ubc.ca/~rboitard/
% Created: 15-Mar-2012; Last revision: 26-Oct-2015

%---------------------------- BEGIN CODE ----------------------------------
if(~exist(Gamut,'var'))
    Gamut = 'BT.2020';
end
if MPEG
    Gamut = [Gamut 'MPEG'];
end
        
if Encode
    if sum(sum([ImgIn(:) > 1  ImgIn(:) < 0]))
        warning('RGB values should be between [0;1], Odd values may appear');
    end
    % R'G'B' to Y'CbCr matrix
    if strcmp(Gamut, 'BT.709')
        % Taken from ITU. (1998). RECOMMENDATION ITU-R BT.709-3.
        % Conception of non-linear precorrection of primary signals
        % Not considered as use of iEOTF before calling this function
        %     E_R = R.^0.45;
        %     E_G = G.^0.45;
        %     E_B = B.^0.45;
        
        % Derivation of luminance signal
        E_Y = 0.2126 * ImgIn(:,:,1) + 0.7152 * ImgIn(:,:,2) + 0.0722 * ImgIn(:,:,3) ;
        % Derivation of luminance color-difference signals (digital coding)
        E_CB = (ImgIn(:,:,3) - E_Y) / 1.8556;
        E_CR = (ImgIn(:,:,1) - E_Y) / 1.5748;
    elseif strcmp(Gamut, 'BT.2020')
        % Taken from ITU. (2012). Recommendation ITU-R BT.2020.        
        % Derivation of non-constant luminance signal
        E_Y = 0.2627 * ImgIn(:,:,1) +... 
            0.6780 * ImgIn(:,:,2) +...
            0.0593 * ImgIn(:,:,3) ;
        
        % Derivation of luminance color-difference signals (digital coding)
        E_CB = (ImgIn(:,:,3) - E_Y) / 1.8814;
        E_CR = (ImgIn(:,:,1) - E_Y) / 1.4746;
        
    elseif strcmp(Gamut, 'BT.2020MPEG')
        % see CfE section B.1.5.3
        % A. Luthra, E. Francois, and W. Husak, “Call for
        % Evidence (CfE) for HDR and WCG Video Coding,” in ISO/IEC
        % JTC1/SC29/WG11 MPEG2014/N15083, 2015.
        E_Y =   0.262700 * ImgIn(:,:,1) +... 
                0.678000 * ImgIn(:,:,2) +...
                0.059300 * ImgIn(:,:,3) ;
        E_CB = -0.139630 * ImgIn(:,:,1) +... 
               -0.360370 * ImgIn(:,:,2) +...
                0.500000 * ImgIn(:,:,3) ;
        E_CR =  0.500000 * ImgIn(:,:,1) +... 
               -0.459786 * ImgIn(:,:,2) +...
               -0.040214 * ImgIn(:,:,3) ;   
        E_Y =   0.26269999999999999 * ImgIn(:,:,1) +... 
                0.67800000000000005 * ImgIn(:,:,2) +...
                0.059299999999999999 * ImgIn(:,:,3) ;
        E_CB = -0.13963000000000000 * ImgIn(:,:,1) +... 
               -0.36037000000000002 * ImgIn(:,:,2) +...
                0.50000000000000000 * ImgIn(:,:,3) ;
        E_CR =  0.50000000000000000 * ImgIn(:,:,1) +... 
               -0.45978599999999997 * ImgIn(:,:,2) +...
               -0.040214000000000000 * ImgIn(:,:,3) ;              
    end
    
    ImgOut(:,:,1) = E_Y;
    ImgOut(:,:,2) = E_CB;
    ImgOut(:,:,3) = E_CR;
else
    E_Y  = ImgIn(:,:,1);
    E_CB = ImgIn(:,:,2);
    E_CR = ImgIn(:,:,3);
    
    % Y'CbCr to R'G'B' transformation
    if strcmp(Gamut, 'BT.709')
        % Taken from ITU. (1998). RECOMMENDATION ITU-R BT.709-3.
        % Derivation of color-channel signals (digital coding)
        ImgOut(:,:,3) =  E_CB * 1.8556 + E_Y; % B'
        ImgOut(:,:,1) =  E_CR * 1.5748 + E_Y; % R'
        ImgOut(:,:,2) = (E_Y - 0.2126 * ImgOut(:,:,1)...
            - 0.0722 * ImgOut(:,:,3) ) / 0.7152;
    elseif strcmp(Gamut, 'BT.2020')
        % Taken from ITU. (2012). Recommendation ITU-R BT.2020.
        ImgOut(:,:,3) =  E_CB * 1.8814 + E_Y; % B'
        ImgOut(:,:,1) =  E_CR * 1.4746 + E_Y; % R'
        ImgOut(:,:,2) = (E_Y - 0.2627 * ImgOut(:,:,1)...
            - 0.0593 * ImgOut(:,:,3) ) / 0.6780;
    elseif strcmp(Gamut, 'BT.2020MPEG')
        % Taken from A. Luthra, E. Francois, and W. Husak, “Call for
        % Evidence (CfE) for HDR and WCG Video Coding,” in ISO/IEC
        % JTC1/SC29/WG11 MPEG2014/N15083, 2015. 
        % Section B.1.5.8.2
        ImgOut(:,:,1) = 1 * E_Y + 0.00000 * E_CB + 1.47460 * E_CR; % R'        
        ImgOut(:,:,2) = 1 * E_Y - 0.16455 * E_CB - 0.57135 * E_CR; % G'
        ImgOut(:,:,3) = 1 * E_Y + 1.88140 * E_CB + 0.00000 * E_CR; % B'          
    elseif strcmp(Gamut, 'Special')
        % Taken from ITU. (2012). Recommendation ITU-R BT.2020.
        ImgOut(:,:,1) = 1 * E_Y + 0.00000 * E_CB - 1.47460 * E_CR; % R'        
        ImgOut(:,:,2) = 1 * E_Y + 0.16455 * E_CB + 0.57135 * E_CR; % G'
        ImgOut(:,:,3) = 1 * E_Y - 1.88140 * E_CB - 0.00000 * E_CR; % B'      
    end
end
end
%--------------------------- END OF CODE ----------------------------------
% Header generated using two templates:
% - 4908-m-file-header-template
% - 27865-creating-function-files-with-a-header-template
