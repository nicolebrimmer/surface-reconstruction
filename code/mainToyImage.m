close all;
clear;

% Note that I have preceded every block of code that produces a graph or figure 
% with the comment "PRODUCES GRAPH" so that other users of this program can 
% easily comment out some or all of the code that produces graphs or figures.  
% After all, I realize that it can get a little annoying when using this 
% code and having 10 figures pop up.

%% Create or generate a toy or real binary image.
% This variable [usingToyBinaryImage] is true if and only if we would like 
% to use a toy binary image instead of a real binary image generated from  
% a real image of a neuron.
fprintf('Loading a binary image and displaying it...\n');
usingToyBinaryImage = true;

% If we would like to use a toy binary image,... 
if (usingToyBinaryImage) 
    % Declare the parameters and arguments associated with the production 
    % of the toy binary image. 
    typeOfToyBinaryImage = 'sphere';
    
    width = 70;
    height = 70;
    depth = 70;
    
    xOffset = 30;
    yOffset = 30;
    zOffset = 30;

    if (strcmp(typeOfToyBinaryImage, 'sphere'))
        radius = 20;
        argumentsForToyBinaryImage(1) = radius;
    elseif (strcmp(typeOfToyBinaryImage, 'ellipsoid'))
        a = 10;
        b = 20;
        c = 30;
        argumentsForToyBinaryImage(1) = a;
        argumentsForToyBinaryImage(2) = b;
        argumentsForToyBinaryImage(3) = c;
    elseif(strcmp(typeOfToyBinaryImage, 'smooth lemniscate'))
        radiusMultiple = 20;
        angleMultiple = 1;
        radiusOffset = 0.2;
        argumentsForToyBinaryImage(1) = radiusMultiple;
        argumentsForToyBinaryImage(2) = angleMultiple;
        argumentsForToyBinaryImage(3) = radiusOffset;
    else
        error(strcat('Could not produce a binary image of type ', typeOfToyBinaryImage))
    end

    numOfPoints = 800;
    noiseStd = 1;
    
    binaryImage = createBinaryToyImage3D ( typeOfToyBinaryImage, width, height, depth, xOffset, yOffset, zOffset, argumentsForToyBinaryImage, numOfPoints, noiseStd );

% If we would like to use a real binary image generated from a real image 
% of a neuron,...
else 
    directoryName = '../data';
    fileName = 'JB_20x_Brain26-4-sCMOS-4_w1Conf 640.TIF';
    numOfShrinks = 2;
    binaryImage = createBinaryRealImage (directoryName, fileName, numOfShrinks );
    
    height = size(binaryImage, 1);
    width = size(binaryImage, 2);
    depth = size(binaryImage, 3);
    
end
% xs, ys, and zs are the x-, y-, and z-coordinates of the point sources in the binary
% toy image.
[ys, xs, zs] = ind2sub(size(binaryImage), find(binaryImage));

% PRODUCES GRAPH
figure;
plot3(xs, ys, zs, '.');
title('Original Binary Toy Image');
axis([0 width 0 height 0 depth]);


fprintf('Completed! \n\n\n');

%% Calculate the normal vector for each point in the point cloud using the PCA algorithm
fprintf('Calculating the normal vector for each point in the point cloud using PCA algorithm...\n');

% This string specifies the definition of what it means for two points to
% be neighbors of one another.
defOfNeighbors = 'maxDistance';
if (strcmp(defOfNeighbors, 'maxDistance'))
    % Determine function.
    func = @getNeighborsMaxDistance;

    % Determine arguments.
    numOfNeighbors = 20;
    maxDistance = determineMaxDistance (xs, ys, zs, numOfNeighbors);
    argumentsForNeighbors(1) = maxDistance;
else
    error(str('The definition of neighbors ', defOfNeighbors, ' is not recognized.'))
end
    
[ tangents, normals, points ] = pcaEachPointSource( xs, ys, zs, func, argumentsForNeighbors );

multipleForVisualization = 10;
% PRODUCES GRAPH
visualizeOnePCA ( xs, ys, zs, func, argumentsForNeighbors, points, tangents, normals, width, height, depth, multipleForVisualization );
% PRODUCES GRAPH
visualizeNormals ( xs, ys, zs, points, normals, width, height, depth, multipleForVisualization );
fprintf('Completed! \n\n');
%% Make the normal vectors consistent with other another (i.e. all pointing out towards the extracellular tissue or all pointing in towards the intracellular tissue)
fprintf('Making the normal vectors consistent with other another (i.e. all pointing out towards the extracellular tissue or all pointing in towards the intracellular tissue)...\n');
useFast = true;
if (useFast)
    [ consistentPoints, consistentNormals] = getConsistentNormalsFast ( points, normals, func, argumentsForNeighbors);
else
    [ consistentPoints, consistentNormals] = getConsistentNormalsSlow ( points, normals );
end

% PRODUCES GRAPH
visualizeNormals ( xs, ys, zs, consistentPoints, consistentNormals, width, height, depth, multipleForVisualization );
fprintf('Completed!\n\n');
%% Perform Level Set Reconstruction
fprintf('Performing level set reconstruction...\n');
rbfName = 'tri-harmonic';
rbfArguments = [];

if (strcmp(rbfName, 'tri-harmonic'))
    rbfArguments = [];
elseif (strcmp(rbfName, 'polyharmonic'))
    k = 3;
    rbfArguments(1) = k;
elseif (strcmp(rbfName, 'multiquadratic'))
    beta = 2;
    rbfArguments(1) = beta;
elseif (strcmp(rbfName, 'gaussian'))
    beta = 4;
    rbfArguments(1) = beta;
else
    error(strcat('The rbf ', rbfName, ' could not be recognized.'));
end

epsilon = 1 * (10 ^ (-1));
fprintf('\tCalculating...\n')
[ weights, allPoints ] = calculateLevelSetReconstruction( consistentPoints, consistentNormals, rbfName, rbfArguments, epsilon );

fprintf('\tApplying...\n')
segmentedImage = applyLevelSetReconstruction ( width, height, depth, allPoints, weights, rbfName, rbfArguments );

fprintf('\tDrawing...\n')
% PRODUCES GRAPH
positive = false;
drawLevelSetReconstruction ( width, height, depth, segmentedImage, xs, ys, zs, positive );
fprintf('Completed!\n\n');

%% End of script
fprintf('Script completed.\n\n');


