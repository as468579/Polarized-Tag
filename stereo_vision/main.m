    left = imread("D:\User\Documents\MATLAB\Ptag\img\5_7\70\distance\b70t70\l.png");
    right = imread("D:\User\Documents\MATLAB\Ptag\img\5_7\70\distance\b70t70\r.png");
    [left_rectified,  right_rectified] = rectifyStereoImages(left, right, stereoParams, "OutputView", "Full");
    
    p_parameters = PMSParameters();
    disparityPMS(left_rectified, right_rectified, p_parameters);