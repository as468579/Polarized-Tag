
function disparityPMS(left_rectified, right_rectified, pms)

%     temporal = false;
%     if length(windowSize) == 3
%         temporal = true;
%     end
%     
%     
%     weight_mtx = 
%     cost_mtx = zeros(size(left_rectified, 1), size(left_rectified, 2), 3);
%     for i = 0:max_disparity
%         cost_mtx = 
%     end
%     disp(size(cost_mtx));

    planeMap = init_planeMap(size(left_rectified, 1:2), pms);
    m = matchPixels(left_rectified, right_rectified, [1, 1], pms, planeMap);
    % filter(mask, image);
   
    % getWeight(15, 12)
end

function m = matchPixels(image, reference, coordinates, pms, planeMap)

%     sum = 0;
%     I_point =  image(p);
%     for width=floor(p(0)-windowSize/2):floor(p(0)+windowSize/2)
%         for height=floor(p(0)-windowSize/2):floor(p(0)+windowSize/2)
%             I_reference = reference(height, width);
%             
%             % sum = sum + getWeight(I_point, I_reference) * getDissimilarity(I_q, reference(height, width - inner(planeParameters, )))
%         end
%     end
    height = coordinates(1);
    width = coordinates(2);
    weights_mtx = zeros(pms.windowSize);
    
    if pms.temporal
    else
        height_range_of_window = ceil(height-pms.windowSize/2):ceil(height+pms.windowSize/2 - 1);
        width_range_of_window =  ceil(width-pms.windowSize/2):ceil(width+pms.windowSize/2 - 1);
        r_diff = image(height, width, 1) - reference(height_range_of_window, width_range_of_window, 1);
        weights_mtx = zeros(pms.windowSzie)
    end

end

function s = getDissimilarity(I_q, I_q_hat, delta_q, delta_q_hat, pms)
    
    s = (1-pms.alpha) * min(abs(I_q - I_q_hat), pms.trun_color) + pms.alpha * min(abs(delta_q - delta_q_hat), pms.trun_grad);
end

function w = getWeight(I_point, I_reference)
    w = exp(-1*abs(I_point-I_reference) / gamma);
end

function planeMap = init_planeMap(mapSize, pms)

    height = mapSize(1);
    width = mapSize(2);    
    planeMap = zeros(height, width, 3);
    max_disparity = pms.disparityRange(2);
    
    x = repmat(linspace(1, height, height)', 1, width);
    y = repmat(linspace(1, width, width), height, 1);
    z = rand(mapSize) * max_disparity;
    n = rand(height, width, 3);
    n = n ./ sqrt( sum(n .* n, 3) );
    
    a = -1 * ( n(:, :, 1) ./ n(:, :, 3) );
    b = -1 * ( n(:, :, 2) ./ n(:, :, 3) );
    c = ( n(:, :, 1) .* x + n(:, :, 2) .* y + n(:, :, 3) .* z ) ./ n(:, :, 3);
    
    planeMap = [a; b ;c];
end
