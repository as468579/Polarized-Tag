function location = EvaluateParticleLocation(Y,lowS,lowV)
    % ��X�j�װ���pixel(�N�����᪺�j�װ��j)
    [x,y] = find(Y(:,:,2)>lowS & Y(:,:,3)>lowV);
    location = [x y]';
end