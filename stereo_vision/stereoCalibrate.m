

    
left = imread("D:\User\Documents\MATLAB\Ptag\img\5_7\70\distance\b70t70\l.png");
right = imread("D:\User\Documents\MATLAB\Ptag\img\5_7\70\distance\b70t70\r.png");


[left_rectified,  right_rectified] = rectifyStereoImages(left, right, stereoParams, "OutputView", "Full");

figure(1);
% imshow(stereoAnaglyph(left_rectified, right_rectified));
imshow(cat(3,left_rectified(:,:,1), right_rectified(:,:,2:3)),'InitialMagnification',50);
% imshow(left_rectified,'InitialMagnification',50);
% saveas(gcf, "rectified.png");
hold on;
plot([0:128:size(left_rectified, 2)], 10, 'r+', 'MarkerSize', 10, 'LineWidth', 2);

timer = tic;
disparityRange = [0 128];
% disparityMap = disparityBM(rgb2gray(left_rectified),rgb2gray(right_rectified),'DisparityRange',disparityRange,'UniquenessThreshold',20);
% disparityMap = disparitySGM(rgb2gray(left_rectified),rgb2gray(right_rectified),'DisparityRange',disparityRange,'UniquenessThreshold',20);
disparityFCVF(left_rectified, right_rectified)
time = toc(timer);
figure(2) 
% imshow(disparityMap, disparityRange,'InitialMagnification',50);
% saveas(gcf, "disparity.png");


%% Distance filter
% xyzPoints = reconstructScene(disparityMap,stereoParams);
% Z = xyzPoints(:,:,3);
% mask = repmat(Z > 550 & Z < 1000, [1,1,3]);
% left_rectified(~mask) = 0;
% figure(3);
% imshow(left_rectified,'InitialMagnification',50);

%% 3D visualization

% points3D = reconstructScene(disparityMap, stereoParams);
% 
% % Convert to meters and create a pointCloud object
% points3D = points3D ./ 1000;
% ptCloud = pointCloud(points3D, 'Color', left_rectified);
% 
% % Create a streaming point cloud viewer
% player3D = pcplayer([-3, 3], [-3, 3], [0, 8], 'VerticalAxis', 'y', ...
%     'VerticalAxisDir', 'down');
% 
% % Visualize the point cloud
% view(player3D, ptCloud);