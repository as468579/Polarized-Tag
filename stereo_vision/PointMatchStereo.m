classdef PointMatchStereo
    properties
        image 
        reference
        height
        width
        grad_image
        grad_reference
        planeMap
        dissimilarityMap
        coordinatesMap
        pms = PMSParameters
    end
    
    methods
        function obj  = PointMatchStereo(image, reference, pms)
            
            obj.image = image;
            obj.reference = reference;
            
            obj.height = size(image, 1);
            obj.width = size(image, 2);
            
            % calcualte gradX and gradY
            gary_image = rgb2gray(image);
            gray_reference = rgb2gray(reference);
            [Gx_image,Gy_image] = imgradientxy(gary_image);
            [Gx_reference,Gy_reference] = imgradientxy(gray_reference);
            obj.grad_image = cat(3, Gx_image, Gy_image);
            obj.grad_reference = cat(3, Gx_reference, Gy_reference);
            
            % create coordinatesMap
            [x, y] = meshgrid(1:size(image, 2), 1:size(image, 1));
            obj.coordinatesMap = cat(3, x, y);
            
            obj.pms = pms;
            
            % randomly initialize planMap
            obj.planeMap = init_planeMap(obj);
            
            % calculate initial dissimilarityMap
%             obj.dissimilarityMap = init_dissimilarityMap(obj);
            get_weighted_dissimilarity(obj);
        end
   
        function get_weighted_dissimilarity(obj)

            width = obj.width;
            height = obj.height;
            
            weighted_dissimilarity = zeros(height, width);
            
%             parfor (w = 1:width, 2)
            for w = 1:obj.width
                for h = 1:height
                    point_coordinate = [h, w];
                    weighted_dissimilarity(h, w) = matchPixels(obj, point_coordinate);
                    str = ["height :", num2str(h), ", width : ", num2str(w)];
                    disp(str);
                end
            end
            obj.dissimilarityMap =  weighted_dissimilarity;
            
        end

        function m = matchPixels(obj, point_coordinates)

            h= point_coordinates(1);
            w = point_coordinates(2);

            height_range_of_window = ceil(h-obj.pms.windowSize/2):ceil(h+obj.pms.windowSize/2 - 1);
            width_range_of_window =  ceil(w-obj.pms.windowSize/2):ceil(w+obj.pms.windowSize/2 - 1);

            height_range_of_window = height_range_of_window(height_range_of_window > 0  & height_range_of_window <= obj.height);
            width_range_of_window = width_range_of_window(width_range_of_window > 0 & width_range_of_window <= obj.width);

            intensities_references = obj.reference(height_range_of_window, width_range_of_window, :);
            range = {height_range_of_window, width_range_of_window};
            
            if obj.pms.temporal
            else

        %         r_diff = image(height, width, 1) - reference(height_range_of_window, width_range_of_window, 1);
        %         g_diff = image(height, width, 2) - reference(height_range_of_window, width_range_of_window, 2);
        %         b_diff = image(height, width, 3) - reference(height_range_of_window, width_range_of_window, 3);

                color_diff =  obj.image(h, w, :) - intensities_references;
                color_distance = sum(abs(color_diff), 3);
                weight_mtx = exp(-1 * color_distance / obj.pms.gamma);
                s = getDissimilarity(obj, point_coordinates, range);
            end
            m = sum(weight_mtx .* s, 'all');
        end

        function s = getDissimilarity(obj, point_coordinate, range)

            height_range_of_window = range{1};
            width_range_of_window = range{2};
            
            height = point_coordinate(1);
            width = point_coordinate(2);
            
            dissimilarityMap = zeros(obj.height, obj.width);
            
            %  get dispariy Map
            x = obj.coordinatesMap(:, :, 1);
            y = obj.coordinatesMap(:, :, 2);
            
            timer_getDisparity  = tic;
            coordinates_references =  obj.coordinatesMap(height_range_of_window, width_range_of_window, :);
            disparities =    obj.planeMap(height, width, 1) .* coordinates_references(:, :, 1) + obj.planeMap(height, width, 2) .* coordinates_references(:, :, 1) + obj.planeMap(height, width, 3);
            time_getDisparity = toc(timer_getDisparity);
            
            % filter out illegal disparity
            timer_filterDisparity  = tic;
            reflected_coordinates = coordinates_references;
            valid = ((coordinates_references(:, :, 1) - disparities) > 1) & ((coordinates_references(:, :, 1) - disparities) <= obj.width);
            tmp = coordinates_references(:, :, 1);
            reflected_coordinates(valid) = tmp(valid) - disparities(valid);
            reflected_coordinates(:, :, 2) = coordinates_references(:, :, 2);
            time_filterDisparity = toc(timer_filterDisparity);
            
            % interpolate2D continuous intensities and gradients of reflected coordinates
            timer_interpolate2D  = tic;
            
