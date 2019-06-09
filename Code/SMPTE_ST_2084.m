function y = SMPTE_ST_2084(x, Inverse, MaxLum)
%SMPTE_ST_2084 - implement the SMPTE ST 2084 as described in the
% MPEG Call for Evidence in Section B.1.5.3.1
%
% Syntax:  y = SMPTE_ST_2084(x, Inverse, MaxLum)
%
% Inputs:
%    - ImgIn: input image, if Inverse = 1 : RGB, otherwise R'G'B'.
%    - Inverse: Inverse EOTF (encoding)
%    - MaxLum: maximum luminance (default= 10,000 nits).
%
% Outputs:
%    -ImgOut: output image, if Inverse = 1 : encoded image, otherwise decoded
%
% Example:
%    Lw_Prime = SMPTE_ST_2084(Lw, true, 10000)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: 
% Reference:
%    - Society of Motion Picture & Television Engineers, ST 2084: High
%    Dynamic Range Electro-Optical Transfer Function of Mastering Reference
%    Displays. The Society of Motion Picture and Television Engineers,
%    2014.
%    - A. Luthra, E. Francois, and W. Husak, “Call for Evidence (CfE) for
%    HDR and WCG Video Coding,” in ISO/IEC JTC1/SC29/WG11 MPEG2014/N15083,
%    2015.
%
% Author: Ronan Boitard
% University of British Columbia, Vancouver, Canada
% email: rboitard.w@gmail.com
% Website: http://http://www.ece.ubc.ca/~rboitard/
% Created: 23-Oct-2015; Last revision: 23-Oct-2015

%---------------------------- BEGIN CODE ----------------------------------
% Compute Inverse-EOTF coefficient
m1 = 2610 / 4096 / 4;
m2 = 2523 / 4096 * 128;
c1 = 3424 / 4096;
c2 = 2413 / 4096 * 32;
c3 = 2392 / 4096 * 32;

if Inverse
    % Normalize The input by the Maximum authorized luminance
    x = x / MaxLum;
%     x (x > 1) = 1;
%     x (x < 0) = 0; 
    
    % Apply the inverse EOTF on the input image
    y = ((c2 *(x.^m1) + c1)./(1 + c3 *( x.^m1))).^m2;
else
    % Remove values outside [0-1] for example caused by overflow in coding
     x (x <= 0) = 0.005;
     x (x > 1) = 1;
    
    % Apply the EOTF on the input image
    y = (max((x.^(1/m2) - c1),0) ./ (c2 - c3 * x.^(1/m2))).^(1/m1);
    
    % Scale the output to the maximum luminance
    y = y * MaxLum; 
%--------------------------- END OF CODE ----------------------------------
% Header generated using two templates:
% - 4908-m-file-header-template
% - 27865-creating-function-files-with-a-header-template    
end
