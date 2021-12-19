function [error, angles] = detect_marker_angles(HSV, points, Degree0Idx)

    if Degree0Idx == 2
        points = flipud(points);
    end
    
    hold on;
    
    predictions = zeros(2, size(points, 1));
    
    % define degree 0 ~ 179
    angles = (0: 1/180: 179/180);
    for i = 1:size(points, 1)
         x_pos = round(points(i, 1));
         y_pos = round(points(i, 2));
         plot(y_pos,  x_pos, 'g*');
         [error, index] = detectAngle(HSV(x_pos, y_pos, 1), angles);
         predictions(1, i) = error;
         predictions(2, i) = index - 1;
    end
    error = predictions(1, :);
    angles = predictions(2, :);
    hold off;


end