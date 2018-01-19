%{
    Loads each one of the tiff files into a matrix and saves this matrix
    into a file named imageMatrices.mat.

    As a result, the file named imageMatrices.mat will contain two
    variables once this function has finished:
    imageMatrix640
    imageMatrix561

%}

function [ ] = readImageFiles( )
    numOfShrinks = 2;

    path = '../../JB Brainbow data early Nov/';
    
    bareFileName640 = 'JB_20x_Brain26-4-sCMOS-4_w1Conf 640.TIF';
    bareFileName561 = 'JB_20x_Brain26-4-sCMOS-4_w2Conf 561.TIF';
    
    fileName640 = [path bareFileName640];
    fileName561 = [path bareFileName561];
    
    imageMatrix640 = readImageFile(fileName640, numOfShrinks);
    imageMatrix561 = readImageFile(fileName561, numOfShrinks);
    
    
    save('imageMatrix640File', 'imageMatrix640');
    save('imageMatrix561File', 'imageMatrix561');

end

