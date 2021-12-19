function avg_hue = get_avg_hue(HSV, x, y, margin)
    % �������������O�]�� 0�M180��ꨤ�׬ۦP�A�]��0�ת�polarizer�i��Q���Ѧ�10�ש�170�צ��ɥ����|�ܦ�140�סA
    % �ëD�ڭ̴��檺0�ש�180��
    
    hues = HSV((x-margin:x+margin), (y-margin:y+margin), 1);
    
    % �ন���פ~���X����(�]��Hue��double�ܤ֭���)
    [M, F] = mode( round(hues * 180), 'all');
    
    if F >= 3
        avg_hue = M / 180;
        return;
    else
        % �P�ҭz�A���M������Ʀb0��polarizer�W�ܦ��i����D���Ӧn���ȡAex:16��
        % ����_�����Ƥ��M�O����Ƹ��n
        avg_hue = median(hues, 'all');
    end
end