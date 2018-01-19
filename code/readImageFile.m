%{
    Transforms a raw input image, that is saved in the form of a tiff file,
    into a 3D matrix.

    @param fileName the name of the tif file that contains the 3D 
                    microscope image (including the file's path).

    @param numOfShrinks the number of times the xy slices are shrunk
                        by 0.5.

    @return rawInputMatrix a 3D matrix whose dimensions are the same
                           as that of the real 3D grayscale image
                           contained in the file [fileName].  
                           Each element in this 3D matrix is associated
                           with a particular pixel in the original
                           grayscale image and its value is the intensity
                           of the corresponding pixel in the image.                       
                           rawInputMatrix[row, col, depth] corresponds to the
                           pixel that is [row] pixels down, [col]
                           pixels to the right, and [depth] pixels out of 
                           page of the upper right corner of the real 3D 
                           grayscale image

    Adapted from main.m in 20160201_segmentation_of_20160121 brainbow_2x4
%}
% One test fileName: ../JB Brainbow data early Nov/JB_20x_Brain26-4-sCMOS-4_w1Conf 640.TIF"
function imageMatrix = readImageFile(fileName, numOfShrinks)
    fprintf(['Loading the image file "' fileName '" into a MATLAB matrix\n']);
    info = imfinfo(fileName);
    numOfSlices = size(info, 1);
    
    % Read the image slice by slice.
    imageMatrix = [];
    for slice = 1:numOfSlices
        img = im2double(imread(fileName, slice));
        
        % Resize in the xy plane by resizing it by 0.5
        % [level] times.
        for shrink = 1:numOfShrinks
            img = imresize(img, 0.5, 'bilinear');
        end
        
        % Add a new slice (along the 3rd dimension) to the
        % imageMatrix.
        imageMatrix = cat(3, imageMatrix, img);
    end
    
    % Increase the contrast of the image, slice by slice.
    % This brightness equalization will lead to the all 
    % slices having the same mean - needs improvement.
    [maxSliceSum, ~] = max(sum(sum(imageMatrix)));
    maxIntensity = max(max(max(imageMatrix)));
    for slice = 1:numOfSlices
        sliceSum = sum(sum(imageMatrix(:, :, slice)));
        scale = maxSliceSum ./ (maxIntensity .* sliceSum);
        imageMatrix(:, :, slice) = imageMatrix(:, :, slice) .* scale;
    end
    
    fprintf(['Completed loading the image file "' fileName '" into a MATLAB matrix\n\n']);
    
end

% The code that this code is adapted from:
%{
function volume = read_volume_from_file(file, level)
  fprintf('loading volume data\n');
  info = imfinfo(file);
  num_slices = size(info, 1);
  volume = [];
  for i = 1:num_slices
    % fprintf('loading slice %d/%d\n', i, num_slices);
    img = im2double(imread(file, i));
    for j = 1:level
      img = imresize(img, 0.5, 'bilinear'); % we should scale in Z too
    end
    volume = cat(3, volume, img);
  end

  % brightness equalization (all slices will have the same mean, needs improvement)
  [brightest_val, brightest_slice] = max(sum(sum(volume)));
  max_intensity = max(max(max(volume)));
  for i = 1:num_slices
    scale = brightest_val ./ (max_intensity .* sum(sum(volume(:, :, i))));
    volume(:, :, i) = volume(:, :, i) .* scale;
  end

  % write images for visual checking
  write_tiff(permute(volume, [3, 2, 1]), sprintf('l%d_y.tif', level));
  write_tiff(permute(volume, [1, 3, 2]), sprintf('l%d_x.tif', level));
  write_tiff(volume, sprintf('l%d_z.tif', level));

end
%}