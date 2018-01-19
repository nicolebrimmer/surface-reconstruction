%{
    Overall segmentation program

    @param alreadyLoaded if false, the program (slowly) loads the image matrix
                         from the tiff files
                         if true, the program quick reloads the image matrix from 
                         some matlab file

%}
clc;
clear;
close all;

% Configuration variables
alreadyLoaded = false;

% Loads the image matrices from the tiff files
if (not (alreadyLoaded))
    readImageFiles();
end

% Only work with the 640 file for now.  Working with both at the same
% has a tendency to break everything.
load('imageMatrix640File', 'imageMatrix640');
imageMatrix = imageMatrix640;

% Visualize the middle slice for testing purposes.
middleSlice = size(imageMatrix, 3) / 2;
figure;
imshow(imageMatrix(:, :, middleSlice));

% Compute a mask and visualize the middle slice.
imageMask = intensityThreshold(imageMatrix);
figure;
imshow(imageMask(:, :, middleSlice));

% Convert your mask into a list of points.
[X, Y] = find(imageMask(:, :, middleSlice));

% Try out MatLab's algorithm for point cloud reconstruction
%Tri = delaunay(X, Y);

%trisurf(Tri, X, Y);

fprintf('Script completed');
    

