function [likelihood, grid3by3Position] = calc_log_likelihood(particles, HSV, pilotDiff, hueDiff_std, hueDiff_thre, s_thre, v_thre)
    
    height = size(HSV, 1);
    width = size(HSV, 2);
    numOfParticles = size(particles, 2);
    likelihood = zeros(1, numOfParticles);
    A = -log(sqrt(2*pi) * hueDiff_std);
    B = -0.5 / (hueDiff_std.^2);
 
    for k = 1:numOfParticles
        

        origX = round(particles(1, k));
        origY = round(particles(2, k));

        rotateMatrix =  [cosd(particles(5,k)) -sind(particles(5,k)); sind(particles(5,k)) cosd(particles(5,k))];
        grid3by3Vector =  rotateMatrix * [1 2 0 1 2 0 1 2 ; ...
                                                   0 0 1 1 1 2 2 2] * particles(7,k);
        grid3by3Position = round( grid3by3Vector + [origX; origY] );


        checkOrigX = origX > 0 && origX <= height;
        checkOrigY = origY > 0 && origY <= width;
        checkX = all(and(grid3by3Position(1, :) > 0, grid3by3Position(1, :) <= height), 'all');
        checkY = all(and(grid3by3Position(2, :) > 0, grid3by3Position(2, :) <= width), 'all');

        if checkX && checkY &&  checkOrigX && checkOrigY
            idx_h = sub2ind(size(HSV), grid3by3Position(1, :), grid3by3Position(2, :), ones(size(grid3by3Position(1, :))));
            idx_s = sub2ind(size(HSV), grid3by3Position(1, :), grid3by3Position(2, :), ones(size(grid3by3Position(1, :))) * 2);
            idx_v = sub2ind(size(HSV), grid3by3Position(1, :), grid3by3Position(2, :), ones(size(grid3by3Position(1, :))) * 3);

            hues = HSV(idx_h);
            numOfGridCells = size(hues, 2);
            % store the difference of each point except for particle itself.
            hueDiff = zeros(1, sum(1:numOfGridCells - 1));

            for i = 2:size(hues,2)
                for j = i-1:-1:1
                    hueDiff(1, sum((i-2):-1:1)+j) = abs(hues(i)-hues(j));
                end
            end



            if all(hueDiff > hueDiff_thre, 'all') && ...
               all(HSV(idx_s) > s_thre, 'all') && ...
               all(HSV(idx_v) > v_thre, 'all') && ...
               HSV(origX, origY, 2) > s_thre && ...
               HSV(origX, origY, 3) > v_thre

                hueOfCell1 = HSV(origX, origY, 1);
                hueOfCell9 = HSV(grid3by3Position(1, 8), grid3by3Position(2, 8), 1);

                Dsquare = (HueDistance(hueOfCell1, hueOfCell9) - pilotDiff)^2;
                likelihood(k) = A + B * Dsquare;
            else
                likelihood(k) = -Inf;
            end
        else
            likelihood(k) = -Inf;
        end

end