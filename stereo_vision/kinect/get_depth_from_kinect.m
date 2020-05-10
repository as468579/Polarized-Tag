% clear;
% clc;
% Create the objects for the color and depth sensors. 
% Device 1 is the color sensor and Device 2 is the depth sensor.
colorVid = videoinput('kinect',1);
depthVid  = videoinput('kinect',2);

preview([colorVid depthVid]);

% Get the source properties for the depth device
srcDepth = getselectedsource(depthVid);

% Set the frames per trigger for both devices to 1.
colorVid.FramesPerTrigger = 1;
depthVid.FramesPerTrigger = 1;

% Set the trigger repeat for both devices to 200
% In order to acquire 201 frames from both the color sensor and the depth sensor.
colorVid.TriggerRepeat = 200;
depthVid.TriggerRepeat = 200;

% Configure the camera for manual triggering for both sensors.
triggerconfig([colorVid depthVid],'manual');

% Start both video objects.
start([colorVid depthVid]);

% Trigger the devices, then get the acquired data.
% Trigger 200 times to get the frames.
for i = 1:10
    % Trigger both objects.
    trigger([colorVid depthVid])
    % Get the acquired frames and metadata.
    [imgColor, ts_color, metaData_Color] = getdata(colorVid);
    [imgDepth, ts_depth, metaData_Depth] = getdata(depthVid);
end

x = 850:5:945;
for i = 1:size(x, 2)-1
    imgColor_tmp = imgColor;
    mask= repmat(imgDepth > x(1, i) & imgDepth <= x(1, i+1), [1,1,3]);
    imgColor_tmp(~mask) = 0;
    tmp = nnz(imgColor_tmp);
    disp(tmp);
    figure(1);
    imshow(imgColor_tmp);
    saveas(gcf, strcat("depth", int2str(x(1, i)), "_", int2str(x(1, i+1)), ".png"));
end
delete(colorVid);
delete(depthVid);
