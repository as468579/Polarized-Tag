function avg_hue = get_avg_hue(HSV, x, y, margin)
    % 不直接取平均是因為 0和180其實角度相同，因此0度的polarizer可能被辨識成10度或170度此時平均會變成140度，
    % 並非我們期望的0度或180度
    
    hues = HSV((x-margin:x+margin), (y-margin:y+margin), 1);
    
    % 轉成角度才能找出眾數(因為Hue為double很少重複)
    [M, F] = mode( round(hues * 180), 'all');
    
    if F >= 3
        avg_hue = M / 180;
        return;
    else
        % 同所述，雖然取中位數在0度polarizer上很有可能取道不太好的值，ex:16度
        % 但比起平均數仍然是中位數較好
        avg_hue = median(hues, 'all');
    end
end