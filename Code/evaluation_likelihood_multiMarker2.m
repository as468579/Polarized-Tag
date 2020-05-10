function [ID, avg_particles] = evaluation_likelihood_multiMarker2(particles, likelihood, HSV, dictionary )
    
    % plz correct sub function ex: evaluate_hue_shift -> evaluate_hueShift
    %                                    AddHue -< addHue
    % Problem
    % 如果物體重疊目前無解
    % 可以使用定期CVDecode
    % counter 讓 CVDecode 每過一段時間就做一次
    % 目前物體離開screen是OK的
    % 但物體進入screen則需要使用CVDecode才能捕捉

    height = size(HSV, 1);
    width = size(HSV, 2);
    
%     grid3by3_xPos = grid3by3Position(1:2:end, :);
%     grid3by3_yPos = grid3by3Position(2:2:end, :);
    
    ID = [];
    avg_particles = [];
   
    % find out how many unique connected component particles have
    % connectedComponents is an 1-D array stores the index of connected component
    connectedComponents = unique(particles(9, :));
    for i = 1 : size(connectedComponents, 2)
       
        % get particles and liklihood whose connected component equals to connectedComponents(i)
        particles_divided   = particles(:, particles(9, :) == connectedComponents(i));
        likelihood_divided = likelihood(:, particles(9, :) == connectedComponents(i));
%         grid3by3_xPos_divided = grid3by3_xPos(particles(9, :) == connectedComponents(i), :);
%         grid3by3_yPos_divided = grid3by3_yPos(particles(9, :) == connectedComponents(i), :);
        
        % decide whether specific connected component is a marker or not by its likelihood
        % filter out most particles which do not seems like a marker
        particles_divided = particles_divided(:, likelihood_divided > -5);
        likelihood_divided = likelihood_divided(likelihood_divided > -5);
%         grid3by3_xPos_divided = grid3by3_xPos(likelihood_divided > -5, :);
%         grid3by3_yPos_divided = grid3by3_yPos(likelihood_divided > -5, :);
        numOfParticles = size(particles_divided, 2);
        
        show_particles(particles_divided, HSV);

        % delete particles which do not seems like a marker
        if isempty(particles_divided)
            likelihood(:, particles(9, :) == connectedComponents(i)) =[];
            particles(:, particles(9, :) == connectedComponents(i)) =[];
