%{
    Performs a level set reconstruction algorithm, by solving a matrix
    equation of the form: K * w = d for the vector w of weights.

    @param points a (numOfPoints x 3) matrix, in which each row represents
                  a point source in the binary image that is associated
                  with a normal vector and a tangent vector.
                  Note that every point source in the binary image will
                  not be associated with a normal vector and a tangent
                  vector because some outlier point sources will not have
                  any neighboring point sources and therefore the PCA
                  algorithm will not return any meaningly data.

                  points[n, :] is a 3D vector representing the location of
                  a point source in the binary image and is associated 
                  with the 2D tangent vector tangents[n, :] and the normal 
                  vector normals[n, :].

    @param normals a (numOfPoints x 3) matrix, in which each row
                   represents a normal vector (i.e. a vector normal to the
                   point cloud in the binary image).

                   normals[n, :] is a 3D vector representing
                   the direction of least variance for the point source
                   points[n, :] in the binary image.

    @param rbfName the name of the rbf to be performed on the points in x.

    @param arguments the values of the constants in the function definition
                     of the rbf to be performed on the points in x.

    @param epsilon A small number.  This number is used to move slightly
                   along the normal vector away from the point source and 
                   is also used to assign small numbers to these points 
                   slightly away from the point source.

    @return weights the weights (i.e. the vector w) that together defines
                    the level set function.
                    A [numOfAllPoints] x 1 vector, where numOfAllPoints is 
                    the number of rows in [allPoints], i.e. the number of
                    points in [allPoints].  Each element in this 
                    matrix is a weight that is associated with a point 
                    in [allPoints].
    
    @return allPoints a (2 * [numOfPoints]) x 3 matrix, each row of which
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


    The full specifications for rbfName and rbfArguments can be found in 
    rbf.m
%}

function [ weights, allPoints ] = calculateLevelSetReconstruction( points, normals, rbfName, rbfArguments, epsilon )

    numOfPoints = size(points, 1);
    numOfDimensions = size(points, 2);
    
    % Construct d, the vector that is on the right hand side of the matrix 
    % equation.
    d = zeros(2 * numOfPoints, 1);
    % d(1:numOfPoints) = 0
    d((numOfPoints + 1):(2 * numOfPoints)) = epsilon;
    
    % Construct allPoints.
    allPoints = zeros(2 * numOfPoints, numOfDimensions);
    for index = 1:(2 * numOfPoints)
        if (index <= numOfPoints)
            allPoints(index, :) = points(index, :);
        else
            allPoints(index, :) = points(index - numOfPoints, :) + epsilon * normals(index - numOfPoints, :); 
        end
    end
    
    % Construct K, the vector that is on the left hand side of the matrix 
    % equation.
    K = zeros(2 * numOfPoints, 2 * numOfPoints);
    for row = 1:(2 * numOfPoints)
        for column = 1:(2 * numOfPoints)
            firstPoint = allPoints(row, :);
            secondPoint = allPoints(column, :);
            
            K(row, column) = rbf(rbfName, rbfArguments, (firstPoint - secondPoint));
        end
    end
    
    % Solve the matrix equation.
    weights = inv(K) * d;
    
end

