function distance = HueDistance(h0,h1)
    % �]��0�� �M 170�� �t10�� �Ӥ��O170��
    distance = min(abs(h1-h0), 1-abs(h1-h0));
end