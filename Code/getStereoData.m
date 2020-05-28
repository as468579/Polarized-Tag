clc;
clear;

left = videoinput('pointgrey', 1);
right = videoinput('pointgrey', 2);

% root = "E:\"; 
root = "C:\Users\User\Documents\MATLAB\PTag\img\";
datestr = strsplit(date, "-");
day = datestr{1};
month = datestr{2};
folder = strcat(root, datestr{2}, "_", datestr{1}, "\");
left_folder = strcat(folder, "left\");
right_folder = strcat(folder, "right\");

numOfFrames = 20;

if ~exist(folder, 'dir')
   mkdir(folder)
end

if ~exist(left_folder, 'dir')
   mkdir(left_folder)
end

if ~exist(right_folder, 'dir')
   mkdir(right_folder)
end

preview(left);
preview(right);
for i=1:numOfFrames
   
    left_image = getsnapshot(left);
    right_image = getsnapshot(right);

    imwrite(left_image, strcat(left_folder, num2str(i), ".png"));
    imwrite(right_image, strcat(right_folder, num2str(i), ".png"));
    
    % stop
    pause;
    disp(i);
    if i == numOfFrames
        closepreview(left);
        closepreview(right);
        delete(left);
        delete(right);
    end
end
