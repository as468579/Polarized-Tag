function ID = evaluation_likelihood_multiMarker(L,X,Y_orig,dict) 
    ID = [];
    
    % x[1,:] = coordinate x
    % x[2,:] = coordinate y
    % x[3,:] = delat x
    % x[4,:] = delta y
    % x[5,:] = theta
    % x[6,:] = delta(theta)
    % x[7,:] = scalar
    % x[8.:] = delta(scalar)
    % x[9,:] = indexOfConnectedComponent
    % x[10,:] = markerId
    
    
    % ���u�nif size(X, 1) == 10�N�i�H�F

    if size(X,1) == 9 || size(X,1) == 10
        
        % find out how many unique connected components number particles have
        % num is a one-D array stores the unique index of connected component
        num = unique(X(9,:));
        
        % pick out same connected component's particles
        for i = 1 : size(num,2)
            
            % Xpart collect part of X, which index of connected components equals to num(i)
            Xpart = X(:,X(9,:) == num(i));
            
            % Lpart collect part of L, which index of connected components equals to num(i)
            Lpart = L(X(9,:)==num(i));
            
            % decide specific connected component is marker or not by Likelihood threshold
            % filter out most particles which don't seem like a marker
            % �����ä��@�w�n > -5 �A�]��likelyhood���ӳ��n >���Aexcept for those we set -Inf
            % To be continue
            Xpart = Xpart(:,Lpart > -5);
            Lpart = Lpart(Lpart>-5);
            
            % Problem 
            % �Y�u������num[i]��Xpart��Likelihood > -5�A���t�@����Likelihood < -5 ������ �ä��|�Q�M�šA�Ӧp��B�z
            show_particles(Xpart, Y_orig);
            if isempty(Xpart)
                % delete non-marker's particle
                X(:,X(9,:) == num(i)) = [];
                L(:,X(9,:) == num(i)) = [];
                continue
            end
            
            
            % Problem
            % �p�G���魫�|�ثe�L��
            % �i�H�ϥΩw��CVDecode
            % counter �� CVDecode �C�L�@�q�ɶ��N���@��
            % �ثe�������}screen�OOK��
            % ������i�Jscreen�h�ݭn�ϥ�CVDecode�~�ஷ��
            
            
            % lastResult is used to track the markId last time
            lastResult = -1;
            
            
            % Problem
            % ���ƻ򦳨�particle�|�P�_��markId
            % X[10] = -1 is the initail value
            if  size(X,1) == 10 && mode(Xpart(10,:))~= -1
                
                %�ϥΤW�@����ID�����u��
                lastResult = mode(Xpart(10,:));
            else
                
             % m,n is x,y coordinate
             m = Xpart(1,:);
             n = Xpart(2,:);
             
             % rotateMatrix = cos( reshape(repmat(Xpart(5,:),2,2),2*length(Xpart(5,:)),2) ... % duplicate angles in T
             %                                  + repmat([0 -pi ; pi 0]/2,length(Xpart(5,:)),1));   % shift angle to convert sine in cosine
             rotateMatrix = [];

               % concatenate the rotateMatrixs of Xpart in verticle direction
              for j = 1:size(Xpart,2)
                  rotateMatrix  =[rotateMatrix; [cosd(Xpart(5,j)) -sind(Xpart(5,j)); sind(Xpart(5,j)) cosd(Xpart(5,j))]];
              end

              comparingVector = [];
              
              % comparingVector stores the coordinates of neighbor 8 points after rotate and scale but doesn't shift yet.
              for j = 1 :size(Xpart,2)
                  comparingVector = [comparingVector;rotateMatrix(1+(j-1)*2:j*2,:) * [1 2 0 1 2 0 1 2 ;
                                                                                                                                                  0 0 1 1 1 2 2 2] * Xpart(7,j)];
              end
              
                % structure of  comparingCoord is like 
                % [x1_1, x1_2, x1_3,... , x1_8;
                %  y1_1, y1_2, y1_3,... , y1_8; 
                %  x2_1, x2_2, x2_3,... , x2_8;
                %  y2_1, y2_2, y2_3,... , y2_8; ...... 
                % 
                
                % [1, 0] means the cell under the original point(left top)
                % [0, 1] means the cell on the right hand of original  point(left top)
                % m means all x of particle which connected component number equals to num(i)
                % n means all y of particle which connected component number equals to num(i)
                comparingCoord = repmat(reshape([m;n],[],1),1,8)+comparingVector;

                % round coordinates 
                comparingCoord = round(comparingCoord);
                m = round(m);
                n = round(n);

                % get ID of each particle which connected component id is the same
                % store ID of first quarter
                IDcount = [];
                for ptcNum = 1:size(m,2)
                    
                    % get the coordinate of the neighbor 8 points
                    % comparingCoord(1+(ptcNum-1)*2,:) get the x coordinates of 8 neighbor
                    % comparingCoord(2+(ptcNum-1)*2,:) get the y coordinates of 8 neighbor 
                    evaluatedComparingCoord = [comparingCoord(1+(ptcNum-1)*2,:) ; comparingCoord(2+(ptcNum-1)*2,:)];
                    
                   % check whether  neighbor points and itself are in the screen
                   
                   % �Ǫ�������
                   %I = all(and(and(evaluatedComparingCoord(1,:) > 1,evaluatedComparingCoord(1,:) <=1024),and(m(ptcNum)> 1,m(ptcNum)<=1024)));
                   %J = all(and(and(evaluatedComparingCoord(2,:) > 1,evaluatedComparingCoord(2,:) <=1224),and(n(ptcNum)> 1,n(ptcNum)<=1224)));
                   
                   % �ڪ�����
                    I = all(and(and(evaluatedComparingCoord(1,:) >= 1,evaluatedComparingCoord(1,:) <=1024),and(m(ptcNum)>= 1,m(ptcNum)<=1024)));
                    J = all(and(and(evaluatedComparingCoord(2,:) >= 1,evaluatedComparingCoord(2,:) <=1224),and(n(ptcNum)>= 1,n(ptcNum)<=1224)));
                    
                    hueDiff = -Inf;
                    Degree0Idx = -1;
                    if I && J
                        % Y_orig(evaluatedComparingCoord(1,8),evaluatedComparingCoord(2,8),1 )= get the hue of 9th point�]�N�O�ĤK�ӾF���I
                        % 0.13 means 20 degree
                        [Degree0Idx,hueDiff] = Evaluate_hue_shift(Y_orig(evaluatedComparingCoord(1,8),evaluatedComparingCoord(2,8),1),Y_orig(m(ptcNum),n(ptcNum),1),0,0.13);
                    end
                %     title(strcat('evaluation of Max L=', num2str(val),' Angle=', num2str(X(5,k) ),' id=',num2str(k)));
                
                % id means ��Particle�{���}�Umark��ID
                    id = -1;
                    error = -1;
                    
                    
                    if hueDiff > -Inf
                        Y = Y_orig;
                        
                        % let zero quarter return to zero
                        Y(:,:,1) = AddHue(Y(:,:,1) , hueDiff);
