%{
    Displays the segmentation produced by the level set reconstruction.  In
    other words, displays the original point cloud (that was either
    extracted from a real image of neurons or was produced algorithmically
    to simulate simple such extractions) and colors in the pixels where the
    level set reconstruction function is positive or equal to zero if 
    [positive] is true or colors in the pixels where the level set 
    reconstruction function is negative or equal to zero otherwise.

    @param width the width of (i.e. the number of columns in) the produced
                 and returned toy binary image.

    @param height the height of (i.e. the number of rows in) the produced
                  and returned toy binary image.

    @param depth the depth of the produced and returned toy binary image.

    @param segmentedImage a [height] x [width] x [depth] matrix the
                          elements of which specify the value of the level
                          set reconstruction function at various locations
                          throughout the input image.

    @param xsPointSources the x coordinates of the point sources in the 
                          binary image.

    @param ysPointSources the y coordinates of the point sources in the 
                          binary image.

    @param zsPointSources the z coordinates of the point sources in the 
                          binary image.

    @param positive a boolean.  If [positive] is true, the pixels where the
                    level set reconstruction function is positive or equal 
                    to zero are colored in.  Otherwise, the pixels where 
                    the level set reconstruction function is negative or 
                    equal to zero are colored in.
%}

function drawLevelSetReconstruction ( width, height, depth, segmentedImage, xsPointSources, ysPointSources, zsPointSources, positive )
    numOfRows = height;
    numOfCols = width;
    numOfDepths = depth;

    % If [positive] is true, then color in the pixels where the level set
    % reconstruction function is positive or equal to zero.
    % Otherwise, color in the pixels where the level set reconstruction
    % function is negative or equal to zero.
    segmentedBinaryImage = zeros(numOfRows, numOfCols, numOfDepths);
    if (positive)
        segmentedBinaryImage(segmentedImage >= 0) = 1;
    else
        segmentedBinaryImage(segmentedImage <= 0) = 1;
    end

    figure;
    hold on;
    
    % Plot the segmented image (i.e. the colored in pixels) in blue.
    [xsBinarySegmentedImage, ysBinarySegmentedImage, zsBinarySegmentedImage] = ind2sub(size(segmentedBinaryImage), find(segmentedBinaryImage));
    plot3(xsBinarySegmentedImage, ysBinarySegmentedImage, zsBinarySegmentedImage, 'b.');
    
    % Plot the original binary image (i.e. the point sources) in red.
    plot3(xsPointSources, ysPointSources, zsPointSources, 'r.');
    
    title('Segmented Image');
    axis([0 width 0 height 0 depth]);
    
end

