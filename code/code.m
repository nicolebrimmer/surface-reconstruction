clc;

%%% Determine the name of the file.
fileNameNumber = 1;

if fileNameNumber == 0
    bareFileName = 'Brain26-4-sCMOS-4_w1Conf 640_deconColor3_15iter.TIF';
elseif fileNameNumber == 1
    bareFileName = 'JB_20x_Brain26-4-sCMOS-4_w1Conf 640.TIF';
elseif fileNameNumber == 2
    bareFileName = 'JB_20x_Brain26-4-sCMOS-4_w2Conf 561.TIF';
end

path = '../../JB Brainbow data early Nov/';
fileName = [path bareFileName];

%%% Convert the image file to a matrix and visualize the middle slice.
imageMatrix = readImageFile(fileName, 3);

middleSlice = size(imageMatrix, 3) / 2;
figure(1);
imshow(imageMatrix(:, :, middleSlice));

%%% Compute a mask and visualize the middle slice.
imageMask = intensityThreshold(imageMatrix);
figure(2);
imshow(imageMask(:, :, middleSlice));

fprintf('Script completed');
