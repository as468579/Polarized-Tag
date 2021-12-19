close all;
clear;
clc;

%% Configuration

% discardSaturateBelow defines the minimum value of Saturate we need
% discardValueBelow defines the minimum value of Valu we need
% For long distance
discardSaturateBelow = 0.1;
discardValueBelow = 0.1;

% which means 0.12 * 180 = 20 degree
Xhsv_diff_1 = 0.12;

% define degree 0 ~ 179

folder = 'D:\User\Documents\MATLAB\Ptag\img\rotate\';
numberOfFile = 10;
numberOfPolarizers = 9;
numberOfMarker = 1;

%% 
 p = zeros(numberOfPolarizers, numberOfFile);
for count = 1:numberOfFile
    fileName = strcat(folder,  num2str(count), '.Bmp');
    rawdata = imread(fileName);
    
    HSV = PolarizedTrunToHSV(rawdata);
    
    % find the region where the polarized light strength is strong enough
    legalParticleLocation = EvaluateParticleLocation(HSV,discardSaturateBelow,discardValueBelow);
    
    % the order of the corner is left-top, right-top, right-bottom, left-bottom
    [boundingSet,L] = PartionPolarizedBounding(legalParticleLocation,Xhsv_diff_1,HSV);
    
    if size(boundingSet, 1) == 0
        disp(sprintf("%d couldn't find marker!!", count));
        continue;
    elseif size(boundingSet, 1) ~= (numberOfMarker * 4)
        disp(sprintf('%d error !!', count));
        continue;
    end
    disp(sprintf('%d correct !!', count));
   
    for nom = 1 : numberOfMarker
  
        corners = boundingSet((nom-1)*4+1:nom*4,:);  
       
        %{
        corners(1,1) = corners(1,1) -1;
        corners(1,2) = corners(1,2) + 7; 
        corners(2, 1) = corners(2, 1) - 1;
        corners(2, 2) = corners(2, 2) + 3;
        corners(3, 1) = corners(3, 1) + 2; 
        corners(3, 2) = corners(3, 2) - 3;
        %}
        imshow(HSV);
        hold on;
        
                
        for i = 1:4
            plot(round(corners(i, 2)), round(corners(i,1)), 'g*');
        end

        points = get_each_cell_center(corners);
      
        
     
        
        assert (length(points) == numberOfPolarizers);
        
        center= points(5,:);
        centerX = round(center(1));
        centerY = round(center(2));
        
        % predictions(1, :) stores prediction error
        % predictions(2, : ) stores prediction angles
        % predictions(3, :) stores labels
        predictions = zeros(3, numberOfPolarizers );
        % predictions(3,:) =  [0, 140, 60, 40, 110, 150, 70, 50, 20];
        predictions(3, :) = [0, 140, 110, 80, 30, 130, 50, 100, 20];
        index_rearrange = [1, 4, 7, 2, 5, 8, 3, 6, 9];
        
        % rearrange cells and porints by column major
        predictions(3, :) = predictions(3, index_rearrange);
        points = points(index_rearrange, :);
        
        [~,pilotPosition] = find_pilotPosition(HSV, points, Xhsv_diff_1);
        if pilotPosition == 2
            rearrange = [7, 4, 1, 8, 5, 2, 9, 6, 3];
            % predictions(3, :) = predictions(3, rearrange);
            points = points(rearrange, :);
        end
        
            % 因為已經rearrange了，所以不管對哪一個pilot都是points(1)-points(9)
            firstQuarter = round(points(1, :));
            lastQuarter = round(points(9, :));

        
        m = 2;
        [Degree0Idx,hueDiff] = Evaluate_hue_shift(...
                                        get_avg_hue(HSV, lastQuarter(1), lastQuarter(2), m),... 
                                        get_avg_hue(HSV, firstQuarter(1), firstQuarter(2), m),...
                                        0,...
                                        Xhsv_diff_1...
                                    );
        
        % correct marker rotate error
        HSV(:, :, 1) = AddHue(HSV(:, :, 1), hueDiff);
        
        
        [predictions(1,:), predictions(2,:)] = detect_marker_angles(HSV, points, Degree0Idx);
        p(:, count) = predictions(2, :)';
        
        histogram(predictions(2,:), 20);
        xlabel('degree of pixel');
        ylabel('number of pixels');
        % saveas(gcf, strcat('detected_value_' , num2str(predictions(2,nop))), 'png');
        
        
        % for detect multiple angles in each cell
        %{
        angles = 0:1/180:179/180;
        margin = 1;
        predictions =[9, (2 * margin + 1) ^2];
        count = 1;

        if Degree0Idx ==2 
            points = flipud(points);
        end
        for i = 1: numberOfPolarizers
            for x_pos = points(i,1) - margin:points(i, 1)+margin
                for y_pos = points(i,2) - margin:points(i, 2)+margin
                    plot(y_pos, x_pos, 'w.');
                    [error, index] = detectAngle(HSV(round(x_pos), round(y_pos), 1), angles);
                    predictions(i, count) = index - 1;
                    count = count + 1;
                end
            end
            figure(2);
            histogram(predictions(i,:), 20);
            count = 1;
            ground_truth = [0, 140, 110, 80, 30, 130, 50, 100, 20];
            ground_truth = ground_truth(index_rearrange);
            title(strcat('ground Truth : ', num2str(ground_truth(i))));
            saveas(gcf, strcat('ground_truth_', num2str(ground_truth(i))), 'png');
            
        end
        %}
        
        
        
    end
end

%{
% remove unsuccessful column
correct_find = ones(numberOfFile);
correct_find(~any(p, 1)) = 0;
p(:,~any(p, 1)) = [];

for i = 1:size(p, 1)
    figure(i);
    histogram(p(i, :), 100);
    title(strcat("Ground Truth : ", num2str(predictions(3, i))));
    xlabel('degree of pixel');
    ylabel('number of pixels');
    % saveas(gcf, strcat('moving_hand_detected_value_' , num2str(predictions(3, i))), 'png');
end
%}
