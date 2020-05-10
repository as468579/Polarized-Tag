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
        
        hold on
        for i = 1:4
            plot(corner(i, 2), corner(i, 1), 'g*');
        end
        hold off
        
        % assume �O�S���n�שα��઺marker�A�h
        % corner[1](���W), corner[2](�k�W), corner[3](�k�U), corner[4](���U), ���ɰw�аO
        % �ھ�bounding set�����P ���ɭԶ��Ǥ]�|�Ocorner[1](���U), corner[2](���W), corner[3](�k�W), corner[4](�k�U),
        % �ҥH corner[1], corner[3],�@�w�O�﨤 �ҥH2, 4�P�z
        % diagonalNormVector stores[ vector(���W<-�k�U); vector(�k�W<-���U) ]
        diagonalNormVector = [corner(1,:)-corner(3,:);corner(2,:)-corner(4,:);];        
        diagonalNormVector = round(diagonalNormVector/6);
        
        % firstQuarterBorder means �@���E�c�� or �T���E�c�� 
        % firstQuarterBorder stores [ �@���E�c�檺�k�U�� ; �T���E�c�檺���U�� ] 
        firstQuarterBorder = [corner(1,:) - diagonalNormVector(1,:)*2 ; corner(2,:) - diagonalNormVector(2,:)*2];
        
        % lastQuarterBorder means �E���E�c�� or �C���E�c��
        % lastQuarterBorder stores [ �E���E�c�檺���W�� ; �C���E�c�檺�k�W�� ]
        lastQuarterBorder = [corner(1,:) - diagonalNormVector(1,:)*4 ; corner(2,:) - diagonalNormVector(2,:)*4];
        
        % firstQuarterMid stores [ �@���E�c�檺���� ; �T���E�c�檺���� ]
        firstQuarterMid = [corner(1,:) - diagonalNormVector(1,:) ; corner(2,:) - diagonalNormVector(2,:)];
        
        % lastQuarterMid stores [ �E���E�c�檺���� ; �C���E�c�檺���� ]
        lastQuarterMid = [corner(1,:) - diagonalNormVector(1,:)*5 ; corner(2,:) - diagonalNormVector(2,:)*5];
        
        % check if the mark �W�X screen
        if  any([firstQuarterMid(:,1)>size(L,1);firstQuarterMid(:,2)>size(L,2);lastQuarterMid(:,1)>size(L,1);lastQuarterMid(:,2)>size(L,2)]) >0
            continue;
        end
        
        % get hue index of [ �@���E�c�� ; �T���E�c�� ] 
        idx_firstQuarter = sub2ind(  size(Y_HSV),  firstQuarterMid(:,1),   firstQuarterMid(:,2),  ones(size(firstQuarterMid(:,1)))  );
        
        % get hue index of [ �E���E�c�� ; �C���E�c�� ]
        idx_lastQuarter = sub2ind(   size(Y_HSV),  lastQuarterMid(:,1),    lastQuarterMid(:,2),  ones(size(lastQuarterMid(:,1)))   );
       
        % diagonalAngleDiff stores [ diff(���W, �k�U); diff(�k�W, ���U) ]
        diagonalAngleDiff = HueDistance(Y_HSV(idx_firstQuarter),Y_HSV(idx_lastQuarter));
        
        % PilotDiff = cosnt 20degree
        % pilotPostion means the index of pilot pair(���W-�k�U : �k�W-���U)
        % which means ���W-�k�U = 1 ,and �k�W-���U = 2 ( according to corner index of firstQuarter )
        % ���B�i�H�[�W���� min �O�_��20�׮t�Z�Ӥj�A�Y�O �h�R�h(�����B�~�Ҽ{�Y170 �P 10��)
        [~,pilotPosition] = min(diagonalAngleDiff-PilotDiff);
        
        %{
        hold on;
        plot(firstQuarterMid(pilotPosition,2),firstQuarterMid(pilotPosition,1),'m*')
        plot(lastQuarterMid(pilotPosition,2),lastQuarterMid(pilotPosition,1),'k*')
        hold off;
        %}
        
        %-------- Built particle in the quarter cells -----------
        % ���o��quarter�����Ҧ���
        % ��k : ���̷ӥ|���I��X0�ץ���Τ�(���quarter���﨤�u)���Ҧ��y��
        % �A��inpolygon�R�h���Aquarter�����y��
        % �A��J candidateX�A�H�� candidiateY
        
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
        % pair ���﨤��V�������I
        pair1_X = candidate_X(firstQuarterAllPoint);
        pair1_Y = candidate_Y(firstQuarterAllPoint);
        pair2_X = pair1_X - diagonalNormVector(pilotPosition,1)*4;
        pair2_Y = pair1_Y - diagonalNormVector(pilotPosition,2)*4;
        plot(pair1_Y,pair1_X,"*r");
        plot(pair2_Y,pair2_X,"*r");
        
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
        X_Concate = [X1; X2; X3; X4; X5; X6; X7; X8; X9];
        X = [X X_Concate];
        
        % plot firstQuarter and lastQuarter
        imshow(Y_HSV)
        hold on;
        plot(firstQuarterMid(pilotPosition,2),firstQuarterMid(pilotPosition,1),'co')
        plot(lastQuarterMid(pilotPosition,2),lastQuarterMid(pilotPosition,1),'go')
        hold off;
        
        % predict angles of firstQuarters and lastQuarters
        %{
        D = (0:1/180:1);
        % predictions[1, :] means error
        % predictions[2, :] means predicted angle
        predictions = zeros(2, 4);
        index = zeros(1, 4);
        % cell 1
        [predictions(1, 1), index(1)] = detectAngle(Y_HSV(firstQuarterMid(1,1), firstQuarterMid(1,2), 1), D);
        % cell 3
        [predictions(1, 2), index(2)] = detectAngle(Y_HSV(firstQuarterMid(2,1), firstQuarterMid(2,2), 1), D);
        % cell 7
        [predictions(1, 3), index(3)] = detectAngle(Y_HSV(lastQuarterMid(2,1), lastQuarterMid(2,2), 1), D);
        % cell 9
        [predictions(1, 4), index(4)] = detectAngle(Y_HSV(lastQuarterMid(1,1), lastQuarterMid(1,2), 1), D);
        predictions(2, :) = (index - 1);
        %}
    end
end
