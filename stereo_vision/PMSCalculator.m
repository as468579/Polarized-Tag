classdef PMSCalculator
    properties
        image 
        reference
        height
        width
        grad_image
        grad_reference
        dissimilarityMap
        coordinatesMap
        pms = PMSParameters
    end
    
    methods
        function obj  = PMSCalculator(image, reference, pms)
            
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
            
        end
   
        function get_weighted_dissimilarity(obj, planeMap)

            height = obj.height;
            width = obj.width;
            weighted_dissimilarity = zeros(obj.height, obj.width);
            
            
            parfor (w = 1:width, 6)
%             for w = 1:obj.width
                for h = 1:height
                    point_coordinate = [h, w];
                    plane = planeMap(h, w, :);
                    weighted_dissimilarity(h, w) = matchPixels(obj, h , w, plane);
                end
            end

            
        end

        function m = matchPixels(obj, h, w, plane)
            
%             h = point_coordinate(1);
%             w = point_coordinate(2);
            
            str = ["h : ", h, ", w : ", w];
            disp(str);
            
            if iscell(plane)
                plane = cell2mat(plane);
                plane = reshape(plane, 1, 3);
            end
            
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
                timer = tic;
                point_coordinate = [h, w];
                [s, numOfInvalid] = getDissimilarity(obj, point_coordinate, range, plane);
                time_getDissimilarity = toc(timer);
            end
            m = sum(weight_mtx .* s, 'all') + numOfInvalid * obj.pms.PLANE_PENALTY;
        end

        function [s, numOfInvalid] = getDissimilarity(obj, point_coordinate, range, plane)
            all = tic;

            height_range_of_window = range{1};
            width_range_of_window = range{2};

            
            height = point_coordinate(1);
            width = point_coordinate(2);

             %  get dispariy Map
            timer = tic;
            coordinates_references =  obj.coordinatesMap(height_range_of_window, width_range_of_window, :);
            disparities = plane(1) .* coordinates_references(:, :, 1) + plane(2) .* coordinates_references(:, :, 2) + plane(3);
            time_getDispariy = toc(timer);
            
            % filter out illegal disparity
            timer = tic;
            reflected_coordinates = coordinates_references;
            valid = (disparities > obj.pms.disparityRange(1) & disparities < obj.pms.disparityRange(2));
            inside = ((coordinates_references(:, :, 1) - disparities) > 1) & ((coordinates_references(:, :, 1) - disparities) <= obj.width);
            
            legal = logical(valid & inside);
            tmp = coordinates_references(:, :, 1);
            reflected_x = tmp(legal) - disparities(legal);
            tmp = coordinates_references(:, :, 2);
            reflected_y = tmp(legal);
            reflected_coordinates = cat(3, reflected_x, reflected_y);
            time_filterDispariy = toc(timer);
            
            % interpolate2D continuous intensities and gradients of reflected coordinates
            timerbig = tic;
            s = zeros(size(coordinates_references(:, :, 1)));
            if sum(legal, 'all') ~= 0
                minX = floor(min(reflected_coordinates(:, :, 1), [], 'all'));
                maxX = ceil(max(reflected_coordinates(:, :, 1), [], 'all'));
                minY = floor(min(reflected_coordinates(:, :, 2), [], 'all'));
                maxY = ceil(max(reflected_coordinates(:, :, 2), [], 'all'));
                if maxY > 370
                    disp("exceed");
                    disp(maxY);
                end
                timer = tic;
                partial_image =  single(obj.image(minY:maxY, minX:maxX, :));
                partial_grad = single(obj.grad_image(minY:maxY, minX:maxX, :));
                partial_coordinates = obj.coordinatesMap(minY:maxY, minX:maxX, :);
%                 partial_image = gpuArray(partial_image);
%                 partial_grad = gpuArray(partial_grad);
                if minY == maxY
                    reflected_intensities_r = interp1(partial_coordinates(:, :, 1), partial_image(:, :, 1), reflected_coordinates(:, :, 1));
                    reflected_intensities_g = interp1(partial_coordinates(:, :, 1), partial_image(:, :, 2), reflected_coordinates(:, :, 1));
                    reflected_intensities_b = interp1(partial_coordinates(:, :, 1), partial_image(:, :, 3), reflected_coordinates(:, :, 1));
                    reflected_gradX = interp1(partial_coordinates(:, :, 1), partial_grad(:, :, 1), reflected_coordinates(:, :, 1));
                    reflected_gradY = interp1(partial_coordinates(:, :, 1), partial_grad(:, :, 2), reflected_coordinates(:, :, 1));
%                     time_interp2 = toc(timer);
                else
                    reflected_intensities_r = interp2(partial_coordinates(:, :, 1), partial_coordinates(:, :, 2), partial_image(:, :, 1), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
                    reflected_intensities_g = interp2(partial_coordinates(:, :, 1), partial_coordinates(:, :, 2), partial_image(:, :, 2), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
                    reflected_intensities_b = interp2(partial_coordinates(:, :, 1), partial_coordinates(:, :, 2), partial_image(:, :, 3), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
                    reflected_gradX = interp2(partial_coordinates(:, :, 1), partial_coordinates(:, :, 2), partial_grad(:, :, 1), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2));
                    reflected_gradY = interp2(partial_coordinates(:, :, 1), partial_coordinates(:, :, 2), partial_grad(:, :, 2), reflected_coordinates(:, :, 1), reflected_coordinates(:, :, 2)); 
%                     time_interp2 = toc(timer);
                end
                
%                 reflected_intensities_r= gather(reflected_intensities_r);
%                 reflected_intensities_g= gather(reflected_intensities_g);
%                 reflected_intensities_b= gather(reflected_intensities_b);
%                 reflected_gradX = gather(reflected_gradX);
%                 reflected_gradY=  gather(reflected_gradY);
                time_interp2 = toc(timer);
                
                % calculate L1 distance in color space, gradient
                r_references = obj.reference(height_range_of_window, width_range_of_window, 1);
                g_references = obj.reference(height_range_of_window, width_range_of_window, 2);
                b_references = obj.reference(height_range_of_window, width_range_of_window, 3);
                r_diff = single(r_references(legal)) - reflected_intensities_r;
                g_diff = single(g_references(legal)) - reflected_intensities_g;
                b_diff = single(b_references(legal)) - reflected_intensities_b;
                color_diff = cat(3, r_diff, g_diff, b_diff);
                color_distance = sum(abs(color_diff), 3);
                color_distance(color_distance < obj.pms.trun_color) = obj.pms.trun_color;
                
                gradX_references = obj.grad_reference(height_range_of_window, width_range_of_window, 1);
                gradY_references = obj.grad_reference(height_range_of_window, width_range_of_window, 2);
                gradX_diff = gradX_references(legal) - reflected_gradX;
                gradY_diff = gradY_references(legal) - reflected_gradY;
                grad_diff = cat(3, gradX_diff, gradY_diff);
                grad_distance = sum(abs(grad_diff), 3);
                grad_distance(grad_distance < obj.pms.trun_grad) = obj.pms.trun_grad;

                % calculate dissimilarity
                s(legal) = (1 - obj.pms.alpha) .* color_distance + obj.pms.alpha .* grad_distance;
            end
            time_blabla = toc(timerbig);
            timer = tic;
            numOfInvalid = (numel(coordinates_references(:, :, 1)) - sum(valid, 'all'));
            time_numOfInvalid = toc(timer);
            time_all = toc(all);
        end

    end
end
