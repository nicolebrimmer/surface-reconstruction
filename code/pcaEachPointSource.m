%{
    Runs the PCA algorithm on each point source in the binary image, 
    binaryImage.

    More specifically, the PCA algorithm is run on each point source p
    in the binary image, binaryImage, with the observations being the 
    neighboring point sources [q].  The parameters, @func and arguments,
    together define what it means for two point sources to be neighbors of
    one another.

    @param xs the x coordinates of the point sources in the binary image.

    @param ys the y coordinates of the point sources in the binary image.

    @param zs the y coordinates of the point sources in the binary image.

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

    @return points a (numOfPoints x 3) matrix, in which each row represents
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

    @return tangents a (numOfPoints x 3) matrix, in which each row
                     represents a tangent vector (i.e. a vector tangent to
                     the point cloud in the binary image).

                     tangents[n, :] is a 3D vector representing
                     the direction of most variance for point source
                     points[n, :] in the binary image.

    @return normals a (numOfPoints x 3) matrix, in which each row
                    represents a normal vector (i.e. a vector normal to the
                    point cloud in the binary image).

                    normals[n, :] is a 3D vector representing
                    the direction of least variance for the point source
                    points[n, :] in the binary image.
%}

function [ tangents, normals, points ] = pcaEachPointSource( xs, ys, zs, func, arguments )
    numOfPoints = length(xs);
    count = 0;
    
    for pointIndex = 1:numOfPoints
        xCenter = xs(pointIndex, 1);
        yCenter = ys(pointIndex, 1);
        zCenter = zs(pointIndex, 1);
        
        [ xOfNeighbors, yOfNeighbors, zOfNeighbors, ~ ] = func( xs, ys, zs, xCenter, yCenter, zCenter, arguments );
        
        numOfNeighbors = length(xOfNeighbors);
        X = zeros(numOfNeighbors, 3);
        
        X(:, 1) = xOfNeighbors;
        X(:, 2) = yOfNeighbors;
        X(:, 3) = zOfNeighbors;
        coeff = pca(X);
        
        % Each column of coeff contains coefficients for one principal
        % direction (such as X or Y) and the columns are in descending
        % order of component variance.
        % First row is therefore the tangent vector.
        % Second row is therefore the normal vector.
        
        % We need this if statement since not all points have enough
        % neighbors to get a tangent and normal vector.
        if (size(coeff, 2) == 3)
            count = count + 1;
            
            tangents(pointIndex, :) = transpose(coeff(:, 2));
            normals(pointIndex, :) = transpose(coeff(:, 3));
            
            points(pointIndex, 1) = xCenter;
            points(pointIndex, 2) = yCenter;
            points(pointIndex, 3) = zCenter;
        end
    end
    
    if (count == 0)
        error('No PCAs could be calculated from the point cloud.');
    end

end