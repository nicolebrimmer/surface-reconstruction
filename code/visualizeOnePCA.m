%{
    Pick a random point source p in the binary image and visualize all of
    the point sources [q] that neighbor that point source p and the normal
    and tangent vectors associated with that center point source p of
    interest.

    @param xs the x coordinates of the point sources in the binary image.

    @param ys the y coordinates of the point sources in the binary image.

    @param zs the z coordinates of the point sources in the binary image.

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
                  with the 3D tangent vector tangents[n, :] and the normal 
                  vector normals[n, :].

    @param tangents a (numOfPoints x 3) matrix, in which each row
                    represents a tangent vector (i.e. a vector tangent to
                    the point cloud in the binary image).

                    tangents[n, :] is a 3D vector representing
                    the direction of most variance for point source
                    points[n, :] in the binary image.

    @param normals a (numOfPoints x 3) matrix, in which each row
                   represents a normal vector (i.e. a vector normal to the
                   point cloud in the binary image).

                   normals[n, :] is a 3D vector representing
                   the direction of least variance for the point source
                   points[n, :] in the binary image.

    @param width the width of the binary image (in pixels).

    @param height the height of the binary image (in pixels).

    @param depth the depth of the binary image (in pixels).

    @param multiple the scalar that the normal vector is multiplied by in
                    order to properly visualize it (otherwise the normal 
                    vectors may be too hard to see).

%}

function [  ] = visualizeOnePCA ( xs, ys, zs, func, arguments, points, tangents, normals, width, height, depth, multiple )
    numOfNormPoints = length(points);
    pointIndex = randi(numOfNormPoints);
    
    xCenter = points(pointIndex, 1);
    yCenter = points(pointIndex, 2);
    zCenter = points(pointIndex, 3);
    
    figure;
    hold on;
    
    % Plot your binary image.
    scatter3(xs, ys, zs, '.');
    axis([0 width 0 height 0 depth]);
    
    % Plot the circle encompassing the neighbors for the chosen point
    % source.
    %{
    typeOfToyBinaryImage = 'sphere';
    xOffset = xCenter;
    yOffset = yCenter;
    zOffset = zCenter;
    radius = arguments(1);
    argumentsForBinaryToyImage(1) = radius;
    numOfPoints = 10000;
    noiseStd = 0;
    
    [ neighboringCircle ] = createBinaryToyImage3D ( typeOfToyBinaryImage, width, height, depth, xOffset, yOffset, zOffset, argumentsForBinaryToyImage, numOfPoints, noiseStd );
    [ysNeighbors, xsNeighbors, zsNeighbors] = ind2sub(size(neighboringCircle), find(neighboringCircle));
    scatter3(xsNeighbors, ysNeighbors, zsNeighbors);
    %}
    
    % Plot your neighboring points in red.
    [ xOfNeighbors, yOfNeighbors, zOfNeighbors, ~ ] = func( xs, ys, zs, xCenter, yCenter, zCenter, arguments );
    plot3(xOfNeighbors, yOfNeighbors, zOfNeighbors, '.');
    
    % Plot the normal.
    normal = normals(pointIndex, :);
    xsOfNormal = [xCenter xCenter+multiple*normal(1)];
    ysOfNormal = [yCenter yCenter+multiple*normal(2)];
    zsOfNormals = [zCenter zCenter+multiple*normal(3)];
    plot3(xsOfNormal, ysOfNormal, zsOfNormals, 'LineWidth', 5);
    
    % Plot the tangent.
    tangent = tangents(pointIndex, :);
    xsOfTangent = [xCenter xCenter+multiple*tangent(1)];
    ysOfTangent = [yCenter yCenter+multiple*tangent(2)];
    zsOfTangent = [zCenter zCenter+multiple*tangent(3)];
    plot3(xsOfTangent, ysOfTangent, zsOfTangent, 'LineWidth', 5);
    
    legend('Original Binary Image', 'Neighbors', 'Normal', 'Tangent');
    title('Visualization of One Random PCA for the Binary Image');
    
    hold off;
end