%             grid3by3_xPos(particles(9, :) == connectedComponents(i), :) = [];
%             grid3by3_yPos(particles(9, :) == connectedComponents(i), :) = [];            
            numOfParticles = 0;
            continue
        end
        
        % lastResult is used to track the markerId last time
        lastResult = -1;
        m = mode(particles_divided(10, :));
        if m ~= -1
            lastReuslt = m;
        else
            origX = particles_divided(1, :);
            origY = particles_divided(2, :);

            rotateMatrix = zeros(2*numOfParticles, 2);
            scaleMatrix   = zeros(2*numOfParticles, 1);
            origMatrix     = zeros(2*numOfParticles, 1);
            for num = 1:size(particles_divided, 2)
                deg = particles_divided(5, num);
                rotateMatrix((num-1)*2 + 1:num*2, :) = [cosd(deg), -sind(deg); sind(deg), cosd(deg)];
                scaleMatrix((num-1)*2 + 1:num*2, 1) =  [particles_divided(7, num); particles_divided(7, num)];
                origMatrix((num-1)*2 + 1:num*2, 1)  =  [particles_divided(1, num); particles_divided(2, num)];
            end

            grid3by3Vector = rotateMatrix * [1 2 0 1 2 0 1 2;...
                                                        0 0 1 1 1 2 2 2] .* scaleMatrix;
            grid3by3Position = round( grid3by3Vector + origMatrix );
            origX = round(origX);
            origY = round(origY);
            numOfGridCells = size(grid3by3Position, 2);
            IDcount = [];
            
            for num = 1:size(particles_divided, 2)

                grid3by3_single = [grid3by3Position((num-1)*2 + 1, :); grid3by3Position(num*2, :)];
                % grid3by3_single = [grid3by3_xPos_divided(num); grid3by3_yPos_divided(num)];
                % assert(all(grid3by3_single == previous_version));
                
                % check whether particles and its neighbor are out of screen
                checkX = all(and(grid3by3_single(1, :) > 0, grid3by3_single(1, :) <= height), 'all');
                checkY = all(and(grid3by3_single(2, :) > 0, grid3by3_single(2, :) <= width), 'all');
                checkOrigX = (origX(num) > 0 && origX(num) <= height);
                checkOrigY = (origY(num) > 0 && origY(num) <= width);
                
                pilotDiff = -Inf;
                Degree0Idx = -1;
                if checkX && checkY && checkOrigX && checkOrigY
                    [Degree0Idx, pilotDiff] = Evaluate_hue_shift(...
                                                        HSV(grid3by3_single(1, 8), grid3by3_single(2, 8), 1),...
                                                        HSV(origX(num), origY(num), 1), ...
                                                        0, ...
                                                        0.013 ...
                                                    );
                end
                
                id = -1;
                error = -1;
                if pilotDiff > -Inf
                    
                    % since we don't need to evaluate cell9 which is a pilot cell
                    corrected_hues = zeros(1, numOfGridCells - 1);
                    idx_h = sub2ind(size(HSV), grid3by3Position(1, 1:7), grid3by3Position(2, 1:7), ones(1, numOfGridCells - 1));
                    corrected_hues = AddHue(HSV(idx_h), pilotDiff);
                    [error, id] = detectID(corrected_hues, dictionary, Degree0Idx);
                    
                    IDcount = [IDcount id];
                    [M, F] = mode(IDcount);
                
                % means there are large enough amount of particles which have same markerId
                    if F > 9
                        break
                    end
                end
            end
            if isempty(IDcount)
                lastResult = -1;
            else
                lastResult = mode(IDcount);
            end
        end
        
        ID = [ID lastResult];
        particles = gpuArray(particles);
        particles(10, particles(9, :) == connectedComponents(i)) = lastResult;
        
        if lastResult ~= -1
            
            markerCoordinates = zeros(2, 9, numOfParticles);
            
            for num = 1:size(particles_divided, 2)
                deg = particles_divided(5, num);
                rotateMatrix = [cosd(deg), -sind(deg); sind(deg), cosd(deg)];
                grid3by3Vector = rotateMatrix * [1 2 0 1 2 0 1 2;...
                                                          0 0 1 1 1 2 2 2] * particles_divided(7, num);
                origX = particles_divided(1, num);
                origY = particles_divided(2, num);
                grid3by3Position = grid3by3Vector + [origX; origY];           
                grid3by3Position = round([[origX; origY], grid3by3Position]);
                markerCoordinates(:, :, num) = grid3by3Position;
            end
            
            
            
            markerCoordinates = round(mean(markerCoordinates, 3));
            markerCoordinates = squeeze(markerCoordinates);
            
            % show the markerId for debug
            % weighted_particles(1) = weighted x coordinate
            % weighted_particles(2) = weighted y coordinate
            % weighted_particles(3) = weighted rotate angle
            % weighted_particles(4) = weighted scale 
           
            
            weighted_particles = zeros(1, 4, 'gpuArray');
            assert(all(size(particles_divided(1, :)) == size(likelihood_divided)), 'all');
            
            
            likelihood_divided = exp(likelihood_divided);
            sumOfLikelihood = sum(likelihood_divided);
            weighted_particles(1) = sum((particles_divided(1, :) .* likelihood_divided(1, :)), 'all') / sumOfLikelihood;
            weighted_particles(2) = sum((particles_divided(2, :) .* likelihood_divided(1, :)), 'all') / sumOfLikelihood;
            weighted_particles(3) = sum((particles_divided(5, :) .* likelihood_divided(1, :)), 'all') / sumOfLikelihood;
            weighted_particles(4) = sum((particles_divided(7, :) .* likelihood_divided(1, :)), 'all') / sumOfLikelihood;
            avg_particles = reshape(weighted_particles, 4, 1);

            weighted_particles = gather(weighted_particles);
            hold on 
%             rectangle(...
%                 'Position', [weighted_particles(2), weighted_particles(1), 2*weighted_particles(4), 2*weighted_particles(4)],...
%                 'LineWidth', 2,...
%                 'LineStyle', '--',...
%                 'EdgeColor', 'w'...
%             );
            
            deg = weighted_particles(3);
            rotateMatrix = [cosd(deg), -sind(deg); sind(deg), cosd(deg)];
            grid3by3Vector = rotateMatrix * [1 2 0 1 2 0 1 2; ...
                                                      0 0 1 1 1 2 2 2] * weighted_particles(4);
            grid3by3Position = grid3by3Vector + [weighted_particles(1); weighted_particles(2)];
            grid3by3Position = round([[weighted_particles(1); weighted_particles(2)], grid3by3Position]);
            p = plot( [weighted_particles(2), weighted_particles(2), weighted_particles(2)+weighted_particles(4)*2, weighted_particles(2)+weighted_particles(4)*2, weighted_particles(2)], ...
                   [weighted_particles(1), weighted_particles(1)+weighted_particles(4)*2, weighted_particles(1)+weighted_particles(4)*2, weighted_particles(1), weighted_particles(1)],...
                    'LineWidth', 2,...
                    'LineStyle', '--',...
                    'Color', 'w'...   
            );
            rotate(p, [0, 0, 1], -1*weighted_particles(3), [weighted_particles(2), weighted_particles(1), 0]);
            plot(grid3by3Position(2, :), grid3by3Position(1, :), 'b*');
            text(weighted_particles(2), weighted_particles(1), strcat('id = ',num2str(ID(size(ID,2)))),'FontSize',20,'Color','g','HorizontalAlignment', 'right');
            hold off
        end
    end
end