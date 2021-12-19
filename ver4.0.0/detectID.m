function [error,ids] = detectID(Y,dict,Degree0Idx)

    % if degre0Idx == 2 means 右下角是0度maybe marker旋轉
    % 所以將dict也做旋轉(等同flip)後再比對
    if(Degree0Idx == 2)
        dict = fliplr(dict);
    end
    [error,ids] = min(sum(abs(dict - Y),2));
end