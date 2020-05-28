left = videoinput("pointgrey", 1);
right = videoinput("pointgrey", 2);

if isrunning(left)
    stop(left)
end

if isrunning(right)
    stop(right)
end

left.FramesPerTrigger  = 100;
right.FramesPerTrigger  = 100;