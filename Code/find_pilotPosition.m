function [value, pilotPosition] = find_pilotPosition(HSV, points, PilotDiff)
    % return corner index of firstQuarter, for example
    % return 1 means diagonal 為 左下 - 右上
    % return 2 means diagonal 為 左上 - 右下
    idx_corner = [1, 3, 7, 9];
    %{
    idx_cell1 = sub2ind(  size(HSV),  round(points(1, 1)),   round(points(1, 2)),  1 );
    idx_cell3 = sub2ind(  size(HSV),  round(points(3, 1)),   round(points(3, 2)),  1 );
    idx_cell7 = sub2ind(  size(HSV),  round(points(7, 1)),   round(points(7, 2)),  1 );
    idx_cell9 = sub2ind(  size(HSV),  round(points(9, 1)),   round(points(9, 2)),  1 );
   
    diagonalAngleDiff = HueDistance( HSV([idx_cell7; idx_cell1]), HSV([idx_cell3; idx_cell9]));
    %}
    
    margin = 2;
    avg_hue_1 = get_avg_hue(HSV, round(points(1, 1)),  round(points(1, 2)), margin);
    avg_hue_3 = get_avg_hue(HSV, round(points(3, 1)),  round(points(3, 2)), margin);
    avg_hue_7 = get_avg_hue(HSV, round(points(7, 1)),  round(points(7, 2)), margin);
    avg_hue_9 = get_avg_hue(HSV, round(points(9, 1)),  round(points(9, 2)), margin);
    
    diagonalAngleDiff = HueDistance([avg_hue_1; avg_hue_7], [avg_hue_9; avg_hue_3]);
    [value ,pilotPosition] = min(abs(diagonalAngleDiff-PilotDiff));
end