%             reflected_intensities_r = interp2(x, y, single(obj.image(:, :, 1)), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
%             reflected_intensities_g = interp2(x, y, single(obj.image(:, :, 2)), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
%             reflected_intensities_b = interp2(x, y, single(obj.image(:, :, 3)), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
%             reflected_gradX = interp2(x, y, obj.grad_image(:, :, 1), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
%             reflected_gradY = interp2(x, y, obj.grad_image(:, :, 2), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
            
            minX = min(reflected_coordinates(:, :, 1), [], 'all');
            maxX = max(reflected_coordinates(:, :, 1), [], 'all');
            minY = min(reflected_coordinates(:, :, 2), [], 'all');
            maxY = max(reflected_coordinates(:, :, 2), [], 'all');
            reflected_intensities_r = qinterp2(x(minY:maxY, minX:maxX), y(minY:maxY, minX:maxX), single(obj.image(minY:maxY, minX:maxX, 1)), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
            reflected_intensities_g = qinterp2(x(minY:maxY, minX:maxX), y(minY:maxY, minX:maxX), single(obj.image(minY:maxY, minX:maxX, 2)), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
            reflected_intensities_b = qinterp2(x(minY:maxY, minX:maxX), y(minY:maxY, minX:maxX), single(obj.image(minY:maxY, minX:maxX, 3)), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
            reflected_gradX = qinterp2(x(minY:maxY, minX:maxX), y(minY:maxY, minX:maxX), obj.grad_image(minY:maxY, minX:maxX, 1), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
            reflected_gradY = qinterp2(x(minY:maxY, minX:maxX), y(minY:maxY, minX:maxX), obj.grad_image(minY:maxY, minX:maxX, 2), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2)); 
%             [x, y] = ndgrid(minY:maxY, minX:maxX);
%             interp_r = griddedInterpolant(x, y, single(obj.image(minY:maxY, minX:maxX, 1)));
%             interp_g = griddedInterpolant(x, y, single(obj.image(minY:maxY, minX:maxX, 2)));
%             interp_b = griddedInterpolant(x, y, single(obj.image(minY:maxY, minX:maxX, 3)));
%             reflected_intensities_r = interp_r(reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
%             reflected_intensities_g= interp_g(reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
%             reflected_intensities_b= interp_b(reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
%             
%             interp_gradX = griddedInterpolant(x, y, single(obj.grad_image(minY:maxY, minX:maxX, 1)));
%             interp_gtadY = griddedInterpolant(x, y, single(obj.grad_image(minY:maxY, minX:maxX, 2)));
%             reflected_gradX = interp_gradX(reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));             
%             reflected_gradY = interp_gtadY(reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2)); 
            time_interpolate2D = toc(timer_interpolate2D);
            
            % calculate L1 distance in color space, gradient
            timer_calculateL1  = tic;
            color_diff = single(obj.reference(height_range_of_window, width_range_of_window, :)) - cat(3, reflected_intensities_r, reflected_intensities_g, reflected_intensities_b);
            color_distance = sum(abs(color_diff), 3);
            color_distance(color_distance < obj.pms.trun_color) = obj.pms.trun_color;
            
            grad_diff = obj.grad_reference(height_range_of_window, width_range_of_window, :) - cat(3, reflected_gradX, reflected_gradY);
            grad_distance = sum(abs(color_diff), 3);
            grad_distance(grad_distance < obj.pms.trun_grad) = obj.pms.trun_grad;
            time_calculateL1 = toc(timer_calculateL1);
            
            % calculate dissimilarity
            timer_dissimilarity  = tic;
            s = (1 - obj.pms.alpha) .* color_distance + obj.pms.alpha .* grad_distance;
            time_dissimilarity = toc(timer_dissimilarity);
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
        
        function dissimilarityMap = init_dissimilarityMap(obj)
            
            dissimilarityMap = zeros(obj.height, obj.width);
            
            %  get dispariy Map
            disparities =    obj.planeMap(:, :, 1) .* obj.coordinatesMap(:, :, 1) + obj.planeMap(:, :, 2) .* obj.coordinatesMap(:, :, 2) + obj.planeMap(:, :, 3);
            
            % filter out illegal disparity
            reflected_coordinates = obj.coordinatesMap;
            valid = (obj.coordinatesMap(:, :, 1) - disparities) > 1;
            tmp = obj.coordinatesMap(:, :, 1);
            reflected_coordinates(valid) = tmp(valid) - disparities(valid);
            reflected_coordinates(:, :, 2) = obj.coordinatesMap(:, :, 2);
            
            % interpolate2D continuous intensities and gradients of reflected coordinates
            x = obj.coordinatesMap(:, :, 1);
            y = obj.coordinatesMap(:, :, 2);
            reflected_intensities_r = interp2(x, y, single(obj.image(:, :, 1)), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
            reflected_intensities_g = interp2(x, y, single(obj.image(:, :, 2)), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
            reflected_intensities_b = interp2(x, y, single(obj.image(:, :, 3)), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
            reflected_gradX = interp2(x, y, obj.grad_image(:, :, 1), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
            reflected_gradY = interp2(x, y, obj.grad_image(:, :, 2), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
            
            % calculate L1 distance in color space, gradient
            color_diff = single(obj.reference) - cat(3, reflected_intensities_r, reflected_intensities_g, reflected_intensities_b);
            color_distance = sum(abs(color_diff), 3);
            color_distance(color_distance < obj.pms.trun_color) = obj.pms.trun_color;

            grad_diff = obj.grad_reference - cat(3, reflected_gradX, reflected_gradY);
            grad_distance = sum(abs(color_diff), 3);
            grad_distance(grad_distance < obj.pms.trun_grad) = obj.pms.trun_grad;

            % calculate dissimilarity
            s = (1 - obj.pms.alpha) .* color_distance + obj.pms.alpha .* grad_distance;
            
            
            assert(all(size(s) == size(dissimilarityMap)));
            dissimilarityMap = s;
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
        
%         function spatial_propagate(obj)
%         
%         end
    end
end