%                         idx_h = sub2ind(size(Y),evaluatedComparingCoord(1,:),evaluatedComparingCoord(2,:),ones(size(evaluatedComparingCoord(1,:)))*1);
                        
                        % because we already know the angle of left top and right down, we only use the rest 7 points to regconize markerId
                        % because we only need Y(x1, y1, 1), ...., Y(x7, y7, 1), to recoginze markerId, we collect the diagonal of Y(evaluatedComparingCoord(1,1:7),evaluatedComparingCoord(2,1:7),1)
                        % transpose let dimension form (7, 1) change to (1, 7)
                        [error,id] = detectID(diag(Y(evaluatedComparingCoord(1,1:7),evaluatedComparingCoord(2,1:7),1))',dict,Degree0Idx);
                        IDcount = [IDcount id];
                        % M means mode number
                        % F means frequency
                        % IDCount will �ֿn through all particles
                        [M,F] = mode(IDcount);
                        
                        % �p�GF > 9�N���������H��
                        if F > 9
                            
                            % �������ӥi�H���n�A�]��row 174 �̫�]�|�令 lastResult
                            % X(10,X(9,:) == num(i)) = M;
                            break;
                        end
                    end
                end
                lastResult = mode(IDcount);
            end

            ID = [ID lastResult];
            X(10,X(9,:) == num(i)) = lastResult;
            
            % if lastResult ~= -1 means we find a marker
            % show the markerId for debug
            if lastResult ~= -1
                hold on
                % rectangle('Position',[Xpart(2,1),Xpart(1,1),2*round(Xpart(7,1)),2*round(Xpart(7,1))],...
                %         'LineWidth',2,'LineStyle','--','EdgeColor','w')
                rotateMatrix  = [cosd(Xpart(5,1)) -sind(Xpart(5,1)); sind(Xpart(5,1)) cosd(Xpart(5,1))];
                comparingVector = rotateMatrix *[1 2 0 1 2 0 1 2 ;0 0 1 1 1 2 2 2] * Xpart(7,1);
                comparingCoord = [Xpart(1,1);Xpart(2,1)] + comparingVector;
                comparingCoord = round(comparingCoord);
                
                plot(comparingCoord(2,:),comparingCoord(1,:), 'r.', 'MarkerSize', 30)
                text(Xpart(2,1),Xpart(1,1),strcat('id = ',num2str(ID(size(ID,2)))),'FontSize',20,'Color','w','HorizontalAlignment', 'right');
                drawnow;
                hold off
            end
            %% save image for debug
            % saveas(gcf,'C:\Users\User\Documents\MATLAB\PTag\result_folder\rotate\multitags6','png');
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