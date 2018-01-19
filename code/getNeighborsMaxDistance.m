%{
    Determines all of the point sources [q] neighboring a specified center 
    point source p of interest.
    A point source q is defined to be "neighboring" the specified center 
    point source p of interest if the distance between p and q is less than
    or equal to maxDistance.

    @param xs the x coordinates of all of the point sources in the binary 
              image.

    @param ys the y coordinates of all of the point sources in the binary 
              image.

    @param zs the z coordinates of all of the point sources in the binary 
              image.    

    @param xCenter the x coordinate of the center point source p of
                   interest.

    @param yCenter the y coordinate of the center point source p of 
                   interest.

    @param zCenter the z coordinate of the center point source p of 
                   interest.

    @param arguments a list of arguments that contains only 1 element:
                     arguments(1) = maxDistance 
                        where maxDistance is the maximum distance between a 
                              center point source p of interest and any of 
                              its neighboring point sources q.
                              A point source q is defined to be a neighbor 
                              of a center point source p of interest if and 
                              only if the distance between p and q is less 
                              than or equal to maxDistance.

    @return xOfNeighbors the x coordinates of the point sources q in the 
                         binary image that are neighbors of the center point 
                        source p of interest.

    @return yOfNeighbors the y coordinates of the point sources q in the 
                         binary image that are neighbors of the center point 
                         source p of interest.

    @return zOfNeighbors the z coordinates of the point sources q in the 
                         binary image that are neighbors of the center point 
                         source p of interest.

    @return indicesOfNeighbors the n-th element of this vector 
                               (i.e.indicesOfNeighbors[n]) is the index of 
                               the point source q whose x-coordinate is
                               xOfNeighbors[n], whose y-coordinate is 
                               yOfNeighbors[n] and whose z-coordinate is 
                               zOfNeighbors[n] in the parameters xs, ys and
                               zs.
                               In other words, xOfNeighbors[n] 
                               = xs[indicesOfNeighbors[n]] and
                               yOfNeighbors[n] =
                               ys[indicesOfNeighbors[n]] and
                               zOfNeighbors[n] = zs[indicesOfNeighbors[n]]
                       
%}

function [ xOfNeighbors, yOfNeighbors, zOfNeighbors, indicesOfNeighbors ] = getNeighborsMaxDistance( xs, ys, zs, xCenter, yCenter, zCenter, arguments )
    % Extract the relevant arguments.
    maxDistance = arguments(1);

    numOfPoints = length(xs);
    numOfNeighbors = 0;
    
    for pointIndex = 1:numOfPoints
        xCurrent = xs(pointIndex, 1);
        yCurrent = ys(pointIndex, 1);
        zCurrent = zs(pointIndex, 1);
        
        distance = ((xCurrent - xCenter) ^ 2 + (yCurrent - yCenter) ^ 2 + (zCurrent - zCenter) ^ 2) ^ (0.5);
        
        if (distance <= maxDistance)
            numOfNeighbors = numOfNeighbors + 1;
            xOfNeighbors(numOfNeighbors, 1) = xCurrent;
            yOfNeighbors(numOfNeighbors, 1) = yCurrent;
            zOfNeighbors(numOfNeighbors, 1) = zCurrent;
            indicesOfNeighbors(numOfNeighbors, 1) = pointIndex;
        end
    end
    
    if (numOfNeighbors == 0)
        xOfNeighbors = zeros(0);
        yOfNeighbors = zeros(0);
        zOfNeighbors = zeros(0);
        indicesOfNeighbors = zeros(0);
    end
end

