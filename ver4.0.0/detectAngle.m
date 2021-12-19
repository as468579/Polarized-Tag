function [error, index] = detectAngle(hue, angles) 
     [error, index] = min( abs(hue-angles) );
end 