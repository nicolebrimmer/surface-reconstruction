%{
    Produce a scatterplot where each point represents a voxel in the
    captured image and the x and y coordinates represent the intensities
    in the 640 nm and 561 nm wavelengths respectively.

%}

function [  ] = plotIntensityScatterplot ( )

    %{
    % Determine file names.
    bareFileName640 = 'JB_20x_Brain26-4-sCMOS-4_w1Conf 640.TIF';
    bareFileName561 = 'JB_20x_Brain26-4-sCMOS-4_w2Conf 561.TIF';
    
    path = '../../JB Brainbow data early Nov/';
    
    fileName640 = [path bareFileName640];
    fileName561 = [path bareFileName561];
    
    % Convert the images into matrices.
    numOfShrinks = 0;
    imageMatrix640 = readImageFile(fileName640, numOfShrinks);
    imageMatrix561 = readImageFile(fileName561, numOfShrinks);
    %}

    load('imageMatrix561File', 'imageMatrix561');
    load('imageMatrix640File', 'imageMatrix640');
    
    % Convert the 3D matrix into another vector of matrices (each
    % matrix representing a slice of the image).
    [x, y, numOfSlices] = size(imageMatrix640);
    imageMatrix640 = reshape(imageMatrix640, [(x * y) numOfSlices]);
    
    [x, y, numOfSlices] = size(imageMatrix561);
    imageMatrix561 = reshape(imageMatrix561, [(x * y) numOfSlices]);
    
    % Plot the image.
    figure;
    hold on;
    for slice = 1:numOfSlices
        fprintf(['Plotting slice ' num2str(slice) ' of ' num2str(numOfSlices) '\n']);
        plot(imageMatrix640(:, slice), imageMatrix561(:, slice), '.', 'MarkerSize' ,4, 'Color', 'black');
    end
    
    xlabel('640 nm intensity');
    ylabel('561 nm intensity');
end

