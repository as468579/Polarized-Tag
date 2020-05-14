% Auto-generated by stereoCalibrator app on 11-May-2020
%-------------------------------------------------------


% Define images to process
imageFileNames1 = {'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\left\1.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\left\10.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\left\11.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\left\13.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\left\14.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\left\2.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\left\3.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\left\5.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\left\7.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\left\8.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\left\9.png',...
    };
imageFileNames2 = {'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\right\1.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\right\10.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\right\11.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\right\13.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\right\14.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\right\2.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\right\3.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\right\5.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\right\7.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\right\8.png',...
    'C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\right\9.png',...
    };

% Detect checkerboards in images
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames1, imageFileNames2);

% Generate world coordinates of the checkerboard keypoints
squareSize = 9.500000e+00;  % in units of 'millimeters'
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Read one of the images from the first stereo pair
I1 = imread(imageFileNames1{1});
[mrows, ncols, ~] = size(I1);

% Calibrate the camera
[stereoParams, pairsUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', true, ...
    'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);

% View reprojection errors
% h1=figure; showReprojectionErrors(stereoParams);

% Visualize pattern locations
% h2=figure; showExtrinsics(stereoParams, 'CameraCentric');

% Display parameter estimation errors
% displayErrors(estimationErrors, stereoParams);

% You can use the calibration data to rectify stereo images.
% I2 = imread(imageFileNames2{1});
% [J1, J2] = rectifyStereoImages(I1, I2, stereoParams);

% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('StereoCalibrationAndSceneReconstructionExample')
% showdemo('DepthEstimationFromStereoVideoExample')
