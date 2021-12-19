function ManualPointEvaluate(test,Y_HSV)
    m = round(test(1));
    n = round(test(2));


    rotateMatrix  = [cosd(test(5)) -sind(test(5)); sind(test(5)) cosd(test(5))];
    comparingVector = rotateMatrix *[1 2 0 1 2 0 1 2 ;0 0 -1 -1 -1 -2 -2 -2] * test(7);
    comparingCoord = [m;n] + comparingVector;
    comparingCoord = int32(comparingCoord-0.5+1);
    image(Yimg)
%     title(strcat('evaluation of Point P = ', num2str(val)))
    hold on
    plot(n,m,'b*',comparingCoord(2,:),comparingCoord(1,:),'c*')
    hold off
end