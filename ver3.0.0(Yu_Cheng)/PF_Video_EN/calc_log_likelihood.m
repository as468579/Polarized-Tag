function L = calc_log_likelihood(Xstd_rgb, Xrgb_trgt, X, Y) %#codegen

% Y is a frame now 
% X is the table of x, y ,delatx, and deltay of particles
% L store log(probability of gussian distrbution) of each particle

% get height of current frame
Npix_h = size(Y, 1);

% get width of current frame
Npix_w = size(Y, 2);

% get number of particles
N = size(X,2);

% store  likelyhoood of particles
L = zeros(1,N);

% frame reshape make rgb channel be the first channel
Y = permute(Y, [3 1 2]);

A = -log(sqrt(2 * pi) * Xstd_rgb);
B = - 0.5 / (Xstd_rgb.^2);

% for the reason that deltax, deltay, and randi could be flaot and then the
% coordinations of the particles could be float after update .That is invalid.
X = round(X);

% calculate each likelyhood of particle 
for k = 1:N
    
    % get x 
    m = X(1,k);
    
    % get y
    n = X(2,k);
    
    % check whether the particles in the screen
    I = (m >= 1 & m <= Npix_h);
    J = (n >= 1 & n <= Npix_w);
    
    if I && J
        
        % r,b,g of coordinate(m, n)
        C = double(Y(:, m, n));
        
        % distanace of current color and target color
        D = C - Xrgb_trgt;
        
        % calculate inner product : square(r - target_r) +square(g -
        % target_g)+ square(b - target_b)
        D2 = D' * D;
        
        L(k) =  A + B * D2;
    else
        
        L(k) = -Inf;
    end
end
