function [Degree0Idx,Diff] = Evaluate_hue_shift(P1,P2,Degree1,Degree2)
    Diff = -Inf;
    
    % delta alpha
    diff(1) = Degree1-P1;
    
    % delta beta
    diff(2) = Degree1-P2;
    
    % 1 means 180 degree
    % <0 or > 0 means 順時針或逆時針+
    % 在我們定義的顏色當中，degree x代表的顏色  = degree( x + 180 )
    % 如此才完整定義了圓上的所有顏色
    if diff(1) <0
        diff(1) = diff(1)+1;
    end
    if diff(2) <0
        diff(2) = diff(2)+1;
    end
%     diff(1) = HueDistance(P1,Degree1);
%     diff(2) = HueDistance(P2,Degree1);
% Don't let Diff have no value, use comparing to return the min diff
%     if HueDistance(Degree2 , AddHue(P2,diff(1) )) <0.05
%         Diff = diff(1);
%     elseif HueDistance(Degree2 , AddHue(P1,diff(2) )) <0.05
%         Diff = diff(2);
%     else
%         disp(strcat('diff1=',num2str(diff(1)),' diff2 = ',num2str(diff(2))));
%         disp(' ');
%     end

    % Degree0ldx means  P1 or P2 is zero degree
    % paper page 16 has flow chart
    % dist(20, P2 + delta(alpha)) < dist(20, P1 + delta(beta))
    if HueDistance(Degree2 , AddHue(P2,diff(1) )) <HueDistance(Degree2 , AddHue(P1,diff(2) ))
        Diff = diff(1);
        Degree0Idx = 2;
    else
        Diff = diff(2);
        Degree0Idx = 1;
    end
end