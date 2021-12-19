function X = update_particles_rotate(F_update, Xstd_pos, Xstd_vec, Xstd_theta, Xstd_deltaTheta, Xstd_scale, Xstd_deltaScale, X)
    %此處修改F_update只是因為後來擴充了update_table，為了要可以相乘(Dimension)
    if(size(X,1)==9)
        F_update = [1 0 1 0 0 0 0 0 0; 0 1 0 1 0 0 0 0 0; 0 0 1 0 0 0 0 0 0; 0 0 0 1 0 0 0 0 0; 0 0 0 0 1 1 0 0 0; 0 0 0 0 0 1 0 0 0; 0 0 0 0 0 0 1 1 0; 0 0 0 0 0 0 0 1 0; 0 0 0 0 0 0 0 0 1];
    end
    if(size(X,1)==10)
        F_update = [1 0 1 0 0 0 0 0 0 0; 0 1 0 1 0 0 0 0 0 0; 0 0 1 0 0 0 0 0 0 0; 0 0 0 1 0 0 0 0 0 0; 0 0 0 0 1 1 0 0 0 0; 0 0 0 0 0 1 0 0 0 0; 0 0 0 0 0 0 1 1 0 0; 0 0 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 0 0 1 0;0 0 0 0 0 0 0 0 0 1];
    end
N = size(X, 2);
X = F_update * X;


% X, Y值也有更新???
X(1:2,:) = X(1:2,:) + Xstd_pos * randn(2, N);
X(3:4,:) = X(3:4,:) + Xstd_vec * randn(2, N);
X(5,:) = X(5,:) + Xstd_theta * randn(1,N);
X(6,:) = X(6,:) + Xstd_deltaTheta * randn(1,N);
X(7,:) = X(7,:) + Xstd_scale * randn(1,N);
X(8,:) = X(8,:) + Xstd_deltaScale * randn(1,N);

% if(size(X,1)) == 9
%     X(9,:) = X(9,:);
% end
% if(size(X,1)) == 10
%     X(9,:) = X(9,:);
%     X(10,:) = X(10,:);
% end

end
