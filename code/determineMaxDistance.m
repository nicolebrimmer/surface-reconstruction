%{
    Calculates a reasonable value of [maxDistance], where two points in the point
    cloud are defined to be neighbors if the distance between them is less
    than or equal to [maxDistance].

    @param xs the x coordinates of the points in the point cloud.

    @param ys the y coordinates of the points in the point cloud.

    @param zs the z coordinates of the points in the point cloud.

    @param numOfNeighbors a positive integer. 
                          This parameter is further described below.

    @return maxDistance the average distance between each point p in the
                        point cloud and the [numOfNeighbors] points in the
                        point cloud that are closest to p.

%}

function [ maxDistance ] = determineMaxDistance ( xs, ys, zs, numOfNeighbors )
    numOfPoints = size(xs, 1);
    
    % Loop through each point p in the point cloud, determining the distance
    % between it and the [numOfNeighbors] closest to it.
    sumOfDistances = 0;
    for pointIndexP = 1:numOfPoints
        pointPX = xs(pointIndexP);
        pointPY = ys(pointIndexP);
        pointPZ = zs(pointIndexP);
        
        % Loop through each point q in the point cloud, determining the
        % distance between p and q.
        distances = zeros(numOfPoints - 1, 1);
        indexOfDistances = 1;
        for pointIndexQ = 1:numOfPoints
            
            % If points p and q are different,...
            if (pointIndexQ ~= pointIndexP)
                pointQX = xs(pointIndexQ);
                pointQY = ys(pointIndexQ);
                pointQZ = zs(pointIndexQ);
                
                distance = ((pointPX - pointQX) ^ 2 + (pointPY - pointQY) ^ 2 + (pointPZ - pointQZ) ^ 2) ^ (1/2);
                distances(indexOfDistances) = distance;
                
                indexOfDistances = indexOfDistances + 1;
            end
            
        end
        
        % Extract the [numOfNeighbors]-th closest neighbor of point p.
        distances = sort(distances);
        distanceOfInterest = distances(numOfNeighbors);
        
        sumOfDistances = sumOfDistances + distanceOfInterest;
    end
    
    maxDistance = sumOfDistances / numOfPoints;
    
end

