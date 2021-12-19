close all;
% clear;
% clc;
timer_total = tic;
%% The limit of polarizer config
% 1. 每一片的角度都要不同
% 2. 左上角和右下角的角度要差20度
% 3. 右上角與左下角的角度不能差20度
% 4. 左上角的點必定是0度，(但右下可以是160度嗎??)
% ( 因為marker有可能會旋轉, flip 可能會導致抓錯 )
% 其他點則沒有度數的限制，只要符合1即可
% 因為若是相鄰的點只差20度，則sample出的particle必定會有兩點在同一個九宮格中
% 如此就會被check是否每一polarizer角度都不同filter掉
% 特殊pattern的位置(左上、右下)可以再思考，是不是要以非對稱pattern會比較好??

%% Parameters
% 0.02 * 
hueDiff_thre = 0.02;

%For short distance
% discardSaturateBelow = 0.4;
% discardValueBelow = 0.6;

%For long distance
discardSaturateBelow = 0.1;
discardValueBelow = 0.1;


scaleRange = [10,20];
F_update = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];
F_update_new = [1 0 1 0 0 0 0 0; 0 1 0 1 0 0 0 0; 0 0 1 0 0 0 0 0; 0 0 0 1 0 0 0 0; 0 0 0 0 1 1 0 0; 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 1];
Npop_particles = 1000;

Xstd_pos =1 ;
Xstd_vec = 1;

Xstd_theta = 1;
Xstd_deltaTheta = 3;

Xstd_scale = 1;
Xstd_deltaScale = 1;

Xhsv_diff_1 = 0.12; 
% Xhsv_diff_2 = 0.5;
% Xhsv_diff_3 = 0.0;

X_std_hsv_diff = 0.005;

% D50 = 0.2992;
% D60 = 0.3526;
% D70 = 0.401;
% D90 = 0.5146;
% D100 = 0.5802;
% D110 = 0.6229;
% D130 = 0.7316;

% D : degree
% 因為偏振片角度180度一個循環，所以顏色定義也是半圈一個循環
% 因為用不同顏色定義不同偏振角度
D = (1/18):(1/18):1;

% 左上的偏振角度永遠是0，右下的偏振角永遠是20
% 160度哩??
% 所以需紀錄剩餘7個角度(row major)

% dict = [     D100  D110    D70    D90   D50    D60   D130 ; ...
%             D100   D60    D70    D90   D50    D110  D130;...
%             D100   D60    D70    D90   D110   D50   D130;...
%              D100   D60    D70    D130  D110   D50   D90;
%              D40  D60  D80  D100  D120  D140  D160];

dict = [   D(10)  D(11)    D(7)    D(9)  D(5)   D(6)   D(13) ; ...
            D(10)   D(6)      D(7)     D(9)   D(5)    D(11)   D(13);...
            D(10)    D(6)      D(7)     D(9)   D(11)   D(5)   D(13);...
             D(10)    D(6)      D(7)     D(13)  D(11)   D(5)   D(9);
             D(4)  D(6)   D(8)  D(10)   D(12)  D(14)  D(16)];
         
% dict = [
%         D(14), D(11), D(8), D(3), D(13), D(5), D(10);
%         D(10), D(7), D(14), D(6), D(17), D(5), D(15);        
%         D(6), D(17), D(11), D(3), D(8), D(16), D(12);      
%         D(11), D(17), D(5), D(15), D(13), D(14), D(8);
%         
%         D(15), D(9), D(4), D(12), D(5), D(14), D(7);
%         
%         D(12), D(9), D(13), D(7), D(17), D(11), D(14);
%         
%         D(7), D(4), D(8), D(10), D(17), D(15), D(12);
%         
%         D(13), D(16), D(5), D(3), D(14), D(17), D(9);
%         
%         D(13), D(3), D(15), D(17), D(5), D(6), D(4);
%         
%         D(8), D(3), D(9), D(13), D(16), D(5), D(17);
%         
%         D(7), D(11), D(12), D(3), D(16), D(17), D(6);
%         
%         D(11), D(6), D(4), D(9), D(14), D(12), D(7);
%         
%         D(14), D(9), D(3), D(5), D(11), D(10), D(16);
%         
%         D(16), D(9), D(3), D(6), D(17), D(11), D(13);
%         
%         D(9), D(13), D(6), D(14), D(8), D(17), D(5);
%         
%         D(12), D(8), D(11), D(7), D(17), D(3), D(10);
%         
%         D(10), D(13), D(9), D(3), D(5), D(11), D(15);
%         
%         %D(6), D(17), D(11), D(3), D(13), D(4), D(16);
%         
%         D(8), D(12), D(4), D(13), D(6), D(14), D(5);
%         
%         D(8), D(10), D(13), D(17), D(5), D(4), D(14);
%         
%         D(7), D(13), D(16), D(4), D(9), D(8), D(15);
%         
%         D(3), D(8), D(12), D(9), D(13), D(6), D(15);
%         
%         D(3), D(10), D(9), D(16), D(8), D(17), D(4);
%         
%         D(12), D(8), D(4), D(9), D(6), D(11), D(16);
%         
%         D(10), D(6), D(13), D(8), D(12), D(9), D(11);
%     ];

