function [boundingSet, labelMap] = partitionPolarizedBounding(legalPolarizedLocation, pilotDiff, HSV)
    %% transform the polarized area in to bianry image
    %[Note] : matlab is column major
    
    height = size(HSV, 1);
    width = size(HSV, 2);
    binary = uint8(zeros(size(HSV, 1), size(HSV, 2), 'gpuArray'));
    index = sub2ind(size(HSV), legalPolarizedLocation(1, :), legalPolarizedLocation(2, :), ones(1, size(legalPolarizedLocation, 2)));
    binary(index) = 255;
    
    %% Dilating and eroding to eliminate noise
    se = strel('square',5);
    dilated_binary = imdilate(binary, se);    
    se = strel('square',4);
    eroded_binary = imerode(dilated_binary, se);
    
    %% label the connectedComponent
    labelMap = bwlabel(eroded_binary);

    %% show binary image
    % figure(1);
    % imshow(labelMap);
    
    %% check the candidate's ratio of  length and width
    numOfConnectedComponents = gather(max(max(labelMap)));
    coordinateOfCCs = cell(1, numOfConnectedComponents);
    
    labelMap = gather(labelMap);
    numOfConnectedComponents = max(max(labelMap));
    
    for i = 1:numOfConnectedComponents
        [r, c] = find(labelMap == i);
        coordinateOfCCs{i} = [r, c]';
    end

    illegal_coordinates = arrayfun(@eliminateIllegalArea, coordinateOfCCs, 'UniformOutput', false);
    illegal_coordinates = cell2mat(illegal_coordinates);
    idx = sub2ind(size(labelMap), illegal_coordinates(1, :), illegal_coordinates(2, :));
    labelMap(idx) = 0;
    
    %% relabel the connected components
    % since we delete some irrational connectedcomponent
    labelMap = gpuArray(labelMap);
    labelMap =  bwlabel(labelMap);
    
    numOfConnectedComponents = max(max(labelMap));
    
    % show the region which shape  is like a square(?)
    % imshow(labelMap)
    
    % find the boundaries of bw
    % B means the coordinations of boundaries
    % Note bwboundaries doesn't support gpu array
    labelMap = gather(labelMap);
    [B,L] = bwboundaries(labelMap, 'noholes');
    
    % 將connected component上色(顏色無意義
    L = gather(L);
    % imshow(label2rgb(L, @jet, [.5 .5 .5])) 
    

    boundingSet = arrayfun(@minBoundingBox, B, 'UniformOutput', false); 
    boundingSet = boundingSet';
    boundingSet = cell2mat(boundingSet);
    boundingSet = boundingSet';

end

function ret =  eliminateIllegalArea(coordinates)
        coordinates = cell2mat(coordinates);
        r = coordinates(1, :)';
        c = coordinates(2, :)';
        length = max(r)-min(r);
        width = max(c)-min(c);
        ratio = length/width;
        
        if  ~(ratio>1.3 || ratio<0.7 || size(r,1)<250 ||size(r,1)/(length*width) < 0.5)
            ret = [];
        else
            ret = coordinates;
        end
end
