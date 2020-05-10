classdef Plane
    properties
        a double
        b double
        c double 
    end
    
    methods
        function obj = Plane(varargin)
            
            if nargin == 1
                 obj.a = varargin{1}(1);
                 obj.b = varargin{1}(2);
                 obj.c = varargin{1}(3);
            elseif nargin == 3
                 obj.a = varargin{1};
                 obj.b = varargin{2};
                 obj.c = varargin{3};                
            end           
            
        end
        
        
        function disparity = getDisparity(obj, x, y)
            disparity = obj.a*x + obj.b*y +obj.c;
        end
        
    end
end