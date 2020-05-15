%     left = imread("C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\distance\b70t70\l.png");
%     right = imread("C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\distance\b70t70\r.png");
%     [left_rectified,  right_rectified] = rectifyStereoImages(left, right, stereoParams, "OutputView", "Full");
    
    left_rectified = imread("C:\Users\User\Documents\MATLAB\PTag\Polarized-Tag\stereo_vision\left.png");
    right_rectified = imread("C:\Users\User\Documents\MATLAB\PTag\Polarized-Tag\stereo_vision\right.png");
    param = PMSParameters();
    timer = tic;
    p = PatchMatchStereo(left_rectified, right_rectified, param);
    p.start();
    time = toc(timer);