

function likelihood = calc_log_likelihood_gpu(particles, HSV, pilotDiff, hueDiff_std, hueDiff_thre, s_thre, v_thre)

    height = size(HSV, 1);
    width = size(HSV, 2);
    numOfParticles = size(particles, 2);

    rotateMatrix = zeros(2 * numOfParticles, 2, 'gpuArray');
%     rotateMatrix = zeros(2 * numOfParticles, 2);
    origMatrix = reshape([particles(1, :); particles(2, :)], [], 1);

    cosineVal = single(arrayfun(@cosd, particles(5, :)));
    sineVal = single(arrayfun(@sind, particles(5, :)));
    
    rotateMatrix(1:2:end, :) = [cosineVal',  sineVal' .* -1];
    rotateMatrix(2:2:end, :) = [sineVal',  cosineVal'];
    
    scaleMatrix = repelem(single(particles(7, :)), 1, 2);
    scaleMatrix = reshape(scaleMatrix, [], 1);
    
    grid3by3Vector = rotateMatrix * [ 0 1 2 0 1 2 0 1 2 ;...
                                               0 0 0 1 1 1 2 2 2 ] .* scaleMatrix;

    grid3by3Position = round( grid3by3Vector + origMatrix );
    
    %% check whether grid positions are in the screen
    % x, y?

    x_pos = grid3by3Position(1:2:end, :);
    y_pos = grid3by3Position(2:2:end, :);
    assert(all(size(x_pos) == size(y_pos), 'all'));

    checkX = all(and(x_pos > 0, x_pos <= height) , 2);
    checkY = all(and(y_pos > 0, y_pos <= width), 2);
    checkParticlesOutOfScreen = all(and(checkX, checkY), 2);

    origSize = size(x_pos);
    % find would find out the element which value isn't zero and return its index
    origIdx = checkParticlesOutOfScreen;
    x_pos = x_pos(checkParticlesOutOfScreen == 1, :);
    y_pos = y_pos(checkParticlesOutOfScreen == 1, :);
    numOfParticles = size(x_pos, 1);
    
    
%     hues = zeros(numOfParticles, size(x_pos, 2), 'gpuArray');
%     saturations = zeros(numOfParticles, size(x_pos, 2), 'gpuArray');
%     values = zeros(numOfParticles, size(x_pos, 2), 'gpuArray');
%     for i = 1:numOfParticles
%         idx_h = sub2ind(size(HSV), x_pos(i, :), y_pos(i, :), ones(1, size(x_pos, 2)));
%         idx_s = sub2ind(size(HSV), x_pos(i, :), y_pos(i, :), ones(1, size(x_pos, 2))*2);
%         idx_v = sub2ind(size(HSV), x_pos(i, :), y_pos(i, :), ones(1, size(x_pos, 2))*3);
%         
%         hues(i, :)         = gpuArray(HSV(idx_h));
%         saturations(i, :) = gpuArray(HSV(idx_s));
%         values(i, :)       = gpuArray(HSV(idx_v));
%     end

    idx_h = sub2ind(size(HSV), x_pos, y_pos, ones(numOfParticles, size(x_pos, 2)));
    idx_s = sub2ind(size(HSV), x_pos, y_pos, ones(numOfParticles, size(x_pos, 2))*2);
    idx_v = sub2ind(size(HSV), x_pos, y_pos, ones(numOfParticles, size(x_pos, 2))*3);

%     hues         = HSV(idx_h);
%     saturations = HSV(idx_s);
%     values       = HSV(idx_v);
    hues         = gpuArray(HSV(idx_h));
    saturations = gpuArray(HSV(idx_s));
    values       = gpuArray(HSV(idx_v));

    assert(all(size(hues) == size(x_pos), 'all'));
    assert(all(size(hues) == size(x_pos), 'all'));
    numOfGridCells = size(hues, 2);
    % store the difference of each point except for particle itself and left top.
    hueDiff = zeros(numOfParticles, sum(1:numOfGridCells - 2), 'gpuArray');
%     hueDiff = zeros(numOfParticles, sum(1:numOfGridCells - 2));
    %% Calculate the difference of hue between each cell in the same grid(3*3)
    %   i        2   3  3  4  4  4  5  5  5  5  ...  8
    %   j        1   1  2  1  2  3  1  2  3  4  ...  7
    % index    1   2  3  4  5  6  7  8  9  10 ...  36

    index_i = [2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8];
    index_j = [1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6, 7];
    disp(size(hueDiff(1, :)));
    disp(size(index_i));
    disp("==============");
    assert(all(size(hueDiff(1, :)) == size(index_i), 'all'));

    
    hueDiff = arrayfun(@HueDistance, hues(:, index_i), hues(:, index_j));
    checkH = all(hueDiff > hueDiff_thre, 2);
    checkS = all(saturations > s_thre, 2);
    checkV = all(values > v_thre, 2);
    assert(all(size(checkS) == size(checkV), 'all'));
    checkOverThreshold = and(and(checkH, checkS), checkV);
    size_after_checkScreen = size(x_pos);
    idx_after_checkScreen = checkOverThreshold;

    x_pos = x_pos(checkOverThreshold == 1, :);
    y_pos = y_pos(checkOverThreshold == 1, :);
    numOfParticles = size(x_pos, 1);
    assert(all(size(x_pos) == size(y_pos), 'all'));
    

    idx_cell1 = sub2ind(size(HSV), x_pos(:, 1), y_pos(:, 1), ones(numOfParticles, 1));
    idx_cell9 = sub2ind(size(HSV), x_pos(:, 9), y_pos(:, 9), ones(numOfParticles, 1));
    hueOfCell1 = HSV(idx_cell1);
    hueOfCell9 = HSV(idx_cell9);
    
    hueDiff_std = single(hueDiff_std);

    A = -log(sqrt(2*pi)) * hueDiff_std;
    B = -0.5 / (hueDiff_std^2);
    diff = HueDistance(hueOfCell1, hueOfCell9);
    Dsquare = (diff - pilotDiff) .^ 2;
    % assert(all(size(likelihood), size(Dsquare, 1), 'all'));

    L = A + B * Dsquare;

    %% recover likelihood to original size and insert -Inf to illegal particles' liklihood
    tmp = ones(size_after_checkScreen(1), 1, 'gpuArray') .* -Inf;
%     tmp = ones(size_after_checkScreen(1), 1) .* -Inf;
    tmp(idx_after_checkScreen) = L;
    L = tmp;

    tmp = ones(origSize(1), 1, 'gpuArray') * -Inf;
%     tmp = ones(origSize(1), 1) * -Inf;
    tmp(origIdx) = L;
    L = tmp;
    
    likelihood = gather(L');
%     1. gpuArray under parfor
%     2. idx_after_checkScreen
%        particles_after_checkScreen

end


