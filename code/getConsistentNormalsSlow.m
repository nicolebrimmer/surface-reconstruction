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
    cloud and then to consider only the normal vector associated with the point
    source q, the point source that is closest to point source p out of all
    point sources in the point cloud that have not been considered as a
    center point source p.
    
%}

function [ consistentPoints, consistentNormals ] = getConsistentNormalsSlow ( points, normals)
    numOfPoints = length(points);
    consistentNormals = normals;
    consistentPoints = points;
    
    % Loops through each unique pairs of point sources p and q exactly once and 
    % and calculates the distance between them and populates the matrix
    % [distances].
    % distances[n, :] is a row vector of the form
    %   ([dist], [pointIndexP], [pointIndexQ])
    % where dist is the distance between point sources p and q and
    % [pointIndexP] is the row index of point source p in the matrix [points]
    % and similarly [pointIndexQ] is the row index of the point source q in
    % the matrix [points].
    numOfUniquePairs = numOfPoints * (numOfPoints - 1) / 2;
    distances = zeros(numOfUniquePairs, 3);
    distancesIndex = 0;
    for pointIndexP = 1:(numOfPoints - 1)
        xp = consistentPoints(pointIndexP, 1);
        yp = consistentPoints(pointIndexP, 2);
        zp = consistentPoints(pointIndexP, 3);
        
        for pointIndexQ = (pointIndexP + 1):numOfPoints
            xq = consistentPoints(pointIndexQ, 1);
            yq = consistentPoints(pointIndexQ, 2);
            zq = consistentPoints(pointIndexQ, 3);
            
            % Calculate distance between the points.
            dist = ((xp - xq) ^ 2 + (yp - yq) ^ 2 + (zp - zq) ^ 2) ^ 0.5;
            
            % Populate the matrix.
            distancesIndex = distancesIndex + 1;
            distances(distancesIndex, 1) = dist;
            distances(distancesIndex, 2) = pointIndexP;
            distances(distancesIndex, 3) = pointIndexQ;
        end
    end
    
    % Keeps track of all of the point sources p that have not been yet
    % considered.
    pointPIndicesToBeConsidered = linspace(2, numOfPoints, (numOfPoints - 1));
    
    % Keeps track of all of the point sources p that have already been
    % considered.
    pointPIndicesConsidered = zeros(1, numOfPoints);
    pointPIndicesConsidered(1, numOfPoints) = 1;
    
    % Loop through each of the point sources p (that are associated with
    % normal vectors) and consider the closest point source q to p.
    for i = 1:(numOfPoints - 1)
        % Choose the closest pair of point sources p and q such that point
        % source p has already been considered and point source q has not
        % been.
        pointPIndex = 0;
        pointQIndex = 0;
        distances = sortrows(distances);
        for distancesIndex = 1:size(distances, 1)
            point1Index = uint8(distances(distancesIndex, 2));
            point2Index = uint8(distances(distancesIndex, 3));

            % We want one point index to have already been considered and
            % the other point index to have not been considered.
            if (any(pointPIndicesToBeConsidered == point1Index) && any(pointPIndicesConsidered == point2Index))
                pointPIndex = point2Index;
                pointQIndex = point1Index;
                break;
            elseif (any(pointPIndicesToBeConsidered == point2Index) && any(pointPIndicesConsidered == point1Index))
                pointPIndex = point1Index;
                pointQIndex = point2Index;
                break;
            end
        end
        
        % If the conditional for this if statement is true, then the
        % previous for loop ran to completion without being able to
        % determine a value for the variables, pointPIndex or pointQIndex.
        if (pointPIndex == 0 || pointQIndex == 0)
            error('Was unable to complete the homogenization of the normal vectors algorithm.');
        end
        
        normalP = consistentNormals(pointPIndex, :);
        normalQ = consistentNormals(pointQIndex, :);
            
        % Determine the angle between the two normals in DEGREES if 
        % we DO NOT flip the normal.
        dotProductSameDirection = sum(normalP .* normalQ);
        magnitudeProductSameDirection = norm(normalP) * norm(normalQ);
        angleSameDirection = acosd(dotProductSameDirection / magnitudeProductSameDirection);

        % Determine the angle between the two normals in DEGREES if 
        % we DO flip the normal.
        oppNormalQ = -1 * normalQ;
        dotProductOppDirection = sum(normalP .* oppNormalQ);
        magnitudeProductOppDirection = norm(normalP) * norm(oppNormalQ);
        angleOppDirection = acosd(dotProductOppDirection / magnitudeProductOppDirection);

        % If the angle between the two vectors is smaller when the
        % normal has been flipped (angleOppDirection) than when it has
        % been flipped (angleSameDirection), then flip the normal
        % associated with point source q.
        if (angleOppDirection < angleSameDirection)
            consistentNormals(pointQIndex, :) = -1 * consistentNormals(pointQIndex, :);
        end 
    
        % Remove current point q from point sources that have yet to be
        % considered (i.e. pointPIndicesToBeConsidered).
        pointPIndicesToBeConsidered(pointPIndicesToBeConsidered == pointQIndex) = [];
        
        % Add current point source q to the point sources that have been
        % considered (i.e. pointPIndicesConsidered).
        pointPIndicesConsidered(1, i) = pointQIndex;
        
        % Remove all lines from distances that correspond to those that
        % have both points in the set that have already been considered.
        distancesIndex = 1;
        while(distancesIndex <= size(distances, 1))
            point1Index = uint8(distances(distancesIndex, 2));
            point2Index = uint8(distances(distancesIndex, 3));

            % We want one point index to have already been considered and
            % the other point index to have not been considered.
            if (any(pointPIndicesConsidered == point1Index) && any(pointPIndicesConsidered == point2Index))
                distances(distancesIndex, :) = [];
            else
                distancesIndex = distancesIndex + 1;
            end
        end
    end
end


