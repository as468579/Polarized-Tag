close all;
% clear;
% clc;
timer_total = tic;
%% The limit of polarizer config
% 1. �C�@�������׳��n���P
% 2. ���W���M�k�U�������׭n�t20��
% 3. �k�W���P���U�������פ���t20��
% 4. ���W�����I���w�O0�סA(���k�U�i�H�O160�׶�??)
% ( �]��marker���i��|����, flip �i��|�ɭP��� )
% ��L�I�h�S���׼ƪ�����A�u�n�ŦX1�Y�i
% �]���Y�O�۾F���I�u�t20�סA�hsample�X��particle���w�|�����I�b�P�@�ӤE�c�椤
% �p���N�|�Qcheck�O�_�C�@polarizer���׳����Pfilter��
% �S��pattern����m(���W�B�k�U)�i�H�A��ҡA�O���O�n�H�D���pattern�|����n??

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
% �]������������180�פ@�Ӵ`���A�ҥH�C��w�q�]�O�b��@�Ӵ`��
% �]���Τ��P�C��w�q���P��������
D = (1/18):(1/18):1;

% ���W���������ץû��O0�A�k�U���������û��O20
% 160�׭�??
% �ҥH�ݬ����Ѿl7�Ө���(row major)

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

% �ϥΥ��w�q�����רӼW�[�r�媺�״I�� (�W�[���~���v)
dict_ext_cand = [D(3) D(14) D(15) D(16) D(17)];

% dict_ext_cand ���ƦC�զX����
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

%Hint : demo���E�c�檺�C��O�ڭ̵���
%Hint : 
% Hint : H��� S���M�� V�j��
% ���ɷ|�קK�B��|�NHSV�����HRGB��ܥX��
% Since0�׻P180�׳��Ored �ҥH�NHSV������RGB��ܥX�ӫ�
% �ҥHH���ȥi�౵��0or����1
%limit1 : �Ҧ����ץu��X�{�@��
%limit2 : �]�����W�k�U�T�w�t20�ר��A�ҥH�k�W���U��������ۮt20�ר�

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
    % turn to HSV�O�]�� polarized���ץi�H��Hue����
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