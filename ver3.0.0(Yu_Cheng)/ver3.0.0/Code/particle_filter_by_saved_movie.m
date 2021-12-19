close all;
clear;

%% The limit of polarizer config
% 1. �C�@�������׳��n���P
% 2. ���W���M�k�U�������׭n�t20��
% 3. �k�W���P���U�������פ���t20��
% ( �]��marker���i��|����, flip �i��|�ɭP��� )
% ��L�I�h�S���׼ƪ�����A�u�n�ŦX1�Y�i
% �]���Y�O�۾F���I�u�t20�סA�hsample�X��particle���w�|�����I�b�P�@�ӤE�c�椤
% �p���N�|�Qcheck�O�_�C�@polarizer���׳����Pfilter��
% �S��pattern����m(���W�B�k�U)�i�H�A��ҡA�O���O�n�H�D���pattern�|����n??

%% Parameters
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
D10 = 1/18;
D50 = D10*5;
D60 = D10*6;
D70 = D10*7;
D90 = 0.5;
D100 = D10*10;
D110 = D10*11;
D130 = D10*13;
D10 = 1/18;
D50 = D10*5;
D60 = D10*6;
D70 = D10*7;
D90 = 0.5;
D100 = D10*10;
D110 = D10*11;
D130 = D10*13;
D = (1/18):(1/18):1;

% ���W���������ץû��O0�A�k�U���������û��O20
% �ҥH�ݬ����Ѿl7�Ө���(row major)
dict = [     D100  D110    D70    D90   D50    D60   D130 ; ...
             D100   D60    D70    D90   D50    D110  D130;...
             D100   D60    D70    D90   D110   D50   D130;...
             D100   D60    D70    D130  D110   D50   D90];
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
% �]��0�׻P180�׳��Ored �ҥH�NHSV������RGB��ܥX�ӫ�
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
  X = create_particles_rotate(Npix_resolution*imageResizeRatio, scaleRange, Npop_particles);
while (true)
% for imgNum = 1:1

    fileName = strcat('C:\Users\USER\Desktop\4AngleCamera\trafficSign\img\multiMarker_2.bmp');
%         fileName = strcat('C:\Users\USER\Desktop\4AngleCamera\PTag\Data\6_19_50mm\singleImg\outdoor\30m\1\temp- (6).bmp');
    rawdata = imread(fileName);
    % Getting Image polarization information
    
    % turn to HSV�O�]�� polarized���ץi�H��Hue����
    Y_HSV = PolarizedTrunToHSV(rawdata) ;
    
    show_particles(X,Y_HSV)
    
    % Forecasting

    X = update_particles_rotate(F_update_new, Xstd_pos, Xstd_vec, Xstd_theta, Xstd_deltaTheta, Xstd_scale, Xstd_deltaScale, X);

    % Calculating Log Likelihood

    L = calc_log_likelihood_using_HSV_difference_rotate(X_std_hsv_diff,Xhsv_diff_1,hueDiff_thre,discardSaturateBelow,discardValueBelow, X, Y_HSV);

    ID = evaluation_likelihood_multiMarker(L,X,Y_HSV,dict);
    % Single marker detection
    % [ID,error] = EVALUATE_largest_L(L,X,Y_HSV,dict);

%         if Likelihood too low, recreate particle
    if(max(L)<-1)
        legalParticleLocation = EvaluateParticleLocation(Y_HSV,discardSaturateBelow,discardValueBelow);
        [boundingSet,L] = PartionPolarizedBounding(legalParticleLocation,Xhsv_diff_1,Y_HSV);
        X = CVDecode(boundingSet,L,Y_HSV,Xhsv_diff_1);
        L = calc_log_likelihood_using_HSV_difference_rotate(X_std_hsv_diff,Xhsv_diff_1,hueDiff_thre,discardSaturateBelow,discardValueBelow, X, Y_HSV);
        ID = evaluation_likelihood_multiMarker(L,X,Y_HSV,dict);
        
        % Write a function that check the boundingPoint sets valid or  not -> "candidate validation"

%             X = CreateParticlePair(Xhsv_diff_1,candidateArea,Y_HSV); % Area version, need to modify into bounding version 

%             Npop_particles = floor(size(legalParticleLocation,2)/3)*2;
%              X=create_particles_rotate(Npix_resolution, scaleRange, Npop_particles,legalParticleLocation);
    else
        % Resampling
        X = resample_particles(X, L);
    end
end


% raw data is grayscale
% color information doesn't mean to the true color of pixel
% color information means different angle of polarizer
% use four piexl of raw data can create one pixel of Y_HSV
% so the return array will be 1/4 ���n of raw data
% use the forluma to calculate polarized to HSV
function HSVImage = PolarizedTrunToHSV(rawdata)
    sample_wholePic = rawdata;
    sample_90angle = sample_wholePic(1:2:2048,1:2:2448);
    sample_0angle= sample_wholePic(2:2:2048,2:2:2448);
    sample_45angle = sample_wholePic(1:2:2048,2:2:2448);
    sample_135angle = sample_wholePic(2:2:2048,1:2:2448);
    
    g0   = double(sample_0angle);
    g45  = double(sample_45angle);
    g90  = double(sample_90angle);
%     g135 = g0 + g90 - g45;
    g135  = double(sample_135angle);
    I = g0 + g90;
    Q = g0 - g90;
    U = g45 - g135;

    I(I==0)=1;

    %linear polarization intensity
    pollnt = sqrt(Q.^2 + U.^2);

    %degree of linear polarization
    polDoLP = pollnt./I;

    %Angle of Polarization;
%     polAoP = atan2(U,Q);
%     H = ((polAoP+pi)*(1/(2*pi)));
    
    polAoP = 0.5*atan2(U,Q) ;
    H = ((polAoP+pi/2)*(1/pi));
    
    S = polDoLP / max(abs(polDoLP(:))) ;
    V_threshold = 10/max(abs(pollnt(:)));
    V = pollnt / max(abs(pollnt(:)));
    HSV_img = cat(3,H,S,V);
%     rgb_img = hsv2rgb(HSV_img);
%     figure(3)
%     imshow(rgb_img);
    HSVImage = HSV_img;
end