% comform that IDs are unique
assert( size(dict, 1) == size(unique(dict, 'row'), 1) );

% conform diff angle of right top and left down is not eual to than 20
diff_leftTop_and_rightDown = abs( dict(:,2) - dict(:,6) );
assert( all( abs( diff_leftTop_and_rightDown - D(2) ) > 1e-3 ) );

dict1 = [dict(:,3) dict(:,6) dict(:,1) dict(:,4) dict(:,7) dict(:,2) dict(:,5)];
dict = dict1;

% 使用未定義的角度來增加字典的豐富度 (增加錯誤機率)
dict_ext_cand = [D(3) D(14) D(15) D(16) D(17)];

% dict_ext_cand 的排列組合順序
dictexIdx = ... 
[
     1     2     4     3 ;...
     4     2     1     5 ;...
     3     2     5     1 ;...
     2     5     1     3 ;...
     1     4     2     3 ;...
     4     1     2     5 ;...
     4     1     2     3 ;...
     2     1     4     3 ;...
     1     2     5     4 ;...
     1     4     5     2 ;...
     4     1     3     5 ;...
     1     2     3     4 ;...
];

%Hint : demo中九宮格的顏色是我們給的
%Hint : 
% Hint : H色度 S飽和度 V強度
% 有時會避免運算會將HSV直接以RGB顯示出來
% Since0度與180度都是red 所以將HSV直接用RGB表示出來後
% 所以H的值可能接近0or接近1
%limit1 : 所有角度只能出現一次
%limit2 : 因為左上右下固定差20度角，所以右上左下之間不能相差20度角

dictExtensionNumber = 4; % 4 or 12
dict_extension = [dict;];

%% Loading Movie
% vr = VideoReader('../Data/littleTagRetro_3m.avi');

imageResizeRatio = 1;
% colorizedImage = imread('../Data/Colorized.bmp');
% Npix_resolution = [size(colorizedImage,2) size(colorizedImage,1)];
% Npix_resolution = [vr.Width vr.Height];
Npix_resolution = [1224 1024];

% Nfrm_movie = floor(vr.Duration * vr.FrameRate);


