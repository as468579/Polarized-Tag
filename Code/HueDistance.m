function distance = HueDistance(h0,h1)
    % 因為0度 和 170度 差10度 而不是170度
    distance = min(abs(h1-h0), 1-abs(h1-h0));
end