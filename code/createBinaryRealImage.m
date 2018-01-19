%{
    Produces a real 3D binary image of a point cloud (which represents stained 
    portions of a neural cell membrane) generated from a real 3D grayscale
    image of a cross section of a single neuron.  

    @param directoryName the full (relative) path of the directory
                         containing the real 2D grayscale image of a 
                         cross section of a single neuron that will be used
                         to generate the binary real image returned by this
                         method.

                         should not end with a backslash (e.g.
                         [directoryName] = '../results' and [directoryName]
                         != '../results/').

    @param fileName the name of the file containing a real 2D grayscale
                    image of a cross section of a single neuron.

                    should not contain the full (relative) path of the
                    directory containing this image (e.g. [fileName] =
                    'test.png' and [fileName] != '../results/test.png').

    @param numOfShrinks the number of times the xy slices are shrunk
                        by 0.5.  This shrinking is performed in order to
                        make the input image matrix more manageable for
                        further computations.

    @return binaryRealImage a 3D binary matrix (i.e. a 3D matrix that contains
                            only 1s and 0s) whose dimensions are the same
                            as that of the real 3D grayscale image
                            contained in the file that is located in the 
                            directory [directoryName] and that is called
                            [fileName].  Each element in this 3D binary
                            matrix is associated with a particular pixel in
                            the original grayscale image and is 1 if and
                            only if the corresponding pixel in the image is
                            a member of the point cloud of the stained cell
                            membrane of the neuron and is 0 otherwise.
                            
                            binaryRealImage[row, col, depth] corresponds to the
                            pixel that is [row] pixels down and [col]
                            pixels to the right and [depth] pixels out of 
                            the plane of the computer screen of the upper 
                            right back corner of the real 3D grayscale 
                            image.

%}

function [ binaryRealImage ] = createBinaryRealImage ( directoryName, fileName, numOfShrinks )
    fullFileName = strcat(directoryName, '/', fileName);
    
    % Read the 3D grayscale image from the source file.
    im = readImageFile(fullFileName, numOfShrinks);
    
    % These variables allow us to use only a portion of the input 3D neural
    % image.  This potentially allows us to run the code on a single neuron
    % even if the input 3D image contains multiple neurons.
    numOfRows = size(im, 1);
    begRow = 1;
    endRow = numOfRows;
    
    numOfCols = size(im, 2);
    begCol = 1;
    endCol = numOfCols;
    
    numOfSlices = size(im, 3);
    begSlice = 1;
    endSlice = numOfSlices;
    
    % For each point (x, y) in the xy plane (i.e. a slice) , determine the 
    % minimum intensity value associated with that point (x, y) in any
    % slice of the input 3D input.
    minimumValues = zeros(numOfRows, numOfCols);
    maximumValue = max(im(:));
    for row = 1:numOfRows
        for col = 1:numOfCols
            
            % Initially set the minimum value to the maximum intensity
            % value of the entire 3D image.  This value is the identity
            % element of the max operation.
            minimumValue = maximumValue;
            
            for slice = 1:numOfSlices
                minimumValue = min(minimumValue, im(row, col, slice));
            end
            
            minimumValues(row, col) = minimumValue;
        end
    end
    
    % Subtract minimumValues matrix from each slice in the input image.
    for slice = 1:numOfSlices
        im(:, :, slice) = im(:, :, slice) - minimumValues;
    end
    
    % Calculate threshold value.
    numOfThresholds = 2;
    thresholdValues = multithresh(im, numOfThresholds);
    thresholdValue = thresholdValues(numOfThresholds);
    
    % Perform thresholding.
    binaryRealImage = zeros(numOfRows, numOfCols, numOfSlices);
    binaryRealImage(im >= thresholdValue) = 1;

    % Perform mask on it.
    mask = zeros(numOfRows, numOfCols, numOfSlices);
    mask(begRow:endRow, begCol:endCol, begSlice:endSlice) = 1;
    binaryRealImage = mask .* binaryRealImage;
end


