 rawdata = imread('C:\Users\User\Documents\MATLAB\PTag\img\rotate\multitags4.bmp');
 Y_HSV = PolarizedTrunToHSV(rawdata) ;
 H = Y_HSV(:, :, 1);
 S = Y_HSV(:, :, 2);
 V = Y_HSV(:, :,3);
 figure;
imshow(rawdata);
figure;
Y_HSV = hsv2rgb(Y_HSV);
Y_HSV = rgb2gray(Y_HSV);
imshow(Y_HSV);
colorbar

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