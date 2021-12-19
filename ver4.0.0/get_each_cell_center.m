function points = get_each_cell_center(corners)

    points = zeros(9, 2);
    center = mean(corners, 1);
    
    height_diff = (corners(4, :) - corners(1, :)) / 3;
    width_diff = (corners(2, :) - corners(1, :)) / 3;
    
    points(1,:) = (-1 *  height_diff) +  (-1 * width_diff);
    points(2,:) = (-1 *  height_diff);
    points(3,:) = (-1 *  height_diff) + width_diff;
    points(4,:) = (-1 * width_diff);
    points(6,:) = width_diff;
    points(7,:) = height_diff + (-1 * width_diff);
    points(8,:) = height_diff;
    points(9,:) = height_diff + width_diff;
   
    % shift to correct position
    points = points + center;
    
    %{
    rotate = [[cosd(-0), -1 * sind(-0)];[sind(-0), cosd(-0)]];
    c = points(5, :);
    points  = points - points(5,:);
    for i = 1:9
        points(i, :) = (rotate * points(i, :)')';
    end
     points  = points + c;
    %}
    
    % for debug
    for i = 1:9
        plot(round(points(i,2)), round(points(i, 1)), 'wo');
    end
        
end