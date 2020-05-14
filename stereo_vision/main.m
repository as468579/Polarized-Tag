    left = imread("C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\distance\b70t70\l.png");
    right = imread("C:\Users\User\Documents\MATLAB\PTag\img\5_7\70\distance\b70t70\r.png");
    [left_rectified,  right_rectified] = rectifyStereoImages(left, right, stereoParams, "OutputView", "Full");
    
    param = PMSParameters();
    timer = tic;
    pms =PointMatchStereo(left_rectified, right_rectified, param);
    time = toc(timer);