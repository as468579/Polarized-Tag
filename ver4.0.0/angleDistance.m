function distance = angleDistance(angle0, angle1)
    % 因為0度 和 170度 差10度 而不是170度
    distance = min(abs(angle1-angle0), 180-abs(angle1-angle0));
end