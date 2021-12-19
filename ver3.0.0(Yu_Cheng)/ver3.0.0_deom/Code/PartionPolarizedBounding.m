function [BoundingSet,L] = PartionPolarizedBounding(legalParticleLocation,reserveOrienDiff,Y_HSV)
    
    %% transform the legal coordinate into bw image
    % bw means binary image
    %idx_h 表示高於S_low, V_low的座標轉換後的index
    %Note index in matlab is column major
    bw = zeros(size(Y_HSV,1),size(Y_HSV,2));
    idx_h = sub2ind(size(Y_HSV),legalParticleLocation(1,:),legalParticleLocation(2,:),ones(1,size(legalParticleLocation,2)));
    bw(idx_h) = 1;
    
    %% Dilating and eroding to eliminate noise
    se = strel('square',5);
    dilatedBW = imdilate(bw,se);    
    se = strel('square',4);
    erodedBW = imerode(dilatedBW,se);
    
    % label the connectedComponent
     % area is the labelMap of original image
    area = bwlabel(erodedBW);
    
    
    area_legalRatio = area;
    %% checking the ratio of candidate length and width 
    numOfConnectedComponent = max(max(area));
    for i = 1:numOfConnectedComponent
        % r is the array of  coordinations of connectedComponent which label is i 
        % c is the array of the other axis of connectedComponent which label is i 
        [r,c] = find(area == i);
        length = max(r)-min(r);
        width = max(c)-min(c);
        ratio = length/width;
        
        % filter out the strange shape of connectedcomponent
        % 我們可觀測到最小的mark邊長為18pixel
        % 所以mark最小的size是256仍大於50
        % 所以size > 仍有調整的空間
        % 另外，因為mark是正方形
        % 面積/(長*寬)最差的情況下為 1/2 (45度)
        % 面積/(長*寬)最好的情況下為 1 (0度, 90度, ...)
        if  ratio>1.3 || ratio<0.7 || size(r,1)<50 || size(r,1)/(length*width) < 0.5
             idx = sub2ind(size(area),r,c);
             area_legalRatio(idx) = 0;        
        end
    end
   
    %% relabel the connected components
    % because we delete some irrational connectedcomponent
    area_legalRatio =  bwlabel(area_legalRatio);
    
    numOfConnectedComponent = max(max(area_legalRatio));
    BoundingSet = [];
%     imshow(area_legalRatio)

    % find the boundaries of bw
    % B means the coordinations of boundaries
    [B,L] = bwboundaries(area_legalRatio,'noholes');
%     imshow(label2rgb(L, @jet, [.5 .5 .5]))   將connected component上色(顏色無意義
%     hold on
    for k = 1:size(B,1)
        boundary = B{k};
        % 可以旋轉找出最小的boundary box
        bb = minBoundingBox(boundary');
        bb = bb';
        BoundingSet = [BoundingSet; bb];
%         plot(bb(:,2),bb(:,1),"m*");
%         plot(boundary(:,2),boundary(:,1),"r*");
    end
%     hold off
end
