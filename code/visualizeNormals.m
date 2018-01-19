%{
    Visualize all of the normal vectors associated with the binary image.

    @param xs the x coordinates of the point sources in the binary image.

    @param ys the y coordinates of the point sources in the binary image.

    @param zs the z coordinates of the point sources in the binary image.

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

    @param normals a (numOfPoints x 3) matrix, in which each row
                   represents a normal vector (i.e. a vector normal to the
                   point cloud in the binary image).

                   normals[n, :] is a 3D vector representing
                   the direction of least variance for the point source
                   points[n, :] in the binary image.

    @param width the width of the binary image (in pixels).

    @param height the height of the binary image (in pixels).

    @param depth the height of the binary image (in pixels).

    @param multiple the scalar that the normal vector is multiplied by in
                    order to properly visualize it (otherwise the normal 
                    vectors may be too hard to see).

%}

function [  ] = visualizeNormals ( xs, ys, zs, points, normals, width, height, depth, multiple )

    figure;
    hold on;
    
    % Plot the binary image.
    plot3(xs, ys, zs, '.');
    axis([0 width 0 height 0 depth]);
    
    % Plot the normals.
    numOfPoints = length(points);
    for pointIndex = 1:numOfPoints
        xCenter = points(pointIndex, 1);
        yCenter = points(pointIndex, 2);
        zCenter = points(pointIndex, 3);
        
        xNormal = [xCenter xCenter+multiple*normals(pointIndex, 1)];
        yNormal = [yCenter yCenter+multiple*normals(pointIndex, 2)];
        zNormal = [zCenter zCenter+multiple*normals(pointIndex, 3)];
        
        plot3(xNormal, yNormal, zNormal, 'g');
    end
    
    title('Visualization for all of the Normal Vectors for the Entire Binary Image');
    
    hold off;


end

