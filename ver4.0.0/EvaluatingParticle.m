% this function is for 4 pattern detection
function EvaluatingParticle(Xstd_h, Xtrgt_diff_h_1,Xtrgt_diff_h_2,Xtrgt_diff_h_3, X, Y_orig) 


Npix_h = size(Y_orig, 1);
Npix_w = size(Y_orig, 2);

N = size(X,2);

L = zeros(1,N);
Y = permute(Y_orig, [3 1 2]);

A = -log(sqrt(2 * pi) * Xstd_h);
B = - 0.5 / (Xstd_h.^2);

X = round(X);

for k = 1:N
    %% Check angle between 0~359 and scaling is pos
    if X(5,k) > 0 && X(5,k) < 359 && X(7,k) > 0 
        %% Calculate comparing coordinate by theta and scaling
        m = X(1,k);
        n = X(2,k);

        rotateMatrix  = [cosd(X(5,k)) -sind(X(5,k)); sind(X(5,k)) cosd(X(5,k))];
        comparingVector = rotateMatrix * [1 0 1; 0 1 1] * X(7,k);
    %     disp(comparingVector)
        comparingCoord = [m;n] + comparingVector;
        comparingCoord = round(comparingCoord);
        
        %% check all 8 coordinate between 1 to image's resolution
        I = all(and(comparingCoord(1,:) >= 1,comparingCoord(1,:) <= Npix_h));
        J = all(and(comparingCoord(2,:) >= 1,comparingCoord(2,:) <= Npix_w));
        M_resolution = m >= 1 && m <= Npix_h;
        N_resolution = n >= 1 && n <= Npix_w;
        %% calculate Likelihood by those coordinate
        if I && J && M_resolution && N_resolution
            
            C = double(Y(1, m, n));
            
            C1 = double(Y(1, comparingCoord(1,1), comparingCoord(2,1)));
            C2 = double(Y(1, comparingCoord(1,2), comparingCoord(2,2)));
            C3 = double(Y(1, comparingCoord(1,3), comparingCoord(2,3)));
            
            HueDiff1 = HueDistance(C,C1);
            HueDiff2 = HueDistance(C,C2);
            HueDiff3 = HueDistance(C,C3);
            D1 = (HueDiff1 - Xtrgt_diff_h_1);
            D2 = (HueDiff2 - Xtrgt_diff_h_2);
            D3 = (HueDiff3 - Xtrgt_diff_h_3);
            D = (D1+D2+D3)/3;
            D2 = D' * D;

            L(k) =  A + B * D2;
            figure(3)
            image(Y_orig)
            title('evaluation of particle')
            hold on
            plot(n,m,'.',comparingCoord(2,:),comparingCoord(1,:),'c*')
            hold off
            pause()
        else

            L(k) = -Inf;
        end
    else
        L(k) = -Inf;
    end
end