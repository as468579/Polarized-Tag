function X = CVDecode(boundingSet, L,  Y_HSV, PilotDiff)
    if mod(size(boundingSet,1),4) ~= 0
        X = [];
        return     
    end
    boundingSet = round(boundingSet);
    X = [];
    % because each bounding box had four coordiante
    for i = 1 : size(boundingSet,1)/4
%     for i = 5 : 6
        corner = boundingSet((i-1)*4+1:i*4,:);
 
        % corner[1], corner[2], corner[3], corner[4], 順時針標記
        % 所以 corner[1], corner[3],一定是對角 所以2, 4同理
        diagonalNormVector = [corner(1,:)-corner(3,:);corner(2,:)-corner(4,:);];
        
        diagonalNormVector = round(diagonalNormVector/6);
        
        % firstQuarterBorder一號九宮格的右下角 : 三號九宮格的左下角
        firstQuarterBorder = [corner(1,:) - diagonalNormVector(1,:)*2 ; corner(2,:) - diagonalNormVector(2,:)*2];
        
        % lastQuarterBorder九號九宮格的左上角 : 七號九宮格的右上角
        lastQuarterBorder = [corner(1,:) - diagonalNormVector(1,:)*4 ; corner(2,:) - diagonalNormVector(2,:)*4];
        
        % firstQuarterBorder一號九宮格的中心 : 三號九宮格的中心
        firstQuarterMid = [corner(1,:) - diagonalNormVector(1,:) ; corner(2,:) - diagonalNormVector(2,:)];
        
         %lastQuarterBorderr九號九宮格的中心 : 七號九宮格的中心
        lastQuarterMid = [corner(1,:) - diagonalNormVector(1,:)*5 ; corner(2,:) - diagonalNormVector(2,:)*5];
        
        % check if the mark 超出 screen
        if  any([firstQuarterMid(:,1)>size(L,1);firstQuarterMid(:,2)>size(L,2);lastQuarterMid(:,1)>size(L,1);lastQuarterMid(:,2)>size(L,2)]) >0
            continue;
        end
        
        % get hue index of 一號九宮格 : 三號九宮格
        idx_firstQuarter = sub2ind(  size(Y_HSV),  firstQuarterMid(:,1),   firstQuarterMid(:,2),  ones(size(firstQuarterMid(:,1)))  );
        
        %get hue index of 七號九宮格 : 九號九宮格
        idx_lastQuarter = sub2ind(   size(Y_HSV),  lastQuarterMid(:,1),    lastQuarterMid(:,2),  ones(size(lastQuarterMid(:,1)))   );
        diagonalAngleDiff = HueDistance(Y_HSV(idx_firstQuarter),Y_HSV(idx_lastQuarter));
        
        % PilotDiff = cosnt 20degree
        % pilotPostion means the index of pilot pair(左上-右下 : 右上-左下)
        % 此處可以加上檢驗 min 是否離20度差距太大，若是 則刪去
        [~,pilotPosition] = min(diagonalAngleDiff-PilotDiff);
        
        % plot(firstQuarterMid(pilotPosition,2),firstQuarterMid(pilotPosition,1),'m*')
        % plot(lastQuarterMid(pilotPosition,2),lastQuarterMid(pilotPosition,1),'k*')
        
        %-------- Built particle in the quarter cells -----------
        % 取得該quarter內的所有做邊
        % 方法 : 先依照四個點找出0度正方形內(邊長quarter為對角線)的所有座標
        % 再用inpolygon刪去不再quarter內的座標
        % 再塞入 candidateX，以及 candidiateY
        x_low = min(corner(:,1));
        x_max = max(corner(:,1));
        y_low = min(corner(:,2));
        y_max = max(corner(:,2));
        candidate_X = [];
        candidate_Y = [];
        for i = x_low:x_max
            for j = y_low:y_max
                candidate_X = [candidate_X i];
                candidate_Y = [candidate_Y j];
            end
        end
        neighbor = [pilotPosition+1 pilotPosition-1];
        neighbor(neighbor == 0) = 4;
        % pick up the particles in the quarter cell
        firstQuarterAllPoint = inpolygon( candidate_X,candidate_Y,...
            [corner(pilotPosition,1),...
                (corner(pilotPosition,1)+(corner(neighbor(1),1)-corner(pilotPosition,1))/3),...
                firstQuarterBorder(pilotPosition,1), ...
                (corner(pilotPosition,1)+(corner(neighbor(2),1)-corner(pilotPosition,1))/3) ],...
            [corner(pilotPosition,2),...                
                (corner(pilotPosition,2)+(corner(neighbor(1),2)-corner(pilotPosition,2))/3),...
                firstQuarterBorder(pilotPosition,2) ,...
                (corner(pilotPosition,2)+(corner(neighbor(2),2)-corner(pilotPosition,2))/3)  ]);
            
        % built particle properties like coordinate, angle and length 
        % pair 指對角方向的對應點
        pair1_X = candidate_X(firstQuarterAllPoint);
        pair1_Y = candidate_Y(firstQuarterAllPoint);
        pair2_X = pair1_X - diagonalNormVector(pilotPosition,1)*4;
        pair2_Y = pair1_Y - diagonalNormVector(pilotPosition,2)*4;
        % plot(pair1_Y,pair1_X,"*r");
        % plot(pair2_Y,pair2_X,"*r");
        
        X1 = pair1_X;
        X2 = pair1_Y;
        X3 = zeros(2,size(X1,2));
        
        X4 = rad2deg(atan2(pair2_Y-pair1_Y,pair2_X-pair1_X))-45;
        X5 = zeros(1,size(X1,2));
        % repelem means repeat element
        X6 = repelem(norm(diagonalNormVector(pilotPosition,:))*4/(2*sqrt(2)),1,size(X1,2));
        X7 = zeros(1,size(X1,2));
        % set connected component's number as one of the particle properties
        X8 = repelem(i,1,size(X1,2));
        
        % initial set id = -1
        X9 = repelem(-1,1,size(X1,2));
        X_Concate = [X1;X2;X3 ;X4 ;X5 ;X6 ;X7;X8;X9];
        X = [X X_Concate];

    end
end
