function distance = angleDistance(angle0, angle1)
    % �]��0�� �M 170�� �t10�� �Ӥ��O170��
    distance = min(abs(angle1-angle0), 180-abs(angle1-angle0));
end