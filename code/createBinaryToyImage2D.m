%{

    Produces a toy 2D binary image of a point cloud (which represents stained 
    portions of a neural cell membrane) generated using the parameters that have 
    been passed to this method.  The produced toy binary image can then be 
    used to test a point cloud surface reconstruction algorithm.

    @param type the type of toy 2D binary image to be produced (and
                returned) by this method.
            
                Currently, the following types of toy binary images are
                supported by this method:
                    (1) 'circle'
                    (2) 'lemniscate'
                    (3) 'smooth lemniscate'
                    (4) 'ellipse'

    @param width the width of (i.e. the number of columns in) the produced
                 and returned toy binary image.

    @param height the height of (i.e. the number of rows in) the produced
                  and returned toy binary image.

    @param xOffset the offset in the x (i.e. column) direction of the
                   center of the produced and returned toy binary image.

    @param yOffset the offset in the y (i.e. row) direction of the center
                   of the produced and returned toy binary image.

    @param arguments a vector of additional arguments required to fully
                     define the produced and returned toy binary image.  
                     The contents of this vector depend on the value of the
                     parameter 'type' as follows:
                        (1) if [type] = 'circle', then
                                arguments = [radius]
                            where the polar equation of the point cloud in 
                            the produced and returned toy binary image before 
                            the application of the offsets [xOffset] and
                            [yOffset] and the addition of noise is
                                r = [radius]
                        (2) if [type] = 'lemniscate', then
                                arguments = [[radiusMultiple], [angleMultiple]]
                            where the polar equation of the point cloud in 
                            the produced and returned toy binary image before 
                            the application of the offsets [xOffset] and
                            [yOffset] and the addition of noise is
                                r = [radiusMultiple] * sqrt(abs(cos([angleMultiple] * theta ) + 0.01))
                        (3) if [type] = 'smooth lemniscate', then
                                arguments = [[radiusMultiple], [angleMultiple], [radiusOffset]]
                            where the polar equation of the point cloud in 
                            the produced and returned toy binary image before 
                            the application of the offsets [xOffset] and
                            [yOffset] and the addition of noise is
                                r = [radiusMultiple] * ((cos([angleMultiple] * theta )) .^ 2 + [radiusOffset]);
                        (4) if [type] = 'ellipse', then
                                arguments = [[angle] [lengthOfMajorAxis] [lengthOfMinorAxis]]
                            where 
                                [angle] is the angle (in radians) that the
                                        major axis of the ellipse makes
                                        with the x axis.
                                [lengthOfMajorAxis] is the length of the
                                                    major axis.
                                [lengthOfMinorAxis] is the length of the
                                                    minor axis.

    @param numOfPoints the number of points in the point cloud of the
                       produced and returned toy binary image.

    @param noiseStd the standard deviation of the noise that causes the 
                    location of each member of the point cloud to deviate 
                    from that described by the passed parameters [arguments],
                    [xOffset], and [yOffset].

    Note that higher values of [numOfPoints] and lower values of [noise] will
    produced a binary toy image that is easier for the point cloud surface 
    reconstruction algorithm to handle.
    
    @return binaryToyImage a [height] x [width] binary matrix representing 
                           the toy binary image, with each value of the 
                           matrix being equal to either 0 (if the 
                           associated point in the image is not in the
                           point cloud) or 1 (if the associated point in
                           the image is in the point cloud).

%}

function [ binaryToyImage ] = createBinaryToyImage2D ( type, width, height, xOffset, yOffset, arguments, numOfPoints, noiseStd)
    angles = rand(numOfPoints, 1) * 2 * pi;
    xNoise = randn(numOfPoints, 1) * noiseStd;
    yNoise = randn(numOfPoints, 1) * noiseStd;
    
    % Apply the polar equation of the specified 'type' of binary toy image
    % to determine the values of r.
    if (strcmp(type, 'circle'))
        radius = arguments(1);
        
        radius = zeros(size(angles)) + radius;
    elseif (strcmp(type, 'lemniscate'))
        radiusMultiple = arguments(1);
        angleMultiple = arguments(2);
        
        radius = radiusMultiple * sqrt(abs(cos(angleMultiple * angles ) + 0.01));
    elseif (strcmp(type, 'smooth lemniscate'))
        radiusMultiple = arguments(1);
        angleMultiple = arguments(2);
        radiusOffset = arguments(3);
        
        radius = radiusMultiple * ((cos(angleMultiple * angles )) .^ 2 + radiusOffset);
    elseif (strcmp(type, 'ellipse'))
        angle = arguments(1);
        lengthOfMajorAxis = arguments(2);
        lengthOfMinorAxis = arguments(3);
        
        % Rotate the ellipse by [angle].
        anglesParam = angles + angle * ones(size(angles));
        
        % Apply the polar equation.
        a = lengthOfMajorAxis;
        b = lengthOfMinorAxis;
        radiusNum = a * b;
        radiusDenom = (((b * cos(anglesParam)) .^ 2) + ((a * sin(anglesParam)) .^ 2)) .^ (1/2);
        radius = radiusNum ./ radiusDenom;
        
    end

    % Convert the value of r (in polar coordinates) into x and y
    % coordinates, apply the offsets (in both the x and y coordinates) and
    % the noise (in both the x and y coordinates).
    xs = round(radius .* cos(angles) + xOffset + xNoise);
    ys = round(radius .* sin(angles) + yOffset + yNoise);
    
    % Could not determine a way to do this using purely matrices so 
    % instead used for loop.
    numOfRows = height;
    numOfCols = width;
    binaryToyImage = zeros(numOfRows, numOfCols);
    for pointIndex = 1:numOfPoints
        x = xs(pointIndex, 1);
        y = ys(pointIndex, 1);
        
        if ((x >= 1) && (x <= width) && (y >= 1) && (y <= height))
            binaryToyImage(y, x) = 1;
        end
    end

end

