function [error,ids] = detectID(Y,dict,Degree0Idx)

    % if degre0Idx == 2 means �k�U���O0��maybe marker����
    % �ҥH�Ndict�]������(���Pflip)��A���
    if(Degree0Idx == 2)
        dict = fliplr(dict);
    end
    [error,ids] = min(sum(abs(dict - Y),2));
end