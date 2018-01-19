%{
    Produces a new set of normals that are consistent with one another,
    more specifically the new normals either all point towards the interior
    of the cell or all point towards the exterior of the cell.

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

    @param func the function that is used to determine the list of the 
                point sources [q] that neighbor a particular center point 
                source of interest p.

                The signature of the function must be as follows:
                [ xOfNeighbors, yOfNeighbors, zOfNeighbors, indicesOfNeighbors ] = func( xs, ys, zs, xCenter, yCenter, zCenter, arguments )

                @param xs the x coordinates of all of the point sources in 
                          the binary image.
                @param ys the y coordinates of all of the point sources in 
                          the binary image.
                @param zs the z coordinates of all of the point sources in 
                          the binary image.
                @param xCenter the x coordinate of the center point source 
                               p of interest.
                @param yCenter the y coordinate of the center point source
                               p of interest.
                @param zCenter the z coordinate of the center point source
                               p of interest.
                @param arguments a list of arguments
                                 if func = @getNeighbrosMaxDistance,
                                 then...
                                    arugments(1) = maxDistance
                                    where two point sources are defined to
                                    be neighboring if and only if the
                                    distance between them is less than or
                                    equal to maxDistance
                @return xOfNeighbors the x coordinates of the point sources
                                     q in the binary image that are
                                     neighbors of the center point source p
                                     of interest.
                @return yOfNeighbors the y coordinates of the point sources
                                     q in the binary image that are 
                                     neighbors of the center point source p
                                     of interest.
                @return zOfNeighbors the z coordinates of the point sources
                                     q in the binary image that are 
                                     neighbors of the center point source p
                                     of interest.
                @return indicesOfNeighbors the n-th element of this vector 
                                           (i.e.indicesOfNeighbors[n]) is
                                           the index of the point source q
                                           whose x-coordinate is
                                           xOfNeighbors[n] and whose
                                           y-coordinate is
                                           yOfNeighbors[n] and whose
                                           z-coordiante is zOfNeighbors[n]
                                           in the parameters xs, ys and zs.
                                           In other words, xOfNeighbors[n]
                                           = xs[indicesOfNeighbors[n]] and
                                           yOfNeighbors[n] =
                                           ys[indicesOfNeighbors[n]] and
                                           zOfNeighbors[n] =
                                           zs[indicesOfNeighbors[n]].
    
    @param arguments a vector containing additional values that further
                     specify what it means for two point sources to be 
                     neighbors of one another.
                     The contents of this vector is specified above and 
                     depends on the function @func.

    @return consistentPoints a (numOfPoints x 3) matrix, in which each row 
                             represents a point source in the binary image 
                             that is associated with a consistent normal 
                             vector.
                   
                             consistentPoints[n, :] is a 3D vector 
                             representing the location of a point source in 
                             the binary image and is associated with the 3D
                             normal vector consistentNormals[n, :].

    @param consistentNormals a (numOfPoints x 3) matrix, in which each row
                             represents a consistent normal vector (i.e. a 
                             vector normal to the point cloud in the binary 
                             image).

                             consistentNormals[n, :] is a 3D vector 
                             representing the direction of least variance 
                             for the point source consistentPoints[n, :] in 
                             the binary image.


    The algorithm of this method is to choose a point source p in the point
    cloud and flip all of the normal vectors for the neighboring point
    sources q to be in approximately the same direction as the normal
    vector for point source q.
    The next point source p is chosen to be a neighbor of one of the point
    sources that has already been considered as a center point source p but
    that has not been a center point source p.
    
%}

