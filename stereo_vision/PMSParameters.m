classdef PMSParameters
    properties
        windowSize(1, 3) = [35, 35, 35]
        disparityRange(1, 2) = [0, 512]
        gamma double = 10
        alpha double = 0.9
        trun_color double = 10 
        trun_grad double = 2
        temporal logical = false
        iteration int8 = 3
    end
end