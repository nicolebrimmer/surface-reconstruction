%{
    Calculates the value of the level set reconstruction function at each
    point in the input image.

    @param width the width of (i.e. the number of columns in) the produced
                 and returned toy binary image.

    @param height the height of (i.e. the number of rows in) the produced
                  and returned toy binary image.

    @param depth the depth of the produced and returned toy binary image.

    @param weights the weights (i.e. the vector w) that together defines
                   the level set function.
                   A [numOfAllPoints] x 1 vector, where numOfAllPoints is 
                   the number of rows in [allPoints], i.e. the number of
                   points in [allPoints].  Each element in this 
                   matrix is a weight that is associated with a point 
                   in [allPoints].
    
    @param allPoints a (2 * [numOfPoints]) x 3 matrix, each row of which
                     specifies the location a point in the input image, where
                     [numOfPoints] is the number of rows in [points], i.e.
                     the number of point sources in [points].
                     The first [numOfPoints] rows in the matrix contain the
                     locations of the point sources that are associated 
                     with a homogenized normal vector.  The second
                     [numOfRows] rows in the matrix contain the locations
                     points that are slightly off the point sources (by an
                     amount specified by epsilon) in the direction of the
                     homogenized normal vectors [normals].

    @param rbfName the name of the rbf to be performed on the points in x.

    @param arguments the values of the constants in the function definition
                     of the rbf to be performed on the points in x.

    @return segmentedImage a [height] x [width] x [depth] matrix the
                           elements of which specify the value of the level
                           set reconstruction function at various locations
                           throughout the input image.

    The full specifications for rbfName and rbfArguments can be found in 
    rbf.m
%}

function [segmentedImage] = applyLevelSetReconstruction ( width, height, depth, allPoints, weights, rbfName, rbfArguments )
    numOfRows = height;
    numOfCols = width;
    numOfDepths = depth;

    % Initialize the segmented image.
    segmentedImage = zeros(numOfRows, numOfCols, numOfDepths);
    
    % Loop through each pixel in the input image and determine the value of
    % the level set reconsturction function at that point.
    numOfAllPoints = size(allPoints, 1);
    for row = 1:numOfRows
        % This method is computationally intensive and to show progress
        % this print statement is included.
        fprintf(strcat('Completed row: ', num2str(row), ' out of ', num2str(numOfRows), '\n'));
        for col = 1:numOfCols
            for dep = 1:numOfDepths
                currPointX = row;
                currPointY = col;
                currPointZ = dep;

                currPoint(1, 1) = currPointX;
                currPoint(1, 2) = currPointY;
                currPoint(1, 3) = currPointZ;

                % To determine the value of level set reconstruction
                % function at the current location in the input image, loop
                % through all of the weights in [weights] and all of the
                % points in [allPoints].
                valueAtPoint = 0;
                for pointIndex = 1:numOfAllPoints
                    cenPoint = allPoints(pointIndex, :);
                    weight = weights(pointIndex);

                    valueAtPoint = valueAtPoint + weight * rbf( rbfName, rbfArguments, (currPoint - cenPoint) );
                end

                % Set the value of the level set reconstruction function at
                % the current location.
                segmentedImage(row, col, dep) = valueAtPoint;
        
        end
    end
    
end

