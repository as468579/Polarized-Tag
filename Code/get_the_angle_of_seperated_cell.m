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
angles = (0:1/180:179/180);

folder = 'C:\Users\User\Documents\MATLAB\PTag\img\11_27\';
numberOfFile = 1;
numberOfPolarizers = 9;
numberOfMarker = 1;

%% 

for count = 1:numberOfFile
    count = 1;
    fileName = strcat(folder,  num2str(count), '.bmp');
    rawdata = imread(fileName);
    
    HSV = PolarizedTrunToHSV(rawdata);
    
    % find the region where the polarized light strength is strong enough
    legalParticleLocation = EvaluateParticleLocation(HSV,discardSaturateBelow,discardValueBelow);
    
    % the order of the corner is left-top, right-top, right-bottom, left-bottom
    [boundingSet,L] = PartionPolarizedBounding(legalParticleLocation,Xhsv_diff_1,HSV);
    
    
    if size(boundingSet, 1) ~= (numberOfPolarizers * 4)
        disp(sprintf('%d error !!', count));
        break;
    end
    disp(sprintf('%d correct !!', count));
   
    %for nom = 1 : numberOfMarker
    for nop = 1:numberOfPolarizers    
        
        corners = boundingSet((nop-1)*4+1:nop*4,:);  
        
        % points = get_each_cell_center(corners);
        % assert (length(points) == numberOfPolarizers);
        
        center= mean(corners, 1);
        centerX = round(center(1));
        centerY = round(center(2));
        
        % for only detect center angle
        % predictions(1, :) stores predictive angles
        % predictions(2, : ) stores ground-truth
        % predictions(2,:) =  [0, 140, 60, 40, 110, 150, 70, 50, 20];
        % index_rearrange = [4, 7, 1, 8, 5, 2, 9, 6, 3];
        % predictions(3,:) = predictions(3, index_rearrange);
        
        % for detect  multiple angles in each cell
        % predictions(1, :) stores predictive angles
        % predictions(2, : ) stores center angles
        % predictions(3, :) stores diff( predictions, center)
        margin = 3; 
        predictions = zeros(3, (2 * margin + 1)^2 );
        [error, index] = detectAngle(HSV(centerX, centerY, 1), angles);
        predictions(2, :) = index - 1;
        ground_truth = [0, 140, 60, 40, 110, 150, 70, 50, 20];
        index_rearrange = [4, 7, 1, 8, 5, 2, 9, 6, 3];
        ground_truth = ground_truth(index_rearrange);
        
        figure(1);
        hold on;
        imshow(HSV);
        count = 1;
        for i = centerX-margin:centerX+margin
            for j = centerY-margin:centerY+margin
                   plot(j, i, 'k.');
                   [error, index] = detectAngle(HSV(i,j, 1), angles);
                   predictions(1, count) = index - 1;
                   predictions(3, count) = angleDistance(predictions(1,count), predictions(2, count));
                   count = count+1;
            end
        end
        hold off;
        
        figure(2);
        histogram(predictions(1,:), 100);
        title(strcat('Ground Truth : ', num2str(ground_truth(nop))));
        xlabel('degree of pixels');
        ylabel('number of pixels');
        saveas(gcf, strcat('detected_value_' , num2str(predictions(2,nop))), 'png');
    end

end