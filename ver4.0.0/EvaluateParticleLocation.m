function location = EvaluateParticleLocation(Y,lowS,lowV)
    % 找出強度夠的pixel(代表偏振後的強度夠大)
    [x,y] = find(Y(:,:,2)>lowS & Y(:,:,3)>lowV);
    location = [x y]';
end