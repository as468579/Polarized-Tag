function ID = evaluation_likelihood_multiMarker(L,X,Y_orig,dict) 
    ID = [];
    
    
    % if size(X, 1) == 10
    if size(X,1) == 9 || size(X,1) == 10
        % find out how many unique connected components number particles have
        num = unique(X(9,:));
        % pick out same connected component's particles
        for i = 1 : size(num,2)
            Xpart = X(:,X(9,:) == num(i));
            Lpart = L(X(9,:)==num(i));
            % decide specific connected component is marker or not by Likelihood thershhold
            Xpart = Xpart(:,Lpart > -5);
            Lpart = Lpart(Lpart>-5);
            
            if isempty(Xpart)
                % delete non-marker's particle
                X(:,X(9,:) == num(i)) = [];
                L(:,X(9,:) == num(i)) = [];
                continue
            end
            
            % 如果物體重疊()目前無解
            %可以使用定期CVDecode
            % counter 讓 CVDecode 每過一段時間就做一次
            
            lastResult = -1;
            if  size(X,1) == 10 && mode(Xpart(10,:))~= -1
                
                %使用上一輪的ID直接沿用
                lastResult = mode(Xpart(10,:));
            else
                 % m,n is x,y coordinate
                m = Xpart(1,:);
                n = Xpart(2,:);
    %             rotateMatrix = cos( reshape(repmat(Xpart(5,:),2,2),2*length(Xpart(5,:)),2) ... % duplicate angles in T
    %                                         + repmat([0 -pi ; pi 0]/2,length(Xpart(5,:)),1));   % shift angle to convert sine in cosine
                rotateMatrix = [];

                for j = 1:size(Xpart,2)
                    rotateMatrix  =[rotateMatrix; [cosd(Xpart(5,j)) -sind(Xpart(5,j)); sind(Xpart(5,j)) cosd(Xpart(5,j))]];
                end

                comparingVector = [];
                for j = 1 :size(Xpart,2)
                    comparingVector = [comparingVector;rotateMatrix(1+(j-1)*2:j*2,:) * [1 2 0 1 2 0 1 2 ;0 0 1 1 1 2 2 2] * Xpart(7,j)];
                end
                % structure of  comparingCoord is like 
                % [x1_1, x1_2, x1_3,... , x1_8;
                %  y1_1, y1_2, y1_3,... , y1_8; 
                %  x2_1, x2_2, x2_3,... , x2_8;
                %  y2_1, y2_2, y2_3,... , y2_8; ...... 
                comparingCoord = repmat(reshape([m;n],[],1),1,8)+comparingVector;

                % round coordinates 
                comparingCoord = round(comparingCoord);
                m = round(m);
                n = round(n);

                % get each particle's ID
                
                % store the ID of first quarter
                IDcount = [];
                for ptcNum = 1:size(m,2)
                    
                    % get the coordinate of the neighbor 8 points
                    evaluatedComparingCoord = [comparingCoord(1+(ptcNum-1)*2,:) ; comparingCoord(2+(ptcNum-1)*2,:)];
                    I = all(and(and(evaluatedComparingCoord(1,:) > 1,evaluatedComparingCoord(1,:) <=1024),and(m(ptcNum)> 1,m(ptcNum)<=1024)));
                    J = all(and(and(evaluatedComparingCoord(2,:) > 1,evaluatedComparingCoord(2,:) <=1224),and(n(ptcNum)> 1,n(ptcNum)<=1224)));
                    hueDiff = -Inf;
                    Degree0Idx = -1;
                    if I && J
                        % Y_orig(evaluatedComparingCoord(1,8),evaluatedComparingCoord(2,8),1
                        % = get the hue of 9th point也就是第八個鄰近點
                        % 0.13 means 20 degree
                        [Degree0Idx,hueDiff] = Evaluate_hue_shift(Y_orig(evaluatedComparingCoord(1,8),evaluatedComparingCoord(2,8),1),Y_orig(m(ptcNum),n(ptcNum),1),0,0.13);
                    end
                %     title(strcat('evaluation of Max L=', num2str(val),' Angle=', num2str(X(5,k) ),' id=',num2str(k)));
                
                % id means 該Particle認為腳下mark的ID
                    id = -1;
                    error = -1;
                    
                    % 
                    if hueDiff > -Inf
                        Y = Y_orig;
                        Y(:,:,1) = AddHue(Y(:,:,1) , hueDiff);
%                         idx_h = sub2ind(size(Y),evaluatedComparingCoord(1,:),evaluatedComparingCoord(2,:),ones(size(evaluatedComparingCoord(1,:)))*1);
                        [error,id] = detectID(diag(Y(evaluatedComparingCoord(1,1:7),evaluatedComparingCoord(2,1:7),1))',dict,Degree0Idx);
                        IDcount = [IDcount id];
                        % M means mode number
                        % F means frequency
                        % IDCount will 累積 throug all particles
                        [M,F] = mode(IDcount);
                        
                        % 如果F > 代表有足夠的信心
                        if F > 9
                             X(10,X(9,:) == num(i)) = M;
                            break;
                        end
                    end
                end
                lastResult = mode(IDcount);
            end

            ID = [ID lastResult];
            X(10,X(9,:) == num(i)) =lastResult;
            
            % if lastResult ~= -1 means 
            if lastResult ~= -1
                hold on
                rectangle('Position',[Xpart(2,1),Xpart(1,1),2*round(Xpart(7,1)),2*round(Xpart(7,1))],...
                        'LineWidth',2,'LineStyle','--','EdgeColor','w')
                rotateMatrix  = [cosd(Xpart(5,1)) -sind(Xpart(5,1)); sind(Xpart(5,1)) cosd(Xpart(5,1))];
                comparingVector = rotateMatrix *[1 2 0 1 2 0 1 2 ;0 0 1 1 1 2 2 2] * Xpart(7,1);
                comparingCoord = [Xpart(1,1);Xpart(2,1)] + comparingVector;
                comparingCoord = round(comparingCoord);

                plot(comparingCoord(2,:),comparingCoord(1,:),"b*")
                text(Xpart(2,1),Xpart(1,1),strcat('id = ',num2str(ID(size(ID,2)))),'FontSize',20,'Color','w','HorizontalAlignment', 'right');
                hold off
            end
        end
    else    
        [val,k] = max(L);
        m = X(1,k);
        n = X(2,k);

        rotateMatrix  = [cosd(X(5,k)) -sind(X(5,k)); sind(X(5,k)) cosd(X(5,k))];
        comparingVector = rotateMatrix *[1 2 0 1 2 0 1 2 ;0 0 1 1 1 2 2 2] * X(7,k);
        comparingCoord = [m;n] + comparingVector;
        comparingCoord = round(comparingCoord);
        m = round(m);
        n = round(n);

        I = all(and(and(comparingCoord(1,:) > 1,comparingCoord(1,:) <=1024),and(m> 1,m<=1024)));
        J = all(and(and(comparingCoord(2,:) > 1,comparingCoord(2,:) <=1224),and(n> 1,n<=1224)));
        hueDiff = -Inf;
        Degree0Idx = -1;
        if I && J && val>-5
            [Degree0Idx,hueDiff] = Evaluate_hue_shift(Y_orig(comparingCoord(1,8),comparingCoord(2,8),1),Y_orig(m,n,1),0,0.13);
        end
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

end