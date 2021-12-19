function X = update_particles(F_update, Xstd_pos, Xstd_vec, X)

%number of particle
N = size(X, 2);

% x = x + deltax , y = y + deltay
X = F_update * X;

% x = x1 coordinate         x40000 coordinate
%        y1 coordinate  ....   y40000 coordinate
%           deltax1                     deltax40000
%           deltay1                     deltay40000

% 將位置加上亂度
X(1:2,:) = X(1:2,:) + Xstd_pos * randn(2, N);

% 將速度加上亂度
X(3:4,:) = X(3:4,:) + Xstd_vec * randn(2, N);

% Xstd maybe could be automatic
