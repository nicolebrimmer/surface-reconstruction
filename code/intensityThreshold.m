%{
    Uses conservative image thresholding to determine a mask that
    labels the 3D location of stained portions of the cell membrane.
    
    @param imageMatrix a matrix representing the 3D image
    @return imageMask a mask 

%}

function [ imageMask ] = intensityThreshold( imageMatrix )
    fprintf('Applying an intensity threshold on the image data');
    
    % Visualize the intensity histogram.
    figure;
    histogram(imageMatrix);
    
    numOfThresholds = 10;
    thresholds = multithresh(imageMatrix, numOfThresholds);
    
    imageMask = imquantize(imageMatrix, thresholds) ./ (numOfThresholds + 1);
    
    %imageMask(imageMask < 1) = 0;
end

