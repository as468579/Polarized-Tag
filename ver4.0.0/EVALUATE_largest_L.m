function [ID,error] = EVALUATE_largest_L(L,X,Y_orig,dict) 

    
    [val,k] = max(L);
    m = X(1,k);
    n = X(2,k);

    rotateMatrix  = [cosd(X(5,k)) -sind(X(5,k)); sind(X(5,k)) cosd(X(5,k))];
    comparingVector = rotateMatrix *[1 2 0 1 2 0 1 2 ;0 0 1 1 1 2 2 2] * X(7,k);
    %     disp(comparingVector)
    comparingCoord = [m;n] + comparingVector;
    comparingCoord = round(comparingCoord);
  	m = round(m);
    n = round(n);
%     figure(3)
% %     Y_orig = hsv2rgb(Y_orig);
%     image(Y_orig)

%     
%     
%     hold on
%     plot(n,m,'b*',...
%          comparingCoord(2,1:7),comparingCoord(1,1:7),'c*',...
%         comparingCoord(2,8),comparingCoord(1,8),'b*'...
%         )

    I = all(and(and(comparingCoord(1,:) > 1,comparingCoord(1,:) <=1024),and(m> 1,m<=1024)));
    J = all(and(and(comparingCoord(2,:) > 1,comparingCoord(2,:) <=1224),and(n> 1,n<=1224)));
    hueDiff = -Inf;
    Degree0Idx = -1;
    if I && J && val>-5
        [Degree0Idx,hueDiff] = Evaluate_hue_shift(Y_orig(comparingCoord(1,8),comparingCoord(2,8),1),Y_orig(m,n,1),0,0.13);
    end
%     title(strcat('evaluation of Max L=', num2str(val),' Angle=', num2str(X(5,k) ),' id=',num2str(k)));
    ID = -1;
    error = -1;
    if hueDiff > -Inf
        Y = Y_orig;
        Y(:,:,1) = AddHue(Y(:,:,1) , hueDiff);
%         imshow(Y)
%             title(strcat('Hue Shift =' ,num2str(hueDiff)," D0ID=",num2str(Degree0Idx)))
%         hold on
        idx_h = sub2ind(size(Y),comparingCoord(1,:),comparingCoord(2,:),ones(size(comparingCoord(1,:)))*1);
        [error,id] = detectID(diag(Y(comparingCoord(1,1:7),comparingCoord(2,1:7),1))',dict,Degree0Idx);
%         rectangle('Position',[n,m,2*round(X(7,k)),2*round(X(7,k))],...
%          'LineWidth',2,'LineStyle','--','EdgeColor','w')
%         text(n,m,strcat('id = ',num2str(id)),'FontSize',20,'Color','w','HorizontalAlignment', 'right');
%         disp(strcat("find out the marker , ID=",num2str(id)));
        ID = id;
    end
        hold off
end