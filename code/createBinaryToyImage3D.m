%{
    Produces a toy 3D binary image of a point cloud (which represents stained 
    portions of a neural cell membrane) generated using the parameters that have 
    been passed to this method.  The produced toy binary image can then be 
    used to test a point cloud surface reconstruction algorithm.

    @param type the type of toy 3D binary image to be produced (and
                returned) by this method.
            
                Currently, the following types of toy binary images are
                supported by this method:
                    (1) 'sphere'
                    (2) 'ellipsoid'

    @param width the width of (i.e. the number of columns in) the produced
                 and returned toy binary image.

    @param height the height of (i.e. the number of rows in) the produced
                  and returned toy binary image.

    @param depth the depth of the produced and returned toy binary image.

    @param xOffset the offset in the x (i.e. column) direction of the
                   center of the produced and returned toy binary image.

    @param yOffset the offset in the y (i.e. row) direction of the center
                   of the produced and returned toy binary image.

    @param zOffset the offset in the z direction of the center of the 
                   produced and returned toy binary image.

    @param arguments a vector of additional arguments required to fully
                     define the produced and returned toy binary image.  
                     The contents of this vector depend on the value of the
                     parameter 'type' as follows:
                        (1) if [type] = 'sphere', then
                                arguments = [radius]
                            where the rectangular equation of the point 
                            cloud in the produced and returned toy binary 
                            image before the application of the offsets 
                            [xOffset], [yOffset], and [zOffset] and the 
                            addition of noise is
                                x = r * (cos(theta) .* sin(phi))
                                y = r * (sin(theta) .* sin(phi))
                                z = r * (cos(phi))
                            where [theta] and [phi] are parameterized 
                            inputs.
                        (2) if [type] = 'ellipsoid', then
                                arguments = [a, b, c]
                           where the rectangular equation of the point 
                            cloud in the produced and returned toy binary 
                            image before the application of the offsets 
                            [xOffset], [yOffset], and [zOffset] and the 
                            addition of noise is
                                x = a * (cos(theta) .* sin(phi));
                                y = b * (sin(theta) .* sin(phi));
                                z = c * cos(phi);
                            where [theta] and [phi] are parameterized 
                            inputs.

    @param numOfPoints the number of points in the point cloud of the
                       produced and returned toy binary image.

    @param noiseStd the standard deviation of the noise that causes the 
                    location of each member of the point cloud to deviate 
                    from that described by the passed parameters [arguments],
                    [xOffset], and [yOffset].

    Note that higher values of [numOfPoints] and lower values of [noise] will
    produced a binary toy image that is easier for the point cloud surface 
    reconstruction algorithm to handle.
    
    @return binaryToyImage a [height] x [width] x [depth] binary matrix representing 
                           the toy binary image, with each value of the 
                           matrix being equal to either 0 (if the 
                           associated point in the image is not in the
                           point cloud) or 1 (if the associated point in
                           the image is in the point cloud).

%}

function [ binaryToyImage ] = createBinaryToyImage3D ( type, width, height, depth, xOffset, yOffset, zOffset, arguments, numOfPoints, noiseStd)
    theta = rand(numOfPoints, 1) * 2 * pi;
    phi = rand(numOfPoints, 1) * 2 * pi;
    
    xNoise = randn(numOfPoints, 1) * noiseStd;
    yNoise = randn(numOfPoints, 1) * noiseStd;
    zNoise = randn(numOfPoints, 1) * noiseStd;
    
    xs = zeros(numOfPoints, 1);
    ys = zeros(numOfPoints, 1);
    zs = zeros(numOfPoints, 1);
    
    % Apply the spherical equation of a sphere.
    if (strcmp(type, 'sphere'))
        r = arguments(1);
        
        xs = r * (cos(theta) .* sin(phi));
        ys = r * (sin(theta) .* sin(phi));
        zs = r * (cos(phi));

        %{
    elseif (strcmp(type, 'lemniscate'))
        radiusMultiple = arguments(1);
        angleMultiple = arguments(2);
        
        radius = radiusMultiple * sqrt(abs(cos(angleMultiple * angles ) + 0.01));
    %}
    elseif (strcmp(type, 'smooth lemniscate'))
        radiusMultiple = arguments(1);
        angleMultiple = arguments(2);
        radiusOffset = arguments(3);
        
        % First do it in 2D.
        r_2D = radiusMultiple * ((cos(angleMultiple * theta)) .^ 2 + radiusOffset);
        x_2D = r_2D .* cos(theta);
        y_2D = r_2D .* sin(theta);
        
        % Rotate it to produce the 3D.
        xs = x_2D;
        ys = y_2D .* sin(phi);
        zs = y_2D .* cos(phi);
    elseif (strcmp(type, 'ellipsoid'))
        a = arguments(1);
        b = arguments(2);
        c = arguments(3);
        
        xs = a * (cos(theta) .* sin(phi));
        ys = b * (sin(theta) .* sin(phi));
        zs = c * cos(phi);
        
    end
    
    % Add noise to it.
    xs = xs + xNoise + xOffset;
    ys = ys + yNoise + yOffset;
    zs = zs + zNoise + zOffset;
    
    % Could not determine a way to do this using purely matrices so 
    % instead used for loop.
    numOfRows = height;
    numOfCols = width;
    numOfDepths = depth;
    binaryToyImage = zeros(numOfRows, numOfCols, numOfDepths);
    for pointIndex = 1:numOfPoints
        x = round(xs(pointIndex, 1));
        y = round(ys(pointIndex, 1));
        z = round(zs(pointIndex, 1));
        
        if ((x >= 1) && (x <= width) && (y >= 1) && (y <= height) && (z >= 1) && (z <= depth))
            binaryToyImage(y, x, z) = 1;
        end
    end

end

