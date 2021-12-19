function X = CreateParticlePair(reserveOrienDiff,area,Y_HSV)
    numOfComponents = max(max(area));
    X = [];
    for i = 1:numOfComponents
        [coor_1,coor_2] = find(area == i);
        idx_h = sub2ind(size(Y_HSV),coor_1,coor_2,ones(size(coor_1,1),1)); 
        value = Y_HSV(idx_h);
        difference = tril(abs(HueDistance(value,value')-reserveOrienDiff),-1);
        difference(difference >0.0005) = Inf;
        difference(difference == 0) = Inf;
        if size(difference(difference~=Inf),1) > 5000
            [~,ind_dif] = mink(difference(:),5000);
        else
            [~,ind_dif] = mink(difference(:),size(difference(difference~=Inf),1));
        end
        [ind_dif_1,ind_dif_2] = ind2sub(size(difference),ind_dif);
        [pair1_X,pair1_Y,~] = ind2sub(size(Y_HSV),idx_h(ind_dif_1));
        [pair2_X,pair2_Y,~] = ind2sub(size(Y_HSV),idx_h(ind_dif_2));

        X1 = pair1_X;
        X2 = pair1_Y;
        X3 = zeros(2,size(X1,1))';
        X4 = rad2deg(atan2(pair2_Y-pair1_Y,pair2_X-pair1_X))-45;
        X5 = zeros(1,size(X1,1))';
        X6 = sqrt((pair1_X-pair2_X).^2 + (pair1_Y-pair2_Y).^2)/(2*sqrt(2));
        X7 = zeros(1,size(X1,1))';
        X_Concate = [X1  X2  X3  X4  X5  X6  X7]';
%         X_Concate = repelem(X_Concate,1,5);
        X = [X X_Concate];
    end

end

%% show legal area 
% imshow(Y_HSV)
% hold on
% plot(legalParticleLocation(2,:),legalParticleLocation(1,:),'*')