function [ consistentPoints, consistentNormals ] = getConsistentNormalsFast ( points, normals, getNeighborsFunc, getNeighborsArguments)
    numOfPoints = length(points);
    consistentNormals = normals;
    consistentPoints = points;
    
    % Keeps track of all of the point sources p that have not been yet
    % considered.
    pointPIndicesToBeConsidered = linspace(1, numOfPoints, numOfPoints);
    
    % Keeps track of all of the neighbors of all of the point sources p
    % that have already been considered.
    neighborIndices = zeros(0);
    
    % Keeps track of all of the point sousrces p that should be considered
    % in the next iteration of the outer for loop below.
    pointPIndicesNextConsidered = pointPIndicesToBeConsidered;
    
    % Keeps track of all of the point sources in the binary image that are
    % associated with a normal vector.
    xsPoints = points(:, 1);
    ysPoints = points(:, 2);
    zsPoints = points(:, 3);
    
    indexOfVisualizedPoint = randi(numOfPoints);

    % Loop through each of the point sources (that are associated with
    % normal vectors) and for each such point source p, consider all of the
    % point sources [s] that are at most maxDistance away from p.
    % Determine the most common direction of all of the point sources [s]
    % and flip (i.e. multiply by -1) all of the normal vectors that point
    % in the opposite direction.
    for i = 1:numOfPoints
        % Pick a random point that is both in pointPIndicesToBeConsidered
        % (i.e. has not been considered yet as a center point source) and
        % in pointPIndicesNextConsidered (i.e. is part of the set to be
        % considered now).
        pointIndexP = -1;
        loopsOfWhile = 0;
        while (pointIndexP == -1)
            possiblePointPs = intersect(pointPIndicesToBeConsidered, pointPIndicesNextConsidered);
            numOfPossiblePointPs = length(possiblePointPs);
            if (numOfPossiblePointPs == 1)
                pointIndexP = possiblePointPs(1);
            elseif (numOfPossiblePointPs == 0)
                pointPIndicesNextConsidered = neighborIndices;
            else
                index = randi(length(possiblePointPs));
                pointIndexP = possiblePointPs(index);
            end
            
            if (loopsOfWhile >= 100)
                error('The maximum distance is not large enough');
            end
            
            
            loopsOfWhile = loopsOfWhile + 1;
        end
        
        pointP = points(pointIndexP, :);
        normalP = consistentNormals(pointIndexP, :);
                
        % Loop through all of the neighbors of the original point source p.
        [ xOfNeighbors, yOfNeighbors, zOfNeighbors, indicesOfNeighbors ] = getNeighborsFunc( xsPoints, ysPoints, zsPoints, pointP(1, 1), pointP(1, 2), pointP(1, 3), getNeighborsArguments );
        numOfNeighbors = length(xOfNeighbors);
        for neighborIndex = 1:numOfNeighbors
            pointS(1, 1) = xOfNeighbors(neighborIndex, 1);
            pointS(1, 2) = yOfNeighbors(neighborIndex, 1);
            pointS(1, 3) = zOfNeighbors(neighborIndex, 1);
            
            pointIndexS = indicesOfNeighbors(neighborIndex, 1);
            normalS = consistentNormals(pointIndexS, :);
            
            % Determine the angle between the two normals in DEGREES if 
            % we DO NOT flip the normal.
            dotProductSameDirection = sum(normalP .* normalS);
            magnitudeProductSameDirection = norm(normalP) * norm(normalS);
            angleSameDirection = acosd(dotProductSameDirection / magnitudeProductSameDirection);
            
            % Determine the angle between the two normals in DEGREES if 
            % we DO flip the normal.
            oppNormalS = -1 * normalS;
            dotProductOppDirection = sum(normalP .* oppNormalS);
            magnitudeProductOppDirection = norm(normalP) * norm(oppNormalS);
            angleOppDirection = acosd(dotProductOppDirection / magnitudeProductOppDirection);
            
            % If the angle between the two vectors is smaller when the
            % normal has been flipped (angleOppDirection) than when it has
            % been flipped (angleSameDirection), then flip the normal.
            if (angleOppDirection < angleSameDirection)
                consistentNormals(pointIndexS, :) = -1 * consistentNormals(pointIndexS, :);
            end 
        end
    
        % Remove current point p from point sources that have yet to be
        % considered (i.e. pointPIndicesToBeConsidered).
        pointPIndicesToBeConsidered(pointPIndicesToBeConsidered == pointIndexP) = [];

        % Consider one of the neighbors of the current center point source next.
        pointPIndicesNextConsidered = indicesOfNeighbors;   
        
        % Add current point p to the points already considered.
        neighborIndices = [neighborIndices; indicesOfNeighbors];
    end
end

