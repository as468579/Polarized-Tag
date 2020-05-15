classdef PatchMatchStereo
    properties
        left_calculator 
        right_calculator 
        left_planeMap
        right_planeMap
        height 
        width
        pms = PMSParameters
    end
    methods
        function obj = PatchMatchStereo(left, right, pms)
            
            obj.height = size(left, 1);
            obj.width = size(left, 2);
            obj.pms = pms;
            
            obj.left_calculator = PMSCalculator(left, right, pms);
            obj.right_calculator = PMSCalculator(right, left, pms);
            
            obj.left_planeMap = init_planeMap(obj);
            obj.right_planeMap = init_planeMap(obj);
        end
        
        function planeMap = init_planeMap(obj)
  
            planeMap = zeros(obj.height, obj.width, 3);
            max_disparity = obj.pms.disparityRange(2);

            [x, y] = meshgrid(1:obj.width, 1:obj.height);
            z = rand(obj.height, obj.width) * max_disparity;
            n = rand(obj.height, obj.width, 3);
            n = n ./ sqrt( sum(n .* n, 3) );

            a = -1 * ( n(:, :, 1) ./ n(:, :, 3) );
            b = -1 * ( n(:, :, 2) ./ n(:, :, 3) );
            c = ( n(:, :, 1) .* x + n(:, :, 2) .* y + n(:, :, 3) .* z ) ./ n(:, :, 3);

            planeMap = cat(3, a, b, c);
        end
        
        
        function propagate(obj)
            iter = obj.pms.iteration;
            for i = 1:iter
                spatial_propagate(obj);
                view_propagate(obj);
                if obj.pms.temporal
                    temporal_propagate(obj)
                end
                plane_refinement(obj);
            end
        end
        
        function spatial_propagate(obj)
            height = obj.height;
            width = obj.width;
            
            left_dissimilarityMap = zeros(height, width);
            right_dissimilarityMap = zeros(height, width);
            for h = 1:height
                for w = 1:height
                    height_range_of_window = ceil(h-obj.pms.windowSize/2):ceil(h+obj.pms.windowSize/2 - 1);
                    width_range_of_window =  ceil(w-obj.pms.windowSize/2):ceil(w+obj.pms.windowSize/2 - 1);

                    height_range_of_window = height_range_of_window(height_range_of_window > 0  & height_range_of_window <= obj.height);
                    width_range_of_window = width_range_of_window(width_range_of_window > 0 & width_range_of_window <= obj.width);
                    
                    h_window = ones(size(height_range_of_window, 2), size(width_range_of_window, 2)) .* h;
                    w_window = ones(size(height_range_of_window, 2), size(width_range_of_window, 2)) .* w;
                    partial_left_plane = obj.left_planeMap(height_range_of_window, width_range_of_window, :);
                    partial_left_plane = mat2cell(partial_left_plane, ones(1, size(partial_left_plane, 1)),  ones(1, size(partial_left_plane, 2)), 3)
                    calculator = obj.left_calculator;
                    left_s = arrayfun(@calculator.matchPixels, h_window, w_window, partial_left_plane);
                    minimal = min(min(left_s));
                    [x, y] = find(left_s == minimal);
                    
                    
                end
            end
        end
        
        function start(obj)
%             obj.left_calculator.get_weighted_dissimilarity(obj.left_planeMap);
%             obj.right_calculator.get_weighted_dissimilarity(obj.right_planeMap);
            spatial_propagate(obj);
        end
    end
end
    