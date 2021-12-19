% this function is for 4 pattern detection
% function L = calc_log_likelihood_using_HSV_difference_rotate(X_std_hsv_diff, Xhsv_diff_1,Xhsv_diff_2,Xhsv_diff_3,s_thre,v_thre, X, Y) 
function L = calc_log_likelihood_using_HSV_difference_rotate(X_std_hsv_diff, Xhsv_diff_1,hueDiff_thre,s_thre,v_thre, X, Y) 

Yimg = Y;
% Y is the frame
Npix_h = size(Y, 1);
Npix_w = size(Y, 2);

% N is the number of particles
N = size(X,2);

% L store the likelyhood of all particles
L = zeros(1,N);
Y = permute(Y, [3 1 2]);

A = -log(sqrt(2 * pi) * X_std_hsv_diff);
B = - 0.5 / (X_std_hsv_diff.^2);

% don't care
neighborNum = 0;

% throgh all particles
for k = 1:N
    %% Check angle between 0~359 and scaling is pos
   
    % Problem : check 若 theta > 360 或 < 0會不會有問題，若有 是不是該在其他地方使theta一定在 0 ~ 359
    % Problem :  why scale is  always larger than zero.
    % unknown  意義不明，可以嘗試修改
    if X(5,k) > -359 && X(5,k) < 359 && X(7,k) > 0 
        
        %% Calculate comparing coordinate by theta and scaling
        
        m = round(X(1,k));
        n = round(X(2,k));
  
        rotateMatrix  = [cosd(X(5,k)) -sind(X(5,k)); sind(X(5,k)) cosd(X(5,k))];
        
        % 左上角為(0, 0) 往下 x + 1  往右 y + 1 (same direction as image)
        % concatenate all points except for (0, 0) by  column major 
        % ex : [ 1 ] + [ 2 ] + [ 0 ] + [ 1 ] + [ 2 ]+ [ 0 ] + [ 1 ] + [ 2 ] 
        %          0         0          1          1          1        2          2          2
        % other points except for (0, 0)
        comparingVector = rotateMatrix * [1 2 0 1 2 0 1 2 ; ...
                                                                          0 0 1 1 1 2 2 2] * X(7,k);
        
        %disp(comparingVector)
        
        %  shfit(0, 0) to (m, n)
        comparingCoord = [m;n] + comparingVector;
        
        
        % 無條件進位，avoid float numbers
        % comparingCoord = round(comparingCoord);
        comparingCoord = int32(comparingCoord-0.5+1);
        
        
        %% check all 8 coordinate  are between 1 to image's resolution, make sure all particles is reasonable
        % neighborNum 為考慮周遭pixel的數量(長 or 寬)(平均後的Hue可能比較平滑，避免Hue漂移的問題)
        % 但必須保證取的pixel不能超出該quarter
        
        % check the points(包含neighborNum) except for(0, 0) whether is out of screen
        I = all(and(comparingCoord(1,:) > neighborNum,comparingCoord(1,:) <= Npix_h - neighborNum));
        
        % 學長版本
        % J = all(and(comparingCoord(2,:) > neighborNum,comparingCoord(2,:) < Npix_w - neighborNum));
        
        % 我的版本
        J = all(and(comparingCoord(2,:) > neighborNum,comparingCoord(2,:) <= Npix_w - neighborNum));       
        
        % check the points (0, 0) whether is out of screen
       M_resolution = m > neighborNum && m <= Npix_h - neighborNum;
       N_resolution = n > neighborNum && n <= Npix_w - neighborNum;
        %% calculate Likelihood by those coordinate
       
        % Since (m, n) is located at left-top rather than center point, we also
        % need to check whtehter (m, n) is leagal
        if I && J && M_resolution && N_resolution
            
            % 因為Y已經被permuted，所以要取h, s, v的話，第二個parameter分別要是1, 2, 3
            % 且因為此時一次處理8個neighbor，所以各都是1 * 8的陣列
            idx_h = sub2ind(size(Y),ones(size(comparingCoord(1,:)))*1,comparingCoord(1,:),comparingCoord(2,:));
            idx_s_thre = sub2ind(size(Y),ones(size(comparingCoord(1,:)))*2,comparingCoord(1,:),comparingCoord(2,:));
            idx_v_thre = sub2ind(size(Y),ones(size(comparingCoord(1,:)))*3,comparingCoord(1,:),comparingCoord(2,:));
            
            % find the hue of points except for itself, and let them be a vector
            hueVector =  Y(idx_h);
            
            % store he differene of hue(or angle of polarizer) of each points except for itself
            hueDiff = zeros(1,sum(1:size(hueVector,2)-1));
            
            % calculate the differene of hue(or angle of polarizer) of each points except for itself
            %     i          2    3   3   4   4   4    5   5   5   5
            %     j          1    2   1   3   2   1    4   3   2   1  
            % index     1    3   2   6   5   4   10  9   8   7   
            for i = 2:size(hueVector,2)
                for j = i-1:-1:1
                    hueDiff(sum((i-2):-1:1)+j) = abs(hueVector(i)-hueVector(j));
                end
            end
            
            % check if 自己的亮度(v) and 飽和度(s)(imply 偏振光的強度) 是否 >value threshold
            % check if neighbor的亮度 and 飽和度(imply 偏振光的強度) 是否 > value threshold
            % check if 9個點的difference of polarized angle是不是大於 (0.02 * 180)
            % 但3.6有點太鬆，可以調高試試看
            if Y(2,m,n)>s_thre && Y(3,m,n)>v_thre&&...
                all(Y(idx_s_thre)>s_thre)&&all(Y(idx_v_thre)>v_thre)&&...
                all(hueDiff>hueDiff_thre)
            
                % C is hue of Y(m,n)  =  Y(1,m,n)
                C = double(mean(mean(Y(1, m-neighborNum:m+neighborNum, n-neighborNum:n+neighborNum))));
                
                % C is hue of 第九號鄰居
                C8 = double(mean(mean(Y(1, comparingCoord(1,8)-neighborNum:comparingCoord(1,8)+neighborNum,comparingCoord(2,8)-neighborNum:comparingCoord(2,8)+neighborNum))));
    %             C2 = double(mean(mean(Y(1, comparingCoord(1,2)-neighborNum:comparingCoord(1,2)+neighborNum, comparingCoord(2,2)-neighborNum:comparingCoord(2,2)+neighborNum))));
    %             C3 = double(mean(mean(Y(1, comparingCoord(1,3)-neighborNum:comparingCoord(1,3)+neighborNum, comparingCoord(2,3)-neighborNum:comparingCoord(2,3)+neighborNum))));


                HueDiff1 = HueDistance(C,C8);
    %             HueDiff3 = HueDistance(C,C3);

    %  Xhsv_diff_1 is 0.12, so the angle is about 0.12 * 180 = 21.6
    %  The reason is the difference of angle of self and 9th neighbor is  about 20
                D1 = (HueDiff1 - Xhsv_diff_1)^2;
    %             D3 = (HueDiff3 - Xhsv_diff_3)^2;
    %             Dsquare = D1+D2+D3;
                Dsquare = D1;
    %             D2 = D' * D;

                L(k) =  A + B * Dsquare;

            
            else
                L(k) = -Inf;
            end
        else

            L(k) = -Inf;
        end
    else
        L(k) = -Inf;
    end
    
end