%% Object Tracking by Particle Filter

 detectResult = zeros(7,4,20);
 detectRound = zeros(7,4,20);
  % X = create_particles_rotate(Npix_resolution*imageResizeRatio, scaleRange, Npop_particles);
  X = create_particles(Npix_resolution * imageResizeRatio, scaleRange, Npop_particles); 
  X = gpuArray(X);
  folder = ('D:\User\Documents\MATLAB\Ptag\img\3_20\');
  % folder = ('D:\User\Documents\MATLAB\Ptag\img\1_1\horizontal\');
  numberOfFile = 917;
  numberOfParticles = [];
  posCount = [];
  time_YHSV = 0;
  time_update_particles_rotate = 0;
  time_evaluateParticleLocation = 0;
  time_partionPolarizedBounding = 0;
  time_cvDecode = 0;
  time_calc_log_likelihood_using_HSV_difference_rotate = 0;
  time_evaluation_likelihood_multiMarker = 0;
% while (true)

for imgNum = 55:255
% for imgNum = 1:117
    % imgNum = '1';
    disp(imgNum);
    fileName = strcat(folder, num2str(imgNum), '.Bmp');
    rawdata = imread(fileName);
    
    % Getting Image polarization information
    % turn to HSV是因為 polarized角度可以當成Hue角度
    % timer_YHSV = tic;
    rawdata = gpuArray(rawdata);
    Y_HSV = PolarizedTrunToHSV(rawdata);
    % time_YHSV = time_YHSV + toc(timer_YHSV);
    
    % Forecasting
    % timer_update_particles_rotate = tic;
    X = update_particles_rotate(F_update_new, Xstd_pos, Xstd_vec, Xstd_theta, Xstd_deltaTheta, Xstd_scale, Xstd_deltaScale, X);
    % time_update_particles_rotate = time_update_particles_rotate + toc(timer_update_particles_rotate);
    
    % Calculating Log Likelihood
    % timer_calc_log_likelihood_using_HSV_difference_rotate = tic;
    % likelihood = calc_log_likelihood_using_HSV_difference_rotate(X_std_hsv_diff,Xhsv_diff_1,hueDiff_thre,discardSaturateBelow,discardValueBelow, X, Y_HSV);
    likelihood = calc_log_likelihood_gpu(X, Y_HSV, Xhsv_diff_1, X_std_hsv_diff, hueDiff_thre, discardSaturateBelow, discardValueBelow);
    % likelihood2 = calc_log_likelihood(X, Y_HSV, Xhsv_diff_1, X_std_hsv_diff, hueDiff_thre, discardSaturateBelow, discardValueBelow);
    % time_calc_log_likelihood_using_HSV_difference_rotate = time_calc_log_likelihood_using_HSV_difference_rotate + toc(timer_calc_log_likelihood_using_HSV_difference_rotate);
    
    % timer_evaluation_likelihood_multiMarker = tic;
    % X = gather(X);
    % Y_HSV = gather(Y_HSV);
    % [ID, avg_X] = evaluation_likelihood_multiMarker(likelihood, X, Y_HSV, dict);
    [ID, avg_X] = evaluation_likelihood_multiMarker2(X, likelihood, Y_HSV, dict);
    posCount= [posCount avg_X];
    % time_evaluation_likelihood_multiMarker = time_evaluation_likelihood_multiMarker + toc(timer_evaluation_likelihood_multiMarker);
    % Single marker detection
    % [ID,error] = EVALUATE_largest_L(L,X,Y_HSV,dict);

%   if Likelihood too low, recreate particle
    if(max(likelihood)<-1)
        % timer_evaluateParticleLocation  = tic;
        legalParticleLocation = EvaluateParticleLocation(Y_HSV,discardSaturateBelow,discardValueBelow);
        % time_evaluateParticleLocation = time_evaluateParticleLocation + toc(timer_evaluateParticleLocation);
        % L here means label array
        
        % timer_partionPolarizedBounding = tic;
        % [boundingSet,L] = PartionPolarizedBounding(legalParticleLocation,Xhsv_diff_1,Y_HSV);
        [boundingSet,L] = partitionPolarizedBounding(legalParticleLocation,Xhsv_diff_1,Y_HSV);
        % time_partionPolarizedBounding = time_partionPolarizedBounding +toc(timer_partionPolarizedBounding);
        
        % timer_cvDecode = tic;
        X = CVDecode(boundingSet,L,Y_HSV,Xhsv_diff_1);
        % time_cvDecode = time_cvDecode +toc(timer_cvDecode);
        
        % L here means likelihood array
        % timer_calc_log_likelihood_using_HSV_difference_rotate = tic;
        % likelihood = calc_log_likelihood_using_HSV_difference_rotate(X_std_hsv_diff,Xhsv_diff_1,hueDiff_thre,discardSaturateBelow,discardValueBelow, X, Y_HSV);
        likelihood = calc_log_likelihood_gpu(X, Y_HSV, Xhsv_diff_1, X_std_hsv_diff, hueDiff_thre, discardSaturateBelow, discardValueBelow);
        % likelihood = calc_log_likelihood_using_HSV_difference_rotate(X_std_hsv_diff,Xhsv_diff_1,hueDiff_thre,discardSaturateBelow,discardValueBelow, X, Y_HSV);
        % time_calc_log_likelihood_using_HSV_difference_rotate = time_calc_log_likelihood_using_HSV_difference_rotate + toc(timer_calc_log_likelihood_using_HSV_difference_rotate);
        
        % timer_evaluation_likelihood_multiMarker = tic;
        % X = gather(X);
        % Y_HSV = gather(Y_HSV);
        % [ID, avg_X] = evaluation_likelihood_multiMarker(likelihood, X, Y_HSV, dict);
        [ID, avg_X] = evaluation_likelihood_multiMarker2(X, likelihood, Y_HSV, dict);
        % time_evaluation_likelihood_multiMarker = time_evaluation_likelihood_multiMarker +toc(timer_evaluation_likelihood_multiMarker);
        
        posCount= [posCount avg_X];
        % Write a function that check the boundingPoint sets valid or  not -> "candidate validation"

%             X = CreateParticlePair(Xhsv_diff_1,candidateArea,Y_HSV); % Area version, need to modify into bounding version 

%             Npop_particles = floor(size(legalParticleLocation,2)/3)*2;
%              X=create_particles_rotate(Npix_resolution, scaleRange, Npop_particles,legalParticleLocation);
    else
        % Resampling
        % disp('resample_particles');
        X = resample_particles(X, likelihood);
    end
    % frames(imgNum-54) = getframe(gcf) ;
    % numberOfParticles = [numberOfParticles, size(X, 2)];
end
% times = [time_YHSV time_update_particles_rotate time_evaluateParticleLocation time_partionPolarizedBounding time_cvDecode time_calc_log_likelihood_using_HSV_difference_rotate time_evaluation_likelihood_multiMarker]
total_time = toc(timer_total)
% bar(times ./ total_time)

%   writerObj = VideoWriter('gpu_ver4_0_0.avi');
%   writerObj.FrameRate = ;
%   
%  open(writerObj);
% % write the frames to the video
% for i=1:length(frames)
%     % convert the image to a frame
%     frame = frames(i) ;    
%     writeVideo(writerObj, frame);
% end
% % close the writer object
% close(writerObj);